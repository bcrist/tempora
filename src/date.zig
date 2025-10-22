
pub const Date = enum (i32) {
    epoch = 0,
    _,

    pub const epoch_year = 2000;

    // In the gregorian calendar, there are 97 leap years per 400 years,
    // so the average length of a year is 365 + 97/400 = 365.2425
    const average_days_per_year_x400 = 365 * 400 + 97;

    pub fn from_ymd(y: Year, m: Month, d: Day) Date {
        return from_yd(y, Ordinal_Day.from_ymd(y, m, d));
    }

    pub fn from_yd(y: Year, d: Ordinal_Day) Date {
        const raw = @intFromEnum(y.starting_date()) + d.as_number() - 1;
        return @enumFromInt(raw);
    }

    pub fn year(self: Date) Year {
        return Year.from_number(self.year_info().year);
    }

    pub fn year_info(self: Date) Year.Info {
        var yi: Year.Info = undefined;

        const raw = @intFromEnum(self);

        const four_hundreths: i64 = @as(i64, raw) * 400;

        // Due to leap years this starts as only a guess; but it will be
        // correct within +/- one year.
        yi.year = @intCast(epoch_year + @divFloor(four_hundreths, average_days_per_year_x400));
        yi.starting_date = Year.from_number(yi.year).starting_date();
        const delta = raw - @intFromEnum(yi.starting_date);
        if (delta < 0) {
            yi.year -= 1;
            yi.is_leap = Year.from_number(yi.year).is_leap();
            yi.starting_date = yi.starting_date.plus_days(if (yi.is_leap) -366 else -365);
        } else if (delta >= 365) {
            if (Year.from_number(yi.year).is_leap()) {
                if (delta >= 366) {
                    yi.starting_date = yi.starting_date.plus_days(366);
                    yi.year += 1;
                    yi.is_leap = Year.from_number(yi.year).is_leap();
                } else {
                    yi.is_leap = true;
                }
            } else {
                yi.starting_date = yi.starting_date.plus_days(365);
                yi.year += 1;
                yi.is_leap = Year.from_number(yi.year).is_leap();
            }
        } else {
            yi.is_leap = Year.from_number(yi.year).is_leap();
        }

        return yi;
    }

    pub fn month(self: Date) Month {
        return self.month_from_yi(self.year_info());
    }

    fn month_from_yi(self: Date, yi: Year.Info) Month {
        var od = self.ordinal_day_from_yi(yi);

        const noleap_od = Ordinal_Day.from_md_assume_non_leap_year;

        if (od.is_before(comptime noleap_od(.march, .first))) {
            if (od.is_before(comptime noleap_od(.february, .first))) {
                return .january;
            } else {
                return .february;
            }
        } else {
            if (yi.is_leap) {
                if (od == comptime noleap_od(.march, .first)) {
                    return .february;
                } else {
                    od = Ordinal_Day.from_number(od.as_number() - 1);
                }
            }

            if (od.is_before(comptime noleap_od(.june, .first))) {
                if (od.is_before(comptime noleap_od(.april, .first))) {
                    return .march;
                } else if (od.is_before(comptime noleap_od(.may, .first))) {
                    return .april;
                } else {
                    return .may;
                }
            } else if (od.is_before(comptime noleap_od(.september, .first))) {
                if (od.is_before(comptime noleap_od(.july, .first))) {
                    return .june;
                } else if (od.is_before(comptime noleap_od(.august, .first))) {
                    return .july;
                } else {
                    return .august;
                }
            } else if (od.is_before(comptime noleap_od(.november, .first))) {
                if (od.is_before(comptime noleap_od(.october, .first))) {
                    return .september;
                } else {
                    return .october;
                }
            } else if (od.is_before(comptime noleap_od(.december, .first))) {
                return .november;
            } else {
                return .december;
            }
        }
    }

    pub fn day(self: Date) Day {
        return self.day_from_yi(self.year_info());
    }

    fn day_from_yi(self: Date, yi: Year.Info) Day {
        var od = self.ordinal_day_from_yi(yi);

        const noleap_od = Ordinal_Day.from_md_assume_non_leap_year;

        const offset: i32 = blk: {
            if (od.is_before(comptime noleap_od(.march, .first))) {
                if (od.is_before(comptime noleap_od(.february, .first))) {
                    break :blk 0;
                } else {
                    break :blk comptime -noleap_od(.february, .first).as_number() + 1;
                }
            } else {
                if (yi.is_leap) {
                    if (od == comptime noleap_od(.march, .first)) {
                        break :blk comptime -noleap_od(.february, .first).as_number() + 1;
                    } else {
                        od = Ordinal_Day.from_number(od.as_number() - 1);
                    }
                }

                if (od.is_before(comptime noleap_od(.june, .first))) {
                    if (od.is_before(comptime noleap_od(.april, .first))) {
                        break :blk comptime -noleap_od(.march, .first).as_number() + 1;
                    } else if (od.is_before(comptime noleap_od(.may, .first))) {
                        break :blk comptime -noleap_od(.april, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.may, .first).as_number() + 1;
                    }
                } else if (od.is_before(comptime noleap_od(.september, .first))) {
                    if (od.is_before(comptime noleap_od(.july, .first))) {
                        break :blk comptime -noleap_od(.june, .first).as_number() + 1;
                    } else if (od.is_before(comptime noleap_od(.august, .first))) {
                        break :blk comptime -noleap_od(.july, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.august, .first).as_number() + 1;
                    }
                } else if (od.is_before(comptime noleap_od(.november, .first))) {
                    if (od.is_before(comptime noleap_od(.october, .first))) {
                        break :blk comptime -noleap_od(.september, .first).as_number() + 1;
                    } else {
                        break :blk comptime -noleap_od(.october, .first).as_number() + 1;
                    }
                } else if (od.is_before(comptime noleap_od(.december, .first))) {
                    break :blk comptime -noleap_od(.november, .first).as_number() + 1;
                } else {
                    break :blk comptime -noleap_od(.december, .first).as_number() + 1;
                }
            }
        };

        return Day.from_number(od.as_number() + offset);
    }

    pub fn ordinal_day(self: Date) Ordinal_Day {
        return self.ordinal_day_from_yi(self.year_info());
    }

    fn ordinal_day_from_yi(self: Date, yi: Year.Info) Ordinal_Day {
        return Ordinal_Day.from_number(@intFromEnum(self) - @intFromEnum(yi.starting_date) + 1);
    }

    pub fn ordinal_week(self: Date) Ordinal_Week {
        return self.ordinal_week_from_yi(self.year_info());
    }

    fn ordinal_week_from_yi(self: Date, yi: Year.Info) Ordinal_Week {
        return Ordinal_Week.from_od(self.ordinal_day_from_yi(yi));
    }

    pub fn week_day(self: Date) Week_Day {
        // epoch (2000-01-01) was a saturday (7).

        var raw: i32 = @intFromEnum(self);
        raw = @mod(raw - 1, 7) + 1;

        return Week_Day.from_number(raw);
    }

    pub const Info = Date_Info;
    pub fn info(self: Date) Info {
        var di: Date_Info = undefined;
        di.raw = @intFromEnum(self);
        const yi = self.year_info();
        di.start_of_year = yi.starting_date;
        di.year = Year.from_number(yi.year);
        di.is_leap_year = yi.is_leap;
        di.month = self.month_from_yi(yi);
        di.day = self.day_from_yi(yi);
        di.week_day = self.week_day();
        di.ordinal_day = self.ordinal_day_from_yi(yi);
        di.start_of_month = @enumFromInt(di.raw - di.day.as_number() + 1);
        di.start_of_week = @enumFromInt(di.raw - di.week_day.as_number() + 1);
        return di;
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
            return Date.from_ymd(y, m, d);
        }
    }

    pub fn advance_to_month_and_day(self: Date, m: Month, d: Day) Date {
        const di = self.info();

        const current = di.ordinal_day.as_number();
        const target = Ordinal_Day.from_ymd(di.year, m, d).as_number();

        if (current < target) {
            return self.plus_days(target - current);
        } else {
            const y = Year.from_number(di.year.as_number() + 1);
            return Date.from_ymd(y, m, d);
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
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader) catch return error.InvalidPattern;
        
        if (pi.timestamp) |ts| {
            return Date_Time.With_Offset.from_timestamp_ms(ts, null).dt.date;
        }
        
        if (pi.year) |pi_y| {
            const y = if (pi.negate_year) Year.from_number(-pi_y.as_number()) else pi_y;

            if (pi.ordinal_day) |od| return from_yd(y, od);
            if (pi.ordinal_week) |ow| {
                const d = from_yd(y, ow.starting_day());
                if (pi.week_day) |wd| {
                    return d.advance_to_week_day(wd);
                }
                return d;
            }
            if (pi.month) |m| {
                if (pi.day) |d| return from_ymd(y, m, d);
            }
            return from_yd(y, .first);
        }
        
        return error.InvalidPattern;
    }
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
};

