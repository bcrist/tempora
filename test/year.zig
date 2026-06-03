test "Year epoch" {
    try std.testing.expectEqual(2000, Year.epoch.as_number());
}

test "Year to/from number" {
    try std.testing.expectEqual(2000, Year.from_number(2000).as_number());
    try std.testing.expectEqual(2020, Year.from_number(2020).as_number());
    try std.testing.expectEqual(1999, Year.from_number(1999).as_number());
    try std.testing.expectEqual(1970, Year.from_number(1970).as_number());
    try std.testing.expectEqual(1987654, Year.from_number(1987654).as_number());
    try std.testing.expectEqual(-1, Year.from_number(-1).as_number());
    try std.testing.expectEqual(-12345, Year.from_number(-12345).as_number());

    try std.testing.expectEqual(2000, Year.from_number(2000).as_unsigned());
    try std.testing.expectEqual(2020, Year.from_number(2020).as_unsigned());
    try std.testing.expectEqual(1999, Year.from_number(1999).as_unsigned());
    try std.testing.expectEqual(1970, Year.from_number(1970).as_unsigned());
    try std.testing.expectEqual(1987654, Year.from_number(1987654).as_unsigned());
}

test "Year.from_string" {
    try std.testing.expectEqual(Year.from_number(2024), try Year.from_string("2024", .{}));
    try std.testing.expectEqual(Year.from_number(4), try Year.from_string(" 4 ", .{}));
    try std.testing.expectEqual(Year.from_number(2024), try Year.from_string("///2024  _/., ", .{}));
    try std.testing.expectEqual(Year.from_number(24), try Year.from_string("'24", .{}));
    try std.testing.expectEqual(Year.from_number(69), try Year.from_string("'69", .{}));
    try std.testing.expectEqual(Year.from_number(-1234), try Year.from_string("-1234", .{}));
    try std.testing.expectEqual(Year.from_number(2024), try Year.from_string("'24", .{ .allow_two_digit_year = true }));
    try std.testing.expectEqual(Year.from_number(1969), try Year.from_string("'69", .{ .allow_two_digit_year = true }));
    try std.testing.expectEqual(Year.from_number(123), try Year.from_string("123", .{}));
    try std.testing.expectEqual(Year.from_number(2000), try Year.from_string(" 2000 AD", .{}));
    try std.testing.expectEqual(Year.from_number(1), try Year.from_string(" 1 AD", .{}));
    try std.testing.expectEqual(Year.from_number(0), try Year.from_string(" 0 AD", .{}));
    try std.testing.expectEqual(Year.from_number(1), try Year.from_string(" 0 BC", .{}));
    try std.testing.expectEqual(Year.from_number(0), try Year.from_string(" 1 BC", .{}));
    try std.testing.expectEqual(Year.from_number(-1), try Year.from_string(" 2 BC", .{}));
    try std.testing.expectEqual(Year.from_number(-1999), try Year.from_string(" 2000 BC", .{}));
    try std.testing.expectError(error.InvalidString, Year.from_string("2024", .{ .allow_non_two_digit_year = false }));
    try std.testing.expectError(error.InvalidString, Year.from_string("'24", .{ .trim = "" }));
    try std.testing.expectError(error.InvalidString, Year.from_string("'24", .{ .allow_two_digit_year = false, .allow_non_two_digit_year = false }));
    try std.testing.expectError(error.InvalidString, Year.from_string(" 2000 BC", .{ .allow_era_suffix = false }));
    try std.testing.expectError(error.InvalidString, Year.from_string(" 0 AD", .{ .allow_era_suffix = false }));
}

test "Year.is_leap" {
    try std.testing.expect(Year.from_number(2000).is_leap());
    try std.testing.expect(!Year.from_number(2001).is_leap());
    try std.testing.expect(!Year.from_number(2002).is_leap());
    try std.testing.expect(!Year.from_number(2003).is_leap());

    try std.testing.expect(Year.from_number(1996).is_leap());
    try std.testing.expect(!Year.from_number(1997).is_leap());
    try std.testing.expect(!Year.from_number(1998).is_leap());
    try std.testing.expect(!Year.from_number(1999).is_leap());

    try std.testing.expect(!Year.from_number(1900).is_leap());
    try std.testing.expect(!Year.from_number(1901).is_leap());
    try std.testing.expect(!Year.from_number(1902).is_leap());
    try std.testing.expect(!Year.from_number(1903).is_leap());
    try std.testing.expect(Year.from_number(1904).is_leap());

    try std.testing.expect(Year.from_number(2016).is_leap());
    try std.testing.expect(Year.from_number(2020).is_leap());
    try std.testing.expect(Year.from_number(2024).is_leap());
    try std.testing.expect(!Year.from_number(2017).is_leap());
    try std.testing.expect(!Year.from_number(2018).is_leap());
    try std.testing.expect(!Year.from_number(2019).is_leap());
    try std.testing.expect(!Year.from_number(2021).is_leap());
    try std.testing.expect(!Year.from_number(2022).is_leap());
    try std.testing.expect(!Year.from_number(2023).is_leap());

    for (0..10000) |i| {
        const y: Year = .from_number(@intCast(i));
        try std.testing.expectEqual(is_leap_naive(y), y.is_leap());
    }

    for (0..10000) |i| {
        const y: Year = .from_number(@intCast(std.math.maxInt(i32) - i));
        try std.testing.expectEqual(is_leap_naive(y), y.is_leap());
    }

    for (0..10000) |i| {
        const i_signed: i32 = @intCast(i);
        const y: Year = .from_number(@intCast(std.math.minInt(i32) + i_signed));
        try std.testing.expectEqual(is_leap_naive(y), y.is_leap());
    }
}

