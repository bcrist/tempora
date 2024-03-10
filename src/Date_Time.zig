
date: Date,
time: Time,

const Date_Time = @This();

pub fn with_offset(self: Date_Time, utc_offset_ms: i32) With_Offset {
    return .{
        .dt = self,
        .utc_offset_ms = utc_offset_ms,
        .timezone = null,
    };
}

/// Assumes this is a local Date_Time from the timezone provided
/// Note that timezones with an annual DST cycle pose a problem here,
/// e.g. 2023-11-05 01:30 central time could refer to either 2023-11-05 06:30 +00:00 or 2023-11-05 07:30 +00:00
/// This function will always pick the earlier option in these cases.
pub fn with_timezone(self: Date_Time, timezone: *const Timezone) With_Offset {
    const offset_ts = self.timestamp_ms();
    var zi = timezone.zone_info(@divFloor(offset_ts, 1000));
    var offset = zi.offset * 1000; 
    var ts = offset_ts - offset;

    if (zi.begin_ts) |begin_ts| {
        if (ts < begin_ts * 1000) {
            zi = timezone.zone_info(@divFloor(ts, 1000));
            offset = zi.offset * 1000;
            ts = offset_ts - offset;

            if (zi.end_ts) |end_ts| {
                if (ts >= end_ts * 1000) {
                    const zi2 = timezone.zone_info(@divFloor(ts, 1000));
                    const offset2 = zi2.offset * 1000;
                    const ts2 = offset_ts - offset;

                    if (ts2 < ts) {
                        ts = ts2;
                        offset = offset2;
                    }
                }
            }

            return .{
                .dt = self,
                .utc_offset_ms = offset,
                .timezone = timezone,
            };
        }
    }
    
    if (zi.end_ts) |end_ts| {
        if (ts >= end_ts * 1000) {
            zi = timezone.zone_info(@divFloor(ts, 1000));
            offset = zi.offset * 1000;
            ts = offset_ts - offset;

            if (zi.begin_ts) |begin_ts| {
                if (ts < begin_ts * 1000) {
                    const zi2 = timezone.zone_info(@divFloor(ts, 1000));
                    const offset2 = zi2.offset * 1000;
                    const ts2 = offset_ts - offset;

                    if (ts2 < ts) {
                        ts = ts2;
                        offset = offset2;
                    }
                }
            }
        }
    }

    return .{
        .dt = self,
        .utc_offset_ms = offset,
    };
}

/// N.B. this does not include leap seconds, and assumes both date/times are from the same timezone
pub fn ms_since(self: Date_Time, past: Date_Time) i64 {
    const date_diff: i64 = @intFromEnum(self.date) - @intFromEnum(past.date);
    const time_diff: i64 = self.time.ms_since_midnight() - past.time.ms_since_midnight();
    return date_diff * std.time.ms_per_day + time_diff;
}

pub fn is_before(self: Date_Time, other: Date_Time) bool {
    if (self.date.is_before(other.date)) return true;
    if (self.date.is_after(other.date)) return false;
    return self.time.is_before(other.time);
}

