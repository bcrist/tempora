pub const Date = enum (i32) {
    epoch = 0,
    _,

    pub const epoch_year = 2000;

    pub fn from_ymd(d: YMD) Date {
        var years: u32 = @intCast(d.year.as_number() + 14700 * 400);
        var month_days_temp: u32 = 979 * d.month.as_unsigned();
        if (d.month.as_number() <= 2) {
            years -= 1;
            month_days_temp += 8829;
        } else {
            month_days_temp -= 2919;
        }
        const month_days: u32 = month_days_temp / 32;
        const centuries: u32 = years / 100;
        const year_days: u33 = @as(u33, years * 365) + years / 4 - centuries + centuries / 4;
        var days: i34 = year_days + month_days + d.day.as_unsigned();
        days -= 14700 * days_per_era + epoch_days_since_0000_02_29;
        return @enumFromInt(days);
    }

    pub fn from_yod(y: Year, od: Ordinal_Day) Date {
        const raw = @intFromEnum(y.starting_date()) + od.as_number() - 1;
        return @enumFromInt(raw);
    }

    pub fn from_yiod(yi: Year.Info, od: Ordinal_Day) Date {
        const raw = @intFromEnum(yi.starting_date) + od.as_number() - 1;
        return @enumFromInt(raw);
    }

    pub fn from_ywd(y: Year, week: ISO_Week, weekday: Week_Day) Date {
        const starting_date = y.starting_date();
        var offset = week.as_number() * 7;
        offset += weekday.as_iso();
        offset -= starting_date.plus_days(3).week_day().as_iso();
        return starting_date.plus_days(offset - 4);
    }

    pub fn from_yiwd(yi: Year.Info, week: ISO_Week, weekday: Week_Day) Date {
        var offset = week.as_number() * 7;
        offset += weekday.as_iso();
        offset -= yi.starting_date.plus_days(3).week_day().as_iso();
        return yi.starting_date.plus_days(offset - 4);
    }

    /// Returns the date corresponding to January 1 of the specified year
    pub fn from_year(y: Year) Date {
        const years: u32 = @intCast(y.as_number() + 14700 * 400 - 1);
        const centuries: u32 = years / 100;
        var days: i34 = @as(u33, years * 365) + years / 4 - centuries + centuries / 4 + 307;
        days -= 14700 * days_per_era + epoch_days_since_0000_02_29;
        return @enumFromInt(days);

        // TODO verify that the above is faster than the old impl:
        // const year_offset = @intFromEnum(self) - Date.epoch_year;
        // var leap_years: i32 = 0;
        // if (year_offset < 0) {
        //     const century_offset: i32 = @divTrunc(year_offset, 100);
        //     leap_years = ((year_offset + 3) >> 2) - century_offset + ((century_offset + 3) >> 2);
        // } else if (year_offset > 0) {
        //     // If 'year' is a leap year, the leap day doesn't happen until february, which is after
        //     // the start of the year.  So we won't actually "pass" it until the next year.  To account
        //     // for this we can just subtract 1 from the year offset when it's positive and add 1 to
        //     // leap_years, since epoch_year is a leap year.
        //     const modified_year_offset: i32 = year_offset - 1;
        //     const century_offset: i32 = @divTrunc(modified_year_offset, 100);
        //     leap_years = (modified_year_offset >> 2) - century_offset + (century_offset >> 2) + 1;
        // }
        // return @enumFromInt(year_offset * 365 + leap_years);
    }

    pub fn year(self: Date) Year {
        return civil.days_to_year(@intFromEnum(self));
    }

    pub fn year_info(self: Date) Year.Info {
        return self.year().info();
    }

    pub fn month(self: Date) Month {
        return self.ymd().month;
    }

    pub fn day(self: Date) Day {
        return self.ymd().day;
    }

    pub fn ordinal_day(self: Date) Ordinal_Day {
        return .from_number(@intFromEnum(self) - @intFromEnum(self.year().starting_date()) + 1);
    }

    pub fn ordinal_week(self: Date) Ordinal_Week {
        return .from_od(self.ordinal_day());
    }

    pub fn week_day(self: Date) Week_Day {
        // epoch (2000-01-01) was a saturday (7).

        var raw: i32 = @intFromEnum(self);
        if (raw < 0) raw += 7; // prevent underflow for std.math.minInt(i32)
        raw = @mod(raw - 1, 7) + 1;

        return Week_Day.from_number(raw);
    }

    pub fn iso_week(self: Date) ISO_Week {
        return self.iso_week_date().week;
    }

    pub fn iso_week_date(self: Date) ISO_Week_Date {
        return .from_date(self);
    }

    pub const Info = Date_Info;
    pub fn info(self: Date) Info {
        const raw = @intFromEnum(self);
        const weekday = self.week_day();
        const c = self.ymd();
        const start_of_year = c.year.starting_date();
        return .{
            .raw = raw,
            .year = c.year,
            .month = c.month,
            .day = c.day,
            .start_of_year = start_of_year,
            .is_leap_year = c.year.is_leap(),
            .week_day = weekday,
            .ordinal_day = .from_number(@intFromEnum(self) - @intFromEnum(start_of_year) + 1),
            .start_of_month = @enumFromInt(raw - c.day.as_number() + 1),
            .start_of_week = @enumFromInt(raw - weekday.as_number() + 1),
        };
    }

    pub const YMD = struct {
        year: Year,
        month: Month,
        day: Day,

        pub fn from_numbers(y: i32, m: i32, d: i32) YMD {
            return .{
                .year = .from_number(y),
                .month = .from_number(m),
                .day = .from_number(d),
            };
        }

        pub fn from_date(d: Date) YMD {
            return civil.days_to_ymd(@intFromEnum(d));
        }

        pub fn date(self: YMD) Date {
            return .from_ymd(self);
        }
    };
    pub fn ymd(self: Date) YMD {
        return .from_date(self);
    }

    pub fn is_before(self: Date, other: Date) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }

    pub fn is_after(self: Date, other: Date) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }

    pub fn plus_days(self: Date, days: i32) Date {
        return @enumFromInt(@intFromEnum(self) + days);
    }

    pub fn advance_to_week_day(self: Date, d: Week_Day) Date {
        const current: i32 = self.week_day().as_number();
        const target: i32 = d.as_number();

        if (current < target) {
            return self.plus_days(target - current);
        } else {
            return self.plus_days(7 + target - current);
        }
    }

    pub fn advance_to_day(self: Date, d: Day) Date {
        const di = self.info();

        const current = di.day.as_number();
        const target = d.as_number();

        if (current < target) {
            return self.plus_days(target - current);
        } else {
            var y = di.year;
            const m = switch (di.month) {
                .december => blk: {
                    y = Year.from_number(y.as_number() + 1);
                    break :blk .january;
                },
                else => Month.from_number(di.month.as_number() + 1),
            };
            return Date.from_ymd(.{ .year = y, .month = m, .day = d });
        }
    }

    pub fn advance_to_month_and_day(self: Date, m: Month, d: Day) Date {
        const di = self.info();

        const current = di.ordinal_day.as_number();
        const target = Ordinal_Day.from_ymd(.{ .year = di.year, .month = m, .day = d }).as_number();

        if (current < target) {
            return self.plus_days(target - current);
        } else {
            const y = Year.from_number(di.year.as_number() + 1);
            return Date.from_ymd(.{ .year = y, .month = m, .day = d });
        }
    }

    pub fn with_time(self: Date, time: Time) Date_Time {
        return .{
            .date = self,
            .time = time,
        };
    }

    pub const iso8601 = "YYYY-MM-DD";
    pub const rfc2822 = "ddd, DD MMM YYYY"; 
    pub const us = "MMMM D, Y";
    pub const us_numeric = "M/D/Y";
    pub const uk = "D MMMM Y";
    pub const uk_numeric = "D/M/Y";

    pub fn format(self: Date, writer: *std.io.Writer) !void {
        try formatting.format(self.with_time(.midnight).with_offset(0), iso8601, writer);
    }

    pub fn fmt(self: Date, comptime pattern: []const u8) Formatter(pattern) {
        return .{ .date = self };
    }

    pub fn Formatter(comptime pattern: []const u8) type {
        return struct {
            date: Date,
            pub inline fn format(self: @This(), writer: *std.io.Writer) !void {
                try formatting.format(self.date.with_time(.midnight).with_offset(0), pattern, writer);
            }
        };
    }

    pub fn from_string(comptime pattern: []const u8, str: []const u8) !Date {
        var reader = std.io.Reader.fixed(str);
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
            error.TzdbCacheNotInitialized => return err,
        };

        const PI = @TypeOf(pi);

        if (@FieldType(PI, "timestamp") != void) {
            return Date_Time.With_Offset.from_timestamp_ms(pi.timestamp, null).dt.date;
        }

        if (@FieldType(PI, "year") != void) {
            if (@FieldType(PI, "ordinal_day") != void) {
                return Date.from_yod(pi.year, pi.ordinal_day);
            }
            
            if (@FieldType(PI, "ordinal_week") != void) {
                var date = Date.from_yod(pi.year, pi.ordinal_week.starting_day());
                if (@FieldType(PI, "week_day") != void) {
                    date = date.advance_to_week_day(pi.week_day);
                }
                return date;
            }
            
            if (@FieldType(PI, "month") != void) {
                return Date.from_ymd(.{
                    .year = pi.year,
                    .month = pi.month,
                    .day = if (@FieldType(PI, "day") != void) pi.day else 1,
                });
            }

            return Date.from_yod(pi.year, .first);
        }

        if (@FieldType(PI, "iso_week_year") != void) {
            var iwd: ISO_Week_Date = .{
                .year = pi.iso_week_year,
                .week = .first,
                .day = .monday,
            };

            if (@FieldType(PI, "iso_week") != void) iwd.week = pi.iso_week;
            if (@FieldType(PI, "week_day") != void) iwd.day = pi.week_day;

            return iwd.date();
        }

        @compileError("Invalid pattern: " ++ pattern);
    }

    const civil = if (@sizeOf(usize) < 8) civil32 else civil64;
};
pub const Date_Info = struct {
    raw: i32,
    start_of_year: Date,
    start_of_month: Date,
    start_of_week: Date,
    is_leap_year: bool,
    year: Year,
    month: Month,
    day: Day,
    week_day: Week_Day,
    ordinal_day: Ordinal_Day,

    pub fn year_info(self: Date_Info) Year.Info {
        return .{
            .year = self.year.as_number(),
            .starting_date = self.start_of_year,
            .is_leap = self.is_leap_year,
        };
    }

    pub fn ymd(self: Date_Info) Date.YMD {
        return .{
            .year = self.year,
            .month = self.month,
            .day = self.day,
        };
    }

    pub fn date(self: Date_Info) Date {
        return @enumFromInt(self.raw);
    }

    pub fn iso_week_date(self: Date_Info) ISO_Week_Date {
        return .from_yiodwd(self.year_info(), self.ordinal_day, self.week_day);
    }
};

