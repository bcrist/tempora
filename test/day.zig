test "Day to/from number" {
    try std.testing.expectEqual(1, (Day.first).as_number());
    try std.testing.expectEqual(1, (Day.@"1").as_number());
    try std.testing.expectEqual(2, (Day.@"2").as_number());
    try std.testing.expectEqual(3, (Day.@"3").as_number());
    try std.testing.expectEqual(4, (Day.@"4").as_number());
    try std.testing.expectEqual(5, (Day.@"5").as_number());
    try std.testing.expectEqual(6, (Day.@"6").as_number());
    try std.testing.expectEqual(7, (Day.@"7").as_number());
    try std.testing.expectEqual(8, (Day.@"8").as_number());
    try std.testing.expectEqual(9, (Day.@"9").as_number());
    try std.testing.expectEqual(10, (Day.@"10").as_number());
    try std.testing.expectEqual(11, (Day.@"11").as_number());
    try std.testing.expectEqual(12, (Day.@"12").as_number());
    try std.testing.expectEqual(13, (Day.@"13").as_number());
    try std.testing.expectEqual(14, (Day.@"14").as_number());
    try std.testing.expectEqual(15, (Day.@"15").as_number());
    try std.testing.expectEqual(16, (Day.@"16").as_number());
    try std.testing.expectEqual(17, (Day.@"17").as_number());
    try std.testing.expectEqual(18, (Day.@"18").as_number());
    try std.testing.expectEqual(19, (Day.@"19").as_number());
    try std.testing.expectEqual(20, (Day.@"20").as_number());
    try std.testing.expectEqual(21, (Day.@"21").as_number());
    try std.testing.expectEqual(22, (Day.@"22").as_number());
    try std.testing.expectEqual(23, (Day.@"23").as_number());
    try std.testing.expectEqual(24, (Day.@"24").as_number());
    try std.testing.expectEqual(25, (Day.@"25").as_number());
    try std.testing.expectEqual(26, (Day.@"26").as_number());
    try std.testing.expectEqual(27, (Day.@"27").as_number());
    try std.testing.expectEqual(28, (Day.@"28").as_number());
    try std.testing.expectEqual(29, (Day.@"29").as_number());
    try std.testing.expectEqual(30, (Day.@"30").as_number());
    try std.testing.expectEqual(31, (Day.@"31").as_number());

    for (1..31) |w| {
        const signed: i32 = @intCast(w);
        try std.testing.expectEqual(signed, Day.from_number(signed).as_number());
        try std.testing.expectEqual(w, Day.from_number(signed).as_unsigned());
    }
}

test "Day.from_yod" {
    try std.testing.expectEqual(Day.first, Day.from_yod(.epoch, .first));
    try std.testing.expectEqual(Day.@"29", Day.from_yod(.epoch, .leap_day));
    try std.testing.expectEqual(Day.first, Day.from_yod(.unix_epoch, .leap_day));
}

test "Day.from_od" {
    try std.testing.expectEqual(Day.first, Day.from_od(.first, false));
    try std.testing.expectEqual(Day.first, Day.from_od(.first, true));
    try std.testing.expectEqual(Day.first, Day.from_od(.leap_day, false));
    try std.testing.expectEqual(Day.@"29", Day.from_od(.leap_day, true));

    try std.testing.expectEqual(Day.@"28", Day.from_od(.from_number(59), true));
    try std.testing.expectEqual(Day.@"28", Day.from_od(.from_number(59), false));
    try std.testing.expectEqual(Day.@"29", Day.from_od(.from_number(60), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(60), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(61), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(61), false));

    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(90), true));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(90), false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(91), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(91), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(92), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(92), false));

    try std.testing.expectEqual(Day.@"29", Day.from_od(.from_number(120), true));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(120), false));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(121), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(121), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(122), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(122), false));

    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(151), true));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(151), false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(152), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(152), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(153), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(153), false));

    try std.testing.expectEqual(Day.@"29", Day.from_od(.from_number(181), true));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(181), false));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(182), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(182), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(183), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(183), false));

    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(212), true));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(212), false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(213), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(213), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(214), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(214), false));

    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(243), true));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(243), false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(244), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(244), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(245), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(245), false));

    try std.testing.expectEqual(Day.@"29", Day.from_od(.from_number(273), true));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(273), false));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(274), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(274), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(275), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(275), false));

    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(304), true));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(304), false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.from_number(305), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(305), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(306), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(306), false));

    try std.testing.expectEqual(Day.@"29", Day.from_od(.from_number(334), true));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(334), false));
    try std.testing.expectEqual(Day.@"30", Day.from_od(.from_number(335), true));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(335), false));
    try std.testing.expectEqual(Day.@"1", Day.from_od(.from_number(336), true));
    try std.testing.expectEqual(Day.@"2", Day.from_od(.from_number(336), false));

    try std.testing.expectEqual(Day.@"31", Day.from_od(.last_no_leap, false));
    try std.testing.expectEqual(Day.@"31", Day.from_od(.last_leap, true));
}

