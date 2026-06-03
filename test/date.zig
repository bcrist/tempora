test "Date epochs" {
    try std.testing.expectFmt("1601-01-01", "{f}", .{ Date.fmt(.ntfs_epoch, "YYYY-MM-DD") });
    try std.testing.expectFmt("1900-01-01", "{f}", .{ Date.fmt(.ntp_epoch, "YYYY-MM-DD") });
    try std.testing.expectFmt("1970-01-01", "{f}", .{ Date.fmt(.unix_epoch, "YYYY-MM-DD") });
    try std.testing.expectFmt("2000-01-01", "{f}", .{ Date.fmt(.epoch, "YYYY-MM-DD") });
}

test "Date.from_yod" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 1, 1)), Date.from_yod(.epoch, .first));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 4, 9)), Date.from_yod(.from_number(0), .from_number(100)));
}

test "Date.from_yiod" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 1, 1)), Date.from_yiod(.from_year(.epoch), .first));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 4, 9)), Date.from_yiod(.from_number(0), .from_number(100)));
}

test "Date.from_ywd" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2000, 1, 4)), Date.from_ywd(.epoch, .first, .tuesday));
}

test "Date.from_yiwd" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 1, 4)), Date.from_yiwd(.from_number(0), .first, .tuesday));
}

test "Date.from_year" {
    try std.testing.expectEqual(Date.epoch, Date.from_year(.from_number(2000)));
    try std.testing.expectEqual(Date.unix_epoch, Date.from_year(.from_number(1970)));
    try std.testing.expectEqual((Date.unix_epoch).plus_days(365), Date.from_year(.from_number(1971)));
}

test "date.year" {
    try std.testing.expectEqual(Year.from_number(2024), Date.from_ymd(.from_numbers(2024, 2, 1)).year());
    try std.testing.expectEqual(Year.from_number(1928), Date.from_ymd(.from_numbers(1928, 12, 24)).year());
    try std.testing.expectEqual(Year.from_number(0), Date.from_ymd(.from_numbers(0, 12, 24)).year());
    try std.testing.expectEqual(Year.from_number(12), Date.from_ymd(.from_numbers(12, 12, 24)).year());
    try std.testing.expectEqual(Year.from_number(-123), Date.from_ymd(.from_numbers(-123, 12, 24)).year());
}

test "date.year_info" {
    try std.testing.expectEqual(Year.Info.from_number(2024), Date.from_ymd(.from_numbers(2024, 2, 1)).year_info());
    try std.testing.expectEqual(Year.Info.from_number(1928), Date.from_ymd(.from_numbers(1928, 12, 24)).year_info());
    try std.testing.expectEqual(Year.Info.from_number(0), Date.from_ymd(.from_numbers(0, 12, 24)).year_info());
    try std.testing.expectEqual(Year.Info.from_number(12), Date.from_ymd(.from_numbers(12, 12, 24)).year_info());
    try std.testing.expectEqual(Year.Info.from_number(-123), Date.from_ymd(.from_numbers(-123, 12, 24)).year_info());
}

test "date.month" {
    try std.testing.expectEqual(Month.from_number(2), Date.from_ymd(.from_numbers(2024, 2, 1)).month());
    try std.testing.expectEqual(Month.from_number(12), Date.from_ymd(.from_numbers(1928, 12, 24)).month());
    try std.testing.expectEqual(Month.from_number(12), Date.from_ymd(.from_numbers(0, 12, 24)).month());
    try std.testing.expectEqual(Month.from_number(12), Date.from_ymd(.from_numbers(12, 12, 24)).month());
    try std.testing.expectEqual(Month.from_number(12), Date.from_ymd(.from_numbers(-123, 12, 24)).month());
}

