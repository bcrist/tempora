pub const Day = enum(u5) {
    first = 1,
    _,

    pub fn from_number(d: i32) Day {
        std.debug.assert(d >= 1);
        std.debug.assert(d <= 31);
        return @enumFromInt(d);
    }

    pub fn as_number(self: Day) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Day) u32 {
        return @intFromEnum(self);
    }
};

const std = @import("std");
