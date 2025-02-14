pub const default_from_string_trim = std.ascii.whitespace ++ "-/,._'";

pub fn format(dto: Date_Time.With_Offset, comptime fmt: []const u8, writer: anytype) !void {
    @setEvalBranchQuota(100000);

    comptime var iter = Token.iterator(fmt);
    const need_date_info = inline while (comptime iter.next()) |token| {
        switch (token) {
            .y, .Y, .YY, .YYY, .YYYY, .YYYYYY,
            .MM, .M, .Mo, .MMM, .MMMM, .Q, .Qo,
            .D, .Do, .DD, .DDD, .DDDo, .DDDD, .d, .e, .do, .dd, .ddd, .dddd, .E, .Eo,
            .w, .wo, .ww, .N, .NN,
            => break true,

            else => {},
        }
    } else false;

    var di: Date.Info = if (need_date_info) dto.dt.date.info() else .{
        .raw = 0,
        .start_of_year = .epoch,
        .start_of_month = .epoch,
        .start_of_week = .epoch,
        .is_leap_year = false,
        .year = .epoch,
        .month = .january,
        .day = .first,
        .week_day = .sunday,
        .ordinal_day = .first,
    };

    iter = comptime Token.iterator(fmt);
    inline while (comptime iter.next()) |token| switch (token) {
        .MM => try writer.print("{:0>2}", .{ di.month.as_unsigned() }),
        .M => try writer.print("{}", .{ di.month.as_unsigned() }),
        .Mo => try write_ordinal(writer, di.month.as_unsigned()),
        .MMM => try writer.writeAll(di.month.short_name()),
        .MMMM => try writer.writeAll(di.month.name()),

        .Q => try writer.print("{}", .{ (di.month.as_unsigned() - 1) / 3 + 1 }),
        .Qo => try write_ordinal(writer, (di.month.as_unsigned() - 1) / 3 + 1),

        .D => try writer.print("{}", .{ di.day.as_unsigned() }),
        .Do => try write_ordinal(writer, di.day.as_unsigned()),
        .DD => try writer.print("{:0>2}", .{ di.day.as_unsigned() }),

        .DDD => try writer.print("{}", .{ di.ordinal_day.as_unsigned() }),
        .DDDo => try write_ordinal(writer, di.ordinal_day.as_unsigned()),
        .DDDD => try writer.print("{:0>3}", .{ di.ordinal_day.as_unsigned() }),

        .d, .e => try writer.print("{}", .{ di.week_day.as_unsigned() - 1 }),
        .do => try write_ordinal(writer, di.week_day.as_unsigned() - 1),
        .dd => try writer.writeAll(di.week_day.name()[0..2]),
        .ddd => try writer.writeAll(di.week_day.short_name()),
        .dddd => try writer.writeAll(di.week_day.name()),
        .E => try writer.print("{}", .{ di.week_day.as_unsigned() }),
        .Eo => try write_ordinal(writer, di.week_day.as_unsigned()),

        .w => try writer.print("{}", .{ di.ordinal_day.ordinal_week().as_unsigned() }),
        .wo => try write_ordinal(writer, di.ordinal_day.ordinal_week().as_unsigned()),
        .ww => try writer.print("{:0>2}", .{ di.ordinal_day.ordinal_week().as_unsigned() }),

        .y => try writer.print("{}", .{ @as(u32, @intCast(@abs(di.year.as_number()))) }),
        .Y => if (di.year.as_number() > 9999) {
            try writer.print("{}", .{ di.year.as_number() });
        } else if (di.year.as_number() < 0) {
            try writer.print("-{}", .{ @as(u32, @intCast(-di.year.as_number())) });
        } else {
            try writer.print("{}", .{ di.year.as_unsigned() });
        },
        .YY => if (di.year.as_number() >= 0) {
            try writer.print("{:0>2}", .{ di.year.as_unsigned() % 100 });
        } else {
            try writer.print("{}", .{ di.year.as_number() });
        },
        .YYY => if (di.year.as_number() >= 0) {
            try writer.print("{}", .{ di.year.as_unsigned() });
        } else {
            try writer.print("{}", .{ di.year.as_number() });
        },
        .YYYY => if (di.year.as_number() >= 0) {
            try writer.print("{:0>4}", .{ di.year.as_unsigned() });
        } else {
            try writer.print("-{:0>4}", .{ @as(u32, @intCast(-di.year.as_number())) });
        },
        .YYYYYY => if (di.year.as_number() > 0) {
            try writer.print("+{:0>6}", .{ di.year.as_unsigned() });
        } else if (di.year.as_number() < 0) {
            try writer.print("-{:0>6}", .{ @as(u32, @intCast(-di.year.as_number())) });
        } else {
            try writer.writeAll("000000");
        },

        .N, .NN => if (di.year.as_number() > 0) {
            try writer.writeAll("AD");
        } else if (di.year.as_number() < 0) {
            try writer.writeAll("BC");
        },

        .literal => |text| {
            try writer.writeAll(text);
        },

        .A => try writer.writeAll(if (dto.dt.time.hours() < 12) "AM" else "PM"),
        .a => try writer.writeAll(if (dto.dt.time.hours() < 12) "am" else "pm"),
        .H => try writer.print("{}", .{ @as(u32, @intCast(dto.dt.time.hours())) }),
        .HH => try writer.print("{:0>2}", .{ @as(u32, @intCast(dto.dt.time.hours())) }),
        .h => try writer.print("{}", .{ @as(u32, switch (dto.dt.time.hours()) {
            0 => 12,
            1...12 => |h| h,
            else => |h| h - 12,
        }) }),
        .hh => try writer.print("{:0>2}", .{ @as(u32, switch (dto.dt.time.hours()) {
            0 => 12,
            1...12 => |h| h,
            else => |h| h - 12,
        }) }),
        .k => try writer.print("{}", .{ @as(u32, switch (dto.dt.time.hours()) {
            0 => 24,
            else => |h| h,
        }) }),
        .kk => try writer.print("{:0>2}", .{ @as(u32, switch (dto.dt.time.hours()) {
            0 => 24,
            else => |h| h,
        }) }),
        .m => try writer.print("{}", .{ @as(u32, @intCast(dto.dt.time.minutes())) }),
        .mm => try writer.print("{:0>2}", .{ @as(u32, @intCast(dto.dt.time.minutes())) }),
        .s => try writer.print("{}", .{ @as(u32, @intCast(dto.dt.time.seconds())) }),
        .ss => try writer.print("{:0>2}", .{ @as(u32, @intCast(dto.dt.time.seconds())) }),
        .S => try writer.print("{}", .{ @as(u32, @intCast(@divFloor(dto.dt.time.ms(), 100))) }),
        .SS => try writer.print("{:0>2}", .{ @as(u32, @intCast(@divFloor(dto.dt.time.ms(), 10))) }),
        .SSS => try writer.print("{:0>3}", .{ @as(u32, @intCast(dto.dt.time.ms())) }),
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
                    try writer.print("-{:0>4}", .{ minutes });
                } else {
                    try writer.print("+{:0>4}", .{ minutes });
                }
            } else {
                if (dto.utc_offset_ms < 0) {
                    try writer.print("-{:0>2}:{:0>2}", .{ @divFloor(minutes, 60), @mod(minutes, 60) });
                } else {
                    try writer.print("+{:0>2}:{:0>2}", .{ @divFloor(minutes, 60), @mod(minutes, 60) });
                }
            }
        },
        .x => try writer.print("{}", .{ dto.timestamp_ms() }),
        .X => try writer.print("{}", .{ dto.timestamp_s() }),
    };
}

