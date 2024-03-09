pub const Month = enum (u4) {
    january = 1,
    february = 2,
    march = 3,
    april = 4,
    may = 5,
    june = 6,
    july = 7,
    august = 8,
    september = 9,
    october = 10,
    november = 11,
    december = 12,

    pub fn from_number(month: i32) Month {
        return @enumFromInt(month);
    }

    pub const From_String_Options = struct {
        trim: []const u8 = formatting.default_from_string_trim,
        allow_short: bool = true,
        allow_long: bool = true,
        allow_numeric: bool = true,
    };
    pub fn from_string(m: []const u8, options: From_String_Options) !Month {
        const trimmed = if (options.trim.len > 0) std.mem.trim(u8, m, options.trim) else m;

        if (options.allow_short and trimmed.len == 3 or options.allow_long and trimmed.len >= 3) {
            inline for (std.meta.fields(Month)) |month| {
                if (std.ascii.eqlIgnoreCase(trimmed[0..3], month.name[0..3])) {
                    if (options.allow_short and trimmed.len == 3) {
                        return @enumFromInt(month.value);
                    }

                    if (options.allow_long and std.ascii.eqlIgnoreCase(trimmed[3..], month.name[3..])) {
                        return @enumFromInt(month.value);
                    }
                }
            }
        }

        if (options.allow_numeric) {
            const numeric = std.fmt.parseInt(u4, trimmed, 10) catch return error.InvalidFormat;
            if (numeric >= 1 and numeric <= 12) {
                return @enumFromInt(numeric);
            }
        }
        
        return error.InvalidFormat;
    }

    pub fn as_number(self: Month) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Month) u32 {
        return @intFromEnum(self);
    }

    pub fn days(self: Month, year: Year) u16 {
        const base = self.days_assume_non_leap_year();
        if (self == .february and year.is_leap()) return base + 1;
        return base;
    }

    pub fn days_from_yi(self: Month, yi: Year.Info) u16 {
        const base = self.days_assume_non_leap_year();
        if (self == .february and yi.is_leap) return base + 1;
        return base;
    }

    pub fn days_assume_non_leap_year(self: Month) u16 {
        if (self == .february) return 28;
        const month: u16 = @intCast(self.as_number());
        if (month < 8) {
            return 30 + (month & 1);
        } else {
            return 30 + ((month + 1) & 1);
        }
    }

    pub fn starting_date(self: Month, year: Year) Date {
        return Date.from_ymd(year, self, .first);
    }

    pub fn name(self: Month) []const u8 {
        return switch (self) {
            .january => "January",
            .february => "February",
            .march => "March",
            .april => "April",
            .may => "May",
            .june => "June",
            .july => "July",
            .august => "August",
            .september => "September",
            .october => "October",
            .november => "November",
            .december => "December",
        };
    }

    pub fn short_name(self: Month) []const u8 {
        return self.name()[0..3];
    }
};

test "Month" {
    try expectEqual(.january, try Month.from_string("Jan", .{}));
    try expectError(error.InvalidFormat, Month.from_string("Jan", .{ .allow_short = false }));
    try expectEqual(.february, try Month.from_string("february", .{}));
    try expectEqual(.february, try Month.from_string("february", .{ .allow_short = false }));
    try expectError(error.InvalidFormat, Month.from_string("febru", .{}));
    try expectEqual(.may, try Month.from_string("may", .{}));
    try expectEqual(.october, try Month.from_string("OCT", .{}));
    try expectEqual(.november, try Month.from_string("NOVembER", .{}));
    try expectEqual(.december, try Month.from_string(" 12 ", .{ .allow_short = false, .allow_long = false }));
    try expectEqual(.september, try Month.from_string("___9", .{ .allow_long = false }));
    try expectEqual(error.InvalidFormat, Month.from_string("___9", .{ .allow_numeric = false }));
    try expectError(error.InvalidFormat, Month.from_string("00", .{}));
    try expectError(error.InvalidFormat, Month.from_string("13", .{}));

    try expectEqual(31, Month.from_number(1).days_assume_non_leap_year());
    try expectEqual(28, Month.from_number(2).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(3).days_assume_non_leap_year());
    try expectEqual(30, Month.from_number(4).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(5).days_assume_non_leap_year());
    try expectEqual(30, Month.from_number(6).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(7).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(8).days_assume_non_leap_year());
    try expectEqual(30, Month.from_number(9).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(10).days_assume_non_leap_year());
    try expectEqual(30, Month.from_number(11).days_assume_non_leap_year());
    try expectEqual(31, Month.from_number(12).days_assume_non_leap_year());

    try expectEqual(31, Month.from_number(1).days(Year.from_number(2020)));
    try expectEqual(29, Month.from_number(2).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(3).days(Year.from_number(2020)));
    try expectEqual(30, Month.from_number(4).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(5).days(Year.from_number(2020)));
    try expectEqual(30, Month.from_number(6).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(7).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(8).days(Year.from_number(2020)));
    try expectEqual(30, Month.from_number(9).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(10).days(Year.from_number(2020)));
    try expectEqual(30, Month.from_number(11).days(Year.from_number(2020)));
    try expectEqual(31, Month.from_number(12).days(Year.from_number(2020)));
}

const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;

const Date = @import("date.zig").Date;
const Year = @import("year.zig").Year;
const formatting = @import("formatting.zig");
const std = @import("std");
