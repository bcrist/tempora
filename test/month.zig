test "Month to/from number" {
    for (1..13) |w| {
        const signed: i32 = @intCast(w);
        try std.testing.expectEqual(signed, Month.from_number(signed).as_number());
        try std.testing.expectEqual(w, Month.from_number(signed).as_unsigned());
    }
}

test "Month.from_string" {
    try std.testing.expectEqual(.january, try Month.from_string("Jan", .{}));
    try std.testing.expectError(error.InvalidString, Month.from_string("Jan", .{ .allow_short = false }));
    try std.testing.expectEqual(.february, try Month.from_string("february", .{}));
    try std.testing.expectEqual(.february, try Month.from_string("february", .{ .allow_short = false }));
    try std.testing.expectError(error.InvalidString, Month.from_string("febru", .{}));
    try std.testing.expectEqual(.may, try Month.from_string("may", .{}));
    try std.testing.expectEqual(.october, try Month.from_string("OCT", .{}));
    try std.testing.expectEqual(.november, try Month.from_string("NOVembER", .{}));
    try std.testing.expectEqual(.december, try Month.from_string(" 12 ", .{ .allow_short = false, .allow_long = false }));
    try std.testing.expectEqual(.september, try Month.from_string("___9", .{ .allow_long = false }));
    try std.testing.expectEqual(error.InvalidString, Month.from_string("___9", .{ .allow_numeric = false }));
    try std.testing.expectError(error.InvalidString, Month.from_string("00", .{}));
    try std.testing.expectError(error.InvalidString, Month.from_string("13", .{}));
}

test "Month.from_yod" {
    try std.testing.expectEqual(Month.january, Month.from_yod(.epoch, .first));
    try std.testing.expectEqual(Month.february, Month.from_yod(.epoch, .leap_day));
    try std.testing.expectEqual(Month.march, Month.from_yod(.unix_epoch, .leap_day));
}

test "Month.from_yiod" {
    try std.testing.expectEqual(Month.january, Month.from_yiod(.from_year(.epoch), .first));
    try std.testing.expectEqual(Month.february, Month.from_yiod(.from_year(.epoch), .leap_day));
    try std.testing.expectEqual(Month.march, Month.from_yiod(.from_year(.unix_epoch), .leap_day));
}

test "Month.from_od" {
    try std.testing.expectEqual(Month.january, Month.from_od(.first, false));
    try std.testing.expectEqual(Month.january, Month.from_od(.first, true));
    try std.testing.expectEqual(Month.march, Month.from_od(.leap_day, false));
    try std.testing.expectEqual(Month.february, Month.from_od(.leap_day, true));

    try std.testing.expectEqual(Month.february, Month.from_od(.from_number(59), true));
    try std.testing.expectEqual(Month.february, Month.from_od(.from_number(59), false));
    try std.testing.expectEqual(Month.february, Month.from_od(.from_number(60), true));
    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(60), false));
    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(61), true));
    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(61), false));

    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(90), true));
    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(90), false));
    try std.testing.expectEqual(Month.march, Month.from_od(.from_number(91), true));
    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(91), false));
    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(92), true));
    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(92), false));

    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(120), true));
    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(120), false));
    try std.testing.expectEqual(Month.april, Month.from_od(.from_number(121), true));
    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(121), false));
    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(122), true));
    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(122), false));

    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(151), true));
    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(151), false));
    try std.testing.expectEqual(Month.may, Month.from_od(.from_number(152), true));
    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(152), false));
    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(153), true));
    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(153), false));

    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(181), true));
    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(181), false));
    try std.testing.expectEqual(Month.june, Month.from_od(.from_number(182), true));
    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(182), false));
    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(183), true));
    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(183), false));

    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(212), true));
    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(212), false));
    try std.testing.expectEqual(Month.july, Month.from_od(.from_number(213), true));
    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(213), false));
    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(214), true));
    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(214), false));

    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(243), true));
    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(243), false));
    try std.testing.expectEqual(Month.august, Month.from_od(.from_number(244), true));
    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(244), false));
    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(245), true));
    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(245), false));

    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(273), true));
    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(273), false));
    try std.testing.expectEqual(Month.september, Month.from_od(.from_number(274), true));
    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(274), false));
    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(275), true));
    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(275), false));

    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(304), true));
    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(304), false));
    try std.testing.expectEqual(Month.october, Month.from_od(.from_number(305), true));
    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(305), false));
    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(306), true));
    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(306), false));

    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(334), true));
    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(334), false));
    try std.testing.expectEqual(Month.november, Month.from_od(.from_number(335), true));
    try std.testing.expectEqual(Month.december, Month.from_od(.from_number(335), false));
    try std.testing.expectEqual(Month.december, Month.from_od(.from_number(336), true));
    try std.testing.expectEqual(Month.december, Month.from_od(.from_number(336), false));

    try std.testing.expectEqual(Month.december, Month.from_od(.last_no_leap, false));
    try std.testing.expectEqual(Month.december, Month.from_od(.last_leap, true));
}