const days_per_era = 400 * 365 + 97;
const epoch_days_since_0000_02_29 = 730426;

const civil64 = struct {
    // Date conversion for 64-bit targets
    // based on https://github.com/benjoffe/fast-date-benchmarks/blob/main/algorithms/benjoffe_fast64.hpp
    // Modified for 2000-01-01 epoch instead of 1970-01-01

    const eras = 14705;
    const d_shift: i64 = eras * days_per_era - epoch_days_since_0000_02_29;
    const y_shift: i64 = 400 * eras - 1;

    const scale = switch (builtin.cpu.arch) {
        .aarch64, .aarch64_be => 1,
        else => 32,
    };

    const shift_0: u32 = 30556 * scale;
    const shift_1: u32 = 5980 * scale;

    const c1: u128 = 505054698555331; // floor(2^64*4/146097)
    const c2: u128 = 50504432782230121; // ceil(2^64*4/1461)
    const c3: u128 = 8619973866219416 * 32 / scale; // floor(2^64/2140);
    const c4: u128 = 24451 * scale;

    pub fn days_to_year(days: i32) Year {
        // 1. Adjust for 100/400 leap year rule
        const reverse_days: u64 = @intCast(d_shift - days);
        const centuries: u64 = @intCast((reverse_days * c1) >> 64); // divide by 36524.25
        const reverse_julian: u64 = reverse_days - centuries / 4 + centuries;

        // 2. Determine year and year-part
        const reverse_years_fixedpoint: u128 = reverse_julian * c2; // divide by 365.25
        const reverse_years: u32 = @intCast(reverse_years_fixedpoint >> 64);
        const years: i32 = @intCast(y_shift - reverse_years);
        const low: u64 = @truncate(reverse_years_fixedpoint);
        const year_part: u32 = @intCast((c4 * low) >> 64);

        // Overflow year when Jan or Feb:
        return .from_number(if (year_part < 3952 * scale) years + 1 else years);
    }

    pub fn days_to_ymd(days: i32) Date.YMD {
        // 1. Adjust for 100/400 leap year rule
        const reverse_days: u64 = @intCast(d_shift - days);
        const centuries: u64 = @intCast((reverse_days * c1) >> 64); // divide by 36524.25
        const reverse_julian: u64 = reverse_days - centuries / 4 + centuries;

        // 2. Determine year and year-part
        const reverse_years_fixedpoint: u128 = reverse_julian * c2; // divide by 365.25
        const reverse_years: u32 = @intCast(reverse_years_fixedpoint >> 64);
        const years: i32 = @intCast(y_shift - reverse_years);
        const low: u64 = @truncate(reverse_years_fixedpoint);
        const year_part: u32 = @intCast((c4 * low) >> 64);

        var bump: bool = undefined;
        const shift: u32 = if (scale == 1) shift_0 else shift: {
            bump = year_part < 3952 * scale;
            break :shift if (bump) shift_1 else shift_0;
        };

        // 3. Year-modulo-bitshift for leap years, also revert to forward direction.
        const mod: u32 = @intCast(@mod(years, 4));
        const n: u32 = mod * (16 * scale) + shift - year_part;
        const raw_month: u32 = n / (2048 * scale);
        const raw_day: i32 = @intCast((c3 * (n % (2048 * scale))) >> 64);

        return .{
            .year = .from_number(if (bump) years + 1 else years),
            .month = .from_number(@intCast(if (scale == 1) month: {
                bump = raw_month > 12;
                break :month if (bump) raw_month - 12 else raw_month;
            } else raw_month)),
            .day = .from_number (raw_day + 1),
        };
    }
};

