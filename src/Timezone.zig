// Parts of this file are based on https://github.com/leroycep/zig-tzif:

// MIT License

// Copyright (c) 2021 LeRoyce Pearson

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

id: []const u8,
transitions: std.MultiArrayList(Transition),
zones: []const Zone_Info,
posix_tz: ?POSIX_TZ,
designations: []const u8,

const Timezone = @This();

pub fn deinit(self: *Timezone, allocator: std.mem.Allocator) void {
    allocator.free(self.id);
    self.transitions.deinit(allocator);
    allocator.free(self.zones);
    allocator.free(self.designations);
}

pub fn zone_info(this: Timezone, utc: i64) Zone_Info {
    const transitions = this.transitions.slice();
    const transition_ts = transitions.items(.ts);
    const next_transition = std.sort.upperBound(i64, transition_ts, utc, ts_order);

    if (next_transition == transitions.len) {
        if (this.posix_tz) |posix_tz| {
            const last_transition_ts: ?i64 = if (transitions.len > 0) transition_ts[transitions.len - 1] else null;
            return posix_tz.zone_info(utc, last_transition_ts);
        }
    }

    if (next_transition == 0) {
        return this.zones[0];
    }

    const transition = transitions.get(next_transition - 1);
    var zone = this.zones[transition.zone_index];
    zone.begin_ts = transition.ts;
    if (next_transition < transitions.len) {
        zone.end_ts = transitions.items(.ts)[next_transition];
    }
    return zone;
}

pub const Zone_Info = struct {
    /// A timezone designation string, e.g. EST or EDT
    /// Note this string MAY be empty.
    designation: []const u8,

    /// UTC timestamp for the first instant when this ZoneInfo became valid.
    begin_ts: ?i64,
    /// UTC timestamp for the first instant when this ZoneInfo is no longer valid.
    end_ts: ?i64,

    /// An i32 specifying the number of seconds to be added to UTC in order to determine local time.
    /// The value MUST NOT be -2**31 and SHOULD be in the range
    /// [-89999, 93599] (i.e., its value SHOULD be more than -25 hours
    /// and less than 26 hours).  Avoiding -2**31 allows 32-bit clients
    /// to negate the value without overflow.  Restricting it to
    /// [-89999, 93599] allows easy support by implementations that
    /// already support the POSIX-required range [-24:59:59, 25:59:59].
    offset: i32,

    /// A value indicating whether local time should be considered Daylight Saving Time (DST).
    ///
    /// A value of `true` indicates that this type of time is DST.
    /// A value of `false` indicates that this time type is standard time.
    is_dst: bool,

    /// This field indicates whether transitions for this local time type
    /// were specified in the original tzdata as one of:
    ///    * UTC
    ///    * Standard time (local time, ignoring DST)
    ///    * Wall clock time (local time, possibly including DST)
    ///    * POSIX TZ string (predicted future transitions)
    source: enum {
        tzdata_utc,
        tzdata_standard,
        tzdata_wall,
        posix_tz,
    },
};

pub const Transition = struct {
    ts: i64,
    zone_index: u8,
};