test "date.day" {
    try std.testing.expectEqual(Day.from_number(1), Date.from_ymd(.from_numbers(2024, 2, 1)).day());
    try std.testing.expectEqual(Day.from_number(24), Date.from_ymd(.from_numbers(1928, 12, 24)).day());
    try std.testing.expectEqual(Day.from_number(24), Date.from_ymd(.from_numbers(0, 12, 24)).day());
    try std.testing.expectEqual(Day.from_number(24), Date.from_ymd(.from_numbers(12, 12, 24)).day());
    try std.testing.expectEqual(Day.from_number(24), Date.from_ymd(.from_numbers(-123, 12, 24)).day());
}

test "date.ordinal_day" {
    try std.testing.expectEqual(Ordinal_Day.from_number(32), Date.from_ymd(.from_numbers(2024, 2, 1)).ordinal_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(359), Date.from_ymd(.from_numbers(1928, 12, 24)).ordinal_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(359), Date.from_ymd(.from_numbers(0, 12, 24)).ordinal_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(359), Date.from_ymd(.from_numbers(12, 12, 24)).ordinal_day());
    try std.testing.expectEqual(Ordinal_Day.from_number(358), Date.from_ymd(.from_numbers(-123, 12, 24)).ordinal_day());
}

test "date.ordinal_week" {
    try std.testing.expectEqual(Ordinal_Week.from_number(5), Date.from_ymd(.from_numbers(2024, 2, 1)).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_number(52), Date.from_ymd(.from_numbers(1928, 12, 24)).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_number(52), Date.from_ymd(.from_numbers(0, 12, 24)).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_number(52), Date.from_ymd(.from_numbers(12, 12, 24)).ordinal_week());
    try std.testing.expectEqual(Ordinal_Week.from_number(52), Date.from_ymd(.from_numbers(-123, 12, 24)).ordinal_week());
}

test "date.week_day" {
    try std.testing.expectEqual(Week_Day.thursday, Date.from_ymd(.from_numbers(2024, 2, 1)).week_day());
    try std.testing.expectEqual(Week_Day.monday, Date.from_ymd(.from_numbers(1928, 12, 24)).week_day());
    try std.testing.expectEqual(Week_Day.sunday, Date.from_ymd(.from_numbers(0, 12, 24)).week_day());
    try std.testing.expectEqual(Week_Day.monday, Date.from_ymd(.from_numbers(12, 12, 24)).week_day());
    try std.testing.expectEqual(Week_Day.monday, Date.from_ymd(.from_numbers(-123, 12, 24)).week_day());
}

test "date.iso_week" {
    try std.testing.expectEqual(ISO_Week.from_number(5), Date.from_ymd(.from_numbers(2024, 2, 1)).iso_week());
    try std.testing.expectEqual(ISO_Week.from_number(52), Date.from_ymd(.from_numbers(1928, 12, 24)).iso_week());
    try std.testing.expectEqual(ISO_Week.from_number(51), Date.from_ymd(.from_numbers(0, 12, 24)).iso_week());
    try std.testing.expectEqual(ISO_Week.from_number(52), Date.from_ymd(.from_numbers(12, 12, 24)).iso_week());
    try std.testing.expectEqual(ISO_Week.from_number(52), Date.from_ymd(.from_numbers(-123, 12, 24)).iso_week());
}

test "date.iso_week_date" {
    try std.testing.expectFmt("2024-W05-4", "{f}", .{ Date.from_ymd(.from_numbers(2024, 2, 1)).iso_week_date().fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("1928-W52-1", "{f}", .{ Date.from_ymd(.from_numbers(1928, 12, 24)).iso_week_date().fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("0000-W51-7", "{f}", .{ Date.from_ymd(.from_numbers(0, 12, 24)).iso_week_date().fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("0012-W52-1", "{f}", .{ Date.from_ymd(.from_numbers(12, 12, 24)).iso_week_date().fmt(ISO_Week_Date.iso8601_week_date) });
    try std.testing.expectFmt("9877-W52-1", "{f}", .{ Date.from_ymd(.from_numbers(-123, 12, 24)).iso_week_date().fmt(ISO_Week_Date.iso8601_week_date) });
}

test "date.info" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 2, 1)), Date.from_ymd(.from_numbers(2024, 2, 1)).info().date());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(1928, 12, 24)), Date.from_ymd(.from_numbers(1928, 12, 24)).info().date());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 12, 24)), Date.from_ymd(.from_numbers(0, 12, 24)).info().date());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(12, 12, 24)), Date.from_ymd(.from_numbers(12, 12, 24)).info().date());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(-123, 12, 24)), Date.from_ymd(.from_numbers(-123, 12, 24)).info().date());
}

