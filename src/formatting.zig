const eval_branch_quota = 100_000;

pub const default_from_string_trim = std.ascii.whitespace ++ "-/,._'";

pub fn format(dto: Date_Time.With_Offset, comptime pattern: []const u8, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    @setEvalBranchQuota(eval_branch_quota);

    comptime var iter = Token.iterator(pattern);
    comptime var need_year = false;
    comptime var need_month_day = false;
    comptime var need_ordinal_day = false;
    comptime var need_week_day = false;
    comptime var need_iso_week_date = false;
    inline while (comptime iter.next()) |token| {
        switch (token) {
            .y, .Y, .YY, .YYY, .YYYY, .YYYYYY, .N, .NN => need_year = true,
            .MM, .M, .Mo, .MMM, .MMMM, .Q, .Qo => need_month_day = true,
            .D, .Do, .DD => need_month_day = true,
            .DDD, .DDDo, .DDDD => need_ordinal_day = true,
            .d, .do, .dd, .ddd, .dddd, .E, .Eo => need_week_day = true,
            .w, .wo, .ww => need_ordinal_day = true,
            .W, .Wo, .WW, .G, .GG, .GGGG => need_iso_week_date = true,
            else => {},
        }
    }

    var ymd: Date.YMD = undefined;
    var od: Ordinal_Day = undefined;
    var wd: Week_Day = undefined;
    var iwd: ISO_Week_Date = undefined;

    if (need_month_day) {
        ymd = dto.dt.date.ymd();
    } else if (need_year) {
        ymd.year = dto.dt.date.year();
    }
    if (need_ordinal_day) od = dto.dt.date.ordinal_day();
    if (need_iso_week_date) iwd = .from_date(dto.dt.date);
    if (need_week_day) wd = if (need_iso_week_date) iwd.day else dto.dt.date.week_day();

    iter = comptime Token.iterator(pattern);
    inline while (comptime iter.next()) |token| switch (token) {
        .MM => try writer.print("{d:0>2}", .{ ymd.month.as_unsigned() }),
        .M => try writer.print("{d}", .{ ymd.month.as_unsigned() }),
        .Mo => try write_ordinal(writer, ymd.month.as_unsigned()),
        .MMM => try writer.writeAll(ymd.month.short_name()),
        .MMMM => try writer.writeAll(ymd.month.name()),

        .Q => try writer.print("{d}", .{ (ymd.month.as_unsigned() - 1) / 3 + 1 }),
        .Qo => try write_ordinal(writer, (ymd.month.as_unsigned() - 1) / 3 + 1),

        .D => try writer.print("{d}", .{ ymd.day.as_unsigned() }),
        .Do => try write_ordinal(writer, ymd.day.as_unsigned()),
        .DD => try writer.print("{d:0>2}", .{ ymd.day.as_unsigned() }),

        .DDD => try writer.print("{d}", .{ od.as_unsigned() }),
        .DDDo => try write_ordinal(writer, od.as_unsigned()),
        .DDDD => try writer.print("{d:0>3}", .{ od.as_unsigned() }),

        .d => try writer.print("{d}", .{ wd.as_unsigned() - 1 }),
        .do => try write_ordinal(writer, wd.as_unsigned() - 1),
        .dd => try writer.writeAll(wd.name()[0..2]),
        .ddd => try writer.writeAll(wd.short_name()),
        .dddd => try writer.writeAll(wd.name()),
        .E => try writer.print("{d}", .{ wd.as_iso() }),
        .Eo => try write_ordinal(writer, wd.as_iso()),

        .w => try writer.print("{d}", .{ od.ordinal_week().as_unsigned() }),
        .wo => try write_ordinal(writer, od.ordinal_week().as_unsigned()),
        .ww => try writer.print("{d:0>2}", .{ od.ordinal_week().as_unsigned() }),

        .W => try writer.print("{d}", .{ iwd.week.as_unsigned() }),
        .Wo => try write_ordinal(writer, iwd.week.as_unsigned()),
        .WW => try writer.print("{d:0>2}", .{ iwd.week.as_unsigned() }),

        .G => if (iwd.year.as_number() > 9999 or iwd.year.as_number() < 0) {
            try writer.print("{d}", .{ iwd.year.as_number() });
        } else {
            try writer.print("{d}", .{ iwd.year.as_unsigned() });
        },
        .GG => try writer.print("{d:0>2}", .{ @as(u32, @intCast(@abs(iwd.year.as_number()) % 100)) }),
        .GGGG => try writer.print("{d:0>4}", .{ @as(u32, @intCast(@abs(iwd.year.as_number()) % 10000)) }),

        .y => try writer.print("{d}", .{ @as(u32, @intCast(@abs(ymd.year.as_number()))) }),
        .YY => try writer.print("{d:0>2}", .{ @as(u32, @intCast(@abs(ymd.year.as_number()) % 100)) }),
        .YYYY => try writer.print("{d:0>4}", .{ @as(u32, @intCast(@abs(ymd.year.as_number()) % 10000)) }),
        .Y => if (ymd.year.as_number() > 9999 or ymd.year.as_number() < 0) {
            try writer.print("{d}", .{ ymd.year.as_number() });
        } else {
            try writer.print("{d}", .{ ymd.year.as_unsigned() });
        },
        .YYY => if (ymd.year.as_number() > 9999) {
            try writer.print("+{d:0>6}", .{ ymd.year.as_unsigned() });
        } else if (ymd.year.as_number() < 0) {
            try writer.print("{d}", .{ ymd.year.as_number() });
        } else {
            try writer.print("{d}", .{ ymd.year.as_unsigned() });
        },
        .YYYYYY => if (ymd.year.as_number() < 0) {
            try writer.print("-{d:0>6}", .{ @as(u32, @intCast(-ymd.year.as_number())) });
        } else if (ymd.year.as_number() == 0) {
            try writer.writeAll("000000");
        } else {
            try writer.print("+{d:0>6}", .{ ymd.year.as_unsigned() });
        },

        .N, .NN => if (ymd.year.as_number() > 0) {
            try writer.writeAll("AD");
        } else if (ymd.year.as_number() < 0) {
            try writer.writeAll("BC");
        },

        .literal => |text| {
            try writer.writeAll(text);
        },

        .A => try writer.writeAll(if (dto.dt.time.hours() < 12) "AM" else "PM"),
        .a => try writer.writeAll(if (dto.dt.time.hours() < 12) "am" else "pm"),
        .H => try writer.print("{d}", .{ @as(u32, @intCast(dto.dt.time.hours())) }),
        .HH => try writer.print("{d:0>2}", .{ @as(u32, @intCast(dto.dt.time.hours())) }),
        .K, .KK => try writer.print("{d: >2}", .{ @as(u32, @intCast(dto.dt.time.hours())) }),
        .h => try writer.print("{d}", .{ @as(u32, @intCast(switch (dto.dt.time.hours()) {
            0 => 12,
            1...12 => |h| h,
            else => |h| h - 12,
        })) }),
        .hh => try writer.print("{d:0>2}", .{ @as(u32, @intCast(switch (dto.dt.time.hours()) {
            0 => 12,
            1...12 => |h| h,
            else => |h| h - 12,
        })) }),
        .k, .kk => try writer.print("{d: >2}", .{ @as(u32, @intCast(switch (dto.dt.time.hours()) {
            0 => 12,
            1...12 => |h| h,
            else => |h| h - 12,
        })) }),
        .m => try writer.print("{d}", .{ @as(u32, @intCast(dto.dt.time.minutes())) }),
        .mm => try writer.print("{d:0>2}", .{ @as(u32, @intCast(dto.dt.time.minutes())) }),
        .s => try writer.print("{d}", .{ @as(u32, @intCast(dto.dt.time.seconds())) }),
        .ss => try writer.print("{d:0>2}", .{ @as(u32, @intCast(dto.dt.time.seconds())) }),
        .S => try writer.print("{d}", .{ @as(u32, @intCast(@divFloor(dto.dt.time.ms(), 100))) }),
        .SS => try writer.print("{d:0>2}", .{ @as(u32, @intCast(@divFloor(dto.dt.time.ms(), 10))) }),
        .SSS => try writer.print("{d:0>3}", .{ @as(u32, @intCast(dto.dt.time.ms())) }),
        .z, .zz, .Z, .ZZ => done: {
            if (token == .z or token == .zz) {
                if (dto.timezone) |tz| {
                    const utc = dto.timestamp_ms();
                    const zi = tz.zone_info(@divFloor(utc, 1000));
                    if (zi.designation.len > 0) {
                        try writer.writeAll(zi.designation);
                        break :done;
                    }
                }
            }

            const minutes: u32 = @intCast(@divFloor(@abs(dto.utc_offset_ms), 60 * 1000));

            if (token == .zz or token == .ZZ) {
                if (dto.utc_offset_ms < 0) {
                    try writer.print("-{d:0>4}", .{ minutes });
                } else {
                    try writer.print("+{d:0>4}", .{ minutes });
                }
            } else {
                if (dto.utc_offset_ms < 0) {
                    try writer.print("-{d:0>2}:{d:0>2}", .{ @divFloor(minutes, 60), @mod(minutes, 60) });
                } else {
                    try writer.print("+{d:0>2}:{d:0>2}", .{ @divFloor(minutes, 60), @mod(minutes, 60) });
                }
            }
        },
        .x => try writer.print("{d}", .{ dto.timestamp_ms() }),
        .X => try writer.print("{d}", .{ dto.timestamp_s() }),
    };
}