test "Month.days" {
    try std.testing.expectEqual(31, Month.from_number(1).days(.from_number(2020)));
    try std.testing.expectEqual(29, Month.from_number(2).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(3).days(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(4).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(5).days(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(6).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(7).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(8).days(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(9).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(10).days(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(11).days(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(12).days(.from_number(2020)));
}

test "Month.days_from_yi" {
    try std.testing.expectEqual(31, Month.from_number(1).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(29, Month.from_number(2).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(3).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(4).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(5).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(6).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(7).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(8).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(9).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(10).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(11).days_from_yi(.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(12).days_from_yi(.from_number(2020)));
}

test "Month.days_assume_non_leap_year" {
    try std.testing.expectEqual(31, Month.from_number(1).days_assume_non_leap_year());
    try std.testing.expectEqual(28, Month.from_number(2).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(3).days_assume_non_leap_year());
    try std.testing.expectEqual(30, Month.from_number(4).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(5).days_assume_non_leap_year());
    try std.testing.expectEqual(30, Month.from_number(6).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(7).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(8).days_assume_non_leap_year());
    try std.testing.expectEqual(30, Month.from_number(9).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(10).days_assume_non_leap_year());
    try std.testing.expectEqual(30, Month.from_number(11).days_assume_non_leap_year());
    try std.testing.expectEqual(31, Month.from_number(12).days_assume_non_leap_year());
}

test "Month.days_assume_leap_year" {
    try std.testing.expectEqual(31, Month.from_number(1).days_assume_leap_year());
    try std.testing.expectEqual(29, Month.from_number(2).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(3).days_assume_leap_year());
    try std.testing.expectEqual(30, Month.from_number(4).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(5).days_assume_leap_year());
    try std.testing.expectEqual(30, Month.from_number(6).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(7).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(8).days_assume_leap_year());
    try std.testing.expectEqual(30, Month.from_number(9).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(10).days_assume_leap_year());
    try std.testing.expectEqual(30, Month.from_number(11).days_assume_leap_year());
    try std.testing.expectEqual(31, Month.from_number(12).days_assume_leap_year());
}

test "Month.starting_ordinal_day" {
    try std.testing.expectEqual(1, Month.starting_ordinal_day(.january, .from_number(2001)).as_number());
    try std.testing.expectEqual(32, Month.starting_ordinal_day(.february, .from_number(2001)).as_number());
    try std.testing.expectEqual(60, Month.starting_ordinal_day(.march, .from_number(2001)).as_number());
    try std.testing.expectEqual(91, Month.starting_ordinal_day(.april, .from_number(2001)).as_number());
    try std.testing.expectEqual(121, Month.starting_ordinal_day(.may, .from_number(2001)).as_number());
    try std.testing.expectEqual(152, Month.starting_ordinal_day(.june, .from_number(2001)).as_number());
    try std.testing.expectEqual(182, Month.starting_ordinal_day(.july, .from_number(2001)).as_number());
    try std.testing.expectEqual(213, Month.starting_ordinal_day(.august, .from_number(2001)).as_number());
    try std.testing.expectEqual(244, Month.starting_ordinal_day(.september, .from_number(2001)).as_number());
    try std.testing.expectEqual(274, Month.starting_ordinal_day(.october, .from_number(2001)).as_number());
    try std.testing.expectEqual(305, Month.starting_ordinal_day(.november, .from_number(2001)).as_number());
    try std.testing.expectEqual(335, Month.starting_ordinal_day(.december, .from_number(2001)).as_number());

    try std.testing.expectEqual(1, Month.starting_ordinal_day(.january, .from_number(2004)).as_number());
    try std.testing.expectEqual(32, Month.starting_ordinal_day(.february, .from_number(2004)).as_number());
    try std.testing.expectEqual(61, Month.starting_ordinal_day(.march, .from_number(2004)).as_number());
    try std.testing.expectEqual(92, Month.starting_ordinal_day(.april, .from_number(2004)).as_number());
    try std.testing.expectEqual(122, Month.starting_ordinal_day(.may, .from_number(2004)).as_number());
    try std.testing.expectEqual(153, Month.starting_ordinal_day(.june, .from_number(2004)).as_number());
    try std.testing.expectEqual(183, Month.starting_ordinal_day(.july, .from_number(2004)).as_number());
    try std.testing.expectEqual(214, Month.starting_ordinal_day(.august, .from_number(2004)).as_number());
    try std.testing.expectEqual(245, Month.starting_ordinal_day(.september, .from_number(2004)).as_number());
    try std.testing.expectEqual(275, Month.starting_ordinal_day(.october, .from_number(2004)).as_number());
    try std.testing.expectEqual(306, Month.starting_ordinal_day(.november, .from_number(2004)).as_number());
    try std.testing.expectEqual(336, Month.starting_ordinal_day(.december, .from_number(2004)).as_number());
}

test "Month.starting_ordinal_day_assume_non_leap_year" {
    try std.testing.expectEqual(1, Month.starting_ordinal_day_assume_non_leap_year(.january).as_number());
    try std.testing.expectEqual(32, Month.starting_ordinal_day_assume_non_leap_year(.february).as_number());
    try std.testing.expectEqual(60, Month.starting_ordinal_day_assume_non_leap_year(.march).as_number());
    try std.testing.expectEqual(91, Month.starting_ordinal_day_assume_non_leap_year(.april).as_number());
    try std.testing.expectEqual(121, Month.starting_ordinal_day_assume_non_leap_year(.may).as_number());
    try std.testing.expectEqual(152, Month.starting_ordinal_day_assume_non_leap_year(.june).as_number());
    try std.testing.expectEqual(182, Month.starting_ordinal_day_assume_non_leap_year(.july).as_number());
    try std.testing.expectEqual(213, Month.starting_ordinal_day_assume_non_leap_year(.august).as_number());
    try std.testing.expectEqual(244, Month.starting_ordinal_day_assume_non_leap_year(.september).as_number());
    try std.testing.expectEqual(274, Month.starting_ordinal_day_assume_non_leap_year(.october).as_number());
    try std.testing.expectEqual(305, Month.starting_ordinal_day_assume_non_leap_year(.november).as_number());
    try std.testing.expectEqual(335, Month.starting_ordinal_day_assume_non_leap_year(.december).as_number());
}
test "Month.starting_ordinal_day_assume_leap_year" {
    try std.testing.expectEqual(1, Month.starting_ordinal_day_assume_leap_year(.january).as_number());
    try std.testing.expectEqual(32, Month.starting_ordinal_day_assume_leap_year(.february).as_number());
    try std.testing.expectEqual(61, Month.starting_ordinal_day_assume_leap_year(.march).as_number());
    try std.testing.expectEqual(92, Month.starting_ordinal_day_assume_leap_year(.april).as_number());
    try std.testing.expectEqual(122, Month.starting_ordinal_day_assume_leap_year(.may).as_number());
    try std.testing.expectEqual(153, Month.starting_ordinal_day_assume_leap_year(.june).as_number());
    try std.testing.expectEqual(183, Month.starting_ordinal_day_assume_leap_year(.july).as_number());
    try std.testing.expectEqual(214, Month.starting_ordinal_day_assume_leap_year(.august).as_number());
    try std.testing.expectEqual(245, Month.starting_ordinal_day_assume_leap_year(.september).as_number());
    try std.testing.expectEqual(275, Month.starting_ordinal_day_assume_leap_year(.october).as_number());
    try std.testing.expectEqual(306, Month.starting_ordinal_day_assume_leap_year(.november).as_number());
    try std.testing.expectEqual(336, Month.starting_ordinal_day_assume_leap_year(.december).as_number());
}

test "Month.starting_date" {
    try std.testing.expectEqual(Date.from_ymd(.init(.epoch, .january, .first)), Month.starting_date(.january, .epoch));
    try std.testing.expectEqual(Date.from_ymd(.init(.epoch, .february, .first)), Month.starting_date(.february, .epoch));
    try std.testing.expectEqual(Date.from_ymd(.init(.epoch, .october, .first)), Month.starting_date(.october, .epoch));
    try std.testing.expectEqual(Date.from_ymd(.init(.epoch, .december, .first)), Month.starting_date(.december, .epoch));
}

test "Month.name" {
    try std.testing.expectEqualStrings("January", Month.name(.january));
    try std.testing.expectEqualStrings("February", Month.name(.february));
    try std.testing.expectEqualStrings("March", Month.name(.march));
    try std.testing.expectEqualStrings("April", Month.name(.april));
    try std.testing.expectEqualStrings("May", Month.name(.may));
    try std.testing.expectEqualStrings("June", Month.name(.june));
    try std.testing.expectEqualStrings("July", Month.name(.july));
    try std.testing.expectEqualStrings("August", Month.name(.august));
    try std.testing.expectEqualStrings("September", Month.name(.september));
    try std.testing.expectEqualStrings("October", Month.name(.october));
    try std.testing.expectEqualStrings("November", Month.name(.november));
    try std.testing.expectEqualStrings("December", Month.name(.december));
}

test "Month.short_name" {
    try std.testing.expectEqualStrings("Jan", Month.short_name(.january));
    try std.testing.expectEqualStrings("Feb", Month.short_name(.february));
    try std.testing.expectEqualStrings("Mar", Month.short_name(.march));
    try std.testing.expectEqualStrings("Apr", Month.short_name(.april));
    try std.testing.expectEqualStrings("May", Month.short_name(.may));
    try std.testing.expectEqualStrings("Jun", Month.short_name(.june));
    try std.testing.expectEqualStrings("Jul", Month.short_name(.july));
    try std.testing.expectEqualStrings("Aug", Month.short_name(.august));
    try std.testing.expectEqualStrings("Sep", Month.short_name(.september));
    try std.testing.expectEqualStrings("Oct", Month.short_name(.october));
    try std.testing.expectEqualStrings("Nov", Month.short_name(.november));
    try std.testing.expectEqualStrings("Dec", Month.short_name(.december));
}

test "Month.is_before" {
    try std.testing.expect(Month.is_before(.september, .october));
    try std.testing.expect(!Month.is_before(.october, .october));
    try std.testing.expect(!Month.is_before(.november, .october));
}

test "Month.is_after" {
    try std.testing.expect(!Month.is_after(.september, .october));
    try std.testing.expect(!Month.is_after(.october, .october));
    try std.testing.expect(Month.is_after(.november, .october));
}

test "Month.plus" {
    try std.testing.expectEqual(Month.from_number(2), Month.from_number(1).plus(1));
    try std.testing.expectEqual(Month.from_number(12), Month.from_number(2).plus(10));
    try std.testing.expectEqual(Month.from_number(2), Month.from_number(3).plus(-1));
    try std.testing.expectEqual(Month.from_number(1), Month.from_number(4).plus(-3));
}

test "Month.prev" {
    try std.testing.expectEqual(Month.from_number(1), Month.from_number(2).prev());
    try std.testing.expectEqual(Month.from_number(2), Month.from_number(3).prev());
    try std.testing.expectEqual(Month.from_number(3), Month.from_number(4).prev());
    try std.testing.expectEqual(Month.from_number(4), Month.from_number(5).prev());
    try std.testing.expectEqual(Month.december, Month.prev(.january));
}

test "Month.next" {
    try std.testing.expectEqual(Month.from_number(3), Month.from_number(2).next());
    try std.testing.expectEqual(Month.from_number(4), Month.from_number(3).next());
    try std.testing.expectEqual(Month.from_number(5), Month.from_number(4).next());
    try std.testing.expectEqual(Month.from_number(6), Month.from_number(5).next());
    try std.testing.expectEqual(Month.january, Month.next(.december));
}

const Month = tempora.Month;
const Date = tempora.Date;
const tempora = @import("tempora");
const std = @import("std");