test "date.ymd" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1), Date.from_ymd(.from_numbers(2024, 2, 1)).ymd());
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24), Date.from_ymd(.from_numbers(1928, 12, 24)).ymd());
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24), Date.from_ymd(.from_numbers(0, 12, 24)).ymd());
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24), Date.from_ymd(.from_numbers(12, 12, 24)).ymd());
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24), Date.from_ymd(.from_numbers(-123, 12, 24)).ymd());
}

test "Date.fmt" {
    const date1 = Date.from_ymd(.from_numbers(2024, 2, 1));
    const date2 = Date.from_ymd(.from_numbers(1928, 12, 24));
    const date3 = Date.from_ymd(.from_numbers(0, 12, 24));
    const date4 = Date.from_ymd(.from_numbers(12, 12, 24));
    const date5 = Date.from_ymd(.from_numbers(-123, 12, 24));

    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1.fmt("YYYY-MM-DD") });
    try std.testing.expectFmt("2024-02-01", "{f}", .{ date1 });
    try std.testing.expectFmt("2 2nd Feb February", "{f}", .{ date1.fmt("M Mo MMM MMMM") });
    try std.testing.expectFmt("1.1st", "{f}", .{ date1.fmt("Q.Qo") });
    try std.testing.expectFmt("24 Do 24th", "{f}", .{ date2.fmt("D [Do] Do") });
    try std.testing.expectFmt("359 359th 359", "{f}", .{ date2.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("32 32nd 032", "{f}", .{ date1.fmt("DDD DDDo DDDD") });
    try std.testing.expectFmt("4 4th Th Thu Thursday", "{f}", .{ date1.fmt("d do dd ddd dddd") });
    try std.testing.expectFmt("4 4th", "{f}", .{ date1.fmt("E Eo") });
    try std.testing.expectFmt("52 52nd 52", "{f}", .{ date2.fmt("w wo ww") });
    try std.testing.expectFmt("2024 24 2024 2024 +002024", "{f}", .{ date1.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("1928 28 1928 1928 +001928", "{f}", .{ date2.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("0 00 0000 0000 +000000", "{f}", .{ date3.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("12 12 0012 0012 +000012", "{f}", .{ date4.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("-123 77 -0123 9877 -000123", "{f}", .{ date5.fmt("Y YY YYY YYYY YYYYYY") });
    try std.testing.expectFmt("AD AD", "{f}", .{ date1.fmt("N NN") });

    try std.testing.expectFmt("0 0th Su Sun Sunday", "{f}", .{ date3.fmt("d do dd ddd dddd") });
    try std.testing.expectFmt("7 7th", "{f}", .{ date3.fmt("E Eo") });

    try std.testing.expectFmt("2000", "{f}", .{ @as(Date, @enumFromInt(0)).fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Year.from_number(2000).starting_date().fmt("Y") });
    try std.testing.expectFmt("2000", "{f}", .{ Date.from_yod(Year.from_number(2000), .first).fmt("Y") });
    try std.testing.expectFmt("2020", "{f}", .{ Date.from_yod(Year.from_number(2020), .first).fmt("Y") });
    try std.testing.expectFmt("1999", "{f}", .{ Date.from_yod(Year.from_number(1999), .first).fmt("Y") });
}

test "Date.from_string" {
    const date1 = Date.from_ymd(.from_numbers(2024, 2, 1));
    const date2 = Date.from_ymd(.from_numbers(1928, 12, 24));
    const date3 = Date.from_ymd(.from_numbers(1970, 1, 1));

    try std.testing.expectEqual(date1, try Date.from_string("YYYY-MM-DD", "2024-02-01"));
    try std.testing.expectEqual(date1, try Date.from_string("Y DDDo", "2024 32nd"));
    try std.testing.expectEqual(date1, try Date.from_string("Y MMM D", "+002024 feb 1"));
    try std.testing.expectEqual(date3, try Date.from_string("YY", "70"));
    try std.testing.expectEqual(date3, (try Date.from_string("YYYY-MM-DD", "1969-12-31")).plus_days(1));
    try std.testing.expectEqual(date3, try Date.from_string("x", "0"));
    try std.testing.expectEqual(date3, try Date.from_string("X", "0"));

    try std.testing.expectEqual(date1, try Date.from_string("G W E", "2024 5 4"));
    try std.testing.expectEqual(date2, try Date.from_string("G W E", "1928 52 1"));
    try std.testing.expectEqual(date3, try Date.from_string("G W E", "1970 1 4"));
    try std.testing.expectEqual(date3.plus_days(-1), try Date.from_string("G W E", "1970 1 3"));
}

test "Date.is_before" {
    try std.testing.expect(Date.from_ymd(.from_numbers(2024, 1, 31)).is_before(Date.from_ymd(.from_numbers(2024, 2, 1))));
    try std.testing.expect(!Date.from_ymd(.from_numbers(2024, 2, 1)).is_before(Date.from_ymd(.from_numbers(2024, 2, 1))));
    try std.testing.expect(!Date.from_ymd(.from_numbers(2024, 2, 2)).is_before(Date.from_ymd(.from_numbers(2024, 2, 1))));
}

test "Date.is_after" {
    try std.testing.expect(!Date.from_ymd(.from_numbers(2024, 1, 31)).is_after(Date.from_ymd(.from_numbers(2024, 2, 1))));
    try std.testing.expect(!Date.from_ymd(.from_numbers(2024, 2, 1)).is_after(Date.from_ymd(.from_numbers(2024, 2, 1))));
    try std.testing.expect(Date.from_ymd(.from_numbers(2024, 2, 2)).is_after(Date.from_ymd(.from_numbers(2024, 2, 1))));
}

test "Date.plus_days" {
    const d: Date = .from_ymd(.from_numbers(2024, 2, 1));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 2, 2)), d.plus_days(1));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 2, 11)), d.plus_days(10));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 1, 31)), d.plus_days(-1));
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 1, 29)), d.plus_days(-3));
}