const Parse_Error = error {
    InvalidString,
    EndOfStream,
    ReadFailed,
    TzdbCacheNotInitialized,
};

pub fn Parse_Result(comptime pattern: []const u8) type {
    @setEvalBranchQuota(eval_branch_quota);

    comptime var has_month: bool = false;
    comptime var has_day: bool = false;
    comptime var has_ordinal_day: bool = false;
    comptime var has_week_day: bool = false;
    comptime var has_ordinal_week: bool = false;
    comptime var has_iso_week: bool = false;
    comptime var has_year: bool = false;
    comptime var has_iso_week_year: bool = false;
    comptime var has_hours: bool = false;
    comptime var has_minutes: bool = false;
    comptime var has_seconds: bool = false;
    comptime var has_ms: bool = false;
    comptime var has_utc_offset_ms: bool = false;
    comptime var has_timestamp: bool = false;

    comptime var iter = Token.iterator(pattern);
    inline while (comptime iter.next()) |token| {
        switch (token) {
            .MM, .M, .Mo, .MMM, .MMMM => has_month = true,
            .Q, .Qo => {},
            .D, .Do, .DD => has_day = true,
            .DDD, .DDDo, .DDDD => has_ordinal_day = true,
            .d, .do, .dd, .ddd, .dddd, .E, .Eo => has_week_day = true,
            .w, .wo, .ww => has_ordinal_week = true,
            .W, .Wo, .WW => has_iso_week = true,
            .y, .Y, .YY, .YYY, .YYYY, .YYYYYY => has_year = true,
            .G, .GG, .GGGG => has_iso_week_year = true,
            .N, .NN => {},
            .A, .a => {},
            .H, .HH, .h, .hh, .k, .kk, .K, .KK => has_hours = true,
            .m, .mm => has_minutes = true,
            .s, .ss => has_seconds = true,
            .S, .SS, .SSS => has_ms = true,
            .Z, .ZZ, .z, .zz => has_utc_offset_ms = true,
            .x, .X => has_timestamp = true,
            .literal => {},
        }
    }

    return struct {
        timestamp: if (has_timestamp) i64 else void,
        year: if (has_year) Year else void,
        month: if (has_month) Month else void,
        day: if (has_day) Day else void,
        ordinal_day: if (has_ordinal_day) Ordinal_Day else void,
        ordinal_week: if (has_ordinal_week) Ordinal_Week else void,
        iso_week: if (has_iso_week) ISO_Week else void,
        iso_week_year: if (has_iso_week_year) Year else void,
        week_day: if (has_week_day) Week_Day else void,
        hours: if (has_hours) i32 else void,
        minutes: if (has_minutes) i32 else void,
        seconds: if (has_seconds) i32 else void,
        ms: if (has_ms) i32 else void,
        utc_offset_ms: if (has_utc_offset_ms) i32 else void,
    };
}

