// N.B. this is not the same as https://en.wikipedia.org/wiki/ISO_week_date
pub const Ordinal_Week = enum (u6) {
    first = 1,
    _,

    pub fn from_number(day: i32) Ordinal_Week {
        std.debug.assert(day >= 1);
        std.debug.assert(day <= 53);
        return @enumFromInt(day);
    }

    pub fn as_number(self: Ordinal_Week) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Ordinal_Week) u32 {
        return @intFromEnum(self);
    }

    pub fn starting_day(self: Ordinal_Week) Ordinal_Day {
        return Ordinal_Day.from_number(@intCast((self.as_unsigned() - 1) * 7 + 1));
    }

    pub fn is_before(self: Ordinal_Week, other: Ordinal_Week) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Ordinal_Week, other: Ordinal_Week) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }
};

const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const std = @import("std");