test "Date.prev" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 1, 31)), Date.from_ymd(.from_numbers(2024, 2, 1)).prev());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(1928, 12, 23)), Date.from_ymd(.from_numbers(1928, 12, 24)).prev());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 12, 23)), Date.from_ymd(.from_numbers(0, 12, 24)).prev());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(12, 12, 23)), Date.from_ymd(.from_numbers(12, 12, 24)).prev());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(-123, 12, 23)), Date.from_ymd(.from_numbers(-123, 12, 24)).prev());
}

test "Date.next" {
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(2024, 2, 2)), Date.from_ymd(.from_numbers(2024, 2, 1)).next());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(1928, 12, 25)), Date.from_ymd(.from_numbers(1928, 12, 24)).next());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(0, 12, 25)), Date.from_ymd(.from_numbers(0, 12, 24)).next());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(12, 12, 25)), Date.from_ymd(.from_numbers(12, 12, 24)).next());
    try std.testing.expectEqual(Date.from_ymd(.from_numbers(-123, 12, 25)), Date.from_ymd(.from_numbers(-123, 12, 24)).next());
}

test "Date.on_or_after" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-01-13");
    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-14"));
    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-14"));
    d = Day.from_number(13).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-13"));
    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-14"));
}

test "Date.next_week_day" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-02-14");
    try std.testing.expectEqual(.monday, d.week_day());
    d = d.next_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-18"));
    d = d.next_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-25"));
}

