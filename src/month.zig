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
            const info = @typeInfo(Month).@"enum";
            inline for (info.field_names, info.field_values) |month_name, month_value| {
                if (std.ascii.eqlIgnoreCase(trimmed[0..3], month_name[0..3])) {
                    if (options.allow_short and trimmed.len == 3) {
                        return @enumFromInt(month_value);
                    }

                    if (options.allow_long and std.ascii.eqlIgnoreCase(trimmed[3..], month_name[3..])) {
                        return @enumFromInt(month_value);
                    }
                }
            }
        }

        if (options.allow_numeric) {
            const numeric = std.fmt.parseInt(u4, trimmed, 10) catch return error.InvalidString;
            if (numeric >= 1 and numeric <= 12) {
                return @enumFromInt(numeric);
            }
        }
        
        return error.InvalidString;
    }

    pub fn as_number(self: Month) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: Month) u32 {
        return @intFromEnum(self);
    }

    pub fn from_yod(y: Year, od: Ordinal_Day) Month {
        return .from_od(od, y.is_leap());
    }

    pub fn from_yiod(yi: Year.Info, od: Ordinal_Day) Month {
        return .from_od(od, yi.is_leap);
    }

    pub fn from_od(od: Ordinal_Day, is_leap_year: bool) Month {
        const noleap_od = Ordinal_Day.from_md_assume_non_leap_year;
        var mut_od: Ordinal_Day = od;

        if (mut_od.is_before(comptime noleap_od(.march, .first))) {
            if (mut_od.is_before(comptime noleap_od(.february, .first))) {
                return .january;
            } else {
                return .february;
            }
        } else {
            if (is_leap_year) {
                if (mut_od == comptime noleap_od(.march, .first)) {
                    return .february;
                } else {
                    mut_od = Ordinal_Day.from_number(mut_od.as_number() - 1);
                }
            }

            if (mut_od.is_before(comptime noleap_od(.june, .first))) {
                if (mut_od.is_before(comptime noleap_od(.april, .first))) {
                    return .march;
                } else if (mut_od.is_before(comptime noleap_od(.may, .first))) {
                    return .april;
                } else {
                    return .may;
                }
            } else if (mut_od.is_before(comptime noleap_od(.september, .first))) {
                if (mut_od.is_before(comptime noleap_od(.july, .first))) {
                    return .june;
                } else if (mut_od.is_before(comptime noleap_od(.august, .first))) {
                    return .july;
                } else {
                    return .august;
                }
            } else if (mut_od.is_before(comptime noleap_od(.november, .first))) {
                if (mut_od.is_before(comptime noleap_od(.october, .first))) {
                    return .september;
                } else {
                    return .october;
                }
            } else if (mut_od.is_before(comptime noleap_od(.december, .first))) {
                return .november;
            } else {
                return .december;
            }
        }
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

    pub fn days_assume_leap_year(self: Month) u16 {
        if (self == .february) return 29;
        const month: u16 = @intCast(self.as_number());
        if (month < 8) {
            return 30 + (month & 1);
        } else {
            return 30 + ((month + 1) & 1);
        }
    }

    pub fn starting_ordinal_day(self: Month, year: Year) Ordinal_Day {
        var result = self.starting_ordinal_day_assume_non_leap_year();
        switch (self) {
            .january, .february => {},
            else => {
                if (year.is_leap()) result = .from_number(result.as_number() + 1);
            }
        }
        return result;
    }

    pub fn starting_ordinal_day_assume_non_leap_year(self: Month) Ordinal_Day {
        switch (self) {
            inline else => |final_month| {
                comptime var raw: u16 = 1;
                inline for (1..@intFromEnum(final_month)) |m| {
                    raw += comptime days_assume_non_leap_year(.from_number(m));
                }
                return .from_number(raw);
            },
        }
    }

    pub fn starting_ordinal_day_assume_leap_year(self: Month) Ordinal_Day {
        switch (self) {
            inline else => |final_month| {
                comptime var raw: u16 = 1;
                inline for (1..@intFromEnum(final_month)) |m| {
                    raw += comptime days_assume_leap_year(.from_number(m));
                }
                return .from_number(raw);
            },
        }
    }

    pub fn starting_date(self: Month, year: Year) Date {
        return Date.from_ymd(.init(year, self, .first));
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

    pub fn is_before(self: Month, other: Month) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Month, other: Month) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus(self: Month, months: i32) Month {
        return .from_number(@mod(self.as_number() + months - 1, 12) + 1);
    }

    pub fn prev(self: Month) Month {
        return self.plus(-1);
    }

    pub fn next(self: Month) Month {
        return self.plus(1);
    }
};

const Date = @import("date.zig").Date;
const Year = @import("year.zig").Year;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const formatting = @import("formatting.zig");
const std = @import("std");