pub fn parse(comptime pattern: []const u8, reader: *std.Io.Reader) Parse_Error!Parse_Result(pattern) {
    var parsed: Parse_Result(pattern) = undefined;
    @setEvalBranchQuota(eval_branch_quota);

    var negate_year = false;
    var hours_is_pm = false;
    comptime var has_am_pm = false;

    comptime var iter = Token.iterator(pattern);
    inline while (comptime iter.next()) |token| {
        switch (token) {
            .MM => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                parsed.month = try Month.from_string(&buf, .{
                    .trim = "",
                    .allow_short = false,
                    .allow_long = false,
                });
            },
            .M, .Mo => {
                const raw = try read_int(u4, reader);
                if (raw < 1 or raw > 12) return error.InvalidString;
                parsed.month = Month.from_number(raw);

                if (token == .Mo) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .MMM, .MMMM => {
                var buf: [3]u8 = undefined;
                try reader.readSliceAll(&buf);
                const m = try Month.from_string(&buf, .{
                    .trim = "",
                    .allow_long = false,
                    .allow_numeric = false,
                });
                parsed.month = m;

                if (token == .MMMM) {
                    const remaining = m.name()[3..];
                    var buf2: [16]u8 = undefined;
                    try reader.readSliceAll(buf2[0..remaining.len]);
                    if (!std.ascii.eqlIgnoreCase(remaining, buf2[0..remaining.len])) {
                        return error.InvalidString;
                    }
                }
            },

            .Q, .Qo => {},

            .D, .Do => {
                const raw = try read_int(u5, reader);
                if (raw < 1 or raw > 31) return error.InvalidString;
                parsed.day = Day.from_number(raw);

                if (token == .Do) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .DD => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u5, &buf, 10) catch return error.InvalidString;
                if (num < 1 or num > 31) return error.InvalidString;
                parsed.day = Day.from_number(num);
            },

            .DDD, .DDDo => {
                const raw = try read_int(u9, reader);
                if (raw < 1 or raw > 366) return error.InvalidString;
                parsed.ordinal_day = Ordinal_Day.from_number(raw);

                if (token == .DDDo) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .DDDD => {
                var buf: [3]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u5, &buf, 10) catch return error.InvalidString;
                if (num < 1 or num > 366) return error.InvalidString;
                parsed.ordinal_day = Ordinal_Day.from_number(num);
            },

            .d, .do => {
                const raw = try read_int(u4, reader) + 1;
                if (raw < 1 or raw > 7) return error.InvalidString;
                parsed.week_day = Week_Day.from_number(raw);

                if (token == .do) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .dd, .ddd, .dddd => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const d = try Week_Day.from_string(&buf, .{
                    .trim = "",
                    .allow_long = false,
                    .allow_numeric = false,
                });
                parsed.week_day = d;

                if (token == .ddd) {
                    if (d.name()[2] != std.ascii.toLower(try reader.takeByte())) {
                        return error.InvalidString;
                    }
                } else if (token == .dddd) {
                    const remaining = d.name()[2..];
                    var buf2: [16]u8 = undefined;
                    try reader.readSliceAll(buf2[0..remaining.len]);
                    if (!std.ascii.eqlIgnoreCase(remaining, buf2[0..remaining.len])) {
                        return error.InvalidString;
                    }
                }
            },

            .E, .Eo => {
                const raw = try read_int(u4, reader);
                if (raw < 1 or raw > 7) return error.InvalidString;
                parsed.week_day = Week_Day.from_iso(raw);

                if (token == .Eo) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },

            .w, .wo => {
                const raw = try read_int(u6, reader);
                if (raw < 1 or raw > 53) return error.InvalidString;
                parsed.ordinal_week = Ordinal_Week.from_number(raw);

                if (token == .wo) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .ww => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u6, &buf, 10) catch return error.InvalidString;
                if (num < 1 or num > 53) return error.InvalidString;
                parsed.ordinal_week = Ordinal_Week.from_number(num);
            },

            .W, .Wo => {
                const raw = try read_int(u6, reader);
                if (raw < 1 or raw > 53) return error.InvalidString;
                parsed.iso_week = ISO_Week.from_number(raw);

                if (token == .Wo) {
                    _ = try reader.takeByte();
                    _ = try reader.takeByte();
                }
            },
            .WW => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u6, &buf, 10) catch return error.InvalidString;
                if (num < 1 or num > 53) return error.InvalidString;
                parsed.iso_week = ISO_Week.from_number(num);
            },

            .y, .Y, .YYY, .YYYYYY => {
                const raw = try read_int(i32, reader);
                parsed.year = Year.from_number(raw);
            },
            .YY => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                parsed.year = try Year.from_string(&buf, .{
                    .trim = "",
                    .allow_non_two_digit_year = false,
                });
            },
            .YYYY => {
                var buf: [4]u8 = undefined;
                try reader.readSliceAll(&buf);
                parsed.year = try Year.from_string(&buf, .{
                    .trim = "",
                    .allow_two_digit_year = false,
                });
            },

            .G => {
                const raw = try read_int(i32, reader);
                parsed.iso_week_year = Year.from_number(raw);
            },
            .GG => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                parsed.iso_week_year = try Year.from_string(&buf, .{
                    .trim = "",
                    .allow_non_two_digit_year = false,
                });
            },
            .GGGG => {
                var buf: [4]u8 = undefined;
                try reader.readSliceAll(&buf);
                parsed.iso_week_year = try Year.from_string(&buf, .{
                    .trim = "",
                    .allow_two_digit_year = false,
                });
            },

            .N, .NN => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                negate_year = std.ascii.eqlIgnoreCase(&buf, "BC");
            },

            .A, .a => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                hours_is_pm = std.ascii.eqlIgnoreCase(&buf, "PM");
                has_am_pm = true;
            },

            .H, .h => {
                const raw = try read_int(u5, reader);
                if (raw > 24) return error.InvalidString;
                parsed.hours = raw;
            },
            .HH, .hh => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u5, &buf, 10) catch return error.InvalidString;
                if (num > 24) return error.InvalidString;
                parsed.hours = num;
            },
            .k, .kk, .K, .KK => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u5, std.mem.trimStart(u8, &buf, " "), 10) catch return error.InvalidString;
                if (num > 24) return error.InvalidString;
                parsed.hours = num;
            },

            .m => {
                const raw = try read_int(u6, reader);
                if (raw > 59) return error.InvalidString;
                parsed.minutes = raw;
            },
            .mm => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u6, &buf, 10) catch return error.InvalidString;
                if (num > 59) return error.InvalidString;
                parsed.minutes = num;
            },

            .s => {
                const raw = try read_int(u6, reader);
                if (raw > 59) return error.InvalidString;
                parsed.seconds = raw;
            },
            .ss => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u6, &buf, 10) catch return error.InvalidString;
                if (num > 59) return error.InvalidString;
                parsed.seconds = num;
            },

            .S => {
                var buf: [1]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u10, &buf, 10) catch return error.InvalidString;
                if (num > 9) return error.InvalidString;
                parsed.ms = num;
            },
            .SS => {
                var buf: [2]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u10, &buf, 10) catch return error.InvalidString;
                if (num > 99) return error.InvalidString;
                parsed.ms = num;
            },
            .SSS => {
                var buf: [3]u8 = undefined;
                try reader.readSliceAll(&buf);
                const num = std.fmt.parseInt(u10, &buf, 10) catch return error.InvalidString;
                if (num > 999) return error.InvalidString;
                parsed.ms = num;
            },

            .Z, .ZZ => parsed.utc_offset_ms = try read_utc_offset(reader, token == .Z),
            .z, .zz => {
                var buf: [5]u8 = undefined;
                const designation: []const u8 = for (0.., &buf) |i, *b| {
                    const ch = reader.peekByte() catch |err| switch (err) {
                        error.EndOfStream => break buf[0..i],
                        else => return err,
                    };
                    
                    if (std.ascii.isAlphabetic(ch)) {
                        b.* = ch;
                        reader.toss(1);
                    } else {
                        break buf[0..i];
                    }
                } else &buf;

                if (designation.len == 0) {
                    parsed.utc_offset_ms = try read_utc_offset(reader, token == .z);
                } else if (try tzdb.designation_offset_ms(designation)) |offset_ms| {
                    parsed.utc_offset_ms = offset_ms;
                } else return error.InvalidString;
            },

            .x, .X => {
                var raw = try read_int(i64, reader);
                if (token == .X) {
                    raw = std.math.mul(i64, raw, 1000) catch return error.InvalidString;
                }
                parsed.timestamp = raw;
            },

            .literal => |text| {
                var buf: [text.len]u8 = undefined;
                try reader.readSliceAll(&buf);
                if (!std.ascii.eqlIgnoreCase(&buf, text)) {
                    //std.log.err("Expected {s}; found {s}", .{ text, &buf });
                    return error.InvalidString;
                }
            },
        }
    }

    if (@FieldType(Parse_Result(pattern), "year") != void and negate_year) {
        parsed.year = .from_number(-parsed.year.as_number());
    }

    if (@FieldType(Parse_Result(pattern), "iso_week_year") != void and negate_year) {
        parsed.iso_week_year = .from_number(-parsed.iso_week_year.as_number());
    }

    if (has_am_pm and @FieldType(Parse_Result(pattern), "hours") != void) {
        parsed.hours = @mod(parsed.hours, 12);
        if (hours_is_pm) parsed.hours += 12;
    }

    return parsed;
}


