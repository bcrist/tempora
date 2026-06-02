standard: Info,
dst: ?DST_Info = null,
designation_data: Designation_Data = @splat(0),

pub const Designation_Data = [30:0]u8;

pub fn init(std_abbr: []const u8, std_offset_seconds: i32, dst_abbr: []const u8, dst_offset_seconds: i32, dst_start: Transition, dst_end: Transition) Posix {
    var designation_data: Designation_Data = @splat(0);
    @memcpy(designation_data[0..std_abbr.len], std_abbr);
    @memcpy(designation_data[std_abbr.len + 1 ..][0..dst_abbr.len], dst_abbr);
    return .{
        .standard = .{
            .designation_offset = 0,
            .utc_offset_seconds = std_offset_seconds,
        },
        .dst = .{
            .info = .{
                .designation_offset = @intCast(std_abbr.len + 1),
                .utc_offset_seconds = dst_offset_seconds,
            },
            .start = dst_start,
            .end = dst_end,
        },
        .designation_data = designation_data,
    };
}

pub fn init_standard(designation: []const u8, utc_offset_seconds: i32) Posix {
    var designation_data: Designation_Data = @splat(0);
    @memcpy(designation_data[0..designation.len], designation);
    return .{
        .standard = .{
            .designation_offset = 0,
            .utc_offset_seconds = utc_offset_seconds,
        },
        .designation_data = designation_data,
    };
}

pub fn parse(str: []const u8) !Posix {
    var reader: std.Io.Reader = .fixed(str);
    var self: Posix = .{
        .standard = undefined,
    };
    self.standard = try .parse(&reader, &self.designation_data, null);
    var dst_info: DST_Info = .{
        .info = Info.parse(&reader, &self.designation_data, self.standard.utc_offset_seconds + std.time.s_per_hour) catch |err| switch (err) {
            error.EndOfStream => return self,
            else => |e| return e,
        },
    };

    if (try peek_byte_or_default(&reader, 0) == ',') {
        reader.toss(1);
        dst_info.start = try .parse(&reader);
        if (try peek_byte_or_default(&reader, 0) != ',') return error.MissingDstEndTransition;
        reader.toss(1);
        dst_info.end = try .parse(&reader);
    }

    if (reader.seek != reader.end) return error.UnexpectedTzStringSuffix;

    self.dst = dst_info;
    return self;
}

pub fn format(self: Posix, w: *std.Io.Writer) std.Io.Writer.Error!void {
    try w.print("{f}", .{ self.standard.fmt(&self, null) });
    if (self.dst) |dst| {
        try w.print("{f}", .{ dst.info.fmt(&self, self.standard.utc_offset_seconds + std.time.s_per_hour) });
        if (!std.meta.eql(dst.start, Transition.default_start) or !std.meta.eql(dst.end, Transition.default_end)) {
            try w.print(",{f},{f}", .{ dst.start, dst.end });
        }
    }
}

pub fn info(self: *const Posix, timestamp_utc_seconds: i64, last_transition_ts: ?i64) Wall_Time_Info {
    if (self.dst) |dst| {
        if (dst.start.is_start_of_year() and dst.end.is_end_of_year(self.standard.utc_offset_seconds, dst.info.utc_offset_seconds)) {
            return self.make_info(.dst, last_transition_ts, null);
        }

        const dt = Date_Time.With_Offset.from_timestamp_s(timestamp_utc_seconds, null).dt;
        const yi = dt.date.year_info();
        const start = dst.start.resolve_ts(yi) - self.standard.utc_offset_seconds;
        const end = dst.end.resolve_ts(yi) - dst.info.utc_offset_seconds;

        if (start < end) {
            if (timestamp_utc_seconds >= start and timestamp_utc_seconds < end) {
                return self.make_info(.dst, @max(last_transition_ts orelse start, start), end);
            } else if (timestamp_utc_seconds < start) {
                const prev_end = dst.end.resolve_ts(yi.prev()) - dst.info.utc_offset_seconds;
                return self.make_info(.std, @max(last_transition_ts orelse prev_end, prev_end), start);
            } else {
                const next_start = dst.start.resolve_ts(yi.next()) - self.standard.utc_offset_seconds;
                return self.make_info(.std, @max(last_transition_ts orelse end, end), next_start);
            }
        } else {
            if (timestamp_utc_seconds >= end and timestamp_utc_seconds < start) {
                return self.make_info(.std, @max(last_transition_ts orelse end, end), start);
            } else if (timestamp_utc_seconds < end) {
                const prev_start = dst.start.resolve_ts(yi.prev()) - self.standard.utc_offset_seconds;
                return self.make_info(.dst, @max(last_transition_ts orelse prev_start, prev_start), end);
            } else {
                const next_end = dst.end.resolve_ts(yi.next()) - dst.info.utc_offset_seconds;
                return self.make_info(.dst, @max(last_transition_ts orelse start, start), next_end);
            }
        }
    }
    
    return self.make_info(.std, last_transition_ts, null);
}

