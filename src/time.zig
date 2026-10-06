pub const Time = enum(i32) {
    midnight = 0,
    @"1am" = 1 * 60 * 60 * 1000,
    @"2am" = 2 * 60 * 60 * 1000,
    @"3am" = 3 * 60 * 60 * 1000,
    @"4am" = 4 * 60 * 60 * 1000,
    @"5am" = 5 * 60 * 60 * 1000,
    @"6am" = 6 * 60 * 60 * 1000,
    @"7am" = 7 * 60 * 60 * 1000,
    @"8am" = 8 * 60 * 60 * 1000,
    @"9am" = 9 * 60 * 60 * 1000,
    @"10am" = 10 * 60 * 60 * 1000,
    @"11am" = 11 * 60 * 60 * 1000,
    noon = 12 * 60 * 60 * 1000,
    @"1pm" = 13 * 60 * 60 * 1000,
    @"2pm" = 14 * 60 * 60 * 1000,
    @"3pm" = 15 * 60 * 60 * 1000,
    @"4pm" = 16 * 60 * 60 * 1000,
    @"5pm" = 17 * 60 * 60 * 1000,
    @"6pm" = 18 * 60 * 60 * 1000,
    @"7pm" = 19 * 60 * 60 * 1000,
    @"8pm" = 20 * 60 * 60 * 1000,
    @"9pm" = 21 * 60 * 60 * 1000,
    @"10pm" = 22 * 60 * 60 * 1000,
    @"11pm" = 23 * 60 * 60 * 1000,
    midnight_eod = 24 * 60 * 60 * 1000,
    _,

    pub const @"12am": Time = .midnight;
    pub const @"12pm": Time = .noon;

    pub fn from_ms(milli: i32) Time {
        return @fromBackingInt(@intCast(milli));
    }

    pub fn from_seconds(s: i32) Time {
        return @fromBackingInt(@intCast(s * 1000));
    }

    pub fn from_minutes(m: i32) Time {
        return @fromBackingInt(@intCast(m * 60_000));
    }

    pub fn from_hours(h: i32) Time {
        return @fromBackingInt(@intCast(h * 3600_000));
    }

    pub fn from_hmsm(hms: HMSM) Time {
        const h_ms = hms.h * 3600_000;
        const m_ms = @as(u31, hms.m) * 60_000;
        const s_ms = @as(u31, hms.s) * 1_000;
        return @fromBackingInt(h_ms + m_ms + s_ms + hms.ms);
    }

    pub fn from_hmsm_numbers(h: i32, m: i32, s: i32, ms: i32) Time {
        const h_ms = h * 3600_000;
        const m_ms = m * 60_000;
        const s_ms = s * 1_000;
        return @fromBackingInt(h_ms + m_ms + s_ms + ms);
    }

    pub fn with_date(self: Time, date: Date) Date_Time {
        return .{
            .date = date,
            .time = self,
        };
    }

    pub fn with_offset(self: Time, utc_offset_ms: i32) With_Offset {
        return .{
            .time = self,
            .utc_offset_ms = utc_offset_ms,
            .timezone = null,
        };
    }

    pub fn with_timezone(self: Time, timezone: *const Timezone, utc_offset_ms: i32) With_Offset {
        return .{
            .time = self,
            .utc_offset_ms = utc_offset_ms,
            .timezone = timezone,
        };
    }

    pub fn hmsm(self: Time) HMSM {
        return .from_time(self);
    }

    pub fn minutes_since_midnight(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @divFloor(raw, 60 * 1000);
    }

    pub fn seconds_since_midnight(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @divFloor(raw, 1000);
    }

    pub fn ms_since_midnight(self: Time) i32 {
        return @backingInt(self);
    }

    pub fn is_before(self: Time, other: Time) bool {
        return @backingInt(self) < @backingInt(other);
    }

    pub fn is_after(self: Time, other: Time) bool {
        return @backingInt(self) > @backingInt(other);
    }

    pub fn plus_duration(self: Time, duration: std.Io.Duration) Time {
        return self.plus_ms(@intCast(duration.toMilliseconds()));
    }

    pub fn minus_duration(self: Time, duration: std.Io.Duration) Time {
        return self.plus_ms(@intCast(-duration.toMilliseconds()));
    }

    pub fn plus_hmsm(self: Time, hms: HMSM) Time {
        return self.plus_ms(hms.ms_since_midnight());
    }

    pub fn plus_ms(self: Time, milli: i32) Time {
        return @fromBackingInt(@intCast(@backingInt(self) + milli));
    }

    pub fn plus_seconds(self: Time, s: i32) Time {
        return @fromBackingInt(@intCast(@backingInt(self) + s * 1000));
    }

    pub fn plus_minutes(self: Time, m: i32) Time {
        return @fromBackingInt(@intCast(@backingInt(self) + m * 60 * 1000));
    }

    pub fn plus_hours(self: Time, h: i32) Time {
        return @fromBackingInt(@intCast(@backingInt(self) + h * 60 * 60 * 1000));
    }

    pub const With_Offset = struct {
        time: Time,
        utc_offset_ms: i32 = 0,
        timezone: ?*const Timezone = null,

        pub fn with_date(self: With_Offset, date: Date) Date_Time.With_Offset {
            return .{
                .dt = .{
                    .date = date,
                    .time = self.time,
                },
                .utc_offset_ms = self.utc_offset_ms,
                .timezone = self.timezone,
            };
        }

        pub fn in_timezone(self: With_Offset, timezone: ?*const Timezone, utc_offset_ms: i32) With_Offset {
            return .{
                .time = self.time.plus_ms(utc_offset_ms - self.utc_offset_ms),
                .utc_offset_ms = utc_offset_ms,
                .timezone = timezone,
            };
        }

        pub const iso8601 = "HH:mm:ss.SSSZ";
        pub const iso8601_local = "HH:mm:ss.SSS";
        pub const rfc2822 = "HH:mm:ss ZZ";
        pub const sql_ms = "HH:mm:ss.SSS z";
        pub const sql = "HH:mm:ss z";
        pub const hms = "h:mm:ss a";
        pub const hm = "h:mm a";

        pub fn format(self: With_Offset, writer: *std.Io.Writer) !void {
            try formatting.format(self.with_date(.epoch), iso8601, writer);
        }

        pub fn fmt(self: With_Offset, comptime pattern: []const u8) Formatter(pattern) {
            return .{ .time_with_offset = self };
        }

        pub fn Formatter(comptime pattern: []const u8) type {
            return struct {
                time_with_offset: With_Offset,
                pub fn format(self: @This(), writer: *std.Io.Writer) !void {
                    try formatting.format(self.time_with_offset.with_date(.epoch), pattern, writer);
                }
            };
        }

        pub fn from_string(comptime pattern: []const u8, str: []const u8) !With_Offset {
            return from_string_tz(pattern, str, null);
        }

        pub fn from_string_tz(comptime pattern: []const u8, str: []const u8, timezone: ?*const Timezone) !With_Offset {
            var stream = std.Io.Reader.fixed(str);
            const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &stream, timezone, null) catch |err| switch (err) {
                error.InvalidString => return err,
                error.EndOfStream => return error.InvalidString,
                error.ReadFailed => unreachable,
            };

            return pi.time(timezone);
        }

        pub fn from_string_tzdb(comptime pattern: []const u8, str: []const u8, tzdb: ?*const TZDB) !With_Offset {
            var stream = std.Io.Reader.fixed(str);
            const timezone = if (tzdb) |db| &db.local else null;
            const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &stream, timezone, tzdb) catch |err| switch (err) {
                error.InvalidString => return err,
                error.EndOfStream => return error.InvalidString,
                error.ReadFailed => unreachable,
            };

            return pi.time(timezone);
        }
    };

    pub const HMSM = struct {
        h: u31,
        m: u8,
        s: u8,
        ms: u10,

        pub const midnight: HMSM = .from_numbers(0, 0, 0, 0);
        pub const @"1am": HMSM = .from_numbers(1, 0, 0, 0);
        pub const @"2am": HMSM = .from_numbers(2, 0, 0, 0);
        pub const @"3am": HMSM = .from_numbers(3, 0, 0, 0);
        pub const @"4am": HMSM = .from_numbers(4, 0, 0, 0);
        pub const @"5am": HMSM = .from_numbers(5, 0, 0, 0);
        pub const @"6am": HMSM = .from_numbers(6, 0, 0, 0);
        pub const @"7am": HMSM = .from_numbers(7, 0, 0, 0);
        pub const @"8am": HMSM = .from_numbers(8, 0, 0, 0);
        pub const @"9am": HMSM = .from_numbers(9, 0, 0, 0);
        pub const @"10am": HMSM = .from_numbers(10, 0, 0, 0);
        pub const @"11am": HMSM = .from_numbers(11, 0, 0, 0);
        pub const noon: HMSM = .from_numbers(12, 0, 0, 0);
        pub const @"1pm": HMSM = .from_numbers(13, 0, 0, 0);
        pub const @"2pm": HMSM = .from_numbers(14, 0, 0, 0);
        pub const @"3pm": HMSM = .from_numbers(15, 0, 0, 0);
        pub const @"4pm": HMSM = .from_numbers(16, 0, 0, 0);
        pub const @"5pm": HMSM = .from_numbers(17, 0, 0, 0);
        pub const @"6pm": HMSM = .from_numbers(18, 0, 0, 0);
        pub const @"7pm": HMSM = .from_numbers(19, 0, 0, 0);
        pub const @"8pm": HMSM = .from_numbers(20, 0, 0, 0);
        pub const @"9pm": HMSM = .from_numbers(21, 0, 0, 0);
        pub const @"10pm": HMSM = .from_numbers(22, 0, 0, 0);
        pub const @"11pm": HMSM = .from_numbers(23, 0, 0, 0);
        pub const midnight_eod: HMSM = .from_numbers(24, 0, 0, 0);

        pub const @"12am": HMSM = .midnight;
        pub const @"12pm": HMSM = .noon;

        pub fn from_numbers(hours: u31, minutes: u8, seconds: u8, milli: u10) HMSM {
            if (hours == 24) {
                std.debug.assert(minutes == 0);
                std.debug.assert(seconds == 0);
                std.debug.assert(milli == 0);
            } else {
                std.debug.assert(hours <= 24);
                std.debug.assert(minutes < 60);
                std.debug.assert(seconds < 60);
                std.debug.assert(milli < 1000);
            }

            return .{
                .h = hours,
                .m = minutes,
                .s = seconds,
                .ms = milli,
            };
        }

        pub fn from_time(t: Time) HMSM {
            const raw: i32 = @backingInt(t);
            std.debug.assert(raw >= 0);
            if (@bitSizeOf(usize) <= 32) {
                const tsec: i32 = @divTrunc(raw, 1000);
                const tmin: i32 = @divTrunc(raw, 60000);
                const hour: i32 = @divTrunc(raw, 3600000);
                const milli: i32 = raw - tsec * 1000;
                const second: i32 = tsec - tmin * 60;
                const minute: i32 = tmin - hour * 60;
                return .{
                    .h = @intCast(hour),
                    .m = @intCast(minute),
                    .s = @intCast(second),
                    .ms = @intCast(milli),
                };
            } else {
                const raw_u32: u32 = @bitCast(raw);
                const raw_u64: u64 = raw_u32;
                const tsec: u32 = @truncate((raw_u64 *% 274877907) >> 38);
                const tmin: u32 = @truncate((raw_u64 *% 1172812403) >> 46);
                const hour: u32 = @truncate((raw_u64 *% 2501999793) >> 53);
                const milli: u32 = raw_u32 - tsec * 1000;
                const second: u32 = tsec - tmin * 60;
                const minute: u32 = tmin - hour * 60;
                return .{
                    .h = @intCast(hour),
                    .m = @intCast(minute),
                    .s = @intCast(second),
                    .ms = @intCast(milli),
                };
            }
        }

        pub fn time(self: HMSM) Time {
            return .from_hmsm(self);
        }

        pub fn minutes_since_midnight(self: HMSM) i32 {
            var m = @as(i32, self.m) + @as(i32, self.h) * 60;
            if (self.s >= 59) {
                var s = self.s;
                if (self.ms > 999) s += 1;
                if (s >= 60) {
                    m += s / 60;
                }
            }
            return m;
        }

        pub fn seconds_since_midnight(self: HMSM) i32 {
            return @as(i32, if (self.ms > 999) 1 else 0) + @as(i32, self.s) + @as(i32, self.m) * 60 + @as(i32, self.h) * (60 * 60);
        }

        pub fn ms_since_midnight(self: HMSM) i32 {
            return self.ms + @as(i32, self.s) * 1000 + @as(i32, self.m) * 60_000 + @as(i32, self.h) * (60 * 60_000);
        }

        pub fn is_before(self: HMSM, other: HMSM) bool {
            return self.ms_since_midnight() < other.ms_since_midnight();
        }

        pub fn is_after(self: HMSM, other: HMSM) bool {
            return self.ms_since_midnight() > other.ms_since_midnight();
        }

        pub fn plus_duration(self: HMSM, duration: std.Io.Duration) HMSM {
            return self.plus_ms(@intCast(duration.toMilliseconds()));
        }

        pub fn minus_duration(self: HMSM, duration: std.Io.Duration) HMSM {
            return self.plus_ms(@intCast(-duration.toMilliseconds()));
        }

        pub fn plus_ms(self: HMSM, milli: i32) HMSM {
            var new: HMSM = self;
            var new_ms = self.ms + milli;
            if (new_ms >= 1000) {
                const seconds: i32 = @divTrunc(new_ms, 1000);
                new_ms -= seconds * 1000;
                new = new.plus_seconds(seconds);
            } else if (new_ms < 0) {
                const seconds: i32 = @divFloor(new_ms, 1000);
                new_ms -= seconds * 1000;
                new = new.plus_seconds(seconds);
            }
            new.ms = @intCast(new_ms);
            return new;
        }

        pub fn plus_seconds(self: HMSM, s: i32) HMSM {
            var new: HMSM = self;
            var new_s = self.s + s;
            if (new_s >= 60) {
                const minutes: i32 = @divTrunc(new_s, 60);
                new_s -= minutes * 60;
                new = new.plus_minutes(minutes);
            } else if (new_s < 0) {
                const minutes: i32 = @divFloor(new_s, 60);
                new_s -= minutes * 60;
                new = new.plus_minutes(minutes);
            }
            new.s = @intCast(new_s);
            return new;
        }

        pub fn plus_minutes(self: HMSM, m: i32) HMSM {
            var new: HMSM = self;
            var new_m = self.m + m;
            if (new_m >= 60) {
                const hours: i32 = @divTrunc(new_m, 60);
                new_m -= hours * 60;
                new = new.plus_hours(hours);
            } else if (new_m < 0) {
                const hours: i32 = @divFloor(new_m, 60);
                new_m -= hours * 60;
                new = new.plus_hours(hours);
            }
            new.m = @intCast(new_m);
            return new;
        }

        pub fn plus_hours(self: HMSM, h: i32) HMSM {
            var new: HMSM = self;
            new.h = @intCast(new.h + h);
            return new;
        }
    };
};

const Date_Time = @import("Date_Time.zig");
const Timezone = @import("Timezone.zig");
const TZDB = @import("TZDB.zig");
const Date = @import("date.zig").Date;
const formatting = @import("formatting.zig");
const std = @import("std");
