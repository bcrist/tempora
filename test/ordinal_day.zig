test "Ordinal_Day to/from number" {
    for (1..366) |w| {
        const signed: i32 = @intCast(w);
        try std.testing.expectEqual(signed, Ordinal_Day.from_number(signed).as_number());
        try std.testing.expectEqual(w, Ordinal_Day.from_number(signed).as_unsigned());
    }
}

test "Ordinal_Day.from_ymd" {
    try std.testing.expectEqual(Ordinal_Day.first, Ordinal_Day.from_ymd(.from_numbers(1234, 1, 1)));
    try std.testing.expectEqual(Ordinal_Day.leap_day, Ordinal_Day.from_ymd(.from_numbers(2004, 2, 29)));
    try std.testing.expectEqual(Ordinal_Day.last_no_leap, Ordinal_Day.from_ymd(.from_numbers(2001, 12, 31)));
    try std.testing.expectEqual(Ordinal_Day.last_leap, Ordinal_Day.from_ymd(.from_numbers(2004, 12, 31)));
}

test "Ordinal_Day.from_yimd" {
    try std.testing.expectEqual(Ordinal_Day.first, Ordinal_Day.from_yimd(.from_number(1234), .january, .first));
    try std.testing.expectEqual(Ordinal_Day.leap_day, Ordinal_Day.from_yimd(.from_number(2004), .february, .@"29"));
    try std.testing.expectEqual(Ordinal_Day.last_no_leap, Ordinal_Day.from_yimd(.from_number(2001), .december, .@"31"));
    try std.testing.expectEqual(Ordinal_Day.last_leap, Ordinal_Day.from_yimd(.from_number(2004), .december, .@"31"));
}

test "Ordinal_Day.from_md_assume_non_leap_year" {
    try std.testing.expectEqual(1, Ordinal_Day.from_md_assume_non_leap_year(.january, .first).as_number());
    try std.testing.expectEqual(31, Ordinal_Day.from_md_assume_non_leap_year(.january, .@"31").as_number());
    try std.testing.expectEqual(32, Ordinal_Day.from_md_assume_non_leap_year(.february, .first).as_number());
    try std.testing.expectEqual(60, Ordinal_Day.from_md_assume_non_leap_year(.march, .first).as_number());
}

test "Ordinal_Day.date_from_year" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 1, 1)), Ordinal_Day.date_from_year(.first, .epoch));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 2, 29)), Ordinal_Day.date_from_year(.leap_day, .epoch));
}

test "Ordinal_Day.date_from_yi" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 1, 1)), Ordinal_Day.date_from_yi(.first, .from_year(.epoch)));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 2, 29)), Ordinal_Day.date_from_yi(.leap_day, .from_year(.epoch)));
}

test "Ordinal_Day.ordinal_week" {
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(1)), Ordinal_Day.from_number(1).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(2)), Ordinal_Day.from_number(2).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(3)), Ordinal_Day.from_number(3).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(4)), Ordinal_Day.from_number(4).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(5)), Ordinal_Day.from_number(5).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(6)), Ordinal_Day.from_number(6).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(7)), Ordinal_Day.from_number(7).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(8)), Ordinal_Day.from_number(8).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(9)), Ordinal_Day.from_number(9).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(10)), Ordinal_Day.from_number(10).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(11)), Ordinal_Day.from_number(11).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(12)), Ordinal_Day.from_number(12).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(13)), Ordinal_Day.from_number(13).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(14)), Ordinal_Day.from_number(14).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_od(.from_number(15)), Ordinal_Day.from_number(15).ordinal_week());
}

test "Ordinal_Day.is_before" {
    try std.testing.expect(Ordinal_Day.is_before(.from_number(1), .from_number(2)));
    try std.testing.expect(!Ordinal_Day.is_before(.from_number(2), .from_number(2)));
    try std.testing.expect(!Ordinal_Day.is_before(.from_number(3), .from_number(2)));
}

test "Ordinal_Day.is_after" {
    try std.testing.expect(!Ordinal_Day.is_after(.from_number(1), .from_number(2)));
    try std.testing.expect(!Ordinal_Day.is_after(.from_number(2), .from_number(2)));
    try std.testing.expect(Ordinal_Day.is_after(.from_number(3), .from_number(2)));
}

test "Ordinal_Day.plus" {
    try std.testing.expectEqual(Ordinal_Day.from_number(2), Ordinal_Day.from_number(1).plus(1));
    try std.testing.expectEqual(Ordinal_Day.from_number(12), Ordinal_Day.from_number(2).plus(10));
    try std.testing.expectEqual(Ordinal_Day.from_number(2), Ordinal_Day.from_number(3).plus(-1));
    try std.testing.expectEqual(Ordinal_Day.from_number(1), Ordinal_Day.from_number(4).plus(-3));
}

test "Ordinal_Day.prev" {
    try std.testing.expectEqual(Ordinal_Day.from_number(1), Ordinal_Day.from_number(2).prev());
    try std.testing.expectEqual(Ordinal_Day.from_number(2), Ordinal_Day.from_number(3).prev());
    try std.testing.expectEqual(Ordinal_Day.from_number(3), Ordinal_Day.from_number(4).prev());
    try std.testing.expectEqual(Ordinal_Day.from_number(4), Ordinal_Day.from_number(5).prev());
}

test "Ordinal_Day.next" {
    try std.testing.expectEqual(Ordinal_Day.from_number(3), Ordinal_Day.from_number(2).next());
    try std.testing.expectEqual(Ordinal_Day.from_number(4), Ordinal_Day.from_number(3).next());
    try std.testing.expectEqual(Ordinal_Day.from_number(5), Ordinal_Day.from_number(4).next());
    try std.testing.expectEqual(Ordinal_Day.from_number(6), Ordinal_Day.from_number(5).next());
}

const Ordinal_Day = tempora.Ordinal_Day;
const Ordinal_Week = tempora.Ordinal_Week;
const Date = tempora.Date;
const tempora = @import("tempora");
const std = @import("std");
