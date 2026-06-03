test "Week_Day.from_number" {
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.from_number(1));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.from_number(2));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.from_number(3));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.from_number(4));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.from_number(5));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.from_number(6));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.from_number(7));
}

test "Week_Day.from_string" {
    try std.testing.expectEqual(.sunday, try Week_Day.from_string("Su", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.monday, try Week_Day.from_string("M", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.tuesday, try Week_Day.from_string("Tu", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("W", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("Th", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.friday, try Week_Day.from_string("F", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("Sa", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("SA", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("sa", .{ .allow_short = true, .allow_long = false }));

    try std.testing.expectEqual(.sunday, try Week_Day.from_string("Sun", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.monday, try Week_Day.from_string("mon", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.tuesday, try Week_Day.from_string("TUe", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("WED", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("ThU", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.friday, try Week_Day.from_string("FRI", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("Sat", .{ .allow_short = true, .allow_long = false }));

    try std.testing.expectEqual(.tuesday, try Week_Day.from_string("tues", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("thurs", .{ .allow_short = true, .allow_long = false }));

    try std.testing.expectError(error.InvalidString, Week_Day.from_string("Sunday", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("monday", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("TUesdaY", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("WEDNESDAY", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("ThURSDAY", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("FRIDAY", .{ .allow_short = true, .allow_long = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("Saturday", .{ .allow_short = true, .allow_long = false }));

    try std.testing.expectEqual(.sunday, try Week_Day.from_string("Sunday", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.monday, try Week_Day.from_string("monday", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.tuesday, try Week_Day.from_string("TUesdaY", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("WEDNESDAY", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("ThURSDAY", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.friday, try Week_Day.from_string("FRIDAY", .{ .allow_short = false, .allow_long = true }));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("Saturday", .{ .allow_short = false, .allow_long = true }));

    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("wednesday", .{}));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("THU", .{}));
    try std.testing.expectEqual(.thursday, try Week_Day.from_string("Th", .{}));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("TH", .{ .allow_short = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("7", .{}));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("7", .{ .allow_numeric = true }));
    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("// wed //", .{}));
    try std.testing.expectEqual(.friday, try Week_Day.from_string("  fri  ", .{ .trim = " " }));
    try std.testing.expectEqual(.sunday, try Week_Day.from_string("  sunday  ", .{ .allow_short = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("  sunda  ", .{ .allow_short = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("  sun  ", .{ .allow_short = false }));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("// wed //", .{ .trim = " " }));
    
}

test "Week_Day.as_number" {
    for (1..8) |n| {
        const signed: i32 = @intCast(n);
        try std.testing.expectEqual(signed, Week_Day.from_number(signed).as_number());
        try std.testing.expectEqual(n, Week_Day.from_number(signed).as_unsigned());
    }
}

test "Week_Day.name" {
    try std.testing.expectEqualStrings("Sunday", Week_Day.name(.sunday));
    try std.testing.expectEqualStrings("Monday", Week_Day.name(.monday));
    try std.testing.expectEqualStrings("Tuesday", Week_Day.name(.tuesday));
    try std.testing.expectEqualStrings("Wednesday", Week_Day.name(.wednesday));
    try std.testing.expectEqualStrings("Thursday", Week_Day.name(.thursday));
    try std.testing.expectEqualStrings("Friday", Week_Day.name(.friday));
    try std.testing.expectEqualStrings("Saturday", Week_Day.name(.saturday));
}

test "Week_Day.short_name" {
    try std.testing.expectEqualStrings("Sun", Week_Day.short_name(.sunday));
    try std.testing.expectEqualStrings("Mon", Week_Day.short_name(.monday));
    try std.testing.expectEqualStrings("Tue", Week_Day.short_name(.tuesday));
    try std.testing.expectEqualStrings("Wed", Week_Day.short_name(.wednesday));
    try std.testing.expectEqualStrings("Thu", Week_Day.short_name(.thursday));
    try std.testing.expectEqualStrings("Fri", Week_Day.short_name(.friday));
    try std.testing.expectEqualStrings("Sat", Week_Day.short_name(.saturday));
}

test "Week_Day.is_before" {
    try std.testing.expect(!Week_Day.is_before(.sunday, .sunday));
    try std.testing.expect(Week_Day.is_before(.sunday, .monday));
    try std.testing.expect(Week_Day.is_before(.sunday, .tuesday));
    try std.testing.expect(Week_Day.is_before(.sunday, .wednesday));
    try std.testing.expect(Week_Day.is_before(.sunday, .thursday));
    try std.testing.expect(Week_Day.is_before(.sunday, .friday));
    try std.testing.expect(Week_Day.is_before(.sunday, .saturday));

    try std.testing.expect(!Week_Day.is_before(.wednesday, .sunday));
    try std.testing.expect(!Week_Day.is_before(.wednesday, .monday));
    try std.testing.expect(!Week_Day.is_before(.wednesday, .tuesday));
    try std.testing.expect(!Week_Day.is_before(.wednesday, .wednesday));
    try std.testing.expect(Week_Day.is_before(.wednesday, .thursday));
    try std.testing.expect(Week_Day.is_before(.wednesday, .friday));
    try std.testing.expect(Week_Day.is_before(.wednesday, .saturday));

    try std.testing.expect(!Week_Day.is_before(.saturday, .sunday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .monday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .tuesday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .wednesday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .thursday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .friday));
    try std.testing.expect(!Week_Day.is_before(.saturday, .saturday));
}

test "Week_Day.is_after" {
    try std.testing.expect(!Week_Day.is_after(.sunday, .sunday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .monday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .tuesday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .wednesday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .thursday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .friday));
    try std.testing.expect(!Week_Day.is_after(.sunday, .saturday));

    try std.testing.expect(Week_Day.is_after(.wednesday, .sunday));
    try std.testing.expect(Week_Day.is_after(.wednesday, .monday));
    try std.testing.expect(Week_Day.is_after(.wednesday, .tuesday));
    try std.testing.expect(!Week_Day.is_after(.wednesday, .wednesday));
    try std.testing.expect(!Week_Day.is_after(.wednesday, .thursday));
    try std.testing.expect(!Week_Day.is_after(.wednesday, .friday));
    try std.testing.expect(!Week_Day.is_after(.wednesday, .saturday));

    try std.testing.expect(Week_Day.is_after(.saturday, .sunday));
    try std.testing.expect(Week_Day.is_after(.saturday, .monday));
    try std.testing.expect(Week_Day.is_after(.saturday, .tuesday));
    try std.testing.expect(Week_Day.is_after(.saturday, .wednesday));
    try std.testing.expect(Week_Day.is_after(.saturday, .thursday));
    try std.testing.expect(Week_Day.is_after(.saturday, .friday));
    try std.testing.expect(!Week_Day.is_after(.saturday, .saturday));
}

test "Week_Day.plus" {
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.sunday, 0));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.sunday, 1));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.sunday, 2));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.sunday, 3));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.sunday, 4));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.sunday, 5));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.sunday, 6));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.sunday, 7));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.sunday, 8));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.sunday, 9));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.sunday, 10));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.sunday, -1));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.sunday, -2));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.sunday, -3));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.sunday, -4));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.sunday, -5));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.sunday, -6));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.sunday, -7));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.sunday, -8));

    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.wednesday, 0));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.wednesday, 1));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.wednesday, 2));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.wednesday, 3));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.wednesday, 4));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.wednesday, 5));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.wednesday, 6));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.wednesday, 7));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.wednesday, 8));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.wednesday, 9));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.wednesday, 10));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.wednesday, -1));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.wednesday, -2));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.wednesday, -3));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.wednesday, -4));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.wednesday, -5));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.wednesday, -6));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.wednesday, -7));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.wednesday, -8));

    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.saturday, 0));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.saturday, 1));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.saturday, 2));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.saturday, 3));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.saturday, 4));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.saturday, 5));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.saturday, 6));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.saturday, 7));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.saturday, 8));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.saturday, 9));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.saturday, 10));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.saturday, -1));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.plus(.saturday, -2));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.plus(.saturday, -3));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.plus(.saturday, -4));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.plus(.saturday, -5));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.plus(.saturday, -6));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.plus(.saturday, -7));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.plus(.saturday, -8));
}