fn make_info(self: *const Posix, dst: Wall_Time_Info.DST_Indicator, begin_ts: ?i64, end_ts: ?i64) Wall_Time_Info {
    const designation_offset = switch (dst) {
        .std => self.standard.designation_offset,
        .dst => self.dst.?.info.designation_offset,
    };
    return .{
        .designation = std.mem.sliceTo(self.designation_data[designation_offset..], 0),
        .begin_ts = begin_ts,
        .end_ts = end_ts,
        .utc_offset_seconds = switch (dst) {
            .std => self.standard.utc_offset_seconds,
            .dst => self.dst.?.info.utc_offset_seconds,
        },
        .dst = dst,
        .source = .posix_tz,
    };
}

pub fn requires_tzif_v3(self: Posix) bool {
    return if (self.dst) |dst| dst.start.requires_tzif_v3() or dst.end.requires_tzif_v3() else false;
}

pub fn std_designation(self: *const Posix) []const u8 {
    return std.mem.sliceTo(self.designation_data[self.standard.designation_offset..], 0);
}

pub fn dst_designation(self: *const Posix) []const u8 {
    if (self.dst) |dst| {
        return std.mem.sliceTo(self.designation_data[dst.info.designation_offset..], 0);
    }
    return "";
}

pub const Info = struct {
    designation_offset: u5,
    utc_offset_seconds: i32,

    /// Note `r` should be created from std.Io.Reader.fixed() or otherwise have all remaining data buffered.
    pub fn parse(r: *std.Io.Reader, designation_data: *Designation_Data, default_offset: ?i32) !Info {
        const designation: []const u8 = if ((try r.peekByte()) == '<') designation: {
            r.toss(1);
            if (std.mem.findScalar(u8, r.buffered(), '>')) |bytes| {
                const designation = r.peek(bytes) catch unreachable;
                r.toss(bytes + 1);
                break :designation designation;
            } else return error.MissingEndOfDesignation;
        } else try r.take(find_non_alpha(r.buffered()) orelse r.buffered().len);
        if (designation.len == 0) return error.DesignationEmpty;

        var designation_data_offset = std.mem.findScalar(u8, designation_data[0..], 0) orelse designation_data.len;
        if (designation_data_offset > 0) designation_data_offset += 1;
        if (designation_data_offset + designation.len > designation_data.len) return error.DesignationTooLong;
        @memcpy(designation_data[designation_data_offset..][0..designation.len], designation);

        const offset = if (try parse_hms(r)) |neg_offset| -neg_offset else default_offset orelse return error.MissingUtcOffset;
        return .{
            .designation_offset = @intCast(designation_data_offset),
            .utc_offset_seconds = offset,
        };
    }

    pub fn fmt(self: Info, posix: *const Posix, default_offset: ?i32) Formatter {
        return .{
            .info = self,
            .data = &posix.designation_data,
            .omit_offset = if (default_offset) |offset| self.utc_offset_seconds == offset else false,
        };
    }

    pub const Formatter = struct {
        info: Info,
        data: *const Designation_Data,
        omit_offset: bool,

        pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void {
            const slice: [:0]const u8 = std.mem.sliceTo(self.data[self.info.designation_offset..], 0);
            if (find_non_alpha(slice)) |_| {
                try w.writeByte('<');
                try w.writeAll(slice);
                try w.writeByte('>');
            } else {
                try w.writeAll(slice);
            }

            if (!self.omit_offset) try format_hms(-self.info.utc_offset_seconds, w);
        }
    };
};

pub const DST_Info = struct {
    info: Info,
    start: Transition = .default_start,
    end: Transition = .default_end,
};