fn is_leap_naive(year: Year) bool {
    const y: i32 = year.as_number();
    if ((y & 3) != 0) return false;
    switch (@mod(y, 400)) {
        100, 200, 300 => return false,
        else => {},
    }
    return true;
}


test "Year.starting_date" {
    var year: Year = .epoch;
    var date: Date = .epoch;

    for (0..10_000) |_| {
        try std.testing.expectEqual(date, year.starting_date());
        date = date.plus_days(if (year.is_leap()) 366 else 365);
        year = year.next();
    }

    year = .epoch;
    date = .epoch;
    for (0..10_000) |_| {
        year = year.prev();
        date = date.plus_days(if (year.is_leap()) -366 else -365);
        try std.testing.expectEqual(date, year.starting_date());
    }
}

test "Year.info" {
    var year: Year = .from_number(-10_000);
    while (year != Year.from_number(10_000)) : (year = year.next()) {
        const yi = year.info();
        try std.testing.expectEqual(yi, Year.Info.from_year(year));
        try std.testing.expectEqual(year.as_number(), yi.raw);
        try std.testing.expectEqual(year.is_leap(), yi.is_leap);
        try std.testing.expectEqual(year.starting_date(), yi.starting_date);
    }
}

test "Year.ending_date" {
    var year: Year = .from_number(-2_000);
    while (year != Year.from_number(5_000)) : (year = year.next()) {
        try std.testing.expectEqual(year.next().starting_date().prev(), year.ending_date());
        try std.testing.expectEqual(year.next().starting_date().prev(), year.info().ending_date());
    }
}

test "Year.ymd" {
    var year: Year = .from_number(-2_000);
    while (year != Year.from_number(5_000)) : (year = year.next()) {
        try std.testing.expectEqual(year.ymd(.january, .first), Date.YMD.init(year, .january, .first));
        try std.testing.expectEqual(year.ymd(.january, .first), year.info().ymd(.january, .first));
    }
}

test "Year.date" {
    var year: Year = .from_number(-2_000);
    while (year != Year.from_number(5_000)) : (year = year.next()) {
        try std.testing.expectEqual(year.date(.january, .first), year.info().date(.january, .first));
    }
}

test "Year.date_info" {
    var year: Year = .from_number(-2_000);
    while (year != Year.from_number(5_000)) : (year = year.next()) {
        try std.testing.expectEqual(year.date_info(.january, .first), year.info().date_info(.january, .first));
    }
}

test "Year.Info.next" {
    var year: Year = .from_number(-2_000);
    var yi = year.info();
    while (year != Year.from_number(5_000)) : (year = year.next()) {
        try std.testing.expectEqual(year.info(), yi);
        yi = yi.next();
    }
}

test "Year.Info.prev" {
    var year: Year = .from_number(5_000);
    var yi = year.info();
    while (year != Year.from_number(-2_000)) : (year = year.prev()) {
        try std.testing.expectEqual(year.info(), yi);
        yi = yi.prev();
    }
}

