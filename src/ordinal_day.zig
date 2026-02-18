// Day of year; January 1 is always ordinal day 1

pub const Ordinal_Day = enum (u9) {
    first = 1,
    _,

    pub fn from_number(day: i32) Ordinal_Day {
        std.debug.assert(day >= 1);
        std.debug.assert(day <= 366);
        return @enumFromInt(day);
    }

    pub fn from_ymd(ymd: Date.YMD) Ordinal_Day {
        const day_of_month: i32 = ymd.day.as_number();
        return Ordinal_Day.from_number(switch (ymd.month) {
            .january => day_of_month,
            .february => Month.january.days_assume_non_leap_year() + day_of_month,
            inline else => |comptime_month| blk: {
                comptime var base = 0;
                inline for (1..comptime comptime_month.as_number()) |prev_month| {
                    base += comptime Month.from_number(prev_month).days_assume_non_leap_year();
                }
                break :blk base + day_of_month + if (ymd.year.is_leap()) @as(u1, 1) else 0;
            },
        });
    }

    pub fn from_yimd(yi: Year.Info, m: Month, d: Day) Ordinal_Day {
        const day_of_month: i32 = d.as_number();
        return Ordinal_Day.from_number(switch (m) {
            .january => day_of_month,
            .february => Month.january.days_assume_non_leap_year() + day_of_month,
            inline else => |comptime_month| blk: {
                comptime var base = 0;
                inline for (1..comptime comptime_month.as_number()) |prev_month| {
                    base += comptime Month.from_number(prev_month).days_assume_non_leap_year();
                }
                break :blk base + day_of_month + if (yi.is_leap) @as(u1, 1) else 0;
            },
        });
    }

    pub fn from_md_assume_non_leap_year(m: Month, d: Day) Ordinal_Day {
        const day_of_month: i32 = d.as_number();
        return Ordinal_Day.from_number(switch (m) {
            .january => day_of_month,
            .february => Month.january.days_assume_non_leap_year() + day_of_month,
            inline else => |comptime_month| blk: {
                comptime var base = 0;
                inline for (1..comptime_month.as_number()) |prev_month| {
                    base += comptime Month.from_number(prev_month).days_assume_non_leap_year();
                }
                break :blk base + day_of_month;
            },
        });
    }

    pub fn as_number(self: Ordinal_Day) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Ordinal_Day) u32 {
        return @intFromEnum(self);
    }

    pub fn date_from_year(self: Ordinal_Day, year: Year) Date {
        return year.starting_date().plus_days(self.as_number() - 1);
    }
    pub fn date_from_yi(self: Ordinal_Day, yi: Year.Info) Date {
        return yi.starting_date.plus_days(self.as_number() - 1);
    }

    pub fn ordinal_week(self: Ordinal_Day) Ordinal_Week {
        return Ordinal_Week.from_number(@intCast((self.as_unsigned() - 1) / 7 + 1));
    }

    pub fn is_before(self: Ordinal_Day, other: Ordinal_Day) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Ordinal_Day, other: Ordinal_Day) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }
};

const Date = @import("date.zig").Date;
const Year = @import("year.zig").Year;
const Month = @import("month.zig").Month;
const Day = @import("day.zig").Day;
const Ordinal_Week = @import("ordinal_week.zig").Ordinal_Week;
const std = @import("std");