test "Date.prev_week_day" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-02-14");
    try std.testing.expectEqual(.monday, d.week_day());
    d = d.prev_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-11"));
    d = d.prev_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-04"));
}

test "Date.next_day_of_month" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-02-14");
    d = d.next_day_of_month(.first);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-03-01"));
    d = d.next_day_of_month(.first);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-04-01"));
    d = d.next_day_of_month(.@"15");
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-04-15"));
}

test "Date.prev_day_of_month" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-02-14");
    d = d.prev_day_of_month(.first);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-01"));
    d = d.prev_day_of_month(.first);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-01"));
    d = d.prev_day_of_month(.@"15");
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "1999-12-15"));
}

test "Date.next_month_and_day" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-01-13");
    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-10-18"));
    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2001-10-18"));
    d = d.next_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2002-09-18"));
}

test "Date.prev_month_and_day" {
    var d = try Date.from_string("YYYY-MM-DD", "2000-01-13");
    d = d.prev_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "1999-10-18"));
    d = d.prev_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "1998-10-18"));
    d = d.prev_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "1998-09-18"));
}

test "Date.YMD.init/from_numbers" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1), Date.YMD.init(.from_number(2024), .february, .first));
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24), Date.YMD.init(.from_number(1928), .december, .@"24"));
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24), Date.YMD.init(.from_number(0), .december, .@"24"));
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24), Date.YMD.init(.from_number(12), .december, .@"24"));
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24), Date.YMD.init(.from_number(-123), .december, .@"24"));
}

test "Date.YMD.from_date" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1), Date.YMD.from_date(.from_ymd(.from_numbers(2024, 2, 1))));
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24), Date.YMD.from_date(.from_ymd(.from_numbers(1928, 12, 24))));
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24), Date.YMD.from_date(.from_ymd(.from_numbers(0, 12, 24))));
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24), Date.YMD.from_date(.from_ymd(.from_numbers(12, 12, 24))));
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24), Date.YMD.from_date(.from_ymd(.from_numbers(-123, 12, 24))));
}

test "Date.YMD.year_info" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1).year_info(), Date.from_ymd(.from_numbers(2024, 2, 1)).year_info());
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24).year_info(), Date.from_ymd(.from_numbers(1928, 12, 24)).year_info());
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24).year_info(), Date.from_ymd(.from_numbers(0, 12, 24)).year_info());
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24).year_info(), Date.from_ymd(.from_numbers(12, 12, 24)).year_info());
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24).year_info(), Date.from_ymd(.from_numbers(-123, 12, 24)).year_info());
}

test "Date.YMD.date" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1).date(), Date.from_ymd(.from_numbers(2024, 2, 1)));
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24).date(), Date.from_ymd(.from_numbers(1928, 12, 24)));
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24).date(), Date.from_ymd(.from_numbers(0, 12, 24)));
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24).date(), Date.from_ymd(.from_numbers(12, 12, 24)));
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24).date(), Date.from_ymd(.from_numbers(-123, 12, 24)));
}

test "Date.YMD.info" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 1).info(), Date.from_ymd(.from_numbers(2024, 2, 1)).info());
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 24).info(), Date.from_ymd(.from_numbers(1928, 12, 24)).info());
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 24).info(), Date.from_ymd(.from_numbers(0, 12, 24)).info());
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 24).info(), Date.from_ymd(.from_numbers(12, 12, 24)).info());
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 24).info(), Date.from_ymd(.from_numbers(-123, 12, 24)).info());
}

