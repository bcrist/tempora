date: Date,
time: Time,

const Date_Time = @This();

pub const epoch = Date_Time{
    .date = .epoch,
    .time = .midnight,
};

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
    const offset_ts = self.with_offset(0).timestamp_ms();
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
        .timezone = timezone,
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

    pub const iso8601 = "YYYY-MM-DDTHH:mm:ss.SSSZ";
    pub const iso8601_local = "YYYY-MM-DDTHH:mm:ss.SSS";
    pub const rfc2822 = "ddd, DD MMM YYYY HH:mm:ss ZZ";
    pub const http = "ddd, DD MMM YYYY HH:mm:ss [GMT]"; // timezone must be GMT
    pub const sql_ms = "YYYY-MM-DD HH:mm:ss.SSS z";
    pub const sql_ms_local = "YYYY-MM-DD HH:mm:ss.SSS";
    pub const sql = "YYYY-MM-DD HH:mm:ss z";
    pub const sql_local = "YYYY-MM-DD HH:mm:ss";

    pub fn format(self: With_Offset, writer: *std.Io.Writer) !void {
        try formatting.format(self, iso8601, writer);
    }

    pub fn fmt(self: With_Offset, comptime pattern: []const u8) Formatter(pattern) {
        return .{ .date_time_with_offset = self };
    }

    pub fn Formatter(comptime pattern: []const u8) type {
        return struct {
            date_time_with_offset: With_Offset,
            pub fn format(self: @This(), writer: *std.Io.Writer) !void {
                try formatting.format(self.date_time_with_offset, pattern, writer);
            }
        };
    }
    
    pub fn from_string(comptime pattern: []const u8, str: []const u8) !With_Offset {
        return from_string_tz(pattern, str, null);
    }

    pub fn from_string_tz(comptime pattern: []const u8, str: []const u8, timezone: ?*const Timezone) !With_Offset {
        var reader = std.Io.Reader.fixed(str);
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
            error.TzdbCacheNotInitialized => return err,
        };

        const PI = @TypeOf(pi);

        var dt: Date_Time = .{
            .date = .epoch,
            .time = .midnight,
        };

        if (@FieldType(PI, "timestamp") != void) {
            dt = from_timestamp_ms(pi.timestamp, null).dt;
        } else {
            if (@FieldType(PI, "year") != void) {
                if (@FieldType(PI, "ordinal_day") != void) {
                    dt.date = Date.from_yod(pi.year, pi.ordinal_day);
                } else if (@FieldType(PI, "ordinal_week") != void) {
                    dt.date = Date.from_yod(pi.year, pi.ordinal_week.starting_day());
                    if (@FieldType(PI, "week_day") != void) {
                        dt.date = dt.date.advance_to_week_day(pi.week_day);
                    }
                } else if (@FieldType(PI, "month") != void) {
                    dt.date = Date.from_ymd(.{
                        .year = pi.year,
                        .month = pi.month,
                        .day = if (@FieldType(PI, "day") != void) pi.day else 1,
                    });
                } else {
                    dt.date = Date.from_yod(pi.year, .first);
                }
            } else if (@FieldType(PI, "iso_week_year") != void) {
                var iwd: ISO_Week_Date = .{
                    .year = pi.iso_week_year,
                    .week = .first,
                    .day = .monday,
                };

                if (@FieldType(PI, "iso_week") != void) iwd.week = pi.iso_week;
                if (@FieldType(PI, "week_day") != void) iwd.day = pi.week_day;

                dt = iwd.date();
            } else @compileError("Invalid pattern: " ++ pattern);

            if (@FieldType(PI, "hours") != void) {
                const m: i32 = if (@FieldType(PI, "minutes") != void) pi.minutes else 0;
                const s: i32 = if (@FieldType(PI, "seconds") != void) pi.seconds else 0;
                const milli: i32 = if (@FieldType(PI, "ms") != void) pi.ms else 0;
                dt.time = Time.from_hmsm(pi.hours, m, s, milli);
            } else @compileError("Invalid pattern: " ++ pattern);
        }

        var dto: With_Offset = .{
            .dt = dt,
            .utc_offset_ms = if (@FieldType(PI, "utc_offset_ms") != void) pi.utc_offset_ms else 0,
            .timezone = null,
        };

        if (timezone) |tz| {
            const tz_utc_offset_ms = tz.zone_info(dto.timestamp_s()).offset * 1000;
            if (@FieldType(PI, "utc_offset_ms") != void) {
                if (tz_utc_offset_ms != pi.utc_offset_ms) {
                    return dto.in_timezone(tz);
                }
            }

            dto.utc_offset_ms = tz_utc_offset_ms;
            dto.timezone = tz;
        }

        return dto;
    }
};

test "Date_Time" {
    try tzdb.init_cache(.{
        .gpa = std.testing.allocator,
        .additional_tzdata_paths = &.{},
    });
    defer tzdb.deinit_cache();

    const tz = (try tzdb.timezone(std.testing.io, "America/Chicago")).?;
    const gmt = (try tzdb.timezone(std.testing.io, "GMT")).?;

    const dt1 = (Date_Time {
        .date = .from_ymd(.{ .year = .from_number(2024), .month = .february, .day = .first }),
        .time = .from_hmsm(12, 34, 56, 789),
    }).with_offset(0);
    const dt2 = (Date_Time {
        .date = .from_ymd(.from_numbers(1928, 12, 24)),
        .time = .from_hmsm(0, 30, 0, 0),
    }).with_offset(0);

    try std.testing.expectFmt("2024-02-01 12:34:56.789 +00:00", "{f}", .{ dt1.fmt(With_Offset.sql_ms) });
    try std.testing.expectFmt("2024-02-01 12:34:56.789 GMT", "{f}", .{ dt1.in_timezone(gmt).fmt(With_Offset.sql_ms) });
    try std.testing.expectFmt("2024-02-01 06:34:56.789 CST", "{f}", .{ dt1.in_timezone(tz).fmt(With_Offset.sql_ms) });

    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 +0000", "{f}", .{ dt2.in_timezone(gmt).fmt(With_Offset.rfc2822) });
    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 GMT", "{f}", .{ dt2.in_timezone(gmt).fmt(With_Offset.http) });
    try std.testing.expectFmt("1928-12-24T00:30:00.000+00:00", "{f}", .{ dt2.in_timezone(gmt).fmt(With_Offset.iso8601) });

    try std.testing.expectEqual(dt1, try With_Offset.from_string(With_Offset.sql_ms, "2024-02-01 12:34:56.789 +00:00"));
    try std.testing.expectEqual(dt1, (try With_Offset.from_string(With_Offset.sql_ms, "2024-02-01 06:34:56.789 CST")).in_timezone(null));
}

const Date = @import("date.zig").Date;
const Time = @import("time.zig").Time;
const Day = @import("day.zig").Day;
const Year = @import("year.zig").Year;
const ISO_Week_Date = @import("iso_week.zig").ISO_Week_Date;
const Timezone = @import("Timezone.zig");
const tzdb = @import("tzdb.zig");
const formatting = @import("formatting.zig");
const std = @import("std");
