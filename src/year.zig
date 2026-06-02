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
        allow_two_digit_year: bool = false,
        allow_non_two_digit_year: bool = true,
        allow_era_suffix: bool = true,
    };
    pub fn from_string(y: []const u8, options: From_String_Options) !Year {
        var trimmed = if (options.trim.len > 0) std.mem.trim(u8, y, options.trim) else y;
        var is_bc = false;
        var is_ad = false;
        if (options.allow_era_suffix) {
            if (std.mem.endsWith(u8, y, "AD") or std.mem.endsWith(u8, y, "ad")) {
                is_ad = true;
                trimmed = trimmed[0 .. trimmed.len - 2];
                trimmed = if (options.trim.len > 0) std.mem.trim(u8, trimmed, options.trim) else trimmed;
            } else if (std.mem.endsWith(u8, y, "BC") or std.mem.endsWith(u8, y, "bc")) {
                is_bc = true;
                trimmed = trimmed[0 .. trimmed.len - 2];
                trimmed = if (options.trim.len > 0) std.mem.trim(u8, trimmed, options.trim) else trimmed;
            }
        }

        var numeric = std.fmt.parseInt(i32, trimmed, 10) catch return error.InvalidString;

        if (is_bc) {
            numeric = -numeric + 1;
        } else if (!is_ad and options.allow_two_digit_year and trimmed.len == 2) {
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

        return error.InvalidString;
    }

    pub fn is_leap(self: Year) bool {
        // based on isleap32_benjoffe from
        // https://github.com/benjoffe/fast-date-benchmarks/blob/main/benchmarks/leap_tests.cpp

        // 32-bit reciprocal of 100 (division-by-constant constant)
        // Value: 42,949,673
        const cen_mul: u32 = ((1 << 32) / 100) + 1;
  
        // Cutoff selected to isolate the `%100 == 0` remainder
        // after domain biasing and 32-bit wrap.
        // Value: 171,798,692
        const cen_cutoff: u32 = cen_mul * 4;
        
        // Signed => unsigned domain shift. A multiple of 100 near 2^31
        // so that `%100` residues remain aligned after bias.
        // Value: 2,147,483,600
        const cen_bias: u32 = cen_mul / 2 * 100;

        const y = self.as_number();
        const y_biased: u32 = @bitCast(y +% cen_bias);

        const low: u32 = y_biased *% cen_mul;
        return 0 == (y & @as(i32, if (low < cen_cutoff) 0xF else 0x3));
    }

    pub fn starting_date(self: Year) Date {
        return .from_year(self);
    }

    pub fn info(self: Year) Info {
        return .from_year(self);
    }

    pub fn dominical_letter(self: Year) Dominical_Letter {
        return .from_yi(self.info());
    }
    
    pub fn is_before(self: Year, other: Year) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Year, other: Year) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus(self: Year, delta_years: i32) Year {
        return .from_number(self.as_number() + delta_years);
    }

    pub fn next(self: Year) Year {
        return self.plus(1);
    }

    pub fn prev(self: Year) Year {
        return self.plus(-1);
    }

    pub const Info = struct {
        raw: i32,
        starting_date: Date,
        is_leap: bool,

        pub fn from_year(y: Year) Info {
            return .{
                .raw = y.as_number(),
                .starting_date = y.starting_date(),
                .is_leap = y.is_leap(),
            };
        }

        pub fn from_number(y: i32) Info {
            return .from_year(.from_number(y));
        }

        pub fn year(self: Info) Year {
            return .from_number(self.raw);
        }

        pub fn ending_date(self: Info) Date {
            return self.starting_date.plus_days(if (self.is_leap) 365 else 364);
        }

        pub fn ymd(self: Info, m: Month, d: Day) Date.YMD {
            return .{
                .year = self.year(),
                .month = m,
                .day = d,
            };
        }

        pub fn date_info(self: Info, m: Month, d: Day) Date.Info {
            return .from_yimd(self, m, d);
        }

        pub fn next(self: Info) Info {
            const next_year = self.raw + 1;
            var next_year_is_leap = false;
            var days_in_year: i32 = 365;
            if (self.is_leap) {
                days_in_year += 1;
            } else {
                next_year_is_leap = Year.from_number(next_year).is_leap();
            }
            return .{
                .raw = next_year,
                .starting_date = self.starting_date.plus_days(days_in_year),
                .is_leap = next_year_is_leap,
            };
        }

        pub fn prev(self: Info) Info {
            const prev_year = self.raw - 1;
            var prev_year_is_leap = false;
            var days_in_prev_year: i32 = 365;
            if (!self.is_leap) {
                prev_year_is_leap = Year.from_number(prev_year).is_leap();
                if (prev_year_is_leap) days_in_prev_year += 1;
            }
            return .{
                .raw = prev_year,
                .starting_date = self.starting_date.plus_days(-days_in_prev_year),
                .is_leap = prev_year_is_leap,
            };
        }
    };
    
    pub const Dominical_Letter = enum (u4) {
        a = Week_Day.sunday.as_unsigned(),
        b = Week_Day.saturday.as_unsigned(),
        c = Week_Day.friday.as_unsigned(),
        d = Week_Day.thursday.as_unsigned(),
        e = Week_Day.wednesday.as_unsigned(),
        f = Week_Day.tuesday.as_unsigned(),
        g = Week_Day.monday.as_unsigned(),

        ag = Week_Day.sunday.as_unsigned() | leap_marker,
        ba = Week_Day.saturday.as_unsigned() | leap_marker,
        cb = Week_Day.friday.as_unsigned() | leap_marker,
        dc = Week_Day.thursday.as_unsigned() | leap_marker,
        ed = Week_Day.wednesday.as_unsigned() | leap_marker,
        fe = Week_Day.tuesday.as_unsigned() | leap_marker,
        gf = Week_Day.monday.as_unsigned() | leap_marker,

        const leap_marker: u4 = 0x8;

        pub fn from_yi(yi: Info) Dominical_Letter {
            var raw: u32 = yi.starting_date.week_day().as_unsigned();
            if (yi.is_leap) raw |= leap_marker;
            return @enumFromInt(raw);
        }

        pub fn from_number(y: i32) Dominical_Letter {
            return @enumFromInt(y);
        }

        pub fn as_number(self: Dominical_Letter) i32 {
            return @intFromEnum(self);
        }
        pub fn as_unsigned(self: Dominical_Letter) u32 {
            return @intCast(@intFromEnum(self));
        }

        pub fn is_leap_year(self: Dominical_Letter) bool {
            return (self.as_unsigned & leap_marker) != 0;
        }
    };
};

const Month = @import("month.zig").Month;
const Day = @import("day.zig").Day;
const Week_Day = @import("week_day.zig").Week_Day;
const Date = @import("date.zig").Date;
const formatting = @import("formatting.zig");
const std = @import("std");
