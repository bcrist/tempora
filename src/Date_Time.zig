
date: Date,
time: Time,

const Date_Time = @This();

pub fn from_timestamp_ms(ts: i64, timezone: ?*const Timezone) Date_Time {
    var offset_ts = ts;
    if (timezone) |tz| {
        offset_ts += tz.zone_info(@divFloor(ts, 1000)).offset * 1000;
    }

    const days = @divFloor(offset_ts, std.time.ms_per_day);
    const adjusted: i32 = @intCast(days - 10957);
    const date: Date = @enumFromInt(adjusted);

    const ms_since_midnight = offset_ts - days * std.time.ms_per_day;
    const time: Time = @enumFromInt(ms_since_midnight);

    return .{
        .date = date,
        .time = time,
    };
}

pub fn from_timestamp_s(ts: i64, timezone: ?*const Timezone) Date_Time {
    return from_timestamp_ms(ts * 1000, timezone);
}

pub fn timestamp_ms(self: Date_Time, timezone: ?*const Timezone) i64 {
    const days: i64 = @intFromEnum(self.date) + 10957;
    const ms_since_midnight = self.time.ms_since_midnight();
    const offset_ts = days * std.time.ms_per_day + ms_since_midnight;
    if (timezone) |tz| {
        const zi = tz.zone_info(@divFloor(offset_ts, 1000));
        const ts = offset_ts - zi.offset * 1000;
        if (zi.begin_ts) |begin_ts| {
            if (ts < begin_ts * 1000) {
                return offset_ts - tz.zone_info(@divFloor(ts, 1000)).offset * 1000;
            }
        }
        if (zi.end_ts) |end_ts| {
            if (ts >= end_ts * 1000) {
                return offset_ts - tz.zone_info(@divFloor(ts, 1000)).offset * 1000;
            }
        }
    }
    return offset_ts;
}

pub fn timestamp_s(self: Date_Time, timezone: ?*const Timezone) i64 {
    return @divFloor(self.timestamp_ms(timezone), 1000);
}

/// N.B. this does not include leap seconds!
pub fn ms_since(self: Date_Time, past: Date_Time) i64 {
    const date_diff: i64 = @intFromEnum(self.date) - @intFromEnum(past.date);
    const time_diff: i64 = self.time.ms_since_midnight() - past.time.ms_since_midnight();
    return date_diff * std.time.ms_per_day + time_diff;
}

pub fn plus_days_and_ms(self: Date_Time, days: i32, ms: i64) Date_Time {
    var new_date: i64 = @intFromEnum(self.date) + days;
    var new_time: i64 = self.time.ms_since_midnight() + ms;
    if (new_time < 0) {
        const additional_days: i64 = @divTrunc(new_time - std.time.ms_per_day + 1, std.time.ms_per_day);
        new_date += additional_days;
        new_time -= additional_days * std.time.ms_per_day;
    } else if (new_time >= std.time.ms_per_day) {
        const additional_days: i64 = @divTrunc(new_time, std.time.ms_per_day);
        new_date += additional_days;
        new_time -= additional_days * std.time.ms_per_day;
    }
    return .{
        .date = @enumFromInt(new_date),
        .time = @enumFromInt(new_time),
    };
}

pub const fmt_iso8601 = "YYYY-MM-DDTHH;mm;ss.SSSZ";
pub const fmt_rfc2822 = "ddd, DD MMM YYYY HH;mm;ss ZZ";
pub const fmt_http = "ddd, DD MMM YYYY HH;mm;ss [GMT]"; // timezone must be GMT
pub const fmt_sql_ms = "YYYY-MM-DD HH;mm;ss.SSS z";
pub const fmt_sql = "YYYY-MM-DD HH;mm;ss z";

pub fn format(self: Date_Time, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = options;
    try formatting.format(self, null, 0, if (fmt.len == 0) fmt_iso8601 else fmt, writer);
}

pub fn fmt_utc(self: Date_Time, timezone: *const Timezone) std.fmt.Formatter(Date_Time_With_Timezone.format_utc) {
    return .{ .data = Date_Time_With_Timezone { .dt = self, .timezone = timezone } };
}

pub fn fmt_local(self: Date_Time, timezone: *const Timezone) std.fmt.Formatter(Date_Time_With_Timezone.format_local) {
    return .{ .data = Date_Time_With_Timezone { .dt = self, .timezone = timezone } };
}

pub fn from_string_utc(comptime fmt: []const u8, str: []const u8) !Date_Time_With_Offset {
    return from_string(fmt, str, true);
}

pub fn from_string_local(comptime fmt: []const u8, str: []const u8) !Date_Time_With_Offset {
    return from_string(fmt, str, false);
}