const civil32 = struct {
    // Date conversion for 32-bit targets
    // based on https://github.com/benjoffe/fast-date-benchmarks/blobmain/algorithms/benjoffe_article_2.hpp
    // Modified for 2000-01-01 epoch instead of 1970-01-01

    const k: u32 = (719162 + 306 - 3845 - days_per_era * 4) * 4 + 3;
    const l: i32 = 14695 * 400;

    pub fn days_to_year(days: i32) Year {
        const d0_33: u33 = @bitCast(@as(i33, days) + 0x8000_0000);
        const d0: u32 = @truncate(d0_33);
        const bucket: u32 = d0 >> 20;
        const era_days: u32 = d0 - (7 * days_per_era) * bucket + 10957;
        const qds: u32 = era_days * 4 + k;
        const cen: u32 = qds / days_per_era;
        const jul: u32 = qds - (cen & ~@as(u32, 3)) + cen * 4;
        const yrs: u32 = jul / 1461;
        const rem: u32 = jul % 1461 / 4;

        var year: i32 = @intCast(yrs + bucket * (7 * 400));
        if (rem >= 306) year += 1;
        year -= l;

        return .from_number(year);
    }

    pub fn days_to_ymd(days: i32) Date.YMD {
        const d0_33: u33 = @bitCast(@as(i33, days) + 0x8000_0000);
        const d0: u32 = @truncate(d0_33);
        const bucket: u32 = d0 >> 20;
        const era_days: u32 = d0 - (7 * days_per_era) * bucket + 10957;
        const qds: u32 = era_days * 4 + k;
        const cen: u32 = qds / days_per_era;
        const jul: u32 = qds - (cen & ~@as(u32, 3)) + cen * 4;
        const yrs: u32 = jul / 1461;
        const rem: u32 = jul % 1461 / 4;

        // Neri-Schneider technique for Day & Month:
        const n: u32 = rem * 2141 + 197913;
        const m: u32 = n / 65536;
        const d: u32 = n % 65536 / 2141;

        const bump: u1 = @intFromBool(rem >= 306);
        const day: u32 = d + 1;
        const month: u32 = if (bump != 0) m - 12 else m;
        var year: i32 = @intCast(yrs + bucket * (7 * 400) + bump);
        year -= l;

        return .{
            .year = .from_number(year),
            .month = .from_number(@intCast(month)),
            .day = .from_number(@intCast(day)),
        };
    }
};

