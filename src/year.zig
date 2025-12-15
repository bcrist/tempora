pub const Year = enum (i32) {
    epoch = Date.epoch_year,
    _,

    pub fn from_number(y: i32) Year {
        return @enumFromInt(y);
    }

    pub fn as_number(self: Year) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Year) u32 {
        return @intCast(@intFromEnum(self));
    }

    pub const From_String_Options = struct {
        trim: []const u8 = formatting.default_from_string_trim,
        allow_two_digit_year: bool = true,
        allow_non_two_digit_year: bool = true,
    };
    pub fn from_string(y: []const u8, options: From_String_Options) !Year {
        const trimmed = if (options.trim.len > 0) std.mem.trim(u8, y, options.trim) else y;
        var numeric = std.fmt.parseInt(i32, trimmed, 10) catch return error.InvalidPattern;

        if (options.allow_two_digit_year and trimmed.len == 2) {
            if (numeric < 50) {
                numeric += 2000;
            } else {
                numeric += 1900;
            }
            return from_number(numeric);
        }
        
        if (options.allow_non_two_digit_year) {
            return from_number(numeric);
        }

        return error.InvalidPattern;
    }

    pub fn is_leap(self: Year) bool {
        const y = self.as_number();
        if ((y & 3) != 0) return false;
        switch (@mod(y, 400)) {
            100, 200, 300 => return false,
            else => {},
        }
        return true;
    }

    pub fn starting_date(self: Year) Date {
        return .from_year(self);
    }

    pub const Info = Year_Info;
    pub fn info(self: Year) Info {
        return .{
            .year = self.as_number(),
            .starting_date = self.starting_date(),
            .is_leap = self.is_leap(),
        };
    }
};
pub const Year_Info = struct {
    year: i32,
    starting_date: Date,
    is_leap: bool,
};

test "Year" {
    try expectEqual(2000, Year.epoch.as_number());
    try expectEqual(2000, Year.from_number(2000).as_number());
    try expectEqual(2020, Year.from_number(2020).as_number());
    try expectEqual(1999, Year.from_number(1999).as_number());
    try expectEqual(1970, Year.from_number(1970).as_number());
    try expectEqual(Year.from_number(2024), try Year.from_string("2024", .{}));
    try expectError(error.InvalidPattern, Year.from_string("2024", .{ .allow_non_two_digit_year = false }));
    try expectEqual(Year.from_number(2024), try Year.from_string("'24", .{}));
    try expectEqual(Year.from_number(24), try Year.from_string("'24", .{ .allow_two_digit_year = false }));
    try expectEqual(Year.from_number(1969), try Year.from_string("69", .{}));
    try expectEqual(Year.from_number(123), try Year.from_string("123", .{}));
    try expectEqual(Year.from_number(4), try Year.from_string(" 4 ", .{}));
    try expectError(error.InvalidPattern, Year.from_string("'24", .{ .allow_two_digit_year = false, .allow_non_two_digit_year = false }));

    try expect(Year.from_number(2000).is_leap());
    try expect(!Year.from_number(2001).is_leap());
    try expect(!Year.from_number(2002).is_leap());
    try expect(!Year.from_number(2003).is_leap());

    try expect(Year.from_number(1996).is_leap());
    try expect(!Year.from_number(1997).is_leap());
    try expect(!Year.from_number(1998).is_leap());
    try expect(!Year.from_number(1999).is_leap());

    try expect(!Year.from_number(1900).is_leap());
    try expect(!Year.from_number(1901).is_leap());
    try expect(!Year.from_number(1902).is_leap());
    try expect(!Year.from_number(1903).is_leap());
    try expect(Year.from_number(1904).is_leap());

    try expect(Year.from_number(2016).is_leap());
    try expect(Year.from_number(2020).is_leap());
    try expect(Year.from_number(2024).is_leap());
    try expect(!Year.from_number(2017).is_leap());
    try expect(!Year.from_number(2018).is_leap());
    try expect(!Year.from_number(2019).is_leap());
    try expect(!Year.from_number(2021).is_leap());
    try expect(!Year.from_number(2022).is_leap());
    try expect(!Year.from_number(2023).is_leap());
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectError = std.testing.expectError;

const Date = @import("date.zig").Date;
const formatting = @import("formatting.zig");
const std = @import("std");
