test "Week_Day.from_iso" {
    try std.testing.expectEqual(Week_Day.monday, Week_Day.from_iso(1));
    try std.testing.expectEqual(Week_Day.tuesday, Week_Day.from_iso(2));
    try std.testing.expectEqual(Week_Day.wednesday, Week_Day.from_iso(3));
    try std.testing.expectEqual(Week_Day.thursday, Week_Day.from_iso(4));
    try std.testing.expectEqual(Week_Day.friday, Week_Day.from_iso(5));
    try std.testing.expectEqual(Week_Day.saturday, Week_Day.from_iso(6));
    try std.testing.expectEqual(Week_Day.sunday, Week_Day.from_iso(7));
}

test "Week_Day.as_iso" {
    try std.testing.expectEqual(1, Week_Day.as_iso(.monday));
    try std.testing.expectEqual(2, Week_Day.as_iso(.tuesday));
    try std.testing.expectEqual(3, Week_Day.as_iso(.wednesday));
    try std.testing.expectEqual(4, Week_Day.as_iso(.thursday));
    try std.testing.expectEqual(5, Week_Day.as_iso(.friday));
    try std.testing.expectEqual(6, Week_Day.as_iso(.saturday));
    try std.testing.expectEqual(7, Week_Day.as_iso(.sunday));
}

test "ISO_Week.last" {
    try std.testing.expectEqual(53, ISO_Week.last(.from_number(2004)).as_number());
    try std.testing.expectEqual(52, ISO_Week.last(.from_number(2005)).as_number());
    try std.testing.expectEqual(52, ISO_Week.last(.from_number(2006)).as_number());
    try std.testing.expectEqual(52, ISO_Week.last(.from_number(2007)).as_number());
    try std.testing.expectEqual(52, ISO_Week.last(.from_number(2008)).as_number());
    try std.testing.expectEqual(53, ISO_Week.last(.from_number(2009)).as_number());
    try std.testing.expectEqual(52, ISO_Week.last(.from_number(2010)).as_number());
}

test "ISO_Week.last_from_dc" {
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.g).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.gf).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.f).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.fe).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.e).as_number());
    try std.testing.expectEqual(53, ISO_Week.last_from_dc(.ed).as_number());
    try std.testing.expectEqual(53, ISO_Week.last_from_dc(.d).as_number());
    try std.testing.expectEqual(53, ISO_Week.last_from_dc(.dc).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.c).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.cb).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.b).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.ba).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.a).as_number());
    try std.testing.expectEqual(52, ISO_Week.last_from_dc(.ag).as_number());
}

test "ISO_Week to/from number" {
    for (1..54) |w| {
        const signed: i32 = @intCast(w);
        try std.testing.expectEqual(signed, ISO_Week.from_number(signed).as_number());
        try std.testing.expectEqual(w, ISO_Week.from_number(signed).as_unsigned());
    }
}

test "ISO_Week.is_before" {
    try std.testing.expect(ISO_Week.is_before(.from_number(1), .from_number(2)));
    try std.testing.expect(!ISO_Week.is_before(.from_number(2), .from_number(2)));
    try std.testing.expect(!ISO_Week.is_before(.from_number(3), .from_number(2)));
}

test "ISO_Week.is_after" {
    try std.testing.expect(!ISO_Week.is_after(.from_number(1), .from_number(2)));
    try std.testing.expect(!ISO_Week.is_after(.from_number(2), .from_number(2)));
    try std.testing.expect(ISO_Week.is_after(.from_number(3), .from_number(2)));
}

test "ISO_Week.plus" {
    try std.testing.expectEqual(ISO_Week.from_number(2), ISO_Week.from_number(1).plus(1));
    try std.testing.expectEqual(ISO_Week.from_number(12), ISO_Week.from_number(2).plus(10));
    try std.testing.expectEqual(ISO_Week.from_number(2), ISO_Week.from_number(3).plus(-1));
    try std.testing.expectEqual(ISO_Week.from_number(1), ISO_Week.from_number(4).plus(-3));
}

