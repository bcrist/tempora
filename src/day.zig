pub const Day = enum(u5) {
    first = 1,
    _,

    pub fn from_number(d: i32) Day {
        std.debug.assert(d >= 1);
        std.debug.assert(d <= 31);
        return @enumFromInt(d);
    }

    pub fn from_yod(y: Year, od: Ordinal_Day) Day {
        return .from_od(od, y.is_leap());
    }

    pub fn from_yiod(yi: Year.Info, od: Ordinal_Day) Day {
        return .from_od(od, yi.is_leap);
    }

    pub fn from_od(od: Ordinal_Day, is_leap_year: bool) Day {
        const noleap_od = Ordinal_Day.from_md_assume_non_leap_year;
        var mut_od: Ordinal_Day = od;

        const offset: i32 = blk: {
            if (mut_od.is_before(comptime noleap_od(.march, .first))) {
                if (mut_od.is_before(comptime noleap_od(.february, .first))) {
                    break :blk 0;
                } else {
                    break :blk comptime -noleap_od(.february, .first).as_number() + 1;
                }
            } else {
                if (is_leap_year) {
                    if (mut_od == comptime noleap_od(.march, .first)) {
                        break :blk comptime -noleap_od(.february, .first).as_number() + 1;
                    } else {
                        mut_od = Ordinal_Day.from_number(mut_od.as_number() - 1);
                    }
                }

                if (mut_od.is_before(comptime noleap_od(.june, .first))) {
                    if (mut_od.is_before(comptime noleap_od(.april, .first))) {
                        break :blk comptime -noleap_od(.march, .first).as_number() + 1;
                    } else if (mut_od.is_before(comptime noleap_od(.may, .first))) {
                        break :blk comptime -noleap_od(.april, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.may, .first).as_number() + 1;
                    }
                } else if (mut_od.is_before(comptime noleap_od(.september, .first))) {
                    if (mut_od.is_before(comptime noleap_od(.july, .first))) {
                        break :blk comptime -noleap_od(.june, .first).as_number() + 1;
                    } else if (mut_od.is_before(comptime noleap_od(.august, .first))) {
                        break :blk comptime -noleap_od(.july, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.august, .first).as_number() + 1;
                    }
                } else if (mut_od.is_before(comptime noleap_od(.november, .first))) {
                    if (mut_od.is_before(comptime noleap_od(.october, .first))) {
                        break :blk comptime -noleap_od(.september, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.october, .first).as_number() + 1;
                    }
                } else if (mut_od.is_before(comptime noleap_od(.december, .first))) {
                    break :blk comptime -noleap_od(.november, .first).as_number() + 1;
                } else {
                    break :blk comptime -noleap_od(.december, .first).as_number() + 1;
                }
            }
        };

        return .from_number(mut_od.as_number() + offset);
    }

    pub fn as_number(self: Day) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Day) u32 {
        return @intFromEnum(self);
    }
};

const Year = @import("Year.zig");
const Ordinal_Day = @import("Ordinal_Day.zig");
const std = @import("std");