// moment.js style format specifiers, see https://momentjs.com/docs/#/displaying/format/
const Token = union (enum) {
    // Month
    M, // 1 2 ... 11 12
    Mo, // 1st 2nd ... 11th 12th
    MM, // 01 02 ... 11 12
    MMM, // Jan Feb ... Nov Dec
    MMMM, // January February ... November December

    // Quarter
    Q, // 1 2 3 4
    Qo, // 1st 2nd 3rd 4th

    // Day-of-month
    D, // 1 2 ... 30 31
    Do, // 1st 2nd ... 30th 31st
    DD, // 01 02 ... 30 31

    // Day-of-year
    DDD, // 1 2 ... 364 365
    DDDo, // 1st 2nd ... 364th 365th
    DDDD, // 001 002 ... 364 365

    // Day-of-week
    d, // 0 1 ... 5 6
    do, // 0th 1st ... 5th 6th
    dd, // Su Mo ... Fr Sa
    ddd, // Sun Mon ... Fri Sat
    dddd, // Sunday Monday ... Friday Saturday
    E, // 1 2 ... 6 7 (ISO; 1 is monday, 7 is sunday)
    Eo, // 1st 2nd ... 6th 7th  (ISO; 1 is monday, 7 is sunday)

    // Week-of-year (Jan 1 => 1)
    w, // 1 2 ... 52 53
    wo, // 1st 2nd ... 52nd 53rd
    ww, // 01 02 ... 52 53

    // Week-of-year (ISO; use with GG or GGGG, not YY or YYYY)
    W, // 1 2 ... 52 53
    Wo, // 1st 2nd ... 52nd 53rd
    WW, // 01 02 ... 52 53

    // ISO Week Year (use with W/WW/Wo)
    G, // any number of digits
    GG, // last two digits
    GGGG, // last four digits

    // Year
    y, // 1 2 ... 9999 (absolute value for negative years)
    Y, // 1 2 ... 9999 +10000 +10001
    YY, // 01 02 ... 99
    YYY, // 0001 0002 ... 9999 +010000 +010001
    YYYY, // 0001 0002 ... 9999
    YYYYYY, // -000123 ... +002024 (always includes + or - prefix and exactly 6 digits)

    // Era
    N, // BC AD
    NN, // Before Christ ... Anno Domini

    // AM/PM
    A, // AM PM
    a, // am pm

    // Hours
    H, // 0 1 ... 22 23
    HH, // 00 01 ... 22 23
    h, // 1 2 ... 11 12
    hh, // 01 02 ... 11 12
    k, kk, //  1  2 ... 11 12  (different from moment.js; space padded like strftime)
    K, KK, //  1  2 ... 22 23  (different from moment.js; space padded like strftime)

    // Minutes
    m, // 0 1 ... 58 59
    mm, // 00 01 ... 58 59

    // Seconds
    s, // 0 1 ... 58 59
    ss, // 00 01 ... 58 59

    // Tenths of seconds
    S, // 0 1 ... 8 9 (second fraction)

    // Hundreths of seconds
    SS, // 00 01 ... 98 99

    // Milliseconds
    SSS, // 000 001 ... 998 999

    // Timezone offset designator
    z, // EST CST ... MST PST (falls back to Z if no timezone)
    zz, // EST CST ... MST PST (falls back to ZZ if no timezone)

    // Timezone offset
    Z, // -07:00 -06:00 ... +06:00 +07:00
    ZZ, // -0700 -0600 ... +0600 +0700

    // Timestamp
    x, // unix millis
    X, // unix seconds

    literal: []const u8,

    pub fn iterator(pattern: []const u8) Iterator {
        return .{ .remaining = pattern };
    }

    pub const Iterator = struct {
        remaining: []const u8,

        pub fn next(self: *Iterator) ?Token {
            const remaining = self.remaining;
            if (remaining.len == 0) return null;

            var literal_chars_used: usize = 0;
            const token: Token = switch (remaining[0]) {
                'M' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .Mo,
                    'M' => blk: {
                        if (remaining.len > 3 and remaining[2] == 'M' and remaining[3] == 'M') break :blk .MMMM;
                        if (remaining.len > 2 and remaining[2] == 'M') break :blk .MMM;
                        break :blk .MM;
                    },
                    else => .M,
                } else .M,
                'Q' => if (remaining.len > 1 and remaining[1] == 'o') .Qo else .Q,
                'D' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .Do,
                    'D' => blk: {
                        if (remaining.len > 3 and remaining[2] == 'D') {
                            break :blk switch (remaining[3]) {
                                'o' => .DDDo,
                                'D' => .DDDD,
                                else => .DDD,
                            };
                        }
                        if (remaining.len > 2 and remaining[2] == 'D') break :blk .DDD;
                        break :blk .DD;
                    },
                    else => .D,
                } else .D,
                'd' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .do,
                    'd' => blk: {
                        if (remaining.len > 3 and remaining[2] == 'd' and remaining[3] == 'd') break :blk .dddd;
                        if (remaining.len > 2 and remaining[2] == 'd') break :blk .ddd;
                        break :blk .dd;
                    },
                    else => .d,
                } else .d,
                'E' => if (remaining.len > 1 and remaining[1] == 'o') .Eo else .E,
                'w' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .wo,
                    'w' => .ww,
                    else => .w,
                } else .w,
                'W' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .Wo,
                    'W' => .WW,
                    else => .W,
                } else .W,
                'y' => .y,
                'Y' => blk: {
                    if (remaining.len >= 6 and std.mem.eql(u8, remaining[1..6], "YYYYY")) break :blk .YYYYYY;
                    if (remaining.len >= 4 and std.mem.eql(u8, remaining[1..4], "YYY")) break :blk .YYYY;
                    if (remaining.len >= 3 and remaining[1] == 'Y' and remaining[2] == 'Y') break :blk .YYY;
                    if (remaining.len >= 2 and remaining[1] == 'Y') break :blk .YY;
                    break :blk .Y;
                },
                'G' => blk: {
                    if (remaining.len >= 4 and std.mem.eql(u8, remaining[1..4], "GGG")) break :blk .GGGG;
                    if (remaining.len >= 2 and remaining[1] == 'G') break :blk .GG;
                    break :blk .G;
                },
                'N' => if (remaining.len > 1 and remaining[1] == 'N') .NN else .N,
                'A' => .A,
                'a' => .a,
                'H' => if (remaining.len > 1 and remaining[1] == 'H') .HH else .H,
                'h' => if (remaining.len > 1 and remaining[1] == 'h') .hh else .h,
                'k' => if (remaining.len > 1 and remaining[1] == 'k') .kk else .k,
                'K' => if (remaining.len > 1 and remaining[1] == 'K') .KK else .K,
                'm' => if (remaining.len > 1 and remaining[1] == 'm') .mm else .m,
                's' => if (remaining.len > 1 and remaining[1] == 's') .ss else .s,
                'S' => if (remaining.len > 2 and remaining[1] == 'S' and remaining[2] == 'S') .SSS
                    else if (remaining.len > 1 and remaining[1] == 'S') .SS
                    else .S,
                'z' => if (remaining.len > 1 and remaining[1] == 'z') .zz else .z,
                'Z' => if (remaining.len > 1 and remaining[1] == 'Z') .ZZ else .Z,
                'x' => .x,
                'X' => .X,
                '[' => blk: {
                    var end: comptime_int = 1;
                    while (end < remaining.len and remaining[end] != ']') end += 1;
                    literal_chars_used = end + 1;
                    break :blk .{ .literal = remaining[1..end] };
                },
                else => blk: {
                    literal_chars_used = 1;
                    break :blk .{ .literal = remaining[0..1] };
                },
            };

            if (token != .literal) {
                self.remaining = remaining[@tagName(token).len..];
            } else {
                self.remaining = remaining[literal_chars_used..];
            }

            return token; 
        }
    };
};

