test "Ordinal_Week to/from number" {
    for (1..54) |w| {
        const signed: i32 = @intCast(w);
        try std.testing.expectEqual(signed, Ordinal_Week.from_number(signed).as_number());
        try std.testing.expectEqual(w, Ordinal_Week.from_number(signed).as_unsigned());
    }
}

test "Ordinal_Week.from_od" {
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(1)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(2)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(3)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(4)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(5)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(6)).as_unsigned());
    try std.testing.expectEqual(1, Ordinal_Week.from_od(Ordinal_Day.from_number(7)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(8)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(9)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(10)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(11)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(12)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(13)).as_unsigned());
    try std.testing.expectEqual(2, Ordinal_Week.from_od(Ordinal_Day.from_number(14)).as_unsigned());
    try std.testing.expectEqual(3, Ordinal_Week.from_od(Ordinal_Day.from_number(15)).as_unsigned());
}

test "Ordinal_Week.starting_day" {
    try std.testing.expectEqual(Ordinal_Day.from_number(1), Ordinal_Week.from_number(1).starting_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(8), Ordinal_Week.from_number(2).starting_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(15), Ordinal_Week.from_number(3).starting_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(22), Ordinal_Week.from_number(4).starting_day());
}

test "Ordinal_Week.is_before" {
    try std.testing.expect(Ordinal_Week.is_before(.from_number(1), .from_number(2)));
    try std.testing.expect(!Ordinal_Week.is_before(.from_number(2), .from_number(2)));
    try std.testing.expect(!Ordinal_Week.is_before(.from_number(3), .from_number(2)));
}

test "Ordinal_Week.is_after" {
    try std.testing.expect(!Ordinal_Week.is_after(.from_number(1), .from_number(2)));
    try std.testing.expect(!Ordinal_Week.is_after(.from_number(2), .from_number(2)));
    try std.testing.expect(Ordinal_Week.is_after(.from_number(3), .from_number(2)));
}

test "Ordinal_Week.plus" {
    try std.testing.expectEqual(Ordinal_Week.from_number(2), Ordinal_Week.from_number(1).plus(1));
    try std.testing.expectEqual(Ordinal_Week.from_number(12), Ordinal_Week.from_number(2).plus(10));
    try std.testing.expectEqual(Ordinal_Week.from_number(2), Ordinal_Week.from_number(3).plus(-1));
    try std.testing.expectEqual(Ordinal_Week.from_number(1), Ordinal_Week.from_number(4).plus(-3));
}

test "Ordinal_Week.prev" {
    try std.testing.expectEqual(Ordinal_Week.from_number(1), Ordinal_Week.from_number(2).prev());
    try std.testing.expectEqual(Ordinal_Week.from_number(2), Ordinal_Week.from_number(3).prev());
    try std.testing.expectEqual(Ordinal_Week.from_number(3), Ordinal_Week.from_number(4).prev());
    try std.testing.expectEqual(Ordinal_Week.from_number(4), Ordinal_Week.from_number(5).prev());
}

test "Ordinal_Week.next" {
    try std.testing.expectEqual(Ordinal_Week.from_number(3), Ordinal_Week.from_number(2).next());
    try std.testing.expectEqual(Ordinal_Week.from_number(4), Ordinal_Week.from_number(3).next());
    try std.testing.expectEqual(Ordinal_Week.from_number(5), Ordinal_Week.from_number(4).next());
    try std.testing.expectEqual(Ordinal_Week.from_number(6), Ordinal_Week.from_number(5).next());
}

const Ordinal_Day = tempora.Ordinal_Day;
const Ordinal_Week = tempora.Ordinal_Week;
const tempora = @import("tempora");
const std = @import("std");