test "ISO_Week.prev" {
    try std.testing.expectEqual(ISO_Week.from_number(1), ISO_Week.from_number(2).prev());
    try std.testing.expectEqual(ISO_Week.from_number(2), ISO_Week.from_number(3).prev());
    try std.testing.expectEqual(ISO_Week.from_number(3), ISO_Week.from_number(4).prev());
    try std.testing.expectEqual(ISO_Week.from_number(4), ISO_Week.from_number(5).prev());
}

test "ISO_Week.next" {
    try std.testing.expectEqual(ISO_Week.from_number(3), ISO_Week.from_number(2).next());
    try std.testing.expectEqual(ISO_Week.from_number(4), ISO_Week.from_number(3).next());
    try std.testing.expectEqual(ISO_Week.from_number(5), ISO_Week.from_number(4).next());
    try std.testing.expectEqual(ISO_Week.from_number(6), ISO_Week.from_number(5).next());
}

test "ISO_Week_Date.from_date" {
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(6) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2005, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2005, 1, 2))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(6) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2005, 12, 31))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2006, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2006, 1, 2))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2006, 12, 31))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2007, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2007, 12, 30))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2007, 12, 31))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(2) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2008, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2008, 12, 28))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2008, 12, 29))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(2) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2008, 12, 30))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(3) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2008, 12, 31))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(4) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2009, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(4) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2009, 12, 31))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(5) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2010, 1, 1))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(6) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2010, 1, 2))));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(7) }, ISO_Week_Date.from_date(.from_ymd(.from_numbers(2010, 1, 3))));
}

test "ISO_Week_Date.date" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(6) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 1, 2)), ISO_Week_Date.date(.{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(7) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 12, 31)), ISO_Week_Date.date(.{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(6) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(7) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 1, 2)), ISO_Week_Date.date(.{ .year = .from_number(2006), .week = .from_number(1), .day = .from_iso(1) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 12, 31)), ISO_Week_Date.date(.{ .year = .from_number(2006), .week = .from_number(52), .day = .from_iso(7) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2007), .week = .from_number(1), .day = .from_iso(1) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 12, 30)), ISO_Week_Date.date(.{ .year = .from_number(2007), .week = .from_number(52), .day = .from_iso(7) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 12, 31)), ISO_Week_Date.date(.{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(1) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(2) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 28)), ISO_Week_Date.date(.{ .year = .from_number(2008), .week = .from_number(52), .day = .from_iso(7) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 29)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(1) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 30)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(2) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 31)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(3) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2009, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(4) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2009, 12, 31)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(4) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 1)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(5) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 2)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(6) }));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 3)), ISO_Week_Date.date(.{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(7) }));
}

