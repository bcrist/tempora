pub const Date = enum(i32) {
    ntfs_epoch = civil.year_to_days(Year.ntfs_epoch.as_number()), // e.g. Windows FILETIME
    ntp_epoch = civil.year_to_days(Year.ntp_epoch.as_number()),
    unix_epoch = civil.year_to_days(Year.unix_epoch.as_number()),
    epoch = civil.year_to_days(Year.epoch.as_number()), // 0
    _,

    pub fn from_ymd(d: YMD) Date {
        return @enumFromInt(civil.ymd_to_days(d.year.as_number(), d.month.as_unsigned(), d.day.as_number()));
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
        return @enumFromInt(civil.year_to_days(y.as_number()));
    }

    pub fn year(self: Date) Year {
        return @enumFromInt(civil.days_to_year(@intFromEnum(self)));
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

    pub fn info(self: Date) Info {
        return .from_date(self);
    }

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

    pub fn next(self: Date) Date {
        return self.plus_days(1);
    }

    pub fn prev(self: Date) Date {
        return self.plus_days(-1);
    }

    /// This will always return a different date.
    /// for the alternative, use .prev().next_week_day() or Week_Day.on_or_after(Date)
    pub fn next_week_day(self: Date, d: Week_Day) Date {
        const current: i32 = self.week_day().as_number();
        const target: i32 = d.as_number();

        var delta_days = target - current;
        if (current >= target) delta_days += 7;
        return self.plus_days(delta_days);
    }
    
    /// This will always return a different date.
    /// for the alternative, use .next().prev_week_day() or Week_Day.on_or_before(Date)
    pub fn prev_week_day(self: Date, d: Week_Day) Date {
        const current: i32 = self.week_day().as_number();
        const target: i32 = d.as_number();

        var delta_days = target - current;
        if (current <= target) delta_days -= 7;
        return self.plus_days(delta_days);
    }

    /// This will always return a different date.
    /// for the alternative, use .prev().next_day_of_month() or Day.on_or_after()
    pub fn next_day_of_month(self: Date, d: Day) Date {
        const _ymd = self.ymd();
        const current = _ymd.day.as_number();
        const target = d.as_number();

        var delta_days = target - current;
        if (current >= target) delta_days += _ymd.month.days(_ymd.year);
        return self.plus_days(delta_days);
    }

    /// This will always return a different date.
    /// for the alternative, use .next().prev_day_of_month() or Day.on_or_before()
    pub fn prev_day_of_month(self: Date, d: Day) Date {
        const _ymd = self.ymd();
        const current = _ymd.day.as_number();
        const target = d.as_number();

        var delta_days = target - current;
        if (current <= target) delta_days -= _ymd.month.prev().days(_ymd.year);
        return self.plus_days(delta_days);
    }

    /// This will always return a different date.
    /// for the alternative, use .prev().next_month_and_day()
    pub fn next_month_and_day(self: Date, m: Month, d: Day) Date {
        const _ymd = self.ymd();

        const target_month = m.as_number();
        const current_month = _ymd.month.as_number();

        const target_day = d.as_number();
        const current_day = _ymd.day.as_number();

        if (target_month > current_month) {
            var delta_days = target_day - current_day;
            if (m == .february or !_ymd.year.is_leap()) {
                delta_days += m.starting_ordinal_day_assume_non_leap_year().as_number();
                delta_days -= _ymd.month.starting_ordinal_day_assume_non_leap_year().as_number();
            } else {
                delta_days += m.starting_ordinal_day_assume_leap_year().as_number();
                delta_days -= _ymd.month.starting_ordinal_day_assume_leap_year().as_number();
            }
            return self.plus_days(delta_days);
        } else if (target_month == current_month and target_day > current_day) {
            return self.plus_days(target_day - current_day);
        } else {
            return .from_ymd(.{
                .year = _ymd.year.next(),
                .month = m,
                .day = d,
            });
        }
    }

    /// This will always return a different date.
    /// for the alternative, use .next().prev_month_and_day()
    pub fn prev_month_and_day(self: Date, m: Month, d: Day) Date {
        const _ymd = self.ymd();

        const target_month = m.as_number();
        const current_month = _ymd.month.as_number();

        const target_day = d.as_number();
        const current_day = _ymd.day.as_number();

        if (target_month < current_month) {
            var delta_days = target_day - current_day;
            if (_ymd.month == .february or !_ymd.year.is_leap()) {
                delta_days += m.starting_ordinal_day_assume_non_leap_year().as_number();
                delta_days -= _ymd.month.starting_ordinal_day_assume_non_leap_year().as_number();
            } else {
                delta_days += m.starting_ordinal_day_assume_leap_year().as_number();
                delta_days -= _ymd.month.starting_ordinal_day_assume_leap_year().as_number();
            }
            return self.plus_days(delta_days);
        } else if (target_month == current_month and target_day < current_day) {
            return self.plus_days(target_day - current_day);
        } else {
            return .from_ymd(.{
                .year = _ymd.year.prev(),
                .month = m,
                .day = d,
            });
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

    pub fn format(self: Date, writer: *std.Io.Writer) !void {
        try formatting.format(self.with_time(.midnight).with_offset(0), iso8601, writer);
    }

    pub fn fmt(self: Date, comptime pattern: []const u8) Formatter(pattern) {
        return .{ .date = self };
    }

    pub fn Formatter(comptime pattern: []const u8) type {
        return struct {
            date: Date,
            pub inline fn format(self: @This(), writer: *std.Io.Writer) !void {
                try formatting.format(self.date.with_time(.midnight).with_offset(0), pattern, writer);
            }
        };
    }

    pub fn from_string(comptime pattern: []const u8, str: []const u8) !Date {
        var reader = std.Io.Reader.fixed(str);
        const pi = formatting.parse(if (pattern.len == 0) iso8601 else pattern, &reader, null, null) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
        };

        return pi.date();
    }

    pub const YMD = struct {
        year: Year,
        month: Month,
        day: Day,

        pub fn init(y: Year, m: Month, d: Day) YMD {
            return .{
                .year = y,
                .month = m,
                .day = d,
            };
        }

        pub fn from_numbers(y: i32, m: i32, d: i32) YMD {
            return .{
                .year = .from_number(y),
                .month = .from_number(m),
                .day = .from_number(d),
            };
        }

        pub fn from_date(d: Date) YMD {
            const raw = civil.days_to_ymd(@intFromEnum(d));
            return .from_numbers(raw.y, raw.m, raw.d);
        }

        pub fn year_info(self: YMD) Year.Info {
            return self.year.info();
        }

        pub fn date(self: YMD) Date {
            return .from_ymd(self);
        }

        pub fn info(self: YMD) Info {
            return .from_ymd(self);
        }

        pub fn iso_week_date(self: Info) ISO_Week_Date {
            return .from_yiodwd(self.year_info(), self.ordinal_day, self.week_day);
        }
        
        pub fn is_before(self: YMD, other: YMD) bool {
            if (self.year != other.year) return self.year.is_before(other.year);

            std.debug.assert(self.month.as_number() >= 1);
            std.debug.assert(self.month.as_number() <= 12);
            std.debug.assert(other.month.as_number() >= 1);
            std.debug.assert(other.month.as_number() <= 12);

            if (self.month != other.month) return self.month.is_before(other.month);

            std.debug.assert(self.day.as_number() >= 1);
            std.debug.assert(self.day.as_number() <= self.month.days(self.year));
            std.debug.assert(other.day.as_number() >= 1);
            std.debug.assert(other.day.as_number() <= other.month.days(self.year));

            return self.day.is_before(other.day);
        }

        pub fn is_after(self: YMD, other: YMD) bool {
            if (self.year != other.year) return self.year.is_after(other.year);

            std.debug.assert(self.month.as_number() >= 1);
            std.debug.assert(self.month.as_number() <= 12);
            std.debug.assert(other.month.as_number() >= 1);
            std.debug.assert(other.month.as_number() <= 12);

            if (self.month != other.month) return self.month.is_after(other.month);

            std.debug.assert(self.day.as_number() >= 1);
            std.debug.assert(self.day.as_number() <= self.month.days(self.year));
            std.debug.assert(other.day.as_number() >= 1);
            std.debug.assert(other.day.as_number() <= other.month.days(self.year));

            return self.day.is_after(other.day);
        }

        pub fn next(self: YMD) YMD {
            const d = self.day.as_number();
            if (d < self.month.days_assume_non_leap_year()) {
                return .{
                    .year = self.year,
                    .month = self.month,
                    .day = .from_number(d + 1),
                };
            } else if (self.month == .february and d == 28 and self.year.is_leap()) {
                return .{
                    .year = self.year,
                    .month = self.month,
                    .day = .from_number(d + 1),
                };
            } else if (self.month != .december) {
                return .{
                    .year = self.year,
                    .month = self.month.next(),
                    .day = .first,
                };
            } else {
                return .{
                    .year = self.year.next(),
                    .month = .january,
                    .day = .first,
                };
            }
        }

        pub fn prev(self: YMD) YMD {
            const d = self.day.as_number();
            if (d > 1) {
                return .{
                    .year = self.year,
                    .month = self.month,
                    .day = .from_number(d - 1),
                };
            } else {
                const prev_month = self.month.prev();
                if (self.month != .january) {
                    return .{
                        .year = self.year,
                        .month = prev_month,
                        .day = .from_number(prev_month.days(self.year)),
                    };
                } else {
                    const prev_year = self.year.prev();
                    return .{
                        .year = prev_year,
                        .month = prev_month,
                        .day = .from_number(prev_month.days(prev_year)),
                    };
                }
            }
        }

        /// This will always return a different date.
        /// for the alternative, use .prev().next_day_of_month() or Day.on_or_after_ymd()
        pub fn next_day_of_month(self: YMD, d: Day) YMD {
            const target = d.as_number();
            const current = self.day.as_number();

            if (target > current) {
                return .{
                    .year = self.year,
                    .month = self.month,
                    .day = d,
                };
            } else if (self.month == .december) {
                return .{
                    .year = self.year.next(),
                    .month = .january,
                    .day = d,
                };
            } else {
                return .{
                    .year = self.year,
                    .month = self.month.next(),
                    .day = d,
                };
            }
        }

        /// This will always return a different date.
        /// for the alternative, use .next().prev_day_of_month() or Day.on_or_before_ymd()
        pub fn prev_day_of_month(self: YMD, d: Day) YMD {
            const target = d.as_number();
            const current = self.day.as_number();

            if (target < current) {
                return .{
                    .year = self.year,
                    .month = self.month,
                    .day = d,
                };
            } else if (self.month == .january) {
                return .{
                    .year = self.year.prev(),
                    .month = .december,
                    .day = d,
                };
            } else {
                return .{
                    .year = self.year,
                    .month = self.month.prev(),
                    .day = d,
                };
            }
        }

        /// This will always return a different date.
        /// for the alternative, use .prev().next_month_and_day()
        pub fn next_month_and_day(self: YMD, m: Month, d: Day) YMD {
            const target_month = m.as_number();
            const current_month = self.month.as_number();

            const target_day = d.as_number();
            const current_day = self.day.as_number();

            return .{
                .year = if (target_month > current_month or target_month == current_month and target_day > current_day) self.year else self.year.next(),
                .month = m,
                .day = d,
            };
        }

        /// This will always return a different date.
        /// for the alternative, use .next().prev_month_and_day()
        pub fn prev_month_and_day(self: YMD, m: Month, d: Day) YMD {
            const target_month = m.as_number();
            const current_month = self.month.as_number();

            const target_day = d.as_number();
            const current_day = self.day.as_number();

            return .{
                .year = if (target_month < current_month or target_month == current_month and target_day < current_day) self.year else self.year.prev(),
                .month = m,
                .day = d,
            };
        }
    };

    pub const Info = struct {
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

        pub fn from_date(d: Date) Info {
            const raw = @intFromEnum(d);
            const weekday = d.week_day();
            const c = d.ymd();
            const start_of_year = c.year.starting_date();
            return .{
                .raw = raw,
                .year = c.year,
                .month = c.month,
                .day = c.day,
                .start_of_year = start_of_year,
                .is_leap_year = c.year.is_leap(),
                .week_day = weekday,
                .ordinal_day = .from_number(raw - @intFromEnum(start_of_year) + 1),
                .start_of_month = @enumFromInt(raw - c.day.as_number() + 1),
                .start_of_week = @enumFromInt(raw - weekday.as_number() + 1),
            };
        }

        pub fn from_ymd(_ymd: YMD) Info {
            const d = _ymd.date();
            const raw = @intFromEnum(d);
            const weekday = d.week_day();
            const leap = _ymd.year.is_leap();
            const start_of_month_raw = raw - _ymd.day.as_number() + 1;
            const start_of_month_od = if (leap) _ymd.month.starting_ordinal_day_assume_leap_year() else _ymd.month.starting_ordinal_day_assume_non_leap_year();
            const start_of_year_raw = start_of_month_raw - start_of_month_od.as_number() + 1;
            return .{
                .raw = raw,
                .year = _ymd.year,
                .month = _ymd.month,
                .day = _ymd.day,
                .start_of_year = @enumFromInt(start_of_year_raw),
                .is_leap_year = leap,
                .week_day = weekday,
                .ordinal_day = .from_number(raw - start_of_year_raw + 1),
                .start_of_month = @enumFromInt(start_of_month_raw),
                .start_of_week = @enumFromInt(raw - weekday.as_number() + 1),
            };
        }

        pub fn from_yimd(yi: Year.Info, m_: Month, d_: Day) Info {
            const d: Date = .from_ymd(.init(yi.year(), m_, d_));
            const raw = @intFromEnum(d);
            const weekday = d.week_day();
            const leap = yi.is_leap;
            const start_of_month_raw = raw - d_.as_number() + 1;
            const start_of_month_od = if (leap) m_.starting_ordinal_day_assume_leap_year() else m_.starting_ordinal_day_assume_non_leap_year();
            const start_of_year_raw = start_of_month_raw - start_of_month_od.as_number() + 1;
            return .{
                .raw = raw,
                .year = yi.year(),
                .month = m_,
                .day = d_,
                .start_of_year = @enumFromInt(start_of_year_raw),
                .is_leap_year = leap,
                .week_day = weekday,
                .ordinal_day = .from_number(raw - start_of_year_raw + 1),
                .start_of_month = @enumFromInt(start_of_month_raw),
                .start_of_week = @enumFromInt(raw - weekday.as_number() + 1),
            };
        }

        pub fn year_info(self: Info) Year.Info {
            return .{
                .year = self.year.as_number(),
                .starting_date = self.start_of_year,
                .is_leap = self.is_leap_year,
            };
        }

        pub fn ymd(self: Info) YMD {
            return .{
                .year = self.year,
                .month = self.month,
                .day = self.day,
            };
        }

        pub fn date(self: Info) Date {
            return @enumFromInt(self.raw);
        }

        pub fn iso_week_date(self: Info) ISO_Week_Date {
            return .from_yiodwd(self.year_info(), self.ordinal_day, self.week_day);
        }
    };
};

const civil = if (@sizeOf(usize) < 8) @import("civil.zig").civil32 else @import("civil.zig").civil64;

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
