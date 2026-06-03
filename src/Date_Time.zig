date: Date,
time: Time,

const Date_Time = @This();

pub const epoch: Date_Time = .{
    .date = .epoch,
    .time = .midnight,
};
pub const unix_epoch: Date_Time = .{
    .date = .unix_epoch,
    .time = .midnight,
};
pub const ntp_epoch: Date_Time = .{
    .date = .ntp_epoch,
    .time = .midnight,
};
pub const ntfs_epoch: Date_Time = .{
    .date = .ntfs_epoch,
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
    var info = timezone.info(@divFloor(offset_ts, 1000));
    var offset = info.utc_offset_seconds * 1000; 
    var ts = offset_ts - offset;

    if (info.begin_ts) |begin_ts| {
        if (ts < begin_ts * 1000) {
            info = timezone.info(@divFloor(ts, 1000));
            offset = info.utc_offset_seconds * 1000;
            ts = offset_ts - offset;

            if (info.end_ts) |end_ts| {
                if (ts >= end_ts * 1000) {
                    const info2 = timezone.info(@divFloor(ts, 1000));
                    const offset2 = info2.utc_offset_seconds * 1000;
                    const ts2 = offset_ts - offset2;

                    if (ts2 < ts) {
                        ts = ts2;
                        offset = offset2;
                    }
                }
            }

            return .{
                .dt = self,
                .utc_offset_ms = offset + Timezone.Leap_Second.get_utc_offset_seconds(timezone.leap_seconds, @divFloor(ts, 1000)) * 1000,
                .timezone = timezone,
            };
        }
    }
    
    if (info.end_ts) |end_ts| {
        if (ts >= end_ts * 1000) {
            info = timezone.info(@divFloor(ts, 1000));
            offset = info.utc_offset_seconds * 1000;
            ts = offset_ts - offset;

            if (info.begin_ts) |begin_ts| {
                if (ts < begin_ts * 1000) {
                    const info2 = timezone.info(@divFloor(ts, 1000));
                    const offset2 = info2.utc_offset_seconds * 1000;
                    const ts2 = offset_ts - offset2;

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
        .utc_offset_ms = offset + Timezone.Leap_Second.get_utc_offset_seconds(timezone.leap_seconds, @divFloor(ts, 1000)) * 1000,
        .timezone = timezone,
    };
}

/// N.B. this does not include leap seconds, and assumes both date/times are from the same timezone.
/// Use Date_Time.With_Offset.duration_since() to avoid these limitations.
pub fn duration_since(self: Date_Time, past: Date_Time) std.Io.Duration {
    return .fromMilliseconds(self.ms_since(past));
}

/// N.B. this does not include leap seconds, and assumes both date/times are from the same timezone.
/// Use Date_Time.With_Offset.ms_since() to avoid these limitations.
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

/// N.B. this does not adjust for leap seconds.
/// Use Date_Time.With_Offset.plus_duration() to avoid this limitation.
pub fn plus_duration(self: Date_Time, duration: std.Io.Duration) Date_Time {
    return self.plus_days_and_ms(0, duration.toMilliseconds());
}

/// N.B. this does not adjust for leap seconds.
/// Use Date_Time.With_Offset.minus_duration() to avoid this limitation.
pub fn minus_duration(self: Date_Time, duration: std.Io.Duration) Date_Time {
    return self.plus_days_and_ms(0, -duration.toMilliseconds());
}

/// Generally `days` and `ms` should have the same sign, otherwise they will act in opposing directions
/// N.B. this does not adjust for leap seconds.
/// Use Date_Time.With_Offset.plus_days_and_ms() to avoid this limitation.
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
    utc_offset_ms: i32 = 0,
    timezone: ?*const Timezone = null,

    pub fn from_timestamp(ts: std.Io.Timestamp, timezone: ?*const Timezone) With_Offset {
        return .from_timestamp_ms(ts.toMilliseconds(), timezone);
    }

    pub fn from_timestamp_ms(ts: i64, timezone: ?*const Timezone) With_Offset {
        var utc_offset_ms: i32 = 0;
        if (timezone) |tz| utc_offset_ms = tz.utc_offset_ms(ts);
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

    pub fn timestamp(self: With_Offset) std.Io.Timestamp {
        return .fromNanoseconds(self.timestamp_ms() * std.time.ns_per_ms);
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

    /// Returns a Date_Time.With_Offset representing the same timestamp, but ensuring that:
    ///   * The `dt.time` field is before `.midnight_eod` but not before `.midnight`.
    ///   * If there is a timezone, the `utc_offset_ms` field is correct for the timestamp.
    /// Note that all `Date` values are canonical by definition.
    pub fn canonical(self: With_Offset) With_Offset {
        var utc_offset_ms = self.utc_offset_ms;
        var delta_ms: ?i64 = null;
        if (self.dt.time.is_before(.midnight) or !self.dt.time.is_before(.midnight_eod)) {
            delta_ms = 0;
        }
        if (self.timezone) |tz| {
            utc_offset_ms = tz.utc_offset_ms(self.timestamp_ms());
            if (utc_offset_ms != self.utc_offset_ms) {
                delta_ms = self.utc_offset_ms - utc_offset_ms;
            }
        }
        return .{
            .dt = if (delta_ms) |delta| self.dt.plus_days_and_ms(0, delta) else self.dt,
            .utc_offset_ms = utc_offset_ms,
            .timezone = self.timezone,
        };
    }

    pub fn duration_since(self: With_Offset, past: With_Offset) std.Io.Duration {
        return .fromMilliseconds(self.ms_since(past));
    }

    pub fn ms_since(self: With_Offset, past: With_Offset) i64 {
        if (self.timezone == &Timezone.tai and past.timezone == &Timezone.tai) {
            return self.dt.ms_since(past.dt) + past.utc_offset_ms - self.utc_offset_ms;
        } else {
            const self_ts = self.timestamp_ms();
            const past_ts = past.timestamp_ms();
            const adj = Timezone.tai.utc_offset_ms(self_ts) - Timezone.tai.utc_offset_ms(past_ts);
            return self_ts - past_ts + adj;
        }
    }

    pub fn duration_since_ignore_leap_seconds(self: With_Offset, past: With_Offset) std.Io.Duration {
        return .fromMilliseconds(self.ms_since_ignore_leap_seconds(past));
    }

    pub fn ms_since_ignore_leap_seconds(self: With_Offset, past: With_Offset) i64 {
        return self.dt.ms_since(past.dt) + past.utc_offset_ms - self.utc_offset_ms;
    }

    pub fn is_before(self: With_Offset, other: With_Offset) bool {
        if (self.utc_offset_ms == other.utc_offset_ms) {
            return self.dt.is_before(other.dt);
        }
        const self_ts = self.timestamp_ms();
        const other_ts = other.timestamp_ms();
        return self_ts < other_ts;
    }

    pub fn is_after(self: With_Offset, other: With_Offset) bool {
        if (self.utc_offset_ms == other.utc_offset_ms) {
            return self.dt.is_after(other.dt);
        }
        const self_ts = self.timestamp_ms();
        const other_ts = other.timestamp_ms();
        return self_ts > other_ts;
    }

    pub fn plus_duration(self: With_Offset, duration: std.Io.Duration) With_Offset {
        return self.plus_days_and_ms(0, duration.toMilliseconds());
    }

    pub fn minus_duration(self: With_Offset, duration: std.Io.Duration) With_Offset {
        return self.plus_days_and_ms(0, -duration.toMilliseconds());
    }

    /// Generally `days` and `ms` should have the same sign, otherwise they will act in opposing directions
    pub fn plus_days_and_ms(self: With_Offset, days: i32, ms: i64) With_Offset {
        const leap_seconds = Timezone.tai.leap_seconds;
        const ts_utc = self.timestamp_ms();
        const ts_tai_offset_ms = Timezone.tai.utc_offset_ms(ts_utc);
        const ts_tai = ts_utc + ts_tai_offset_ms;
        const new_ts_tai = ts_tai + @as(i64, days) * std.time.ms_per_day + ms;
        const new_ts_tai_offset_seconds = Timezone.Leap_Second.get_utc_offset_seconds_from_tai(leap_seconds, @divFloor(new_ts_tai, 1000));
        const new_ts_tai_offset_ms = new_ts_tai_offset_seconds * 1000;
        const new_ts_utc = new_ts_tai - new_ts_tai_offset_ms;
        var new_utc_offset_ms = self.utc_offset_ms;
        var dst_delta: i64 = 0;
        if (self.timezone) |tz| {
            new_utc_offset_ms = tz.utc_offset_ms(new_ts_utc);
            dst_delta = self.utc_offset_ms - new_utc_offset_ms;
            if (tz.leap_seconds.len > 0) {
                dst_delta -= Timezone.Leap_Second.get_utc_offset_seconds(tz.leap_seconds, ts_utc);
                dst_delta += Timezone.Leap_Second.get_utc_offset_seconds(tz.leap_seconds, new_ts_utc);
            }
        }
        return .{
            .dt = self.dt.plus_days_and_ms(days, ms + ts_tai_offset_ms - new_ts_tai_offset_ms + dst_delta),
            .utc_offset_ms = new_utc_offset_ms,
            .timezone = self.timezone,
        };
    }

    pub fn plus_duration_ignore_leap_seconds(self: With_Offset, duration: std.Io.Duration) With_Offset {
        return self.plus_days_and_ms_ignore_leap_seconds(0, duration.toMilliseconds());
    }

    pub fn minus_duration_ignore_leap_seconds(self: With_Offset, duration: std.Io.Duration) With_Offset {
        return self.plus_days_and_ms_ignore_leap_seconds(0, -duration.toMilliseconds());
    }

    pub fn plus_days_and_ms_ignore_leap_seconds(self: With_Offset, days: i32, ms: i64) With_Offset {
        if (self.timezone) |tz| {
            const ts_utc = self.timestamp_ms();
            const new_ts_utc = ts_utc + @as(i64, days) * std.time.ms_per_day + ms;
            const new_utc_offset_ms = tz.utc_offset_ms(new_ts_utc);
            return .{
                .dt = self.dt.plus_days_and_ms(days, ms + self.utc_offset_ms - new_utc_offset_ms),
                .utc_offset_ms = new_utc_offset_ms,
                .timezone = self.timezone,
            };
        }
        return .{
            .dt = self.dt.plus_days_and_ms(days, ms),
            .utc_offset_ms = self.utc_offset_ms,
            .timezone = null,
        };
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

    pub fn from_string_tz(comptime pattern: []const u8, str: []const u8, tz: ?*const Timezone) !With_Offset {
        var reader = std.Io.Reader.fixed(str);
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader, tz, null) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
        };

        return pi.date_time(tz);
    }

    pub fn from_string_tzdb(comptime pattern: []const u8, str: []const u8, tzdb: ?*const TZDB) !With_Offset {
        var reader = std.Io.Reader.fixed(str);
        const timezone = if (tzdb) |db| &db.local else null;
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader, timezone, tzdb) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
        };

        return pi.date_time(timezone);
    }
};

const Date = @import("date.zig").Date;
const Time = @import("time.zig").Time;
const Day = @import("day.zig").Day;
const Year = @import("year.zig").Year;
const ISO_Week_Date = @import("iso_week.zig").ISO_Week_Date;
const Timezone = @import("Timezone.zig");
const TZDB = @import("TZDB.zig");
const formatting = @import("formatting.zig");
const std = @import("std");