/// This is based on Posix definition of the TZ environment variable
pub const POSIX_TZ = struct {
    std_designation: []const u8,
    std_offset: i32,
    dst_designation: ?[]const u8 = null,
    /// This field is ignored when dst is null
    dst_offset: i32 = 0,
    dst_range: ?struct {
        start: Rule,
        end: Rule,
    } = null,

    pub const Rule = union(enum) {
        julian_day: struct {
            /// 1 <= day <= 365. Leap days are not counted and are impossible to refer to
            day: u16,
            /// The default DST transition time is 02:00:00 local time
            time: i32 = 2 * std.time.s_per_hour,
        },
        julian_day_zero: struct {
            /// 0 <= day <= 365. Leap days are counted, and can be referred to.
            day: u16,
            /// The default DST transition time is 02:00:00 local time
            time: i32 = 2 * std.time.s_per_hour,
        },
        /// In the format of "Mm.n.d", where m = month, n = n, and d = day.
        month_nth_week_day: struct {
            /// Month of the year. 1 <= month <= 12
            month: u8,
            /// Specifies which of the weekdays should be used. Does NOT specify the week of the month! 1 <= week <= 5.
            ///
            /// Let's use M3.2.0 as an example. The month is 3, which translates to March.
            /// The day is 0, which means Sunday. `n` is 2, which means the second Sunday
            /// in the month, NOT Sunday of the second week!
            ///
            /// In 2021, this is difference between 2023-03-07 (Sunday of the second week of March)
            /// and 2023-03-14 (the Second Sunday of March).
            ///
            /// * When n is 1, it means the first week in which the day `day` occurs.
            /// * 5 is a special case. When n is 5, it means "the last day `day` in the month", which may occur in either the fourth or the fifth week.
            n: u8,
            /// Day of the week. 0 <= day <= 6. Day zero is Sunday.
            day: u8,
            /// The default DST transition time is 02:00:00 local time
            time: i32 = 2 * std.time.s_per_hour,
        },

        pub fn is_at_start_of_year(self: Rule) bool {
            switch (self) {
                .julian_day => |j| return j.day == 1 and j.time == 0,
                .julian_day_zero => |j| return j.day == 0 and j.time == 0,
                .month_nth_week_day => |mwd| return mwd.month == 1 and mwd.n == 1 and mwd.day == 0 and mwd.time == 0,
            }
        }

        pub fn is_at_end_of_year(self: Rule) bool {
            switch (self) {
                .julian_day => |j| return j.day == 365 and j.time >= 24,
                // Since julian_day_zero dates account for leap year, it would vary depending on the year.
                .julian_day_zero => return false,
                // There is also no way to specify "end of the year" with month_nth_week_day rules
                .month_nth_week_day => return false,
            }
        }

        /// Returned value is the local timestamp when the timezone will transition in the given year.
        pub fn to_secs(self: Rule, yi: Year.Info) i64 {
            switch (self) {
                .julian_day => |j| {
                    var x: i32 = j.day;
                    if (x < 60 or !yi.is_leap) x -= 1;
                    const dt = yi.starting_date.plus_days(x).with_time(.midnight).with_offset(0);
                    return dt.timestamp_s() + j.time;
                },
                .julian_day_zero => |j| {
                    const dt = yi.starting_date.plus_days(j.day).with_time(.midnight).with_offset(0);
                    return dt.timestamp_s() + j.time;
                },
                .month_nth_week_day => |mwd| {
                    const month = Month.from_number(mwd.month);
                    const target_week_day = Week_Day.from_number(mwd.day + 1);
                    const first_of_month = Ordinal_Day.from_yimd(yi, month, .first).date_from_yi(yi);
                    var day = first_of_month;
                    if (day.week_day() != target_week_day) {
                        day = day.advance_to_week_day(target_week_day);
                    }
                    day = day.plus_days(7 * (mwd.n - 1));

                    const first_of_next_month = first_of_month.plus_days(month.days_from_yi(yi));
                    if (!day.is_before(first_of_next_month)) {
                        day = day.plus_days(-7);
                    }

                    const dt = day.with_time(@enumFromInt(mwd.time * 1000)).with_offset(0);
                    return dt.timestamp_s();
                },
            }
        }

        pub fn format(self: Rule, writer: *std.io.Writer) !void {
            switch (self) {
                .julian_day => |julian_day| {
                    try writer.print("J{}", .{julian_day.day});
                },
                .julian_day_zero => |julian_day_zero| {
                    try writer.print("{}", .{julian_day_zero.day});
                },
                .month_nth_week_day => |month_week_day| {
                    try writer.print("M{}.{}.{}", .{
                        month_week_day.month,
                        month_week_day.n,
                        month_week_day.day,
                    });
                },
            }

            const time = switch (self) {
                inline else => |rule| rule.time,
            };

            // Only write out the time if it is not the default time of 02:00
            if (time != 2 * std.time.s_per_hour) {
                const seconds = @mod(time, std.time.s_per_min);
                const minutes = @mod(@divTrunc(time, std.time.s_per_min), 60);
                const hours = @divTrunc(@divTrunc(time, std.time.s_per_min), 60);

                try writer.print("/{}", .{hours});
                if (minutes != 0 or seconds != 0) {
                    try writer.print(":{}", .{minutes});
                }
                if (seconds != 0) {
                    try writer.print(":{}", .{seconds});
                }
            }
        }
    };

    pub fn zone_info(self: POSIX_TZ, utc: i64, last_transition_ts: ?i64) Zone_Info {
        const dst_designation = self.dst_designation orelse {
            std.debug.assert(self.dst_range == null);
            return .{
                .designation = self.std_designation,
                .begin_ts = last_transition_ts,
                .end_ts = null,
                .offset = self.std_offset,
                .is_dst = false,
                .source = .posix_tz,
            };
        };

        if (self.dst_range) |range| {
            const dt = Date_Time.With_Offset.from_timestamp_s(utc, null).dt;
            const yi = dt.date.year_info();
            const start_dst = range.start.to_secs(yi) - self.std_offset;
            const end_dst = range.end.to_secs(yi) - self.dst_offset;

            const is_dst_all_year = range.start.is_at_start_of_year() and range.end.is_at_end_of_year();
            if (is_dst_all_year) {
                return .{
                    .designation = dst_designation,
                    .begin_ts = last_transition_ts,
                    .end_ts = null,
                    .offset = self.dst_offset,
                    .is_dst = true,
                    .source = .posix_tz,
                };
            }

            if (start_dst < end_dst) {
                if (utc >= start_dst and utc < end_dst) {
                    return .{
                        .designation = dst_designation,
                        .begin_ts = @max(last_transition_ts orelse start_dst, start_dst),
                        .end_ts = end_dst,
                        .offset = self.dst_offset,
                        .is_dst = true,
                        .source = .posix_tz,
                    };
                } else if (utc < start_dst) {
                    const prev_yi = Year.from_number(yi.year - 1).info();
                    const prev_end_dst = range.end.to_secs(prev_yi) - self.dst_offset;
                    return .{
                        .designation = self.std_designation,
                        .begin_ts = @max(last_transition_ts orelse prev_end_dst, prev_end_dst),
                        .end_ts = start_dst,
                        .offset = self.std_offset,
                        .is_dst = false,
                        .source = .posix_tz,
                    };
                } else { // utc >= end_dst
                    const next_yi = Year.from_number(yi.year + 1).info();
                    const next_start_dst = range.start.to_secs(next_yi) - self.std_offset;
                    return .{
                        .designation = self.std_designation,
                        .begin_ts = @max(last_transition_ts orelse end_dst, end_dst),
                        .end_ts = next_start_dst,
                        .offset = self.std_offset,
                        .is_dst = false,
                        .source = .posix_tz,
                    };
                }
            } else {
                if (utc >= end_dst and utc < start_dst) {
                    return .{
                        .designation = self.std_designation,
                        .begin_ts = @max(last_transition_ts orelse end_dst, end_dst),
                        .end_ts = start_dst,
                        .offset = self.std_offset,
                        .is_dst = false,
                        .source = .posix_tz,
                    };
                } else if (utc < end_dst) {
                    const prev_yi = Year.from_number(yi.year - 1).info();
                    const prev_start_dst = range.start.to_secs(prev_yi) - self.std_offset;
                    return .{
                        .designation = dst_designation,
                        .begin_ts = @max(last_transition_ts orelse prev_start_dst, prev_start_dst),
                        .end_ts = end_dst,
                        .offset = self.dst_offset,
                        .is_dst = true,
                        .source = .posix_tz,
                    };
                } else { // utc >= start_dst
                    const next_yi = Year.from_number(yi.year + 1).info();
                    const next_end_dst = range.end.to_secs(next_yi) - self.dst_offset;
                    return .{
                        .designation = dst_designation,
                        .begin_ts = @max(last_transition_ts orelse start_dst, start_dst),
                        .end_ts = next_end_dst,
                        .offset = self.dst_offset,
                        .is_dst = true,
                        .source = .posix_tz,
                    };
                }
            }
        } else {
            return .{
                .designation = self.std_designation,
                .begin_ts = last_transition_ts,
                .end_ts = null,
                .offset = self.std_offset,
                .is_dst = false,
                .source = .posix_tz,
            };
        }
    }

    pub fn format(self: POSIX_TZ, writer: *std.io.Writer) !void {
        const should_quote_std_designation = for (self.std_designation) |character| {
            if (!std.ascii.isAlphabetic(character)) {
                break true;
            }
        } else false;

        if (should_quote_std_designation) {
            try writer.writeAll("<");
            try writer.writeAll(self.std_designation);
            try writer.writeAll(">");
        } else {
            try writer.writeAll(self.std_designation);
        }

        const std_offset_west = -self.std_offset;
        const std_seconds = @rem(std_offset_west, std.time.s_per_min);
        const std_minutes = @rem(@divTrunc(std_offset_west, std.time.s_per_min), 60);
        const std_hours = @divTrunc(@divTrunc(std_offset_west, std.time.s_per_min), 60);

        try writer.print("{}", .{std_hours});
        if (std_minutes != 0 or std_seconds != 0) {
            try writer.print(":{}", .{if (std_minutes < 0) -std_minutes else std_minutes});
        }
        if (std_seconds != 0) {
            try writer.print(":{}", .{if (std_seconds < 0) -std_seconds else std_seconds});
        }

        if (self.dst_designation) |dst_designation| {
            const should_quote_dst_designation = for (dst_designation) |character| {
                if (!std.ascii.isAlphabetic(character)) {
                    break true;
                }
            } else false;

            if (should_quote_dst_designation) {
                try writer.writeAll("<");
                try writer.writeAll(dst_designation);
                try writer.writeAll(">");
            } else {
                try writer.writeAll(dst_designation);
            }

            // Only write out the DST offset if it is not just the standard offset plus an hour
            if (self.dst_offset != self.std_offset + std.time.s_per_hour) {
                const dst_offset_west = -self.dst_offset;
                const dst_seconds = @rem(dst_offset_west, std.time.s_per_min);
                const dst_minutes = @rem(@divTrunc(dst_offset_west, std.time.s_per_min), 60);
                const dst_hours = @divTrunc(@divTrunc(dst_offset_west, std.time.s_per_min), 60);

                try writer.print("{}", .{dst_hours});
                if (dst_minutes != 0 or dst_seconds != 0) {
                    try writer.print(":{}", .{if (dst_minutes < 0) -dst_minutes else dst_minutes});
                }
                if (dst_seconds != 0) {
                    try writer.print(":{}", .{if (dst_seconds < 0) -dst_seconds else dst_seconds});
                }
            }
        }

        if (self.dst_range) |dst_range| {
            try writer.print(",{f},{f}", .{ dst_range.start, dst_range.end });
        }
    }

    test format {
        const america_denver = POSIX_TZ{
            .std_designation = "MST",
            .std_offset = -25200,
            .dst_designation = "MDT",
            .dst_offset = -21600,
            .dst_range = .{
                .start = .{
                    .month_nth_week_day = .{
                        .month = 3,
                        .n = 2,
                        .day = 0,
                        .time = 2 * std.time.s_per_hour,
                    },
                },
                .end = .{
                    .month_nth_week_day = .{
                        .month = 11,
                        .n = 1,
                        .day = 0,
                        .time = 2 * std.time.s_per_hour,
                    },
                },
            },
        };

        try std.testing.expectFmt("MST7MDT,M3.2.0,M11.1.0", "{f}", .{america_denver});

        const europe_berlin = POSIX_TZ{
            .std_designation = "CET",
            .std_offset = 3600,
            .dst_designation = "CEST",
            .dst_offset = 7200,
            .dst_range = .{
                .start = .{
                    .month_nth_week_day = .{
                        .month = 3,
                        .n = 5,
                        .day = 0,
                        .time = 2 * std.time.s_per_hour,
                    },
                },
                .end = .{
                    .month_nth_week_day = .{
                        .month = 10,
                        .n = 5,
                        .day = 0,
                        .time = 3 * std.time.s_per_hour,
                    },
                },
            },
        };
        try std.testing.expectFmt("CET-1CEST,M3.5.0,M10.5.0/3", "{f}", .{europe_berlin});

        const antarctica_syowa = POSIX_TZ{
            .std_designation = "+03",
            .std_offset = 3 * std.time.s_per_hour,
            .dst_designation = null,
            .dst_offset = undefined,
            .dst_range = null,
        };
        try std.testing.expectFmt("<+03>-3", "{f}", .{antarctica_syowa});

        const pacific_chatham = POSIX_TZ{
            .std_designation = "+1245",
            .std_offset = 12 * std.time.s_per_hour + 45 * std.time.s_per_min,
            .dst_designation = "+1345",
            .dst_offset = 13 * std.time.s_per_hour + 45 * std.time.s_per_min,
            .dst_range = .{
                .start = .{
                    .month_nth_week_day = .{
                        .month = 9,
                        .n = 5,
                        .day = 0,
                        .time = 2 * std.time.s_per_hour + 45 * std.time.s_per_min,
                    },
                },
                .end = .{
                    .month_nth_week_day = .{
                        .month = 4,
                        .n = 1,
                        .day = 0,
                        .time = 3 * std.time.s_per_hour + 45 * std.time.s_per_min,
                    },
                },
            },
        };
        try std.testing.expectFmt("<+1245>-12:45<+1345>,M9.5.0/2:45,M4.1.0/3:45", "{f}", .{pacific_chatham});
    }
};

fn ts_order(a: i64, b: i64) std.math.Order {
    return std.math.order(a, b);
}

const Date_Time = @import("Date_Time.zig");
const Date = @import("date.zig").Date;
const Week_Day = @import("week_day.zig").Week_Day;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const Month = @import("month.zig").Month;
const Year = @import("year.zig").Year;
const testing = std.testing;
const std = @import("std");
