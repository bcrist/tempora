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

        if (options.allow_short and trimmed.len >= 2 or options.allow_long and trimmed.len >= 3) {
            inline for (std.meta.fields(Week_Day)) |day| {
                if (std.ascii.eqlIgnoreCase(trimmed[0..2], day.name[0..2])) {
                    if (options.allow_short) {
                        if (trimmed.len == 2) {
                            return @enumFromInt(day.value);
                        } else if (trimmed.len == 3 and trimmed[2] == day.name[2]) {
                            return @enumFromInt(day.value);
                        }
                    }

                    if (options.allow_long and std.ascii.eqlIgnoreCase(trimmed[2..], day.name[2..])) {
                        return @enumFromInt(day.value);
                    }
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
};

test "Week_Day" {
    try expectEqual(.monday, try Week_Day.from_string("Mon", .{}));
    try expectError(error.InvalidString, Week_Day.from_string("Tues", .{}));
    try expectEqual(.wednesday, try Week_Day.from_string("wednesday", .{}));
    try expectError(error.InvalidString, Week_Day.from_string("7", .{}));
    try expectEqual(.saturday, try Week_Day.from_string("7", .{ .allow_numeric = true }));
}

const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;

const formatting = @import("formatting.zig");
const std = @import("std");