pub fn is_after(self: Date_Time, other: Date_Time) bool {
    if (self.date.is_after(other.date)) return true;
    if (self.date.is_before(other.date)) return false;
    return self.time.is_after(other.time);
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

pub const With_Offset = struct {
    dt: Date_Time,
    utc_offset_ms: i32,
    timezone: ?*const Timezone,

    pub fn from_timestamp_ms(ts: i64, timezone: ?*const Timezone) With_Offset {
        var utc_offset_ms: i32 = 0;
        if (timezone) |tz| utc_offset_ms = tz.zone_info(@divFloor(ts, 1000)).offset * 1000;
        const offset_ts = ts + utc_offset_ms;

        const days = @divFloor(offset_ts, std.time.ms_per_day);
        const adjusted: i32 = @intCast(days - 10957);
        const date: Date = @enumFromInt(adjusted);

        const ms_since_midnight = offset_ts - days * std.time.ms_per_day;
        const time: Time = @enumFromInt(ms_since_midnight);

        return .{
            .dt = .{
                .date = date,
                .time = time,
            },
            .utc_offset_ms = utc_offset_ms,
            .timezone = timezone,
        };
    }

    pub fn from_timestamp_s(ts: i64, timezone: ?*const Timezone) With_Offset {
        return from_timestamp_ms(ts * 1000, timezone);
    }

    pub fn timestamp_ms(self: With_Offset) i64 {
        const days: i64 = @intFromEnum(self.dt.date) + 10957;
        const ms_since_midnight = self.dt.time.ms_since_midnight();
        return days * std.time.ms_per_day + ms_since_midnight - self.utc_offset_ms;
    }

    pub fn timestamp_s(self: With_Offset) i64 {
        return @divFloor(self.timestamp_ms(), 1000);
    }

    pub fn in_timezone(self: With_Offset, timezone: ?*const Timezone) With_Offset {
        return from_timestamp_ms(self.timestamp_ms(), timezone);
    }

    /// N.B. this does not include leap seconds
    pub fn ms_since(self: With_Offset, past: With_Offset) i64 {
        return self.timestamp_ms() - past.timestamp_ms();
    }

    pub const fmt_iso8601 = "YYYY-MM-DDTHH;mm;ss.SSSZ";
    pub const fmt_rfc2822 = "ddd, DD MMM YYYY HH;mm;ss ZZ";
    pub const fmt_http = "ddd, DD MMM YYYY HH;mm;ss [GMT]"; // timezone must be GMT
    pub const fmt_sql_ms = "YYYY-MM-DD HH;mm;ss.SSS z";
    pub const fmt_sql = "YYYY-MM-DD HH;mm;ss z";

    pub fn format(self: With_Offset, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        try formatting.format(self, if (fmt.len == 0) fmt_iso8601 else fmt, writer);
    }
    
    pub fn from_string(comptime fmt: []const u8, str: []const u8) !With_Offset {
        var stream = std.io.fixedBufferStream(str);
        var peek_stream = std.io.peekStream(1, stream.reader());
        const pi = formatting.parse(if (fmt.len == 0) fmt_iso8601 else fmt, &peek_stream) catch return error.InvalidFormat;

        var dt: Date_Time = .{
            .date = .epoch,
            .time = .midnight,
        };

        if (pi.timestamp) |ts| {
            dt = from_timestamp_ms(ts, null).dt;
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

        return .{
            .dt = dt,
            .utc_offset_ms = pi.utc_offset_ms orelse 0,
            .timezone = null,
        };
    }
};

var test_dt_buf: [256]u8 = undefined;
// for testing only!
fn dt_str(comptime fmt: []const u8, dto: With_Offset) ![]const u8 {
    return std.fmt.bufPrint(&test_dt_buf, "{" ++ fmt ++ "}", .{ dto });
}

test "Date_Time" {
    try tzdb.init_cache(std.testing.allocator);
    defer tzdb.deinit_cache();

    const tz = (try tzdb.timezone("America/Chicago")).?;
    const gmt = (try tzdb.timezone("GMT")).?;

    const dt1 = (Date_Time {
        .date = Date.from_ymd(Year.from_number(2024), .february, .first),
        .time = Time.from_hmsm(12, 34, 56, 789),
    }).with_offset(0);
    const dt2 = (Date_Time {
        .date = Date.from_ymd(Year.from_number(1928), .december, Day.from_number(24)),
        .time = Time.from_hmsm(0, 30, 0, 0),
    }).with_offset(0);

    try expectEqualStrings("2024-02-01 12:34:56.789 +00:00", try dt_str(With_Offset.fmt_sql_ms, dt1));
    try expectEqualStrings("2024-02-01 12:34:56.789 GMT", try dt_str(With_Offset.fmt_sql_ms, dt1.in_timezone(gmt)));
    try expectEqualStrings("2024-02-01 06:34:56.789 CST", try dt_str(With_Offset.fmt_sql_ms, dt1.in_timezone(tz)));

    try expectEqualStrings("Mon, 24 Dec 1928 00:30:00 +0000", try dt_str(With_Offset.fmt_rfc2822, dt2.in_timezone(gmt)));
    try expectEqualStrings("Mon, 24 Dec 1928 00:30:00 GMT", try dt_str(With_Offset.fmt_http, dt2.in_timezone(gmt)));
    try expectEqualStrings("1928-12-24T00:30:00.000+00:00", try dt_str(With_Offset.fmt_iso8601, dt2.in_timezone(gmt)));

    try expectEqual(dt1, try With_Offset.from_string(With_Offset.fmt_sql_ms, "2024-02-01 12:34:56.789 +00:00"));
    try expectEqual(dt1, (try With_Offset.from_string(With_Offset.fmt_sql_ms, "2024-02-01 06:34:56.789 CST")).in_timezone(null));
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