test "Date" {
    const date1 = Date.from_ymd(.from_numbers(2024, 2, 1));
    const date2 = Date.from_ymd(.from_numbers(1928, 12, 24));
    const date3 = Date.from_ymd(.from_numbers(0, 12, 24));
    const date4 = Date.from_ymd(.from_numbers(12, 12, 24));
    const date5 = Date.from_ymd(.from_numbers(-123, 12, 24));
    const date6 = Date.from_ymd(.from_numbers(1970, 1, 1));

    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1.fmt("YYYY-MM-DD") });
    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1 });
    try std.testing.expectFmt("2 2nd Feb February", "{f}", .{ date1.fmt("M Mo MMM MMMM") });
    try std.testing.expectFmt("1.1st", "{f}", .{ date1.fmt("Q.Qo") });
    try std.testing.expectFmt("24 Do 24th", "{f}", .{ date2.fmt("D [Do] Do") });
    try std.testing.expectFmt("359 359th 359", "{f}", .{ date2.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("32 32nd 032", "{f}", .{ date1.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("4 4th Th Thu Thursday", "{f}", .{ date1.fmt("d do dd ddd dddd") });
    try std.testing.expectFmt("4 4th", "{f}", .{ date1.fmt("E Eo") });
    try std.testing.expectFmt("52 52nd 52", "{f}", .{ date2.fmt("w wo ww") });
    try std.testing.expectFmt("2024 24 2024 2024 +002024", "{f}", .{ date1.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("1928 28 1928 1928 +001928", "{f}", .{ date2.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("0 00 0 0000 000000", "{f}", .{ date3.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("12 12 12 0012 +000012", "{f}", .{ date4.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("-123 23 -123 0123 -000123", "{f}", .{ date5.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("AD AD", "{f}", .{ date1.fmt("N NN") });

    try std.testing.expectFmt("0 0th Su Sun Sunday", "{f}", .{ date3.fmt("d do dd ddd dddd") });
    try std.testing.expectFmt("7 7th", "{f}", .{ date3.fmt("E Eo") });

    try std.testing.expectFmt("2000", "{f}", .{ @as(Date, @enumFromInt(0)).fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Year.from_number(2000).starting_date().fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Date.from_yod(Year.from_number(2000), .first).fmt("Y") });
    try std.testing.expectFmt("2020", "{f}", .{ Date.from_yod(Year.from_number(2020), .first).fmt("Y") });
    try std.testing.expectFmt("1999", "{f}", .{ Date.from_yod(Year.from_number(1999), .first).fmt("Y") });

    try std.testing.expectEqual(date1, try Date.from_string("YYYY-MM-DD", "2024-02-01"));
    try std.testing.expectEqual(date1, try Date.from_string("Y DDDo", "2024 32nd"));
    try std.testing.expectEqual(date1, try Date.from_string("Y MMM D", "+002024 feb 1"));
    try std.testing.expectEqual(date6, try Date.from_string("YY", "70"));
    try std.testing.expectEqual(date6, (try Date.from_string("YYYY-MM-DD", "1969-12-31")).plus_days(1));
    try std.testing.expectEqual(date6, try Date.from_string("x", "0"));
    try std.testing.expectEqual(date6, try Date.from_string("X", "0"));

    try std.testing.expectEqual(53, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week().as_number());
    try std.testing.expectEqual(6, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().day.as_iso());
    try std.testing.expectEqual(2004, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().year.as_number());
    try std.testing.expectFmt("2005-01-01", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().fmt("YYYY-MM-DD") });
    try std.testing.expectFmt("2004-W53-6", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().fmt("GGGG-[W]WW-E") });
    try std.testing.expectFmt("2004-W53-7", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2005-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 3)).iso_week_date() });
    try std.testing.expectFmt("2005-W52-6", "{f}", .{ Date.from_ymd(.from_numbers(2005, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2005-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2006, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2006-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2006, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2006-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2006, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2007-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2007, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2007-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2007, 12, 30)).iso_week_date() });
    try std.testing.expectFmt("2008-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2007, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2008-W01-2", "{f}", .{ Date.from_ymd(.from_numbers(2008, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2008-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 28)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 29)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-2", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 30)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-3", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-4", "{f}", .{ Date.from_ymd(.from_numbers(2009, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-4", "{f}", .{ Date.from_ymd(.from_numbers(2009, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-5", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-6", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-7", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 3)).iso_week_date() });

    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-6"), Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-7"), Date.from_ymd(.from_numbers(2005, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W01-1"), Date.from_ymd(.from_numbers(2005, 1, 3)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-6"), Date.from_ymd(.from_numbers(2005, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-7"), Date.from_ymd(.from_numbers(2006, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W01-1"), Date.from_ymd(.from_numbers(2006, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W52-7"), Date.from_ymd(.from_numbers(2006, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W01-1"), Date.from_ymd(.from_numbers(2007, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W52-7"), Date.from_ymd(.from_numbers(2007, 12, 30)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-1"), Date.from_ymd(.from_numbers(2007, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-2"), Date.from_ymd(.from_numbers(2008, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W52-7"), Date.from_ymd(.from_numbers(2008, 12, 28)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-1"), Date.from_ymd(.from_numbers(2008, 12, 29)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-2"), Date.from_ymd(.from_numbers(2008, 12, 30)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-3"), Date.from_ymd(.from_numbers(2008, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-4"), Date.from_ymd(.from_numbers(2009, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-4"), Date.from_ymd(.from_numbers(2009, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-5"), Date.from_ymd(.from_numbers(2010, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-6"), Date.from_ymd(.from_numbers(2010, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-7"), Date.from_ymd(.from_numbers(2010, 1, 3)).iso_week_date());

    try std.testing.expectEqual(date1, try Date.from_string("G W E", "2024 5 4"));
    try std.testing.expectEqual(date2, try Date.from_string("G W E", "1928 52 1"));
    try std.testing.expectEqual(date6, try Date.from_string("G W E", "1970 1 4"));
    try std.testing.expectEqual(date6.plus_days(-1), try Date.from_string("G W E", "1970 1 3"));

    var d = Date.from_ymd(.{ .year = .from_number(2000), .month = .january, .day = .first });
    try std.testing.expectEqual(.first, d.ordinal_day());
    try std.testing.expectEqual(d, (try Date.from_string("YYYY-MM-DD", "1999-12-31")).plus_days(1));
    try std.testing.expect(!d.is_after(d));
    try std.testing.expect(!d.is_before(d));
    try std.testing.expect(d.is_after(try Date.from_string("YYYY-MM-DD", "1999-12-31")));
    try std.testing.expect(d.is_before(try Date.from_string("YYYY-MM-DD", "2000-01-02")));

    d = d.advance_to_day(Day.from_number(14));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-14"));
    d = d.advance_to_day(Day.from_number(14));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-14"));
    d = d.advance_to_day(Day.from_number(13));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-03-13"));
    d = d.advance_to_day(Day.from_number(14));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-03-14"));

    try std.testing.expectEqual(.tuesday, d.week_day());
    d = d.advance_to_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-03-17"));
    d = d.advance_to_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-03-24"));

    d = d.advance_to_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-10-18"));
    d = d.advance_to_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2001-10-18"));
    d = d.advance_to_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2002-09-18"));
}

test "gregorian civil date conversion" {
    try check_civil_conversion(2000, 1, 1, .epoch);

    try check_civil_conversion(0, 1, 1, @enumFromInt(-730_485));
    try check_civil_conversion(0, 1, 2, @enumFromInt(-730_484));
    try check_civil_conversion(175, 1, 22, @enumFromInt(-666_546));
    try check_civil_conversion(238, 5, 4, @enumFromInt(-643_434));
    try check_civil_conversion(477, 10, 30, @enumFromInt(-555_961));
    try check_civil_conversion(526, 3, 5, @enumFromInt(-538_304));
    try check_civil_conversion(527, 4, 28, @enumFromInt(-537_885));
    try check_civil_conversion(533, 5, 8, @enumFromInt(-535_683));
    try check_civil_conversion(609, 12, 22, @enumFromInt(-507_697));
    try check_civil_conversion(637, 9, 17, @enumFromInt(-497_566));
    try check_civil_conversion(734, 1, 25, @enumFromInt(-462_373));
    try check_civil_conversion(781, 9, 4, @enumFromInt(-444_984));
    try check_civil_conversion(785, 2, 27, @enumFromInt(-443_712));
    try check_civil_conversion(785, 2, 28, @enumFromInt(-443_711));
    try check_civil_conversion(785, 3, 1, @enumFromInt(-443_710));
    try check_civil_conversion(785, 3, 2, @enumFromInt(-443_709));
    try check_civil_conversion(814, 6, 12, @enumFromInt(-433_015));
    try check_civil_conversion(867, 6, 10, @enumFromInt(-413_659));
    try check_civil_conversion(884, 5, 8, @enumFromInt(-407_482));
    try check_civil_conversion(904, 12, 8, @enumFromInt(-399_964));
    try check_civil_conversion(977, 1, 17, @enumFromInt(-373_626));
    try check_civil_conversion(1004, 3, 15, @enumFromInt(-363_708));
    try check_civil_conversion(1006, 10, 24, @enumFromInt(-362_755));
    try check_civil_conversion(1075, 5, 19, @enumFromInt(-337_711));
    try check_civil_conversion(1080, 7, 3, @enumFromInt(-335_839));
    try check_civil_conversion(1134, 10, 3, @enumFromInt(-316_025));
    try check_civil_conversion(1143, 4, 14, @enumFromInt(-312_910));
    try check_civil_conversion(1211, 4, 10, @enumFromInt(-288_077));
    try check_civil_conversion(1303, 12, 11, @enumFromInt(-254_230));
    try check_civil_conversion(1308, 2, 18, @enumFromInt(-252_700));
    try check_civil_conversion(1308, 2, 27, @enumFromInt(-252_691));
    try check_civil_conversion(1308, 2, 28, @enumFromInt(-252_690));
    try check_civil_conversion(1308, 2, 29, @enumFromInt(-252_689));
    try check_civil_conversion(1308, 3, 1, @enumFromInt(-252_688));
    try check_civil_conversion(1325, 2, 18, @enumFromInt(-246_490));
    try check_civil_conversion(1325, 2, 27, @enumFromInt(-246_481));
    try check_civil_conversion(1325, 2, 28, @enumFromInt(-246_480));
    try check_civil_conversion(1325, 3, 1, @enumFromInt(-246_479));
    try check_civil_conversion(1333, 1, 9, @enumFromInt(-243_608));
    try check_civil_conversion(1346, 1, 17, @enumFromInt(-238_852));
    try check_civil_conversion(1413, 4, 26, @enumFromInt(-214_282));
    try check_civil_conversion(1452, 9, 23, @enumFromInt(-199_887));
    try check_civil_conversion(1500, 2, 28, @enumFromInt(-182_563));
    try check_civil_conversion(1500, 3, 1, @enumFromInt(-182_562));
    try check_civil_conversion(1500, 3, 2, @enumFromInt(-182_561));
    try check_civil_conversion(1529, 9, 3, @enumFromInt(-171_784));
    try check_civil_conversion(1566, 7, 6, @enumFromInt(-158_329));
    try check_civil_conversion(1578, 6, 4, @enumFromInt(-153_978));
    try check_civil_conversion(1600, 2, 27, @enumFromInt(-146_040));
    try check_civil_conversion(1600, 2, 28, @enumFromInt(-146_039));
    try check_civil_conversion(1600, 2, 29, @enumFromInt(-146_038));
    try check_civil_conversion(1600, 3, 1, @enumFromInt(-146_037));
    try check_civil_conversion(1600, 9, 10, @enumFromInt(-145_844));
    try check_civil_conversion(1608, 1, 9, @enumFromInt(-143_167));
    try check_civil_conversion(1622, 2, 22, @enumFromInt(-138_009));
    try check_civil_conversion(1630, 6, 11, @enumFromInt(-134_978));
    try check_civil_conversion(1739, 6, 15, @enumFromInt(-95_163));
    try check_civil_conversion(1777, 12, 22, @enumFromInt(-81_093));
    try check_civil_conversion(1788, 9, 15, @enumFromInt(-77_173));
    try check_civil_conversion(1804, 7, 20, @enumFromInt(-71_387));
    try check_civil_conversion(1814, 6, 26, @enumFromInt(-67_759));
    try check_civil_conversion(1859, 11, 25, @enumFromInt(-51_171));
    try check_civil_conversion(1896, 2, 2, @enumFromInt(-37_953));
    try check_civil_conversion(1900, 7, 25, @enumFromInt(-36_319));
    try check_civil_conversion(1910, 8, 4, @enumFromInt(-32_657));
    try check_civil_conversion(1910, 9, 18, @enumFromInt(-32_612));
    try check_civil_conversion(1914, 7, 24, @enumFromInt(-31_207));
    try check_civil_conversion(1916, 2, 20, @enumFromInt(-30_631));
    try check_civil_conversion(1917, 1, 24, @enumFromInt(-30_292));
    try check_civil_conversion(1918, 6, 23, @enumFromInt(-29_777));
    try check_civil_conversion(1935, 12, 30, @enumFromInt(-23_378));
    try check_civil_conversion(1936, 2, 13, @enumFromInt(-23_333));
    try check_civil_conversion(1939, 10, 31, @enumFromInt(-21_977));
    try check_civil_conversion(1941, 7, 3, @enumFromInt(-21_366));
    try check_civil_conversion(1941, 11, 1, @enumFromInt(-21_245));
    try check_civil_conversion(1942, 2, 2, @enumFromInt(-21_152));
    try check_civil_conversion(1945, 6, 22, @enumFromInt(-19_916));
    try check_civil_conversion(1949, 5, 22, @enumFromInt(-18_486));
    try check_civil_conversion(1954, 12, 29, @enumFromInt(-16_439));
    try check_civil_conversion(1958, 11, 8, @enumFromInt(-15_029));
    try check_civil_conversion(1960, 12, 13, @enumFromInt(-14_263));
    try check_civil_conversion(1963, 9, 9, @enumFromInt(-13_263));
    try check_civil_conversion(1963, 10, 30, @enumFromInt(-13_212));
    try check_civil_conversion(1964, 1, 26, @enumFromInt(-13_124));
    try check_civil_conversion(1968, 1, 24, @enumFromInt(-11_665));
    try check_civil_conversion(1968, 6, 28, @enumFromInt(-11_509));
    try check_civil_conversion(1968, 10, 30, @enumFromInt(-11_385));
    try check_civil_conversion(1970, 12, 6, @enumFromInt(-10_618));
    try check_civil_conversion(1977, 1, 14, @enumFromInt(-8_387));
    try check_civil_conversion(1977, 3, 1, @enumFromInt(-8_341));
    try check_civil_conversion(1979, 9, 14, @enumFromInt(-7_414));
    try check_civil_conversion(1980, 10, 25, @enumFromInt(-7_007));
    try check_civil_conversion(1992, 8, 4, @enumFromInt(-2_706));
    try check_civil_conversion(1999, 10, 6, @enumFromInt(-87));
    try check_civil_conversion(1999, 10, 26, @enumFromInt(-67));
    try check_civil_conversion(1999, 12, 31, @enumFromInt(-1));
    try check_civil_conversion(2000, 1, 2, @enumFromInt(1));
    try check_civil_conversion(2003, 6, 28, @enumFromInt(1_274));
    try check_civil_conversion(2005, 12, 26, @enumFromInt(2_186));
    try check_civil_conversion(2018, 5, 4, @enumFromInt(6_698));
    try check_civil_conversion(2018, 7, 17, @enumFromInt(6_772));
    try check_civil_conversion(2022, 12, 14, @enumFromInt(8_383));
    try check_civil_conversion(2022, 12, 26, @enumFromInt(8_395));
    try check_civil_conversion(2023, 7, 2, @enumFromInt(8_583));
    try check_civil_conversion(2027, 3, 1, @enumFromInt(9_921));
    try check_civil_conversion(2028, 5, 4, @enumFromInt(10_351));
    try check_civil_conversion(2029, 10, 15, @enumFromInt(10_880));
    try check_civil_conversion(2031, 11, 9, @enumFromInt(11_635));
    try check_civil_conversion(2032, 7, 21, @enumFromInt(11_890));
    try check_civil_conversion(2038, 1, 19, @enumFromInt(13_898));
    try check_civil_conversion(2038, 1, 20, @enumFromInt(13_899));
    try check_civil_conversion(2040, 8, 4, @enumFromInt(14_826));
    try check_civil_conversion(2041, 8, 10, @enumFromInt(15_197));
    try check_civil_conversion(2043, 8, 9, @enumFromInt(15_926));
    try check_civil_conversion(2052, 4, 22, @enumFromInt(19_105));
    try check_civil_conversion(2054, 8, 31, @enumFromInt(19_966));
    try check_civil_conversion(2092, 3, 16, @enumFromInt(33_678));
    try check_civil_conversion(2104, 2, 24, @enumFromInt(38_039));
    try check_civil_conversion(2104, 2, 28, @enumFromInt(38_043));
    try check_civil_conversion(2104, 2, 29, @enumFromInt(38_044));
    try check_civil_conversion(2104, 3, 1, @enumFromInt(38_045));
    try check_civil_conversion(2126, 3, 5, @enumFromInt(46_084));
    try check_civil_conversion(2156, 1, 22, @enumFromInt(56_999));
    try check_civil_conversion(2166, 5, 11, @enumFromInt(60_761));
    try check_civil_conversion(2233, 11, 12, @enumFromInt(85_417));
    try check_civil_conversion(2252, 5, 27, @enumFromInt(92_188));
    try check_civil_conversion(2261, 11, 28, @enumFromInt(95_660));
    try check_civil_conversion(2271, 10, 30, @enumFromInt(99_283));
    try check_civil_conversion(2386, 10, 3, @enumFromInt(141_259));
    try check_civil_conversion(2388, 12, 30, @enumFromInt(142_078));
    try check_civil_conversion(2389, 8, 1, @enumFromInt(142_292));
    try check_civil_conversion(2401, 2, 19, @enumFromInt(146_512));
    try check_civil_conversion(2445, 10, 8, @enumFromInt(162_814));
    try check_civil_conversion(2485, 8, 11, @enumFromInt(177_366));
    try check_civil_conversion(2509, 11, 5, @enumFromInt(186_217));
    try check_civil_conversion(2515, 1, 24, @enumFromInt(188_123));
    try check_civil_conversion(2546, 7, 4, @enumFromInt(199_607));
    try check_civil_conversion(2555, 5, 8, @enumFromInt(202_837));
    try check_civil_conversion(2578, 1, 5, @enumFromInt(211_115));
    try check_civil_conversion(2585, 3, 8, @enumFromInt(213_734));
    try check_civil_conversion(2618, 12, 14, @enumFromInt(226_067));
    try check_civil_conversion(2619, 5, 30, @enumFromInt(226_234));
    try check_civil_conversion(2658, 11, 6, @enumFromInt(240_639));
    try check_civil_conversion(2719, 8, 3, @enumFromInt(262_823));
    try check_civil_conversion(2767, 12, 11, @enumFromInt(280_485));
    try check_civil_conversion(2774, 5, 6, @enumFromInt(282_823));
    try check_civil_conversion(2788, 10, 30, @enumFromInt(288_114));
    try check_civil_conversion(2798, 12, 7, @enumFromInt(291_804));
    try check_civil_conversion(2800, 7, 26, @enumFromInt(292_401));
    try check_civil_conversion(2817, 12, 1, @enumFromInt(298_738));
    try check_civil_conversion(2826, 10, 24, @enumFromInt(301_987));
    try check_civil_conversion(2834, 9, 19, @enumFromInt(304_874));
    try check_civil_conversion(2838, 12, 25, @enumFromInt(306_432));
    try check_civil_conversion(2865, 11, 15, @enumFromInt(316_254));
    try check_civil_conversion(2912, 1, 25, @enumFromInt(333_125));
    try check_civil_conversion(2913, 11, 23, @enumFromInt(333_793));
    try check_civil_conversion(2918, 11, 16, @enumFromInt(335_612));
    try check_civil_conversion(2922, 6, 28, @enumFromInt(336_932));
    try check_civil_conversion(2932, 12, 5, @enumFromInt(340_745));
    try check_civil_conversion(2988, 3, 17, @enumFromInt(360_936));
    try check_civil_conversion(3111, 6, 8, @enumFromInt(405_942));
    try check_civil_conversion(3132, 6, 1, @enumFromInt(413_606));
    try check_civil_conversion(3134, 12, 30, @enumFromInt(414_548));
    try check_civil_conversion(3146, 8, 31, @enumFromInt(418_810));
    try check_civil_conversion(3380, 11, 28, @enumFromInt(504_367));
    try check_civil_conversion(3393, 2, 18, @enumFromInt(508_832));
    try check_civil_conversion(3409, 8, 11, @enumFromInt(514_849));
    try check_civil_conversion(3414, 3, 19, @enumFromInt(516_530));
    try check_civil_conversion(3438, 1, 9, @enumFromInt(525_227));
    try check_civil_conversion(3488, 10, 26, @enumFromInt(543_780));
    try check_civil_conversion(3490, 5, 8, @enumFromInt(544_339));
    try check_civil_conversion(3501, 3, 30, @enumFromInt(548_317));
    try check_civil_conversion(3629, 12, 24, @enumFromInt(595_338));
    try check_civil_conversion(3649, 3, 15, @enumFromInt(602_359));
    try check_civil_conversion(3806, 2, 5, @enumFromInt(659_663));
    try check_civil_conversion(6544, 1, 2, @enumFromInt(1_659_663));
    try check_civil_conversion(9281, 11, 28, @enumFromInt(2_659_663));
    try check_civil_conversion(31185, 3, 2, @enumFromInt(10_659_663));

    try check_civil_conversion(-1, 12, 31, @enumFromInt(-730_486));
    try check_civil_conversion(-274, 3, 17, @enumFromInt(-830_486));

    try check_civil_conversion(5_881_610, 7, 11, @enumFromInt(std.math.maxInt(i32)));
    try check_civil_conversion(-5_877_611, 6, 22, @enumFromInt(std.math.minInt(i32)));
}

fn check_civil_conversion(y: i32, m: u8, d: u8, date: Date) !void {
    errdefer std.debug.print("For {f}\n", .{ date });
    try std.testing.expectEqual(date, Date.from_ymd(.from_numbers(y, m, d)));
    if (y > -5877611) {
        try std.testing.expectEqual(Date.from_year(.from_number(y)), Date.from_ymd(.from_numbers(y, 1, 1)));
    }

    var ymd = civil64.days_to_ymd(@intFromEnum(date));
    try std.testing.expectEqual(y, ymd.year.as_number());
    try std.testing.expectEqual(m, ymd.month.as_number());
    try std.testing.expectEqual(d, ymd.day.as_number());
    try std.testing.expectEqual(y, civil64.days_to_year(@intFromEnum(date)).as_number());

    ymd = civil32.days_to_ymd(@intFromEnum(date));
    try std.testing.expectEqual(y, ymd.year.as_number());
    try std.testing.expectEqual(m, ymd.month.as_number());
    try std.testing.expectEqual(d, ymd.day.as_number());
    try std.testing.expectEqual(y, civil32.days_to_year(@intFromEnum(date)).as_number());
}

const Year = @import("year.zig").Year;
const Month = @import("month.zig").Month;
const Day = @import("day.zig").Day;
const Week_Day = @import("week_day.zig").Week_Day;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const Ordinal_Week = @import("ordinal_week.zig").Ordinal_Week;
const ISO_Week_Date = @import("iso_week.zig").ISO_Week_Date;
const ISO_Week = @import("iso_week.zig").ISO_Week;
const Date_Time = @import("Date_Time.zig");
const Time = @import("time.zig").Time;
const formatting = @import("formatting.zig");
const builtin = @import("builtin");
const std = @import("std");