fn write_ordinal(writer: *std.Io.Writer, num: u32) std.Io.Writer.Error!void {
    try writer.print("{d}", .{ num });
    try writer.writeAll(switch(num % 100) {
        11, 12, 13 => "th",
        else => switch (num % 10) {
            1 => "st",
            2 => "nd",
            3 => "rd",
            else => "th",
        },
    });
}

fn read_int(comptime T: type, reader: *std.Io.Reader) Parse_Error!T {
    var sign: T = 1;
    var value: T = 0;

    if (@typeInfo(T).int.signedness == .signed) switch(try reader.peekByte()) {
        '-' => {
            sign = -1;
            reader.toss(1);
        },
        '+' => {
            reader.toss(1);
        },
        else => {},
    };

    while (true) {
        const c = reader.peekByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        switch (c) {
            '0'...'9' => {
                reader.toss(1);
                const digit = std.math.cast(T, c - '0') orelse return error.InvalidString;
                const tens = std.math.mul(T, value, 10) catch return error.InvalidString;
                value = std.math.add(T, tens, digit) catch return error.InvalidString;
            },
            else => break,
        }
    }

    return std.math.mul(T, sign, value) catch return error.InvalidString;
}

fn read_utc_offset(reader: *std.Io.Reader, colon: bool) !i32 {
    const mult: i32 = switch (try reader.takeByte()) {
        '+' => 1,
        '-' => -1,
        else => return error.InvalidString,
    };

    var hours: [2]u8 = undefined;
    hours[0] = try reader.takeByte();
    hours[1] = try reader.takeByte();

    if (colon and ':' != try reader.takeByte()) return error.InvalidString;

    var minutes: [2]u8 = undefined;
    minutes[0] = try reader.takeByte();
    minutes[1] = try reader.takeByte();

    const h: i32 = std.fmt.parseInt(u5, &hours, 10) catch return error.InvalidString;
    const m: i32 = std.fmt.parseInt(u5, &minutes, 10) catch return error.InvalidString;

    if (h > 23) return error.InvalidString;
    if (m > 59) return error.InvalidString;

    return (h * 60 + m) * 60 * 1000 * mult;
}

const Date_Time = @import("Date_Time.zig");
const Date = @import("date.zig").Date;
const Year = @import("year.zig").Year;
const Month = @import("month.zig").Month;
const Day = @import("day.zig").Day;
const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
const Ordinal_Week = @import("ordinal_week.zig").Ordinal_Week;
const Week_Day = @import("week_day.zig").Week_Day;
const ISO_Week_Date = @import("iso_week.zig").ISO_Week_Date;
const ISO_Week = @import("iso_week.zig").ISO_Week;
const Time = @import("time.zig").Time;
const Timezone = @import("Timezone.zig");
const tzdb = @import("tzdb.zig");
const std = @import("std");