const Parse_Info = struct {
    timestamp: ?i64 = null,
    negate_year: bool = false,
    year: ?Year = null,
    month: ?Month = null,
    day: ?Day = null,
    ordinal_day: ?Ordinal_Day = null,
    ordinal_week: ?Ordinal_Week = null,
    week_day: ?Week_Day = null,
    hours_is_pm: bool = false,
    hours: ?i32 = null,
    minutes: ?i32 = null,
    seconds: ?i32 = null,
    ms: ?i32 = null,
    utc_offset_ms: ?i32 = null,
};

pub fn parse(comptime fmt: []const u8, stream: *std.io.FixedBufferStream([]const u8)) !Parse_Info {
    var reader = stream.reader();
    var parsed: Parse_Info = .{};
    @setEvalBranchQuota(100000);

    comptime var iter = Token.iterator(fmt);
    inline while (comptime iter.next()) |token| {
        switch (token) {
            .MM => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    parsed.month = try Month.from_string(&buf, .{
                        .trim = "",
                        .allow_short = false,
                        .allow_long = false,
                    });
                } else return error.InvalidFormat;
            },
            .M, .Mo => {
                const raw = try read_int(u4, stream);
                if (raw < 1 or raw > 12) return error.InvalidFormat;
                parsed.month = Month.from_number(raw);

                if (token == .Mo) {
                    _ = try reader.readByte();
                    _ = try reader.readByte();
                }
            },
            .MMM, .MMMM => {
                var buf: [3]u8 = undefined;
                if (3 == try reader.readAll(&buf)) {
                    const m = try Month.from_string(&buf, .{
                        .trim = "",
                        .allow_long = false,
                        .allow_numeric = false,
                    });
                    parsed.month = m;

                    if (token == .MMMM) {
                        const remaining = m.name()[3..];
                        var buf2: [16]u8 = undefined;
                        if (remaining.len == try reader.readAll(buf2[0..remaining.len])) {
                            if (!std.ascii.eqlIgnoreCase(remaining, buf2[0..remaining.len])) {
                                return error.InvalidFormat;
                            }
                        } else return error.InvalidFormat;
                    }
                } else return error.InvalidFormat;
            },

            .Q, .Qo => {},

            .D, .Do => {
                const raw = try read_int(u5, stream);
                if (raw < 1 or raw > 31) return error.InvalidFormat;
                parsed.day = Day.from_number(raw);

                if (token == .Do) {
                    _ = try reader.readByte();
                    _ = try reader.readByte();
                }
            },
            .DD => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u5, &buf, 10);
                    if (num < 1 or num > 31) return error.InvalidFormat;
                    parsed.day = Day.from_number(num);
                } else return error.InvalidFormat;
            },

            .DDD, .DDDo => {
                const raw = try read_int(u9, stream);
                if (raw < 1 or raw > 366) return error.InvalidFormat;
                parsed.ordinal_day = Ordinal_Day.from_number(raw);

                if (token == .DDDo) {
                    _ = try reader.readByte();
                    _ = try reader.readByte();
                }
            },
            .DDDD => {
                var buf: [3]u8 = undefined;
                if (3 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u5, &buf, 10);
                    if (num < 1 or num > 366) return error.InvalidFormat;
                    parsed.ordinal_day = Ordinal_Day.from_number(num);
                } else return error.InvalidFormat;
            },

            .d, .do, .e, .E, .Eo => {
                var raw = try read_int(u3, stream);
                if (token != .E and token != .Eo) raw += 1;
                if (raw < 1 or raw > 7) return error.InvalidFormat;
                parsed.week_day = Week_Day.from_number(raw);

                if (token == .do or token == .Eo) {
                    _ = try reader.readByte();
                    _ = try reader.readByte();
                }
            },
            .dd, .ddd, .dddd => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const d = try Week_Day.from_string(&buf, .{
                        .trim = "",
                        .allow_long = false,
                        .allow_numeric = false,
                    });
                    parsed.week_day = d;

                    if (token == .ddd) {
                        if (d.name()[2] != std.ascii.toLower(try reader.readByte())) {
                            return error.InvalidFormat;
                        }
                    } else if (token == .dddd) {
                        const remaining = d.name()[2..];
                        var buf2: [16]u8 = undefined;
                        if (remaining.len == try reader.readAll(buf2[0..remaining.len])) {
                            if (!std.ascii.eqlIgnoreCase(remaining, buf2[0..remaining.len])) {
                                return error.InvalidFormat;
                            }
                        } else return error.InvalidFormat;
                    }
                } else return error.InvalidFormat;
            },

            .w, .wo => {
                const raw = try read_int(u6, stream);
                if (raw < 1 or raw > 53) return error.InvalidFormat;
                parsed.ordinal_week = Ordinal_Week.from_number(raw);

                if (token == .wo) {
                    _ = try reader.readByte();
                    _ = try reader.readByte();
                }
            },
            .ww => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u6, &buf, 10);
                    if (num < 1 or num > 53) return error.InvalidFormat;
                    parsed.ordinal_week = Ordinal_Week.from_number(num);
                } else return error.InvalidFormat;
            },

            .y, .Y, .YYY, .YYYYYY => {
                const raw = try read_int(i32, stream);
                parsed.year = Year.from_number(raw);
            },
            .YY => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    parsed.year = try Year.from_string(&buf, .{
                        .trim = "",
                        .allow_non_two_digit_year = false,
                    });
                } else return error.InvalidFormat;
            },
            .YYYY => {
                var buf: [4]u8 = undefined;
                if (4 == try reader.readAll(&buf)) {
                    parsed.year = try Year.from_string(&buf, .{
                        .trim = "",
                        .allow_two_digit_year = false,
                    });
                } else return error.InvalidFormat;
            },

            .N, .NN => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    parsed.negate_year = std.ascii.eqlIgnoreCase(&buf, "BC");
                } else return error.InvalidFormat;
            },

            .A, .a => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    parsed.hours_is_pm = std.ascii.eqlIgnoreCase(&buf, "PM");
                } else return error.InvalidFormat;
            },

            .H, .h, .k => {
                const raw = try read_int(u5, stream);
                if (raw > 24) return error.InvalidFormat;
                parsed.hours = raw;
            },
            .HH, .hh, .kk => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u5, &buf, 10);
                    if (num > 24) return error.InvalidFormat;
                    parsed.hours = num;
                } else return error.InvalidFormat;
            },

            .m => {
                const raw = try read_int(u6, stream);
                if (raw > 59) return error.InvalidFormat;
                parsed.minutes = raw;
            },
            .mm => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u6, &buf, 10);
                    if (num > 59) return error.InvalidFormat;
                    parsed.minutes = num;
                } else return error.InvalidFormat;
            },

            .s => {
                const raw = try read_int(u6, stream);
                if (raw > 59) return error.InvalidFormat;
                parsed.seconds = raw;
            },
            .ss => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u6, &buf, 10);
                    if (num > 59) return error.InvalidFormat;
                    parsed.seconds = num;
                } else return error.InvalidFormat;
            },

            .S => {
                var buf: [1]u8 = undefined;
                if (1 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u10, &buf, 10);
                    if (num > 9) return error.InvalidFormat;
                    parsed.ms = num;
                } else return error.InvalidFormat;
            },
            .SS => {
                var buf: [2]u8 = undefined;
                if (2 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u10, &buf, 10);
                    if (num > 99) return error.InvalidFormat;
                    parsed.ms = num;
                } else return error.InvalidFormat;
            },
            .SSS => {
                var buf: [3]u8 = undefined;
                if (3 == try reader.readAll(&buf)) {
                    const num = try std.fmt.parseInt(u10, &buf, 10);
                    if (num > 999) return error.InvalidFormat;
                    parsed.ms = num;
                } else return error.InvalidFormat;
            },

            .Z, .ZZ => parsed.utc_offset_ms = try read_utc_offset(reader, token == .Z),
            .z, .zz => {
                var buf: [5]u8 = undefined;
                const designation: []const u8 = for (0..buf.len) |i| {
                    if (0 == try reader.read(buf[i..i+1])) {
                        break buf[0..i];
                    }
                    
                    if (!std.ascii.isAlphabetic(buf[i])) {
                        stream.pos -= 1;
                        break buf[0..i];
                    }
                } else &buf;

                if (designation.len == 0) {
                    parsed.utc_offset_ms = try read_utc_offset(reader, token == .z);
                } else if (try tzdb.designation_offset_ms(designation)) |offset_ms| {
                    parsed.utc_offset_ms = offset_ms;
                } else return error.InvalidFormat;
            },

            .x, .X => {
                var raw = try read_int(i64, stream);
                if (token == .X) {
                    raw = try std.math.mul(i64, raw, 1000);
                }
                parsed.timestamp = raw;
            },

            .literal => |text| {
                var buf: [text.len]u8 = undefined;
                if (text.len == try reader.readAll(&buf)) {
                    if (!std.ascii.eqlIgnoreCase(&buf, text)) {
                        //std.log.err("Expected {s}; found {s}", .{ text, &buf });
                        return error.InvalidFormat;
                    }
                } else return error.InvalidFormat;
            },

        }
    }
    return parsed;
}