test "ISO_Week_Date.is_before" {
    try std.testing.expect(ISO_Week_Date.is_before(.from_date(.from_ymd(.from_numbers(2008, 12, 31))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
    try std.testing.expect(!ISO_Week_Date.is_before(.from_date(.from_ymd(.from_numbers(2009, 1, 1))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
    try std.testing.expect(!ISO_Week_Date.is_before(.from_date(.from_ymd(.from_numbers(2009, 12, 31))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
}

test "ISO_Week_Date.is_after" {
    try std.testing.expect(!ISO_Week_Date.is_after(.from_date(.from_ymd(.from_numbers(2008, 12, 31))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
    try std.testing.expect(!ISO_Week_Date.is_after(.from_date(.from_ymd(.from_numbers(2009, 1, 1))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
    try std.testing.expect(ISO_Week_Date.is_after(.from_date(.from_ymd(.from_numbers(2009, 12, 31))), .from_date(.from_ymd(.from_numbers(2009, 1, 1)))));
}

test "ISO_Week_Date.plus_days" {
    var rng: std.Random.Xoshiro256 = .init(std.testing.random_seed);
    const rnd = rng.random();
    const limit: Date = .from_year(.from_number(2222));
    var d: Date = .unix_epoch;
    while (d.is_before(limit)) {
        const plus_amount = rnd.int(i10);
        try std.testing.expectEqual(d.plus_days(plus_amount).iso_week_date(), d.iso_week_date().plus_days(plus_amount));
        d = d.plus_days(rnd.intRangeAtMostBiased(i32, 5, 132));
    }
}

test "ISO_Week_Date.prev" {
    try std.testing.expectEqual(ISO_Week_Date{
        .year = .from_number(1999),
        .week = .from_number(52),
        .day = .sunday,
    }, ISO_Week_Date.prev(.{
        .year = .epoch,
        .week = .first,
        .day = .monday,
    }));
}

test "ISO_Week_Date.next" {
    try std.testing.expectEqual(ISO_Week_Date{
        .year = .epoch,
        .week = .first,
        .day = .monday,
    }, ISO_Week_Date.next(.{
        .year = .from_number(1999),
        .week = .from_number(52),
        .day = .sunday,
    }));
}

test "ISO_Week_Date.fmt" {
    try std.testing.expectFmt("2004-W53-6", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(6) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2004-W53-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2005-W52-6", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(6) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2005-W52-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2006-W01-1", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(1), .day = .from_iso(1) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2006-W52-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(52), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2007-W01-1", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(1), .day = .from_iso(1) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2007-W52-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(52), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2008-W01-1", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(1) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2008-W01-2", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(2) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2008-W52-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(52), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W01-1", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(1) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W01-2", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(2) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W01-3", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(3) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W01-4", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(4) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W53-4", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(4) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W53-5", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(5) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W53-6", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(6) }).fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("2009-W53-7", "{f}", .{ (ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(7) }).fmt(ISO_Week_Date.iso8601_week_date) });

    try std.testing.expectFmt("2005-01-01", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().fmt("YYYY-MM-DD") });
    try std.testing.expectFmt("2004-W53-6", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().fmt("GGGG-[W]WW-E") });
    try std.testing.expectFmt("2004-W53-7", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2005-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2005, 1, 3)).iso_week_date() });
    try std.testing.expectFmt("2005-W52-6", "{f}", .{ Date.from_ymd(.from_numbers(2005, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2005-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2006, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2006-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2006, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2006-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2006, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2007-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2007, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2007-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2007, 12, 30)).iso_week_date() });
    try std.testing.expectFmt("2008-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2007, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2008-W01-2", "{f}", .{ Date.from_ymd(.from_numbers(2008, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2008-W52-7", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 28)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-1", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 29)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-2", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 30)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-3", "{f}", .{ Date.from_ymd(.from_numbers(2008, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2009-W01-4", "{f}", .{ Date.from_ymd(.from_numbers(2009, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-4", "{f}", .{ Date.from_ymd(.from_numbers(2009, 12, 31)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-5", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 1)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-6", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 2)).iso_week_date() });
    try std.testing.expectFmt("2009-W53-7", "{f}", .{ Date.from_ymd(.from_numbers(2010, 1, 3)).iso_week_date() });
}

test "ISO_Week_Date.from_string" {
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(6) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-6"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2004), .week = .from_number(53), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-7"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(6) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-6"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2005), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-7"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W01-1"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2006), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W52-7"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W01-1"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2007), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W52-7"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-1"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(1), .day = .from_iso(2) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-2"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2008), .week = .from_number(52), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W52-7"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(1) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-1"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(2) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-2"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(3) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-3"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(1), .day = .from_iso(4) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-4"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(4) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-4"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(5) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-5"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(6) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-6"));
    try std.testing.expectEqual(ISO_Week_Date{ .year = .from_number(2009), .week = .from_number(53), .day = .from_iso(7) }, ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-7"));

    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-6"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 1, 2)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-7"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 1, 3)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W01-1"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2005, 12, 31)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-6"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-7"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 1, 2)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W01-1"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2006, 12, 31)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W52-7"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W01-1"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 12, 30)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W52-7"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2007, 12, 31)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-1"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-2"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 28)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W52-7"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 29)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-1"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 30)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-2"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2008, 12, 31)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-3"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2009, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-4"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2009, 12, 31)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-4"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 1)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-5"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 2)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-6"));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2010, 1, 3)).iso_week_date(), try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-7"));
}

const ISO_Week = tempora.ISO_Week;
const ISO_Week_Date = tempora.ISO_Week_Date;
const Week_Day = tempora.Week_Day;
const Date = tempora.Date;
const tempora = @import("tempora");
const std = @import("std");
