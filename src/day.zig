//! Day of month

pub const Day = enum(u5) {
    first = 1,
    _,

    pub const @"1": Day = .first;
    pub const @"2": Day = @enumFromInt(2);
    pub const @"3": Day = @enumFromInt(3);
    pub const @"4": Day = @enumFromInt(4);
    pub const @"5": Day = @enumFromInt(5);
    pub const @"6": Day = @enumFromInt(6);
    pub const @"7": Day = @enumFromInt(7);
    pub const @"8": Day = @enumFromInt(8);
    pub const @"9": Day = @enumFromInt(9);
    pub const @"10": Day = @enumFromInt(10);
    pub const @"11": Day = @enumFromInt(11);
    pub const @"12": Day = @enumFromInt(12);
    pub const @"13": Day = @enumFromInt(13);
    pub const @"14": Day = @enumFromInt(14);
    pub const @"15": Day = @enumFromInt(15);
    pub const @"16": Day = @enumFromInt(16);
    pub const @"17": Day = @enumFromInt(17);
    pub const @"18": Day = @enumFromInt(18);
    pub const @"19": Day = @enumFromInt(19);
    pub const @"20": Day = @enumFromInt(20);
    pub const @"21": Day = @enumFromInt(21);
    pub const @"22": Day = @enumFromInt(22);
    pub const @"23": Day = @enumFromInt(23);
    pub const @"24": Day = @enumFromInt(24);
    pub const @"25": Day = @enumFromInt(25);
    pub const @"26": Day = @enumFromInt(26);
    pub const @"27": Day = @enumFromInt(27);
    pub const @"28": Day = @enumFromInt(28);
    pub const @"29": Day = @enumFromInt(29);
    pub const @"30": Day = @enumFromInt(30);
    pub const @"31": Day = @enumFromInt(31);

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

    pub fn is_before(self: Day, other: Day) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Day, other: Day) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus(self: Day, days: i32) Day {
        return .from_number(self.as_number() + days);
    }

    pub fn prev(self: Day) Day {
        return self.plus(-1);
    }

    pub fn next(self: Day) Day {
        return self.plus(1);
    }

    /// This may return the same date.
    /// for the alternative, use Date.next_day_of_month()
    pub fn on_or_after(self: Day, date: Date) Date {
        const _ymd = date.ymd();
        const current = _ymd.day.as_number();
        const target = self.as_number();

        var delta_days = target - current;
        if (current > target) delta_days += _ymd.month.days(_ymd.year);
        return date.plus_days(delta_days);
    }

    /// This may return the same date.
    /// for the alternative, use Date.prev_day_of_month()
    pub fn on_or_before(self: Day, date: Date) Date {
        const _ymd = date.ymd();
        const current = _ymd.day.as_number();
        const target = self.as_number();

        var delta_days = target - current;
        if (current < target) delta_days -= _ymd.month.prev().days(_ymd.year);
        return date.plus_days(delta_days);
    }

    /// This may return the same date.
    /// for the alternative, use Date.YMD.next_day_of_month()
    pub fn on_or_after_ymd(self: Day, ymd: Date.YMD) Date.YMD {
        const target = self.as_number();
        const current = ymd.day.as_number();

        if (target >= current) {
            return .{
                .year = ymd.year,
                .month = ymd.month,
                .day = self,
            };
        } else if (ymd.month == .december) {
            return .{
                .year = ymd.year.next(),
                .month = .january,
                .day = self,
            };
        } else {
            return .{
                .year = ymd.year,
                .month = ymd.month.next(),
                .day = self,
            };
        }
    }

    /// This may return the same date.
    /// for the alternative, use Date.YMD.prev_day_of_month()
    pub fn on_or_before_ymd(self: Day, ymd: Date.YMD) Date.YMD {
        const target = self.as_number();
        const current = ymd.day.as_number();

        if (target <= current) {
            return .{
                .year = ymd.year,
                .month = ymd.month,
                .day = self,
            };
        } else if (ymd.month == .january) {
            return .{
                .year = ymd.year.prev(),
                .month = .december,
                .day = self,
            };
        } else {
            return .{
                .year = ymd.year,
                .month = ymd.month.prev(),
                .day = self,
            };
        }
    }
};

const Date = @import("date.zig").Date;
const Year = @import("year.zig").Year;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const std = @import("std");