pub const Transition = struct {
    date: Transition_Date,
    time: Time = .@"2am",

    pub const default_start: Transition = .{ .date = .{ .month_week_day = .{
        .month = .march,
        .week = .second,
        .day = .sunday,
    }}};

    pub const default_end: Transition = .{ .date = .{ .month_week_day = .{
        .month = .november,
        .week = .first,
        .day = .sunday,
    }}};

    pub fn parse(r: *std.Io.Reader) !Transition {
        const date: Transition_Date = try .parse(r);
        var time: Time = .@"2am";
        if (try peek_byte_or_default(r, 0) == '/') {
            r.toss(1);
            const seconds = try parse_hms(r) orelse return error.MissingTransitionTime;
            time = @enumFromInt(1000 * seconds);
        }
        return .{
            .date = date,
            .time = time,
        };
    }

    pub fn format(self: Transition, w: *std.Io.Writer) std.Io.Writer.Error!void {
        try self.date.format(w);
        if (self.time != .@"2am") {
            try w.writeByte('/');
            try format_hms(self.time.seconds_since_midnight(), w);
        }
    }

    pub fn resolve(self: Transition, yi: Year.Info) Date_Time {
        return self.date.resolve(yi).with_time(self.time);
    }

    pub fn resolve_ts(self: Transition, yi: Year.Info) i64 {
        return self.resolve(yi).with_offset(0).timestamp_s();
    }

    pub fn is_start_of_year(self: Transition) bool {
        if (self.time.is_after(.midnight)) return false;
        return self.date.is_start_of_year();
    }

    pub fn is_end_of_year(self: Transition, std_offset: i32, dst_offset: i32) bool {
        // Note: RFC 9636 section 3.3.1 says that for DST all year to be detected,
        // the DST offset should be less than/west of the standard offset.
        // And indeed, zic.c explicitly turns DST all year with a positive (dst_offset - std_offset)
        // into a fake zone with the std offset mirrored to the east (at least in tzcode 2026b).
        // But RFC 8536 does not include this stipulation, so we're not enforcing it:
        //      if (dst_offset >= std_offset) return false;
        if (self.time.is_before(Time.midnight_eod.plus_seconds(dst_offset - std_offset))) return false;
        return self.date.is_end_of_year();
    }

    pub fn requires_tzif_v3(self: Transition) bool {
        return self.time.is_before(.midnight) or self.time.is_after(.midnight_eod);
    }
};

pub const Transition_Date = union (enum) {
    ordinal_day: Ordinal_Day,
    ordinal_day_no_leap: Ordinal_Day, // Feb 29 is not counted, even if it exists
    month_week_day: struct {
        month: Month,
        week: Week_Index,
        day: Week_Day,
    },

    pub fn parse(r: *std.Io.Reader) !Transition_Date {
        switch (try r.peekByte()) {
            'M' => {
                r.toss(1);
                const month = try parse_unsigned(r, 1, 2) orelse return error.InvalidMonth;
                if (try peek_byte_or_default(r, 0) != '.') return error.ExpectedDot;
                r.toss(1);
                const week = try parse_unsigned(r, 1, 1) orelse return error.InvalidWeek;
                if (try peek_byte_or_default(r, 0) != '.') return error.ExpectedDot;
                r.toss(1);
                const dow = try parse_unsigned(r, 1, 1) orelse return error.InvalidDayOfWeek;
                if (month == 0 or month > 12) return error.InvalidMonth;
                if (week == 0 or week > 5) return error.InvalidWeek;
                if (dow > 6) return error.InvalidDayOfWeek;
                return .{ .month_week_day = .{
                    .month = .from_number(month),
                    .week = @enumFromInt(week - 1),
                    .day = .from_number(dow + 1),
                }};
            },
            'J' => {
                r.toss(1);
                const julian = try parse_unsigned(r, 1, 3) orelse return error.InvalidJulianOrdinalDay;
                if (julian == 0 or julian > 365) return error.InvalidJulianOrdinalDay;
                return .{ .ordinal_day_no_leap = .from_number(julian) };
            },
            else => {
                const od = try parse_unsigned(r, 1, 3) orelse return error.InvalidOrdinalDay;
                if (od > 365) return error.InvalidOrdinalDay;
                return .{ .ordinal_day = .from_number(od + 1) };
            },
        }
    }

    pub fn format(self: Transition_Date, w: *std.Io.Writer) std.Io.Writer.Error!void {
        switch (self) {
            .ordinal_day => |od| try w.print("{d}", .{ od.as_unsigned() - 1 }),
            .ordinal_day_no_leap => |od| try w.print("J{d}", .{ od.as_unsigned() }),
            .month_week_day => |mwd| try w.print("M{d}.{d}.{d}", .{
                mwd.month.as_unsigned(),
                @intFromEnum(mwd.week) + 1,
                mwd.day.as_unsigned() - 1,
            }),
        }
    }

    pub fn resolve(self: Transition_Date, yi: Year.Info) Date {
        return switch (self) {
            .ordinal_day => |od| .from_yiod(yi, od),
            .ordinal_day_no_leap => |od| .from_yiod(yi, if (od.is_before(.leap_day) or !yi.is_leap) od else od.next()),
            .month_week_day => |mwd| d: {
                const first_of_month = yi.ymd(mwd.month, .first).date();
                var d = mwd.day.on_or_after(first_of_month).plus_days(mwd.week.offset_days());
                switch (mwd.week) {
                    .first, .second, .third => {}, // we can never overshoot the end of the month for these
                    else => {
                        const first_of_next_month = first_of_month.plus_days(mwd.month.days_from_yi(yi));
                        while (!d.is_before(first_of_next_month)) d = d.plus_days(-7);
                    },
                }
                break :d d;
            },
        };
    }

    pub fn is_start_of_year(self: Transition_Date) bool {
        return switch (self) {
            .ordinal_day, .ordinal_day_no_leap => |od| od == .first,
            .month_week_day => false,
        };
    }

    pub fn is_end_of_year(self: Transition_Date) bool {
        return switch (self) {
            .ordinal_day_no_leap => |od| od.as_number() == 365,
            .ordinal_day, .month_week_day => false,
        };
    }
};

