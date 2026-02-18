//! https://en.wikipedia.org/wiki/ISO_week_date

pub const ISO_Week_Date = struct {
    year: Year,
    week: ISO_Week,
    day: Week_Day,

    pub fn from_date(d: Date) ISO_Week_Date {
        const yi = d.year_info();
        const od: Ordinal_Day = .from_number(@intFromEnum(d) - @intFromEnum(yi.starting_date) + 1);
        return .from_yiodwd(yi, od, d.week_day());
    }

    pub fn from_yiodwd(yi: Year.Info, od: Ordinal_Day, wd: Week_Day) ISO_Week_Date {
        switch ((od.as_unsigned() + 10 - wd.as_iso()) / 7) {
            0 => {
                var prev_year = yi.year().plus(-1);
                return .{
                    .year = prev_year,
                    .week = .last_from_dc(.from_yi(.{
                        .raw = prev_year.as_number(),
                        .is_leap = !yi.is_leap and prev_year.is_leap(),
                        .starting_date = .from_year(prev_year),
                    })),
                    .day = wd,
                };
            },
            53 => {
                const last_week: ISO_Week = .last_from_dc(.from_yi(yi));
                return if (last_week.as_number() == 53) .{
                    .year = yi.year(),
                    .week = last_week,
                    .day = wd,
                } else .{
                    .year = yi.year().plus(1),
                    .week = .first,
                    .day = wd,
                };
            },
            else => |w| {
                return .{
                    .year = yi.year(),
                    .week = .from_number(@intCast(w)),
                    .day = wd,
                };
            },
        }
    }

    pub fn date(self: ISO_Week_Date) Date {
        return .from_ywd(self.year, self.week, self.day);
    }

    pub fn is_before(self: ISO_Week_Date, other: ISO_Week_Date) bool {
        if (self.year.as_number() != other.year.as_number()) {
            return self.year.as_number() < other.year.as_number();
        }

        std.debug.assert(self.week.as_number() >= 1);
        std.debug.assert(self.week.as_number() <= ISO_Week.last(self.year).as_number());

        if (self.week.as_number() != other.week.as_number()) {
            return self.week.as_number() < other.week.as_number();
        }

        std.debug.assert(self.day.as_number() >= 1);
        std.debug.assert(self.day.as_number() <= 7);

        return self.day.as_iso() < other.day.as_iso();
    }

    pub fn is_after(self: ISO_Week_Date, other: ISO_Week_Date) bool {
        if (self.year.as_number() != other.year.as_number()) {
            return self.year.as_number() < other.year.as_number();
        }

        std.debug.assert(self.week.as_number() >= 1);
        std.debug.assert(self.week.as_number() <= ISO_Week.last(self.year).as_number());

        if (self.week.as_number() != other.week.as_number()) {
            return self.week.as_number() < other.week.as_number();
        }

        std.debug.assert(self.day.as_number() >= 1);
        std.debug.assert(self.day.as_number() <= 7);

        return self.day.as_iso() < other.day.as_iso();
    }

    pub const iso8601_week_date = "GGGG-[W]WW-E";
    pub const iso8601_week = "GGGG-[W]WW";
    pub const datecode = "GGWW"; 

    pub fn format(self: ISO_Week_Date, writer: *std.Io.Writer) !void {
        try formatting.format(self.date().with_time(.midnight).with_offset(0), iso8601_week_date, writer);
    }

    pub fn fmt(self: ISO_Week_Date, comptime pattern: []const u8) Formatter(pattern) {
        return .{ .date = self.date() };
    }

    pub fn Formatter(comptime pattern: []const u8) type {
        return struct {
            date: Date,
            pub inline fn format(self: @This(), writer: *std.Io.Writer) !void {
                try formatting.format(self.date.with_time(.midnight).with_offset(0), pattern, writer);
            }
        };
    }

    pub fn from_string(comptime pattern: []const u8, str: []const u8) !ISO_Week_Date {
        var reader = std.Io.Reader.fixed(str);
        const pi = formatting.parse(if (pattern.len == 0) iso8601_week_date else pattern, &reader) catch |err| switch (err) {
            error.InvalidString => return err,
            error.EndOfStream => return error.InvalidString,
            error.ReadFailed => unreachable,
            error.TzdbCacheNotInitialized => return err,
        };

        const PI = @TypeOf(pi);

        if (@FieldType(PI, "timestamp") != void) {
            return Date_Time.With_Offset.from_timestamp_ms(pi.timestamp, null).dt.date.iso_week_date();
        }

        if (@FieldType(PI, "year") != void) {
            if (@FieldType(PI, "ordinal_day") != void) {
                return Date.from_yod(pi.year, pi.ordinal_day).iso_week_date();
            }
            
            if (@FieldType(PI, "ordinal_week") != void) {
                var d = Date.from_yod(pi.year, pi.ordinal_week.starting_day());
                if (@FieldType(PI, "week_day") != void) {
                    d = d.advance_to_week_day(pi.week_day);
                }
                return d.iso_week_date();
            }
            
            if (@FieldType(PI, "month") != void) {
                return Date.from_ymd(.{
                    .year = pi.year,
                    .month = pi.month,
                    .day = if (@FieldType(PI, "day") != void) pi.day else 1,
                }).iso_week_date();
            }

            return Date.from_yod(pi.year, .first).iso_week_date();
        }

        if (@FieldType(PI, "iso_week_year") != void) {
            var iwd: ISO_Week_Date = .{
                .year = pi.iso_week_year,
                .week = .first,
                .day = .monday,
            };

            if (@FieldType(PI, "iso_week") != void) iwd.week = pi.iso_week;
            if (@FieldType(PI, "week_day") != void) iwd.day = pi.week_day;

            return iwd;
        }

        @compileError("Invalid pattern: " ++ pattern);
    }
};

pub const ISO_Week = enum (u6) {
    first = 1,
    _,

    pub fn last(year: Year) ISO_Week {
        return .last_from_dc(year.dominical_letter());
    }

    pub fn last_from_dc(dc: Year.Dominical_Letter) ISO_Week {
        return .from_number(switch (dc) {
            .d, .dc, .ed => 53,
            else => 52,
        });
    }

    pub fn from_number(day: i32) ISO_Week {
        std.debug.assert(day >= 1);
        std.debug.assert(day <= 53);
        return @enumFromInt(day);
    }

    pub fn as_number(self: ISO_Week) i32 {
        return @intFromEnum(self);
    }
    pub fn as_unsigned(self: ISO_Week) u32 {
        return @intFromEnum(self);
    }
};

const Week_Day = @import("week_day.zig").Week_Day;
const Year = @import("year.zig").Year;
const Year_Info = Year.Info;
const Date = @import("date.zig").Date;
const Date_Time = @import("Date_Time.zig");
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const formatting = @import("formatting.zig");
const std = @import("std");
