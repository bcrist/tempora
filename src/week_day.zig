pub const Week_Day = enum(u3) {
    sunday = 1,
    monday = 2,
    tuesday = 3,
    wednesday = 4,
    thursday = 5,
    friday = 6,
    saturday = 7,

    pub fn from_number(d: i32) Week_Day {
        return @enumFromInt(d);
    }

    pub fn from_iso(d: i32) Week_Day {
        return if (d == 7) .sunday else .from_number(d + 1);
    }

    pub const From_String_Options = struct {
        trim: []const u8 = formatting.default_from_string_trim,
        allow_long: bool = true,
        allow_short: bool = true,
        allow_numeric: bool = false,
    };
    pub fn from_string(d: []const u8, options: From_String_Options) !Week_Day {
        const trimmed = if (options.trim.len > 0) std.mem.trim(u8, d, options.trim) else d;

        if (trimmed.len == 0) return error.InvalidString;

        if (options.allow_short or options.allow_long) {
            const info = @typeInfo(Week_Day).@"enum";
            inline for (info.fields) |field| {
                if (trimmed[0] | 0x20 == field.name[0]) {
                    const day: Week_Day = @enumFromInt(field.value);
                    if (switch (trimmed.len) {
                        1 => options.allow_short and day == .monday or day == .wednesday or day == .friday,
                        2 => options.allow_short and trimmed[1] | 0x20 == field.name[1],
                        3 => options.allow_short and trimmed[1] | 0x20 == field.name[1] and trimmed[2] | 0x20 == field.name[2],
                        4 => options.allow_short and day == .tuesday and std.ascii.eqlIgnoreCase(trimmed, "tues"),
                        5 => options.allow_short and day == .thursday and std.ascii.eqlIgnoreCase(trimmed, "thurs"),
                        else => options.allow_long and std.ascii.eqlIgnoreCase(trimmed, field.name),
                    }) return day;
                }
            }
        }

        if (options.allow_numeric) {
            const numeric = std.fmt.parseInt(u3, trimmed, 10) catch return error.InvalidString;
            if (numeric >= 1 and numeric <= 7) {
                return @enumFromInt(numeric);
            }
        }

        return error.InvalidString;
    }

    pub fn as_number(self: Week_Day) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Week_Day) u32 {
        return @intFromEnum(self);
    }

    pub fn as_iso(self: Week_Day) u3 {
        return if (self == .sunday) 7 else @intCast(self.as_unsigned() - 1);
    }

    pub fn name(self: Week_Day) []const u8 {
        return switch (self) {
            .sunday => "Sunday",
            .monday => "Monday",
            .tuesday => "Tuesday",
            .wednesday => "Wednesday",
            .thursday => "Thursday",
            .friday => "Friday",
            .saturday => "Saturday",
        };
    }

    pub fn short_name(self: Week_Day) []const u8 {
        return self.name()[0..3];
    }

    pub fn is_before(self: Week_Day, other: Week_Day) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Week_Day, other: Week_Day) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus(self: Week_Day, days: i32) Week_Day {
        return .from_number(@intCast(@mod(self.as_number() + days - 1, 7) + 1));
    }

    pub fn prev(self: Week_Day) Week_Day {
        return self.plus(-1);
    }

    pub fn next(self: Week_Day) Week_Day {
        return self.plus(1);
    }

    /// This may return the same date.
    /// for the alternative, use Date.next_week_day()
    pub fn on_or_after(self: Week_Day, date: Date) Date {
        const current: i32 = date.week_day().as_number();
        const target: i32 = self.as_number();
        var delta_days = target - current;
        if (current > target) delta_days += 7;
        return date.plus_days(delta_days);
    }

    /// This may return the same date.
    /// for the alternative, use Date.prev_week_day()
    pub fn on_or_before(self: Week_Day, date: Date) Date {
        const current: i32 = date.week_day().as_number();
        const target: i32 = self.as_number();
        var delta_days = target - current;
        if (current < target) delta_days -= 7;
        return date.plus_days(delta_days);
    }
};

/// definitional impl for testing correctness
pub fn oracle(d: Date) Week_Day {
    comptime {
        // 2000-01-01 was a saturday (7).
        std.debug.assert(Date.year(.epoch).as_number() == 2000);
        std.debug.assert(Week_Day.as_number(.saturday) == 7);
    }
    const rd: i64 = @intFromEnum(d);
    return @enumFromInt(@mod(rd - 1, 7) + 1);
}

/// An alternative oracle that uses @rem instead of @mod
pub fn oracle2(d: Date) Week_Day {
    comptime {
        // 2000-01-01 was a saturday (7).
        std.debug.assert(Date.year(.epoch).as_number() == 2000);
        std.debug.assert(Week_Day.as_number(.saturday) == 7);
    }
    const rd: i64 = @intFromEnum(d);
    return @enumFromInt(@rem(@rem(rd, 7) + 13, 7) + 1);
}

