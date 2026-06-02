test {
    _ = @import("posix_tz.zig");
    _ = @import("tzif.zig");

    try std.testing.expect(tempora.now_utc(std.testing.io).dt.date.is_after(.epoch));
}

test "Time" {
    const t1: Time = .from_hmsm(0, 0, 0, 0);
    const t2: Time = .from_hmsm(1, 2, 3, 4);
    const t3: Time = .from_hmsm(23, 59, 59, 999);
    const t4: Time = .from_hmsm(12, 0, 0, 0);
    const t5: Time = .from_hmsm(4, 45, 0, 0);
    const t6: Time = .from_hmsm(20, 15, 0, 0);

    try std.testing.expectFmt("00:00:00.000+00:00", "{f}", .{ t1.with_offset(0) });

    try std.testing.expectFmt("00:00:00.000", "{f}", .{ t1.with_offset(0).fmt(Time.With_Offset.iso8601_local) });
    try std.testing.expectFmt("01:02:03.004", "{f}", .{ t2.with_offset(0).fmt(Time.With_Offset.iso8601_local) });
    try std.testing.expectFmt("23:59:59.999", "{f}", .{ t3.with_offset(0).fmt(Time.With_Offset.iso8601_local) });
    try std.testing.expectFmt("12:00:00.000", "{f}", .{ t4.with_offset(0).fmt(Time.With_Offset.iso8601_local) });
    try std.testing.expectFmt("04:45:00.000", "{f}", .{ t5.with_offset(0).fmt(Time.With_Offset.iso8601_local) });
    try std.testing.expectFmt("20:15:00.000", "{f}", .{ t6.with_offset(0).fmt(Time.With_Offset.iso8601_local) });

    try std.testing.expectFmt("12:00:00 am", "{f}", .{ t1.with_offset(0).fmt(Time.With_Offset.hms) });
    try std.testing.expectFmt("1:02:03 am", "{f}", .{ t2.with_offset(0).fmt(Time.With_Offset.hms) });
    try std.testing.expectFmt("11:59:59 pm", "{f}", .{ t3.with_offset(0).fmt(Time.With_Offset.hms) });
    try std.testing.expectFmt("12:00:00 pm", "{f}", .{ t4.with_offset(0).fmt(Time.With_Offset.hms) });
    try std.testing.expectFmt("4:45:00 am", "{f}", .{ t5.with_offset(0).fmt(Time.With_Offset.hms) });
    try std.testing.expectFmt("8:15:00 pm", "{f}", .{ t6.with_offset(0).fmt(Time.With_Offset.hms) });

    try std.testing.expectFmt("12:00 am", "{f}", .{ t1.with_offset(0).fmt("kk:mm a") });
    try std.testing.expectFmt(" 1:02 am", "{f}", .{ t2.with_offset(0).fmt("kk:mm a") });
    try std.testing.expectFmt("11:59 pm", "{f}", .{ t3.with_offset(0).fmt("kk:mm a") });
    try std.testing.expectFmt("12:00 pm", "{f}", .{ t4.with_offset(0).fmt("kk:mm a") });
    try std.testing.expectFmt(" 4:45 am", "{f}", .{ t5.with_offset(0).fmt("kk:mm a") });
    try std.testing.expectFmt(" 8:15 pm", "{f}", .{ t6.with_offset(0).fmt("kk:mm a") });

    try std.testing.expectFmt(" 0:00", "{f}", .{ t1.with_offset(0).fmt("KK:mm") });
    try std.testing.expectFmt(" 1:02", "{f}", .{ t2.with_offset(0).fmt("KK:mm") });
    try std.testing.expectFmt("23:59", "{f}", .{ t3.with_offset(0).fmt("KK:mm") });
    try std.testing.expectFmt("12:00", "{f}", .{ t4.with_offset(0).fmt("KK:mm") });
    try std.testing.expectFmt(" 4:45", "{f}", .{ t5.with_offset(0).fmt("KK:mm") });
    try std.testing.expectFmt("20:15", "{f}", .{ t6.with_offset(0).fmt("KK:mm") });

    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601, "00:00:00.000+00:00"), t1.with_offset(0));

    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "00:00:00.000"), t1.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "01:02:03.004"), t2.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "23:59:59.999"), t3.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "12:00:00.000"), t4.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "04:45:00.000"), t5.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "20:15:00.000"), t6.with_offset(0));

    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "12:00:00.000 am"), t1.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "1:02:03.004 am"), t2.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "11:59:59.999 pm"), t3.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "12:00:00.000 pm"), t4.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "4:45:00.000 am"), t5.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("h:mm:ss.SSS a", "8:15:00.000 pm"), t6.with_offset(0));

    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", " 0:00:00.000"), t1.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", " 1:02:03.004"), t2.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", "23:59:59.999"), t3.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", "12:00:00.000"), t4.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", " 4:45:00.000"), t5.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("KK:mm:ss.SSS", "20:15:00.000"), t6.with_offset(0));

    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", "12:00:00.000 am"), t1.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", " 1:02:03.004 am"), t2.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", "11:59:59.999 pm"), t3.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", "12:00:00.000 pm"), t4.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", " 4:45:00.000 am"), t5.with_offset(0));
    try std.testing.expectEqual(Time.With_Offset.from_string("kk:mm:ss.SSS a", " 8:15:00.000 pm"), t6.with_offset(0));
}