test "Week_Day.next" {
    try std.testing.expectEqual(Week_Day.monday, Week_Day.next(.sunday));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.next(.monday));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.next(.tuesday));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.next(.wednesday));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.next(.thursday));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.next(.friday));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.next(.saturday));
}

test "Week_Day.prev" {
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.prev(.sunday));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.prev(.monday));
    try std.testing.expectEqual(Week_Day.monday, Week_Day.prev(.tuesday));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.prev(.wednesday));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.prev(.thursday));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.prev(.friday));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.prev(.saturday));
}

test "Week_Day.on_or_after" {
    const d: Date = .from_ymd(.from_numbers(2001, 5, 9));
    try std.testing.expectEqual(Week_Day.wednesday, d.week_day());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 13)), Week_Day.on_or_after(.sunday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 14)), Week_Day.on_or_after(.monday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 15)), Week_Day.on_or_after(.tuesday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 9)), Week_Day.on_or_after(.wednesday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 10)), Week_Day.on_or_after(.thursday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 11)), Week_Day.on_or_after(.friday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 12)), Week_Day.on_or_after(.saturday, d));
}

test "Week_Day.on_or_before" {
    const d: Date = .from_ymd(.from_numbers(2001, 5, 9));
    try std.testing.expectEqual(Week_Day.wednesday, d.week_day());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 6)), Week_Day.on_or_before(.sunday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 7)), Week_Day.on_or_before(.monday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 8)), Week_Day.on_or_before(.tuesday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 9)), Week_Day.on_or_before(.wednesday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 3)), Week_Day.on_or_before(.thursday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 4)), Week_Day.on_or_before(.friday, d));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2001, 5, 5)), Week_Day.on_or_before(.saturday, d));
}

const Date = tempora.Date;
const Week_Day = tempora.Week_Day;
const tempora = @import("tempora");
const std = @import("std");