pub const Week_Index = enum (u3) {
    first = 0,
    second = 1,
    third = 2,
    fourth = 3,
    last = 4,

    pub fn offset_days(self: Week_Index) i32 {
        return @as(i32, @intFromEnum(self)) * 7;
    }
};

fn format_hms(offset: i32, w: *std.Io.Writer) std.Io.Writer.Error!void {
    var remaining: u33 = undefined;
    if (offset < 0) {
        try w.writeByte('-');
        remaining = @intCast(-offset);
    } else {
        remaining = @intCast(offset);
    }

    const seconds = remaining % 60;
    remaining /= 60;
    const minutes = remaining % 60;
    remaining /= 60;
    const hours = remaining;

    try w.print("{d}", .{ hours });
    if (minutes != 0 or seconds != 0) {
        try w.print(":{d:0>2}", .{ minutes });
    }
    if (seconds != 0) {
        try w.print(":{d:0>2}", .{ seconds });
    }
}

fn parse_hms(reader: *std.Io.Reader) !?i32 {
    const negate: bool = switch (try peek_byte_or_default(reader, 0)) {
        '+' => negate: {
            reader.toss(1);
            break :negate false;
        },
        '-' => negate: {
            reader.toss(1);
            break :negate true;
        },
        else => false,
    };

    const hours = try parse_unsigned(reader, 1, 3) orelse return null;
    var minutes: i32 = 0;
    var seconds: i32 = 0;

    if ((try peek_byte_or_default(reader, 0)) == ':') {
        reader.toss(1);
        minutes = try parse_unsigned(reader, 2, 2) orelse return error.InvalidMinutes;

        if ((try peek_byte_or_default(reader, 0)) == ':') {
            reader.toss(1);
            seconds = try parse_unsigned(reader, 2, 2) orelse return error.InvalidSeconds;
        }
    }

    if (seconds > 59) return error.InvalidSeconds;
    if (minutes > 59) return error.InvalidMinutes;
    if (hours > 167) return error.InvalidHours;

    const offset = hours * (60 * 60) + minutes * 60 + seconds;
    return if (negate) -offset else offset;
}

fn parse_unsigned(reader: *std.Io.Reader, min_digits: usize, max_digits: usize) !?i32 {
    std.debug.assert(min_digits <= max_digits);
    var number: i32 = 0;
    for (0..min_digits) |_| switch (try peek_byte_or_default(reader, 0)) {
        '0'...'9' => |b| {
            reader.toss(1);
            number = try std.math.mul(i32, number, 10);
            number = try std.math.add(i32, number, b - '0');
        },
        else => return null,
    };
    for (min_digits..max_digits) |_| switch (try peek_byte_or_default(reader, 0)) {
        '0'...'9' => |b| {
            reader.toss(1);
            number = try std.math.mul(i32, number, 10);
            number = try std.math.add(i32, number, b - '0');
        },
        else => return number,
    };

    return switch (try peek_byte_or_default(reader, 0)) {
        '0'...'9' => null,
        else => number,
    };
}

fn peek_byte_or_default(r: *std.Io.Reader, default: u8) !u8 {
    return r.peekByte() catch |err| switch (err) {
        error.EndOfStream => default,
        else => |e| return e,
    };
}

pub fn find_non_alpha(str: []const u8) ?usize {
    for (str, 0..) |c, i| {
        if (!is_alpha(c)) return i;
    }
    return null;
}

fn is_alpha(c: u8) bool {
    return switch (c | 0x20) {
        'a'...'z' => true,
        else => false,
    };
}

const Posix = @This();

const Wall_Time_Info = @import("Wall_Time_Info.zig");
const Date_Time = @import("../Date_Time.zig");
const Time = @import("../time.zig").Time;
const Date = @import("../date.zig").Date;
const Week_Day = @import("../week_day.zig").Week_Day;
const Ordinal_Day = @import("../ordinal_day.zig").Ordinal_Day;
const Month = @import("../month.zig").Month;
const Year = @import("../year.zig").Year;
const std = @import("std");