test "Date" {
    const date1 = Date.from_ymd(.from_numbers(2024, 2, 1));
    const date2 = Date.from_ymd(.from_numbers(1928, 12, 24));
    const date3 = Date.from_ymd(.from_numbers(0, 12, 24));
    const date4 = Date.from_ymd(.from_numbers(12, 12, 24));
    const date5 = Date.from_ymd(.from_numbers(-123, 12, 24));
    const date6 = Date.from_ymd(.from_numbers(1970, 1, 1));

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

    try std.testing.expectEqual(date1, try Date.from_string("YYYY-MM-DD", "2024-02-01"));
    try std.testing.expectEqual(date1, try Date.from_string("Y DDDo", "2024 32nd"));
    try std.testing.expectEqual(date1, try Date.from_string("Y MMM D", "+002024 feb 1"));
    try std.testing.expectEqual(date6, try Date.from_string("YY", "70"));
    try std.testing.expectEqual(date6, (try Date.from_string("YYYY-MM-DD", "1969-12-31")).plus_days(1));
    try std.testing.expectEqual(date6, try Date.from_string("x", "0"));
    try std.testing.expectEqual(date6, try Date.from_string("X", "0"));

    try std.testing.expectEqual(53, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week().as_number());
    try std.testing.expectEqual(6, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().day.as_iso());
    try std.testing.expectEqual(2004, Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date().year.as_number());
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

    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-6"), Date.from_ymd(.from_numbers(2005, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2004-W53-7"), Date.from_ymd(.from_numbers(2005, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W01-1"), Date.from_ymd(.from_numbers(2005, 1, 3)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-6"), Date.from_ymd(.from_numbers(2005, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2005-W52-7"), Date.from_ymd(.from_numbers(2006, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W01-1"), Date.from_ymd(.from_numbers(2006, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2006-W52-7"), Date.from_ymd(.from_numbers(2006, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W01-1"), Date.from_ymd(.from_numbers(2007, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2007-W52-7"), Date.from_ymd(.from_numbers(2007, 12, 30)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-1"), Date.from_ymd(.from_numbers(2007, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W01-2"), Date.from_ymd(.from_numbers(2008, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2008-W52-7"), Date.from_ymd(.from_numbers(2008, 12, 28)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-1"), Date.from_ymd(.from_numbers(2008, 12, 29)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-2"), Date.from_ymd(.from_numbers(2008, 12, 30)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-3"), Date.from_ymd(.from_numbers(2008, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W01-4"), Date.from_ymd(.from_numbers(2009, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-4"), Date.from_ymd(.from_numbers(2009, 12, 31)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-5"), Date.from_ymd(.from_numbers(2010, 1, 1)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-6"), Date.from_ymd(.from_numbers(2010, 1, 2)).iso_week_date());
    try std.testing.expectEqual(try ISO_Week_Date.from_string(ISO_Week_Date.iso8601_week_date, "2009-W53-7"), Date.from_ymd(.from_numbers(2010, 1, 3)).iso_week_date());

    try std.testing.expectEqual(date1, try Date.from_string("G W E", "2024 5 4"));
    try std.testing.expectEqual(date2, try Date.from_string("G W E", "1928 52 1"));
    try std.testing.expectEqual(date6, try Date.from_string("G W E", "1970 1 4"));
    try std.testing.expectEqual(date6.plus_days(-1), try Date.from_string("G W E", "1970 1 3"));

    var d = Date.from_ymd(.{ .year = .from_number(2000), .month = .january, .day = .first });
    try std.testing.expectEqual(.first, d.ordinal_day());
    try std.testing.expectEqual(d, (try Date.from_string("YYYY-MM-DD", "1999-12-31")).plus_days(1));
    try std.testing.expect(!d.is_after(d));
    try std.testing.expect(!d.is_before(d));
    try std.testing.expect(d.is_after(try Date.from_string("YYYY-MM-DD", "1999-12-31")));
    try std.testing.expect(d.is_before(try Date.from_string("YYYY-MM-DD", "2000-01-02")));

    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-14"));
    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-01-14"));
    d = Day.from_number(13).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-13"));
    d = Day.from_number(14).on_or_after(d);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-14"));

    try std.testing.expectEqual(.monday, d.week_day());
    d = d.next_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-18"));
    d = d.next_week_day(.friday);
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-02-25"));

    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2000-10-18"));
    d = d.next_month_and_day(.october, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2001-10-18"));
    d = d.next_month_and_day(.september, Day.from_number(18));
    try std.testing.expectEqual(d, try Date.from_string("YYYY-MM-DD", "2002-09-18"));
}

test "Date_Time" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.america, &.embedded);
    try db.add_lazy(tempora.tz.gmt, &.embedded);
    try db.add_designations(tempora.tz.designations.common);

    const tz = db.timezone("America/Chicago").?;
    const gmt = db.timezone("GMT").?;

    const dt1 = (Date_Time {
        .date = .from_ymd(.{ .year = .from_number(2024), .month = .february, .day = .first }),
        .time = .from_hmsm(12, 34, 56, 789),
    }).with_offset(0);
    const dt2 = (Date_Time {
        .date = .from_ymd(.from_numbers(1928, 12, 24)),
        .time = .from_hmsm(0, 30, 0, 0),
    }).with_offset(0);

    const DTO = Date_Time.With_Offset;

    try std.testing.expectFmt("2024-02-01 12:34:56.789 +00:00", "{f}", .{ dt1.fmt(DTO.sql_ms) });
    try std.testing.expectFmt("2024-02-01 12:34:56.789 GMT", "{f}", .{ dt1.in_timezone(gmt).fmt(DTO.sql_ms) });
    try std.testing.expectFmt("2024-02-01 06:34:56.789 CST", "{f}", .{ dt1.in_timezone(tz).fmt(DTO.sql_ms) });

    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 +0000", "{f}", .{ dt2.in_timezone(gmt).fmt(DTO.rfc2822) });
    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 GMT", "{f}", .{ dt2.in_timezone(gmt).fmt(DTO.http) });
    try std.testing.expectFmt("1928-12-24T00:30:00.000+00:00", "{f}", .{ dt2.in_timezone(gmt).fmt(DTO.iso8601) });

    try std.testing.expectEqual(dt1, try DTO.from_string(DTO.sql_ms, "2024-02-01 12:34:56.789 +00:00"));
    try std.testing.expectEqual(dt1, (try DTO.from_string_tzdb(DTO.sql_ms, "2024-02-01 06:34:56.789 CST", &db)).in_timezone(null));
}

test "Month" {
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

    try std.testing.expectEqual(31, Month.from_number(1).days(Year.from_number(2020)));
    try std.testing.expectEqual(29, Month.from_number(2).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(3).days(Year.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(4).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(5).days(Year.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(6).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(7).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(8).days(Year.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(9).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(10).days(Year.from_number(2020)));
    try std.testing.expectEqual(30, Month.from_number(11).days(Year.from_number(2020)));
    try std.testing.expectEqual(31, Month.from_number(12).days(Year.from_number(2020)));
}

test "Week_Day" {
    try std.testing.expectEqual(.monday, try Week_Day.from_string("Mon", .{}));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("Tues", .{}));
    try std.testing.expectEqual(.wednesday, try Week_Day.from_string("wednesday", .{}));
    try std.testing.expectError(error.InvalidString, Week_Day.from_string("7", .{}));
    try std.testing.expectEqual(.saturday, try Week_Day.from_string("7", .{ .allow_numeric = true }));
}

test "Year" {
    try std.testing.expectEqual(2000, Year.epoch.as_number());
    try std.testing.expectEqual(2000, Year.from_number(2000).as_number());
    try std.testing.expectEqual(2020, Year.from_number(2020).as_number());
    try std.testing.expectEqual(1999, Year.from_number(1999).as_number());
    try std.testing.expectEqual(1970, Year.from_number(1970).as_number());
    try std.testing.expectEqual(Year.from_number(2024), try Year.from_string("2024", .{}));
    try std.testing.expectError(error.InvalidString, Year.from_string("2024", .{ .allow_non_two_digit_year = false }));
    try std.testing.expectEqual(Year.from_number(24), try Year.from_string("'24", .{}));
    try std.testing.expectEqual(Year.from_number(2024), try Year.from_string("'24", .{ .allow_two_digit_year = true }));
    try std.testing.expectEqual(Year.from_number(69), try Year.from_string("'69", .{}));
    try std.testing.expectEqual(Year.from_number(1969), try Year.from_string("'69", .{ .allow_two_digit_year = true }));
    try std.testing.expectEqual(Year.from_number(123), try Year.from_string("123", .{}));
    try std.testing.expectEqual(Year.from_number(4), try Year.from_string(" 4 ", .{}));
    try std.testing.expectError(error.InvalidString, Year.from_string("'24", .{ .allow_two_digit_year = false, .allow_non_two_digit_year = false }));
    try std.testing.expectEqual(Year.from_number(2000), try Year.from_string(" 2000 AD", .{}));
    try std.testing.expectEqual(Year.from_number(1), try Year.from_string(" 1 AD", .{}));
    try std.testing.expectEqual(Year.from_number(0), try Year.from_string(" 0 AD", .{}));
    try std.testing.expectEqual(Year.from_number(1), try Year.from_string(" 0 BC", .{}));
    try std.testing.expectEqual(Year.from_number(0), try Year.from_string(" 1 BC", .{}));
    try std.testing.expectEqual(Year.from_number(-1), try Year.from_string(" 2 BC", .{}));
    try std.testing.expectEqual(Year.from_number(-1999), try Year.from_string(" 2000 BC", .{}));
    try std.testing.expectError(error.InvalidString, Year.from_string(" 2000 BC", .{ .allow_era_suffix = false }));

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

test "timezone" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.all, &.embedded);

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());

    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("UTC", utc.posix.?.std_designation());
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
}

test "current timezone (system)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_current(std.testing.io, .system(null));


    try std.testing.expect(db.local.infos.len > 0);
}

test "current timezone (link, override)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.africa, &.embedded);
    try db.add_current(std.testing.io, .{
        .override = "Africa/Cairo",
        .search_paths = &.{},
        .tzdata_override_search_path = null,
        .tzdata_search_paths = &.{},
        .link_existing = true,
    });

    try std.testing.expectEqualStrings("Africa/Cairo", db.local.id);
}

test "TZDB.designation_utc_offset_ms" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_designations(tempora.tz.designations.common);

    try std.testing.expect(db.designations.count() > 0);

    const dto = Date.epoch.with_time(.midnight).with_offset(0);

    try std.testing.expectEqual(-6 * 60 * 60 * 1000, db.designation_utc_offset_ms("CST", dto).?);
    try std.testing.expectEqual(1 * 60 * 60 * 1000, db.designation_utc_offset_ms("BST", dto).?);
    try std.testing.expectEqual(13 * 60 * 60 * 1000, db.designation_utc_offset_ms("NZDT", dto).?);
}

const Time = tempora.Time;
const Date = tempora.Date;
const Date_Time = tempora.Date_Time;
const Year = tempora.Year;
const Month = tempora.Month;
const Day = tempora.Day;
const Week_Day = tempora.Week_Day;
const ISO_Week_Date = tempora.ISO_Week_Date;
const Timezone = tempora.Timezone;
const TZDB = tempora.TZDB;
const tempora = @import("tempora");
const std = @import("std");