/// for benchmarking only
pub fn hinnant(d: Date) Week_Day {
    const rd: i32 = @intFromEnum(d);
    if (rd >= -6) {
        return @enumFromInt(@rem(rd + 6, 7) + 1);
    } else {
        return @enumFromInt(@rem(rd + 7, 7) + 7);
    }
}

/// for benchmarking only
pub fn neri(d: Date) Week_Day {
    const rd: i32 = @intFromEnum(d);
    const rd_u32: u32 = @bitCast(rd);
    const pos_offset: u32 = comptime Week_Day.as_unsigned(.saturday) - 1;
    const neg_offset: u32 = ~@as(u32, (@as(comptime_int, pos_offset) + 0x1_0000_0002) % 7) + 1;
    return @enumFromInt(@rem(rd_u32 +% if (rd >= 0) pos_offset else neg_offset, 7) + 1);
}

pub const joffe_limited_min = -71_303_174; // 17 July -193,222
pub const joffe_limited_max = 107_653_804; // 8 February 296_746
/// adapted from https://www.benjoffe.com/fast-day-of-week#unreasonable
/// N.B. The exact valid range for this algorithm is determined by the `offset` constant.
/// There is no such value that gives a correct answer for all possible `i28` values,
/// but there are many which work for `i27`, so I've selected one which is skewed towards
/// future dates rather than being as close to balanced as possible.
pub fn joffe_limited(d: Date) Week_Day {
    const rd: i32 = @intFromEnum(d);
    std.debug.assert(rd >= joffe_limited_min and rd <= joffe_limited_max);
    const rd_u32: u32 = @bitCast(rd);
    const mult: u32 = (1 << 32) / 7 + 1;
    const offset: u32 = 0b111_1110101 << 22;
    const raw = rd_u32 *% mult +% offset;
    const rounded: u8 = @truncate(raw >> 29);
    return @enumFromInt(rounded);
}

/// adapted from https://www.benjoffe.com/fast-day-of-week#v1
pub fn joffe_shift(d: Date) Week_Day {
    const rd: i32 = @intFromEnum(d);
    const rd_u32: u32 = @bitCast(rd);
    const mult: u32 = (1 << 32) / 7;
    const offset: u32 = 0b111_11110 << 24;
    const a: u32 = rd_u32 *% mult +% offset;
    const b: u32 = @bitCast((rd >> 1) + (rd >> 4));
    const rounded: u8 = @truncate((a +% b) >> 29);
    return @enumFromInt(rounded);
}

/// adapted from https://www.benjoffe.com/fast-day-of-week#v2
pub fn joffe_mul2(d: Date) Week_Day {
    const rd: i32 = @intFromEnum(d);
    const rd_u32: u32 = @bitCast(rd);
    const rd_i64: i64 = rd;
    const mult1: u32 = (1 << 32) / 7 + 1;
    const mult2: i32 = @bitCast(mult1 *% 4);
    const offset: u32 = 0b111_11100 << 24;
    const a: u32 = rd_u32 *% mult1 +% offset;
    const b_i64 = rd_i64 * mult2;
    const b_u64: u64 = @bitCast(b_i64);
    const b: u32 = @truncate(b_u64 >> 32);
    const rounded: u8 = @truncate((a +% b) >> 29);
    return @enumFromInt(rounded);
}

/// adapted from https://www.benjoffe.com/fast-day-of-week#v3
pub fn joffe_split(d: Date) Week_Day {
    const rd: i64 = @intFromEnum(d);
    const rd_u64: u64 = @bitCast(rd);
    const mult: u32 = (1 << 32) / 7;
    const offset: u32 = 0b111_11100 << 24;
    const wide: u64 = rd_u64 *% mult;
    const hi: u32 = @truncate(wide >> 32);
    const lo: u32 = @truncate(wide);
    const raw: u32 = lo +% (hi << 2) +% offset;
    const rounded: u8 = @truncate(raw >> 29);
    return @enumFromInt(rounded);
}

/// adapted from https://www.benjoffe.com/fast-day-of-week#widen
pub fn joffe_64b(d: Date) Week_Day {
    const rd: i64 = @intFromEnum(d);
    const rd_u64: u64 = @bitCast(rd);
    const mult: u64 = ((1 << 40) / 7 + 1) << 24;
    const offset: u64 = 0b111_11100 << 56;
    const raw = rd_u64 *% mult +% offset;
    const rounded: u8 = @truncate(raw >> 61);
    return @enumFromInt(rounded);
}

pub const Date = @import("date.zig").Date;

const formatting = @import("formatting.zig");
const std = @import("std");