// moment.js style format specifiers, see https://momentjs.com/docs/#/displaying/format/
const Token = union (enum) {
    M, // 1 2 ... 11 12
    Mo, // 1st 2nd ... 11th 12th
    MM, // 01 02 ... 11 12
    MMM, // Jan Feb ... Nov Dec
    MMMM, // January February ... November December
    Q, // 1 2 3 4
    Qo, // 1st 2nd 3rd 4th
    D, // 1 2 ... 30 31
    Do, // 1st 2nd ... 30th 31st
    DD, // 01 02 ... 30 31
    DDD, // 1 2 ... 364 365
    DDDo, // 1st 2nd ... 364th 365th
    DDDD, // 001 002 ... 364 365
    d, // 0 1 ... 5 6
    do, // 0th 1st ... 5th 6th
    dd, // Su Mo ... Fr Sa
    ddd, // Sun Mon ... Fri Sat
    dddd, // Sunday Monday ... Friday Saturday
    e, // 0 1 ... 5 6 (locale)
    E, // 1 2 ... 6 7 (ISO)
    Eo, // 1st 2nd ... 6th 7th
    w, // 1 2 ... 52 53
    wo, // 1st 2nd ... 52nd 53rd
    ww, // 01 02 ... 52 53
    y, // 1 2 ... 2020 ...
    Y, // 11970 11971 ... 19999 20000 20001 (Holocene calendar)
    YY, // 70 71 ... 29 30
    YYY, // 1 2 ... 1970 1971 ... 2029 2030
    YYYY, // 0001 0002 ... 1970 1971 ... 2029 2030
    YYYYYY, // e.g. -000123 ... +002024
    N, // BC AD
    NN, // Before Christ ... Anno Domini
    A, // AM PM
    a, // am pm
    H, // 0 1 ... 22 23
    HH, // 00 01 ... 22 23
    h, // 1 2 ... 11 12
    hh, // 01 02 ... 11 12
    k, // 1 2 ... 23 24
    kk, // 01 02 ... 23 24
    m, // 0 1 ... 58 59
    mm, // 00 01 ... 58 59
    s, // 0 1 ... 58 59
    ss, // 00 01 ... 58 59
    S, // 0 1 ... 8 9 (second fraction)
    SS, // 00 01 ... 98 99
    SSS, // 000 001 ... 998 999
    z, // EST CST ... MST PST (falls back to Z if no timezone)
    zz, // EST CST ... MST PST (falls back to ZZ if no timezone)
    Z, // -07:00 -06:00 ... +06:00 +07:00
    ZZ, // -0700 -0600 ... +0600 +0700
    x, // unix millis
    X, // unix seconds
    literal: []const u8,

    pub fn iterator(fmt: []const u8) Iterator {
        return .{ .remaining = fmt };
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
                'e' => .e,
                'E' => if (remaining.len > 1 and remaining[1] == 'o') .Eo else .E,
                'w' => if (remaining.len > 1) switch (remaining[1]) {
                    'o' => .wo,
                    'w' => .ww,
                    else => .w,
                } else .w,
                'y' => .y,
                'Y' => blk: {
                    if (remaining.len >= 6 and std.mem.eql(u8, remaining[1..6], "YYYYY")) break :blk .YYYYYY;
                    if (remaining.len >= 4 and std.mem.eql(u8, remaining[1..4], "YYY")) break :blk .YYYY;
                    if (remaining.len >= 3 and remaining[1] == 'Y' and remaining[2] == 'Y') break :blk .YYY;
                    if (remaining.len >= 2 and remaining[1] == 'Y') break :blk .YY;
                    break :blk .Y;
                },
                'N' => if (remaining.len > 1 and remaining[1] == 'N') .NN else .N,
                'A' => .A,
                'a' => .a,
                'H' => if (remaining.len > 1 and remaining[1] == 'H') .HH else .H,
                'h' => if (remaining.len > 1 and remaining[1] == 'h') .hh else .h,
                'k' => if (remaining.len > 1 and remaining[1] == 'k') .kk else .k,
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
                    if (std.mem.indexOfScalar(u8, remaining, ']')) |end| {
                        literal_chars_used = end + 1;
                        break :blk .{ .literal = remaining[1..end] };
                    } else {
                        literal_chars_used = remaining.len;
                        break :blk .{ .literal = remaining[1..] };
                    }
                },
                ';' => blk: {
                    // Since std.fmt treats ':' as a special character in format strings, we support using
                    // semicolons in the format string, which will be treated as colons instead.
                    literal_chars_used = 1;
                    break :blk .{ .literal = ":" };
                },
                else => blk: {
                    literal_chars_used = std.mem.indexOfAny(u8, remaining, "MQDdeEwYNAaHhkmsSzZxX[") orelse remaining.len;
                    break :blk .{ .literal = remaining[0..literal_chars_used] };
                    // literal_chars_used = 1;
                    // break :blk .{ .literal = remaining[0..1] };
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

fn write_ordinal(writer: anytype, num: u32) !void {
    try writer.print("{}", .{num});
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

fn read_int(comptime T: type, stream: *std.io.FixedBufferStream([]const u8)) !T {
    const reader = stream.reader();

    var sign: T = 1;
    var value: T = 0;

    if (@typeInfo(T).int.signedness == .signed) switch(try reader.readByte()) {
        '-' => sign = -1,
        '+' => {},
        else => stream.pos -= 1,
    };

    while (true) {
        const c = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        switch (c) {
            '0'...'9' => {
                const digit = std.math.cast(T, c - '0') orelse return error.Overflow;
                value = try std.math.add(T, try std.math.mul(T, value, 10), digit);
            },
            else => {
                stream.pos -= 1;
                break;
            },
        }
    }

    return try std.math.mul(T, sign, value);
}

fn read_utc_offset(reader: anytype, colon: bool) !i32 {
    const mult: i32 = switch (try reader.readByte()) {
        '+' => 1,
        '-' => -1,
        else => return error.InvalidFormat,
    };

    var hours: [2]u8 = undefined;
    hours[0] = try reader.readByte();
    hours[1] = try reader.readByte();

    if (colon and ':' != try reader.readByte()) return error.InvalidFormat;

    var minutes: [2]u8 = undefined;
    minutes[0] = try reader.readByte();
    minutes[1] = try reader.readByte();

    const h: i32 = try std.fmt.parseInt(u5, &hours, 10);
    const m: i32 = try std.fmt.parseInt(u5, &minutes, 10);

    if (h > 23) return error.InvalidFormat;
    if (m > 59) return error.InvalidFormat;

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
const Time = @import("time.zig").Time;
const Timezone = @import("Timezone.zig");
const tzdb = @import("tzdb.zig");
const std = @import("std");