test "Date" {
    const date1 = Date.from_ymd(Year.from_number(2024), .february, .first);
    const date2 = Date.from_ymd(Year.from_number(1928), .december, Day.from_number(24));
    const date3 = Date.from_ymd(Year.from_number(0), .december, Day.from_number(24));
    const date4 = Date.from_ymd(Year.from_number(12), .december, Day.from_number(24));
    const date5 = Date.from_ymd(Year.from_number(-123), .december, Day.from_number(24));
    const date6 = Date.from_ymd(Year.from_number(1970), .january, .first);

    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1.fmt("YYYY-MM-DD") });
    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1 });
    try std.testing.expectFmt("2 2nd Feb February", "{f}", .{ date1.fmt("M Mo MMM MMMM") });
    try std.testing.expectFmt("1.1st", "{f}", .{ date1.fmt("Q.Qo") });
    try std.testing.expectFmt("24 Do 24th", "{f}", .{ date2.fmt("D [Do] Do") });
    try std.testing.expectFmt("359 359th 359", "{f}", .{ date2.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("32 32nd 032", "{f}", .{ date1.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("4 4 4th Th Thu Thursday", "{f}", .{ date1.fmt("d e do dd ddd dddd") });
    try std.testing.expectFmt("5 5th", "{f}", .{ date1.fmt("E Eo") });
    try std.testing.expectFmt("52 52nd 52", "{f}", .{ date2.fmt("w wo ww") });
    try std.testing.expectFmt("2024 24 2024 2024 +002024", "{f}", .{ date1.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("1928 28 1928 1928 +001928", "{f}", .{ date2.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("0 00 0 0000 000000", "{f}", .{ date3.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("12 12 12 0012 +000012", "{f}", .{ date4.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("-123 -123 -123 -0123 -000123", "{f}", .{ date5.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("AD AD", "{f}", .{ date1.fmt("N NN") });

    try std.testing.expectFmt("2000", "{f}", .{ @as(Date, @enumFromInt(0)).fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Year.from_number(2000).starting_date().fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Date.from_yd(Year.from_number(2000), .first).fmt("Y") });
    try std.testing.expectFmt("2020", "{f}", .{ Date.from_yd(Year.from_number(2020), .first).fmt("Y") });
    try std.testing.expectFmt("1999", "{f}", .{ Date.from_yd(Year.from_number(1999), .first).fmt("Y") });

    try std.testing.expectEqual(date1, try Date.from_string("YYYY-MM-DD", "2024-02-01"));
    try std.testing.expectEqual(date1, try Date.from_string("Y DDDo", "2024 32nd"));
    try std.testing.expectEqual(date1, try Date.from_string("Y MMM D", "+002024 feb 1"));
    try std.testing.expectEqual(date6, try Date.from_string("YY", "70"));
    try std.testing.expectEqual(date6, (try Date.from_string("YYYY-MM-DD", "1969-12-31")).plus_days(1));
    try std.testing.expectEqual(date6, try Date.from_string("x", "0"));
    try std.testing.expectEqual(date6, try Date.from_string("X", "0"));
    try std.testing.expectError(error.InvalidPattern, Date.from_string("MM", "12"));

    var d = Date.from_ymd(Year.from_number(2000), .january, .first);
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

const Year = @import("year.zig").Year;
const Month = @import("month.zig").Month;
const Day = @import("day.zig").Day;
const Week_Day = @import("week_day.zig").Week_Day;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const Ordinal_Week = @import("ordinal_week.zig").Ordinal_Week;
const Date_Time = @import("Date_Time.zig");
const Time = @import("time.zig").Time;
const formatting = @import("formatting.zig");
const std = @import("std");