test "Day.is_before" {
    try std.testing.expect(Day.is_before(.@"1", .@"2"));
    try std.testing.expect(!Day.is_before(.@"2", .@"2"));
    try std.testing.expect(!Day.is_before(.@"3", .@"2"));
}

test "Day.is_after" {
    try std.testing.expect(!Day.is_after(.@"1", .@"2"));
    try std.testing.expect(!Day.is_after(.@"2", .@"2"));
    try std.testing.expect(Day.is_after(.@"3", .@"2"));
}

test "Day.plus" {
    try std.testing.expectEqual(Day.from_number(2), Day.from_number(1).plus(1));
    try std.testing.expectEqual(Day.from_number(12), Day.from_number(2).plus(10));
    try std.testing.expectEqual(Day.from_number(2), Day.from_number(3).plus(-1));
    try std.testing.expectEqual(Day.from_number(1), Day.from_number(4).plus(-3));
}

test "Day.prev" {
    try std.testing.expectEqual(Day.from_number(1), Day.from_number(2).prev());
    try std.testing.expectEqual(Day.from_number(2), Day.from_number(3).prev());
    try std.testing.expectEqual(Day.from_number(3), Day.from_number(4).prev());
    try std.testing.expectEqual(Day.from_number(4), Day.from_number(5).prev());
}

test "Day.next" {
    try std.testing.expectEqual(Day.from_number(3), Day.from_number(2).next());
    try std.testing.expectEqual(Day.from_number(4), Day.from_number(3).next());
    try std.testing.expectEqual(Day.from_number(5), Day.from_number(4).next());
    try std.testing.expectEqual(Day.from_number(6), Day.from_number(5).next());
}

test "Week_Day.on_or_after" {
    const d: Date = .from_ymd(.from_numbers(2001, 5, 9));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 6, 7)), Day.on_or_after(.@"7", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 6, 8)), Day.on_or_after(.@"8", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 9)), Day.on_or_after(.@"9", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 10)), Day.on_or_after(.@"10", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 11)), Day.on_or_after(.@"11", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 12)), Day.on_or_after(.@"12", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 13)), Day.on_or_after(.@"13", d));
}

test "Week_Day.on_or_before" {
    const d: Date = .from_ymd(.from_numbers(2001, 5, 9));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 7)), Day.on_or_before(.@"7", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 8)), Day.on_or_before(.@"8", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 9)), Day.on_or_before(.@"9", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 4, 10)), Day.on_or_before(.@"10", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 4, 11)), Day.on_or_before(.@"11", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 4, 12)), Day.on_or_before(.@"12", d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 4, 13)), Day.on_or_before(.@"13", d));
}

test "Week_Day.on_or_after_ymd" {
    const d: Date.YMD = .from_numbers(2001, 5, 9);
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 6, 7), Day.on_or_after_ymd(.@"7", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 6, 8), Day.on_or_after_ymd(.@"8", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 9), Day.on_or_after_ymd(.@"9", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 10), Day.on_or_after_ymd(.@"10", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 11), Day.on_or_after_ymd(.@"11", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 12), Day.on_or_after_ymd(.@"12", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 13), Day.on_or_after_ymd(.@"13", d));
}

test "Week_Day.on_or_before_ymd" {
    const d: Date.YMD = .from_numbers(2001, 5, 9);
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 7), Day.on_or_before_ymd(.@"7", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 8), Day.on_or_before_ymd(.@"8", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 5, 9), Day.on_or_before_ymd(.@"9", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 4, 10), Day.on_or_before_ymd(.@"10", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 4, 11), Day.on_or_before_ymd(.@"11", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 4, 12), Day.on_or_before_ymd(.@"12", d));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 4, 13), Day.on_or_before_ymd(.@"13", d));
}

const Day = tempora.Day;
const Month = tempora.Month;
const Date = tempora.Date;
const tempora = @import("tempora");
const std = @import("std");
