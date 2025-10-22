pub const Time = enum (i32) {
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

    pub fn from_hmsm(h: i32, m: i32, s: i32, milli: i32) Time {
        const mm = h * 60 + m;
        const ss = mm * 60 + s;
        const msms = ss * 1000 + milli;
        std.debug.assert(msms >= 0);
        std.debug.assert(msms < @intFromEnum(Time.midnight_eod));
        return @enumFromInt(msms);
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

    pub fn hours(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @divFloor(raw, 60 * 60 * 1000);
    }

    pub fn minutes_since_midnight(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @divFloor(raw, 60 * 1000);
    }

    pub fn minutes(self: Time) i32 {
        const raw = self.ms_since_midnight();
        const delta = raw - self.hours() * 60 * 60 * 1000;
        return @divFloor(delta, 60 * 1000);
    }

    pub fn seconds_since_midnight(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @divFloor(raw, 1000);
    }

    pub fn seconds(self: Time) i32 {
        const raw = self.ms_since_midnight();
        const delta = raw - self.minutes_since_midnight() * 60 * 1000;
        return @divFloor(delta, 1000);
    }

    pub fn ms_since_midnight(self: Time) i32 {
        return @intFromEnum(self);
    }

    pub fn ms(self: Time) i32 {
        const raw = self.ms_since_midnight();
        return @mod(raw, 1000);
    }

    pub fn is_before(self: Time, other: Time) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Time, other: Time) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus_ms(self: Time, milli: i32) Date {
        return @enumFromInt(@intFromEnum(self) + milli);
    }

    pub fn plus_seconds(self: Time, s: i32) Date {
        return @enumFromInt(@intFromEnum(self) + s * 1000);
    }

    pub fn plus_minutes(self: Time, m: i32) Date {
        return @enumFromInt(@intFromEnum(self) + m * 60 * 1000);
    }

    pub fn plus_hours(self: Time, h: i32) Date {
        return @enumFromInt(@intFromEnum(self) + h * 60 * 60 * 1000);
    }

    pub const With_Offset = struct {
        time: Time,
        utc_offset_ms: i32,
        timezone: ?*const Timezone,

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

        pub fn format(self: With_Offset, writer: *std.io.Writer) !void {
            try formatting.format(self.with_date(.epoch), iso8601, writer);
        }

        pub fn fmt(self: With_Offset, comptime pattern: []const u8) Formatter(pattern) {
            return .{ .time_with_offset = self };
        }

        pub fn Formatter(comptime pattern: []const u8) type {
            return struct {
                time_with_offset: With_Offset,
                pub fn format(self: @This(), writer: *std.io.Writer) !void {
                    try formatting.format(self.time_with_offset.with_date(.epoch), pattern, writer);
                }
            };
        }

        pub fn from_string(comptime pattern: []const u8, str: []const u8) !With_Offset {
            return from_string_tz(pattern, str, null);
        }

        pub fn from_string_tz(comptime pattern: []const u8, str: []const u8, timezone: ?*const Timezone) !With_Offset {
            var stream = std.io.fixedBufferStream(str);
            const pi = formatting.parse(if (pattern.len == 0) iso8601 else fmt, &stream) catch return error.InvalidPattern;

            if (pi.timestamp) |ts| {
                const dto = Date_Time.With_Offset.from_timestamp_ms(ts, timezone);
                return .{
                    .time = dto.dt.time,
                    .utc_offset_ms = dto.utc_offset_ms,
                    .timezone = dto.timezone,
                };
            } else if (pi.hours) |raw_h| {
                const h = @mod(if (pi.hours_is_pm) raw_h + 12 else raw_h, 24);
                const m = pi.minutes orelse 0;
                const s = pi.seconds orelse 0;
                const milli = pi.ms orelse 0;
                return .{
                    .time = Time.from_hmsm(h, m, s, milli),
                    .utc_offset_ms = pi.utc_offset_ms orelse if (timezone) |tz| tz.zone_info(std.time.timestamp()).offset * 1000 else 0,
                    .timezone = timezone,
                };
            } else return error.InvalidPattern;
        }
    };
};

const Date_Time = @import("Date_Time.zig");
const Timezone = @import("Timezone.zig");
const Date = @import("date.zig").Date;
const formatting = @import("formatting.zig");
const std = @import("std");