test "Year.Dominical_Letter" {
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.a));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.b));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.c));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.d));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.e));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.f));
    try std.testing.expectEqual(false, Year.Dominical_Letter.is_leap_year(.g));

    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.ag));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.ba));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.cb));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.dc));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.ed));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.fe));
    try std.testing.expectEqual(true, Year.Dominical_Letter.is_leap_year(.gf));

    var year: Year = .from_number(-2000);
    while (year != Year.from_number(4000)) {
        const expected: Year.Dominical_Letter = switch (@mod(year.as_number(), 400)) {
            0, 28, 56, 84 => .ba,
            1, 29, 57, 85 => .g,
            2, 30, 58, 86 => .f,
            3, 31, 59, 87 => .e,
            4, 32, 60, 88 => .dc,
            5, 33, 61, 89 => .b,
            6, 34, 62, 90 => .a,
            7, 35, 63, 91 => .g,
            8, 36, 64, 92 => .fe,
            9, 37, 65, 93 => .d,
            10, 38, 66, 94 => .c,
            11, 39, 67, 95 => .b,
            12, 40, 68, 96 => .ag,
            13, 41, 69, 97 => .f,
            14, 42, 70, 98 => .e,
            15, 43, 71, 99 => .d,
            16, 44, 72 => .cb,
            17, 45, 73 => .a,
            18, 46, 74 => .g,
            19, 47, 75 => .f,
            20, 48, 76 => .ed,
            21, 49, 77 => .c,
            22, 50, 78 => .b,
            23, 51, 79 => .a,
            24, 52, 80 => .gf,
            25, 53, 81 => .e,
            26, 54, 82 => .d,
            27, 55, 83 => .c,

            100 => .c,
            128, 156, 184 => .dc,
            101, 129, 157, 185 => .b,
            102, 130, 158, 186 => .a,
            103, 131, 159, 187 => .g,
            104, 132, 160, 188 => .fe,
            105, 133, 161, 189 => .d,
            106, 134, 162, 190 => .c,
            107, 135, 163, 191 => .b,
            108, 136, 164, 192 => .ag,
            109, 137, 165, 193 => .f,
            110, 138, 166, 194 => .e,
            111, 139, 167, 195 => .d,
            112, 140, 168, 196 => .cb,
            113, 141, 169, 197 => .a,
            114, 142, 170, 198 => .g,
            115, 143, 171, 199 => .f,
            116, 144, 172 => .ed,
            117, 145, 173 => .c,
            118, 146, 174 => .b,
            119, 147, 175 => .a,
            120, 148, 176 => .gf,
            121, 149, 177 => .e,
            122, 150, 178 => .d,
            123, 151, 179 => .c,
            124, 152, 180 => .ba,
            125, 153, 181 => .g,
            126, 154, 182 => .f,
            127, 155, 183 => .e,

            200 => .e,
            228, 256, 284 => .fe,
            201, 229, 257, 285 => .d,
            202, 230, 258, 286 => .c,
            203, 231, 259, 287 => .b,
            204, 232, 260, 288 => .ag,
            205, 233, 261, 289 => .f,
            206, 234, 262, 290 => .e,
            207, 235, 263, 291 => .d,
            208, 236, 264, 292 => .cb,
            209, 237, 265, 293 => .a,
            210, 238, 266, 294 => .g,
            211, 239, 267, 295 => .f,
            212, 240, 268, 296 => .ed,
            213, 241, 269, 297 => .c,
            214, 242, 270, 298 => .b,
            215, 243, 271, 299 => .a,
            216, 244, 272 => .gf,
            217, 245, 273 => .e,
            218, 246, 274 => .d,
            219, 247, 275 => .c,
            220, 248, 276 => .ba,
            221, 249, 277 => .g,
            222, 250, 278 => .f,
            223, 251, 279 => .e,
            224, 252, 280 => .dc,
            225, 253, 281 => .b,
            226, 254, 282 => .a,
            227, 255, 283 => .g,

            300 => .g,
            328, 356, 384 => .ag,
            301, 329, 357, 385 => .f,
            302, 330, 358, 386 => .e,
            303, 331, 359, 387 => .d,
            304, 332, 360, 388 => .cb,
            305, 333, 361, 389 => .a,
            306, 334, 362, 390 => .g,
            307, 335, 363, 391 => .f,
            308, 336, 364, 392 => .ed,
            309, 337, 365, 393 => .c,
            310, 338, 366, 394 => .b,
            311, 339, 367, 395 => .a,
            312, 340, 368, 396 => .gf,
            313, 341, 369, 397 => .e,
            314, 342, 370, 398 => .d,
            315, 343, 371, 399 => .c,
            316, 344, 372 => .ba,
            317, 345, 373 => .g,
            318, 346, 374 => .f,
            319, 347, 375 => .e,
            320, 348, 376 => .dc,
            321, 349, 377 => .b,
            322, 350, 378 => .a,
            323, 351, 379 => .g,
            324, 352, 380 => .fe,
            325, 353, 381 => .d,
            326, 354, 382 => .c,
            327, 355, 383 => .b,

            else => unreachable,
        };
        try std.testing.expectEqual(expected, year.dominical_letter());
        try std.testing.expectEqual(year.dominical_letter(), Year.Dominical_Letter.from_yi(year.info()));
        year = year.next();
    }
}

const Date = tempora.Date;
const Year = tempora.Year;
const tempora = @import("tempora");
const std = @import("std");