fn from_string(comptime fmt: []const u8, str: []const u8, utc: bool) !Date_Time_With_Offset {
    var stream = std.io.fixedBufferStream(str);
    var peek_stream = std.io.peekStream(1, stream.reader());
    const pi = formatting.parse(if (fmt.len == 0) fmt_iso8601 else fmt, &peek_stream) catch return error.InvalidFormat;

    var dt: Date_Time = .{
        .date = .epoch,
        .time = .midnight,
    };

    if (pi.timestamp) |ts| {
        dt = Date_Time.from_timestamp_ms(ts, null);
    } else {
        if (pi.year) |pi_y| {
            const y = if (pi.negate_year) Year.from_number(-pi_y.as_number()) else pi_y;

            if (pi.ordinal_day) |od| {
                dt.date = Date.from_yd(y, od);
            } else if (pi.ordinal_week) |ow| {
                const d = Date.from_yd(y, ow.starting_day());
                dt.date = if (pi.week_day) |wd| d.advance_to_week_day(wd) else d;
            } else if (pi.month) |m| {
                dt.date = if (pi.day) |d| Date.from_ymd(y, m, d) else Date.from_yd(y, .first);
            } else {
                dt.date = Date.from_yd(y, .first);
            }
        } else return error.InvalidFormat;

        if (pi.hours) |raw_h| {
            const h = @mod(if (pi.hours_is_pm) raw_h + 12 else raw_h, 24);
            const m = pi.minutes orelse 0;
            const s = pi.seconds orelse 0;
            const milli = pi.ms orelse 0;
            dt.time = Time.from_hmsm(h, m, s, milli);
        } else return error.InvalidFormat;
    }

    const utc_offset_ms = pi.utc_offset_ms orelse 0;
    
    if (utc_offset_ms != 0 and utc) {
        dt = dt.plus_days_and_ms(0, -utc_offset_ms);
    }

    return .{
        .dt = dt,
        .utc_offset_ms = utc_offset_ms,
    };
}

pub const Date_Time_With_Timezone = struct {
    dt: Date_Time,
    timezone: *const Timezone,

    pub fn format_local(self: Date_Time_With_Timezone, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        const offset = self.timezone.zone_info(self.dt.timestamp_s(self.timezone)).offset * 1000;
        try formatting.format(self.dt, self.timezone, offset, if (fmt.len == 0) Date_Time.fmt_iso8601 else fmt, writer);
    }

    pub fn format_utc(self: Date_Time_With_Timezone, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        const offset = self.timezone.zone_info(self.dt.timestamp_s(null)).offset * 1000;
        var dt = self.dt;
        if (offset != 0) {
            dt = dt.plus_days_and_ms(0, offset);
        }
        try formatting.format(dt, self.timezone, offset, if (fmt.len == 0) Date_Time.fmt_iso8601 else fmt, writer);
    }
};

pub const Date_Time_With_Offset = struct {
    dt: Date_Time,
    utc_offset_ms: i32,
};

var test_dt_buf: [256]u8 = undefined;
// for testing only!
fn dt_str(comptime fmt: []const u8, dt: Date_Time) ![]const u8 {
    return std.fmt.bufPrint(&test_dt_buf, "{" ++ fmt ++ "}", .{ dt });
}
fn local_dt_str(comptime fmt: []const u8, dt: Date_Time, tz: *const Timezone) ![]const u8 {
    return std.fmt.bufPrint(&test_dt_buf, "{" ++ fmt ++ "}", .{ dt.fmt_local(tz) });
}
fn utc_dt_str(comptime fmt: []const u8, dt: Date_Time, tz: *const Timezone) ![]const u8 {
    return std.fmt.bufPrint(&test_dt_buf, "{" ++ fmt ++ "}", .{ dt.fmt_utc(tz) });
}

test "Date_Time" {
    try tzdb.init_cache(std.testing.allocator);
    defer tzdb.deinit_cache();

    const tz = (try tzdb.timezone("America/Chicago")).?;
    const gmt = (try tzdb.timezone("GMT")).?;

    const dt1: Date_Time = .{
        .date = Date.from_ymd(Year.from_number(2024), .february, .first),
        .time = Time.from_hmsm(12, 34, 56, 789),
    };
    const dt2: Date_Time = .{
        .date = Date.from_ymd(Year.from_number(1928), .december, Day.from_number(24)),
        .time = Time.from_hmsm(0, 30, 0, 0),
    };

    try expectEqualStrings("2024-02-01 12:34:56.789 +00:00", try dt_str(fmt_sql_ms, dt1));
    try expectEqualStrings("2024-02-01 06:34:56.789 CST", try utc_dt_str(fmt_sql_ms, dt1, tz));
    try expectEqualStrings("2024-02-01 12:34:56.789 CST", try local_dt_str(fmt_sql_ms, dt1, tz));

    try expectEqualStrings("Mon, 24 Dec 1928 00:30:00 +0000", try utc_dt_str(fmt_rfc2822, dt2, gmt));
    try expectEqualStrings("Mon, 24 Dec 1928 00:30:00 GMT", try utc_dt_str(fmt_http, dt2, gmt));
    try expectEqualStrings("1928-12-24T00:30:00.000+00:00", try utc_dt_str(fmt_iso8601, dt2, gmt));

    try expectEqual(dt1, (try Date_Time.from_string_utc(fmt_sql_ms, "2024-02-01 12:34:56.789 +00:00")).dt);
    try expectEqual(dt1, (try Date_Time.from_string_utc(fmt_sql_ms, "2024-02-01 06:34:56.789 CST")).dt);
    try expectEqual(dt1, (try Date_Time.from_string_local(fmt_sql_ms, "2024-02-01 12:34:56.789 CST")).dt);
}

const expect = std.testing.expect;
const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const Date = @import("date.zig").Date;
const Time = @import("time.zig").Time;
const Day = @import("day.zig").Day;
const Year = @import("year.zig").Year;
const Timezone = @import("Timezone.zig");
const tzdb = @import("tzdb.zig");
const formatting = @import("formatting.zig");
const std = @import("std");
