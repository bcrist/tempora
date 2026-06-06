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
            inline for (info.field_names, info.field_values) |field_name, field_value| {
                if (trimmed[0] | 0x20 == field_name[0]) {
                    const day: Week_Day = @enumFromInt(field_value);
                    if (switch (trimmed.len) {
                        1 => options.allow_short and day == .monday or day == .wednesday or day == .friday,
                        2 => options.allow_short and trimmed[1] | 0x20 == field_name[1],
                        3 => options.allow_short and trimmed[1] | 0x20 == field_name[1] and trimmed[2] | 0x20 == field_name[2],
                        4 => options.allow_short and day == .tuesday and std.ascii.eqlIgnoreCase(trimmed, "tues"),
                        5 => options.allow_short and day == .thursday and std.ascii.eqlIgnoreCase(trimmed, "thurs"),
                        else => options.allow_long and std.ascii.eqlIgnoreCase(trimmed, field_name),
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

const Date = @import("date.zig").Date;
const formatting = @import("formatting.zig");
const std = @import("std");