test "Date.YMD.is_before" {
    try std.testing.expect(Date.YMD.from_numbers(2024, 1, 31).is_before(Date.YMD.from_numbers(2024, 2, 1)));
    try std.testing.expect(!Date.YMD.from_numbers(2024, 2, 1).is_before(Date.YMD.from_numbers(2024, 2, 1)));
    try std.testing.expect(!Date.YMD.from_numbers(2024, 2, 2).is_before(Date.YMD.from_numbers(2024, 2, 1)));
}

test "Date.YMD.is_after" {
    try std.testing.expect(!Date.YMD.from_numbers(2024, 1, 31).is_after(Date.YMD.from_numbers(2024, 2, 1)));
    try std.testing.expect(!Date.YMD.from_numbers(2024, 2, 1).is_after(Date.YMD.from_numbers(2024, 2, 1)));
    try std.testing.expect(Date.YMD.from_numbers(2024, 2, 2).is_after(Date.YMD.from_numbers(2024, 2, 1)));
}

test "Date.YMD.prev" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 1, 31), Date.YMD.from_numbers(2024, 2, 1).prev());
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 23), Date.YMD.from_numbers(1928, 12, 24).prev());
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 23), Date.YMD.from_numbers(0, 12, 24).prev());
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 23), Date.YMD.from_numbers(12, 12, 24).prev());
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 23), Date.YMD.from_numbers(-123, 12, 24).prev());
}

test "Date.YMD.next" {
    try std.testing.expectEqual(Date.YMD.from_numbers(2024, 2, 2), Date.YMD.from_numbers(2024, 2, 1).next());
    try std.testing.expectEqual(Date.YMD.from_numbers(1928, 12, 25), Date.YMD.from_numbers(1928, 12, 24).next());
    try std.testing.expectEqual(Date.YMD.from_numbers(0, 12, 25), Date.YMD.from_numbers(0, 12, 24).next());
    try std.testing.expectEqual(Date.YMD.from_numbers(12, 12, 25), Date.YMD.from_numbers(12, 12, 24).next());
    try std.testing.expectEqual(Date.YMD.from_numbers(-123, 12, 25), Date.YMD.from_numbers(-123, 12, 24).next());
}

test "Date.YMD.next_day_of_month" {
    var d = Date.YMD.from_numbers(2000, 2, 14);
    d = d.next_day_of_month(.first);
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 3, 1), d);
    d = d.next_day_of_month(.first);
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 4, 1), d);
    d = d.next_day_of_month(.@"15");
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 4, 15), d);
}

test "Date.YMD.prev_day_of_month" {
    var d = Date.YMD.from_numbers(2000, 2, 14);
    d = d.prev_day_of_month(.first);
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 2, 1), d);
    d = d.prev_day_of_month(.first);
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 1, 1), d);
    d = d.prev_day_of_month(.@"15");
    try std.testing.expectEqual(Date.YMD.from_numbers(1999, 12, 15), d);
}

test "Date.YMD.next_month_and_day" {
    var d = Date.YMD.from_numbers(2000, 1, 13);
    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(2000, 10, 18), d);
    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(2001, 10, 18), d);
    d = d.next_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(2002, 9, 18), d);
}

test "Date.YMD.prev_month_and_day" {
    var d = Date.YMD.from_numbers(2000, 1, 13);
    d = d.prev_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(1999, 10, 18), d);
    d = d.prev_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(1998, 10, 18), d);
    d = d.prev_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(Date.YMD.from_numbers(1998, 9, 18), d);
}

const Time = tempora.Time;
const Date = tempora.Date;
const Year = tempora.Year;
const Month = tempora.Month;
const Day = tempora.Day;
const Week_Day = tempora.Week_Day;
const Ordinal_Day = tempora.Ordinal_Day;
const Ordinal_Week = tempora.Ordinal_Week;
const ISO_Week = tempora.ISO_Week;
const ISO_Week_Date = tempora.ISO_Week_Date;
const tempora = @import("tempora");
const std = @import("std");
