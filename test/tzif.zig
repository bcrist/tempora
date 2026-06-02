// Many of these test cases are from https://github.com/leroycep/zig-tzif/blob/master/tzif.zig
// Thanks for the test suite :)

test "invalid bytes" {
    try testing.expectError(error.InvalidFormat, tzif.read_memory(std.testing.allocator, "asdf", "asdfasdfasdfasdfsdf", false));
}

test "UTC" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    const res = try tzif.read_memory(arena.allocator(), "UTC", @embedFile("zoneinfo/UTC"), false);

    try testing.expectEqual(0, res.transition_count);
    try testing.expectEqualDeep(&[_]Timezone.Wall_Time_Info {
        .{
            .designation = "UTC",
            .begin_ts = null,
            .end_ts = null,
            .utc_offset_seconds = 0,
            .dst = .std,
            .source = .tzdata_wall,
        }
    }, res.infos);
}

test "Pacific/Honolulu" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    const transition_times = [7]i64{
        -2334101314, // Mon Jan 13 1896 22:31:26 GMT
        -1157283000, // Sun Apr 30 1933 12:30:00 GMT
        -1155436200, // Sun May 21 1933 21:30:00 GMT
        -880198200,  // Mon Feb 09 1942 12:30:00 GMT
        -769395600,  // Tue Aug 14 1945 23:00:00 GMT
        -765376200,  // Sun Sep 30 1945 11:30:00 GMT
        -712150200,  // Sun Jun 08 1947 12:30:00 GMT
    };
    const transition_types = [7]u8{ 1, 2, 1, 3, 4, 1, 5 };
    const infos = [6]Timezone.Wall_Time_Info{
        .{ .designation = "LMT", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -37886, .dst = .std, .source = .tzdata_wall },
        .{ .designation = "HST", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -37800, .dst = .std, .source = .tzdata_wall },
        .{ .designation = "HDT", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -34200, .dst = .dst, .source = .tzdata_wall },
        .{ .designation = "HWT", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -34200, .dst = .dst, .source = .tzdata_wall },
        .{ .designation = "HPT", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -34200, .dst = .dst, .source = .tzdata_utc },
        .{ .designation = "HST", .begin_ts = null, .end_ts = null, .utc_offset_seconds = -36000, .dst = .std, .source = .tzdata_wall },
    };

    const res = try tzif.read_memory(arena.allocator(), "Pacific/Honolulu", @embedFile("zoneinfo/Pacific/Honolulu"), false);

    try testing.expectEqualStrings("Pacific/Honolulu", res.id);
    try testing.expectEqualSlices(i64, &transition_times, res.transition_timestamps[0..res.transition_count]);
    try testing.expectEqualStrings(&transition_types, res.transition_info_indices[0..res.transition_count]);
    try testing.expectEqualDeep(&infos, res.infos);

    {
        const info = res.info(-1156939200);
        try testing.expectEqual(-34200, info.utc_offset_seconds);
        try testing.expectEqual(.dst, info.dst);
        try testing.expectEqualStrings("HDT", info.designation);
    }
    {
        // A second before the first timezone transition
        const info = res.info(-2334101315);
        try testing.expectEqual(-37886, info.utc_offset_seconds);
        try testing.expectEqual(.std, info.dst);
        try testing.expectEqualStrings("LMT", info.designation);
    }
    {
        // At the first timezone transition
        const info = res.info(-2334101314);
        try testing.expectEqual(-37800, info.utc_offset_seconds);
        try testing.expectEqual(.std, info.dst);
        try testing.expectEqualStrings("HST", info.designation);
    }
    {
        // After the first timezone transition
        const info = res.info(-2334101313);
        try testing.expectEqual(-37800, info.utc_offset_seconds);
        try testing.expectEqual(.std, info.dst);
        try testing.expectEqualStrings("HST", info.designation);
    }
    {
        // After the last timezone transition; conversion should be performed using the Posix TZ footer.
        // Taken from RFC8536 Appendix B.2
        const info = res.info(1546300800);
        try testing.expectEqual(-10 * std.time.s_per_hour, info.utc_offset_seconds);
        try testing.expectEqual(.std, info.dst);
        try testing.expectEqual(.posix_tz, info.source);
        try testing.expectEqualStrings("HST", info.designation);
    }
}

test "posix TZ string, regular year" {
    // IANA identifier America/Denver; default DST transition time at 2 am
    var result = try Posix.parse("MST7MDT,M3.2.0,M11.1.0");
    var stdoff: i32 = -25200;
    var dstoff: i32 = -21600;
    try testing.expectEqualStrings("MST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("MDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    try testing.expectEqual(Posix.Transition{
        .date = .{ .month_week_day = .{
            .month = .march,
            .week = .second,
            .day = .sunday,
        }},
        .time = .@"2am",
    }, result.dst.?.start);
    try testing.expectEqual(Posix.Transition{
        .date = .{ .month_week_day = .{
            .month = .november,
            .week = .first,
            .day = .sunday,
        }},
        .time = .@"2am",
    }, result.dst.?.end);
    try testing.expectEqual(stdoff, result.info(1612734960, 0).utc_offset_seconds);
    // 2021-03-14T01:59:59-07:00 (2nd Sunday of the 3rd month, MST)
    try testing.expectEqual(stdoff, result.info(1615712399, 0).utc_offset_seconds);
    // 2021-03-14T02:00:00-07:00 (2nd Sunday of the 3rd month, MST)
    try testing.expectEqual(dstoff, result.info(1615712400, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1620453601, 0).utc_offset_seconds);
    // 2021-11-07T01:59:59-06:00 (1st Sunday of the 11th month, MDT)
    try testing.expectEqual(dstoff, result.info(1636271999, 0).utc_offset_seconds);
    // 2021-11-07T02:00:00-06:00 (1st Sunday of the 11th month, MDT)
    try testing.expectEqual(stdoff, result.info(1636272000, 0).utc_offset_seconds);

    // IANA identifier: Europe/Berlin
    result = try Posix.parse("CET-1CEST,M3.5.0,M10.5.0/3");
    stdoff = 3600;
    dstoff = 7200;
    try testing.expectEqualStrings("CET", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("CEST", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    try testing.expectEqual(Posix.Transition{
        .date = .{ .month_week_day = .{
            .month = .march,
            .week = .last,
            .day = .sunday,
        }},
        .time = .@"2am",
    }, result.dst.?.start);
    try testing.expectEqual(Posix.Transition{
        .date = .{ .month_week_day = .{
            .month = .october,
            .week = .last,
            .day = .sunday,
        }},
        .time = .@"3am",
    }, result.dst.?.end);
    // 2023-10-29T00:59:59Z, or 2023-10-29 01:59:59 CEST. Offset should still be CEST.
    try testing.expectEqual(dstoff, result.info(1698541199, 0).utc_offset_seconds);
    // 2023-10-29T01:00:00Z, or 2023-10-29 03:00:00 CEST. Offset should now be CET.
    try testing.expectEqual(stdoff, result.info(1698541200, 0).utc_offset_seconds);

    // IANA identifier: America/New_York
    result = try Posix.parse("EST5EDT,M3.2.0/02:00:00,M11.1.0");
    stdoff = -18000;
    dstoff = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-05:00 --> dst 2023-03-12T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1678604399, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678604400, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-04:00 --> std 2023-11-05T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1699163999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699164000, 0).utc_offset_seconds);

    // IANA identifier: America/New_York
    result = try Posix.parse("EST5EDT,M3.2.0/02:00:00,M11.1.0/02:00:00");
    stdoff = -18000;
    dstoff = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-05:00 --> dst 2023-03-12T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1678604399, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678604400, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-04:00 --> std 2023-11-05T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1699163999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699164000, 0).utc_offset_seconds);

    // IANA identifier: America/New_York
    result = try Posix.parse("EST5EDT,M3.2.0,M11.1.0/02:00:00");
    stdoff = -18000;
    dstoff = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-05:00 --> dst 2023-03-12T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1678604399, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678604400, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-04:00 --> std 2023-11-05T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1699163999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699164000, 0).utc_offset_seconds);

    // IANA identifier: America/Chicago
    result = try Posix.parse("CST6CDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    stdoff = -21600;
    dstoff = -18000;
    try testing.expectEqualStrings("CST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("CDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-06:00 --> dst 2023-03-12T03:00:00-05:00
    try testing.expectEqual(stdoff, result.info(1678607999, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678608000, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-05:00 --> std 2023-11-05T01:00:00-06:00
    try testing.expectEqual(dstoff, result.info(1699167599, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699167600, 0).utc_offset_seconds);

    // IANA identifier: America/Denver
    result = try Posix.parse("MST7MDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    stdoff = -25200;
    dstoff = -21600;
    try testing.expectEqualStrings("MST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("MDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-07:00 --> dst 2023-03-12T03:00:00-06:00
    try testing.expectEqual(stdoff, result.info(1678611599, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678611600, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-06:00 --> std 2023-11-05T01:00:00-07:00
    try testing.expectEqual(dstoff, result.info(1699171199, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699171200, 0).utc_offset_seconds);

    // IANA identifier: America/Los_Angeles
    result = try Posix.parse("PST8PDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    stdoff = -28800;
    dstoff = -25200;
    try testing.expectEqualStrings("PST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("PDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-08:00 --> dst 2023-03-12T03:00:00-07:00
    try testing.expectEqual(stdoff, result.info(1678615199, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678615200, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-07:00 --> std 2023-11-05T01:00:00-08:00
    try testing.expectEqual(dstoff, result.info(1699174799, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699174800, 0).utc_offset_seconds);

    // IANA identifier: America/Sitka
    result = try Posix.parse("AKST9AKDT,M3.2.0,M11.1.0");
    stdoff = -32400;
    dstoff = -28800;
    try testing.expectEqualStrings("AKST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("AKDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-12T01:59:59-09:00 --> dst 2023-03-12T03:00:00-08:00
    try testing.expectEqual(stdoff, result.info(1678618799, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1678618800, 0).utc_offset_seconds);
    // transition dst 2023-11-05T01:59:59-08:00 --> std 2023-11-05T01:00:00-09:00
    try testing.expectEqual(dstoff, result.info(1699178399, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1699178400, 0).utc_offset_seconds);

    // IANA identifier: Asia/Jerusalem
    result = try Posix.parse("IST-2IDT,M3.4.4/26,M10.5.0");
    stdoff = 7200;
    dstoff = 10800;
    try testing.expectEqualStrings("IST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("IDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2023-03-24T01:59:59+02:00 --> dst 2023-03-24T03:00:00+03:00
    try testing.expectEqual(stdoff, result.info(1679615999, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1679616000, 0).utc_offset_seconds);
    // transition dst 2023-10-29T01:59:59+03:00 --> std 2023-10-29T01:00:00+02:00
    try testing.expectEqual(dstoff, result.info(1698533999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1698534000, 0).utc_offset_seconds);

    // IANA identifier: America/Argentina/Buenos_Aires
    result = try Posix.parse("WART4WARST,J1/0,J365/25"); // TODO : separate tests for jday ?
    stdoff = -10800;
    dstoff = -10800;
    try testing.expectEqualStrings("WART", result.std_designation());
    try testing.expectEqualStrings("WARST", result.dst_designation());
    // transition std 2023-03-24T01:59:59-03:00 --> dst 2023-03-24T03:00:00-03:00
    try testing.expectEqual(stdoff, result.info(1679633999, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1679637600, 0).utc_offset_seconds);
    // transition dst 2023-10-29T01:59:59-03:00 --> std 2023-10-29T01:00:00-03:00
    try testing.expectEqual(dstoff, result.info(1698555599, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1698552000, 0).utc_offset_seconds);

    // IANA identifier: America/Nuuk
    result = try Posix.parse("WGT3WGST,M3.5.0/-2,M10.5.0/-1");
    stdoff = -10800;
    dstoff = -7200;
    try testing.expectEqualStrings("WGT", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("WGST", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2021-03-27T21:59:59-03:00 --> dst 2021-03-27T23:00:00-02:00
    try testing.expectEqual(stdoff, result.info(1616893199, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1616893200, 0).utc_offset_seconds);
    // transition dst 2021-10-30T22:59:59-02:00 --> std 2021-10-30T22:00:00-03:00
    try testing.expectEqual(dstoff, result.info(1635641999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1635642000, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/New_York, start transition time specified" {
    // IANA identifier: America/New_York
    const result = try Posix.parse("EST5EDT,M3.2.0/02:00:00,M11.1.0");
    const stdoff: i32 = -18000;
    const dstoff: i32 = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-05:00 --> dst 2020-03-08T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1583650799, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583650800, 0).utc_offset_seconds);
    // transition dst 2020-11-01T01:59:59-04:00 --> std 2020-11-01T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1604210399, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604210400, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/New_York, both transition times specified" {
    // IANA identifier: America/New_York
    const result = try Posix.parse("EST5EDT,M3.2.0/02:00:00,M11.1.0/02:00:00");
    const stdoff: i32 = -18000;
    const dstoff: i32 = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-05:00 --> dst 2020-03-08T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1583650799, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583650800, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-04:00 --> std 2020-11-01T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1604210399, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604210400, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/New_York, end transition time specified" {
    // IANA identifier: America/New_York
    const result = try Posix.parse("EST5EDT,M3.2.0,M11.1.0/02:00:00");
    const stdoff: i32 = -18000;
    const dstoff: i32 = -14400;
    try testing.expectEqualStrings("EST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("EDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-05:00 --> dst 2020-03-08T03:00:00-04:00
    try testing.expectEqual(stdoff, result.info(1583650799, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583650800, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-04:00 --> std 2020-11-01T01:00:00-05:00
    try testing.expectEqual(dstoff, result.info(1604210399, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604210400, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/Chicago, both transition times specified" {
    // IANA identifier: America/Chicago
    const result = try Posix.parse("CST6CDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    const stdoff: i32 = -21600;
    const dstoff: i32 = -18000;
    try testing.expectEqualStrings("CST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("CDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-06:00 --> dst 2020-03-08T03:00:00-05:00
    try testing.expectEqual(stdoff, result.info(1583654399, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583654400, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-05:00 --> std 2020-11-01T01:00:00-06:00
    try testing.expectEqual(dstoff, result.info(1604213999, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604214000, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/Denver, both transition times specified" {
    // IANA identifier: America/Denver
    const result = try Posix.parse("MST7MDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    const stdoff: i32 = -25200;
    const dstoff: i32 = -21600;
    try testing.expectEqualStrings("MST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("MDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-07:00 --> dst 2020-03-08T03:00:00-06:00
    try testing.expectEqual(stdoff, result.info(1583657999, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583658000, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-06:00 --> std 2020-11-01T01:00:00-07:00
    try testing.expectEqual(dstoff, result.info(1604217599, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604217600, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/Los_Angeles, both transition times specified" {
    // IANA identifier: America/Los_Angeles
    const result = try Posix.parse("PST8PDT,M3.2.0/2:00:00,M11.1.0/2:00:00");
    const stdoff: i32 = -28800;
    const dstoff: i32 = -25200;
    try testing.expectEqualStrings("PST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("PDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-08:00 --> dst 2020-03-08T03:00:00-07:00
    try testing.expectEqual(stdoff, result.info(1583661599, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583661600, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-07:00 --> std 2020-11-01T01:00:00-08:00
    try testing.expectEqual(dstoff, result.info(1604221199, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604221200, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/Sitka" {
    // IANA identifier: America/Sitka
    const result = try Posix.parse("AKST9AKDT,M3.2.0,M11.1.0");
    const stdoff: i32 = -32400;
    const dstoff: i32 = -28800;
    try testing.expectEqualStrings("AKST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("AKDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-08T01:59:59-09:00 --> dst 2020-03-08T03:00:00-08:00
    try testing.expectEqual(stdoff, result.info(1583665199, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1583665200, 0).utc_offset_seconds);
    // transtion dst 2020-11-01T01:59:59-08:00 --> std 2020-11-01T01:00:00-09:00
    try testing.expectEqual(dstoff, result.info(1604224799, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1604224800, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, Asia/Jerusalem" {
    // IANA identifier: Asia/Jerusalem
    const result = try Posix.parse("IST-2IDT,M3.4.4/26,M10.5.0");
    const stdoff: i32 = 7200;
    const dstoff: i32 = 10800;
    try testing.expectEqualStrings("IST", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("IDT", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-27T01:59:59+02:00 --> dst 2020-03-27T03:00:00+03:00
    try testing.expectEqual(stdoff, result.info(1585267199, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1585267200, 0).utc_offset_seconds);
    // transtion dst 2020-10-25T01:59:59+03:00 --> std 2020-10-25T01:00:00+02:00
    try testing.expectEqual(dstoff, result.info(1603580399, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1603580400, 0).utc_offset_seconds);
}

// Buenos Aires has DST all year long, make sure that it never returns the STD offset
test "posix TZ string, leap year, America/Argentina/Buenos_Aires" {
    // IANA identifier: America/Argentina/Buenos_Aires
    const result = try Posix.parse("XXX2WARST3,J1/0,J365/23");
    const stdoff: i32 = -2 * std.time.s_per_hour;
    const dstoff: i32 = -3 * std.time.s_per_hour;
    try testing.expectEqualStrings("XXX", result.std_designation());
    try testing.expectEqualStrings("WARST", result.dst_designation());
    _ = stdoff;

    // transition std 2020-03-27T01:59:59-03:00 --> dst 2020-03-27T03:00:00-03:00
    try testing.expectEqual(dstoff, result.info(1585285199, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1585288800, 0).utc_offset_seconds);
    // transtion dst 2020-10-25T01:59:59-03:00 --> std 2020-10-25T01:00:00-03:00
    try testing.expectEqual(dstoff, result.info(1603601999, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1603598400, 0).utc_offset_seconds);

    // Make sure it returns dstoff at the start of the year
    try testing.expectEqual(dstoff, result.info(1577836800, 0).utc_offset_seconds); // 2020
    try testing.expectEqual(dstoff, result.info(1609459200, 0).utc_offset_seconds); // 2021

    // Make sure it returns dstoff at the end of the year
    try testing.expectEqual(dstoff, result.info(1609459199, 0).utc_offset_seconds);
}

test "posix TZ string, leap year, America/Nuuk" {
    // IANA identifier: America/Nuuk
    const result = try Posix.parse("WGT3WGST,M3.5.0/-2,M10.5.0/-1");
    const stdoff: i32 = -10800;
    const dstoff: i32 = -7200;
    try testing.expectEqualStrings("WGT", result.std_designation());
    try testing.expectEqual(stdoff, result.standard.utc_offset_seconds);
    try testing.expectEqualStrings("WGST", result.dst_designation());
    try testing.expectEqual(dstoff, result.dst.?.info.utc_offset_seconds);
    // transition std 2020-03-28T21:59:59-03:00 --> dst 2020-03-28T23:00:00-02:00
    try testing.expectEqual(stdoff, result.info(1585443599, 0).utc_offset_seconds);
    try testing.expectEqual(dstoff, result.info(1585443600, 0).utc_offset_seconds);
    // transtion dst 2020-10-24T22:59:59-02:00 --> std 2020-10-24T22:00:00-03:00
    try testing.expectEqual(dstoff, result.info(1603587599, 0).utc_offset_seconds);
    try testing.expectEqual(stdoff, result.info(1603587600, 0).utc_offset_seconds);
}

test "posix TZ, valid strings" {
    // from CPython's zoneinfo tests;
    // https://github.com/python/cpython/blob/main/Lib/test/test_zoneinfo/test_zoneinfo.py
    // Extreme offset hour
    _ = try Posix.parse("AAA24");
    _ = try Posix.parse("AAA+24");
    _ = try Posix.parse("AAA-24");
    _ = try Posix.parse("AAA24BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA+24BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA-24BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB24,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB+24,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB-24,J60/2,J300/2");
    // Extreme offset minute
    _ = try Posix.parse("AAA4:00BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA4:59BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB5:00,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB5:59,J60/2,J300/2");
    // Extreme offset second
    _ = try Posix.parse("AAA4:00:00BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA4:00:59BBB,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB5:00:00,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB5:00:59,J60/2,J300/2");
    // Extreme total offset
    _ = try Posix.parse("AAA24:59:59BBB5,J60/2,J300/2");
    _ = try Posix.parse("AAA-24:59:59BBB5,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB24:59:59,J60/2,J300/2");
    _ = try Posix.parse("AAA4BBB-24:59:59,J60/2,J300/2");
    // Extreme month
    _ = try Posix.parse("AAA4BBB,M12.1.1/2,M1.1.1/2");
    _ = try Posix.parse("AAA4BBB,M1.1.1/2,M12.1.1/2");
    // Extreme week
    _ = try Posix.parse("AAA4BBB,M1.5.1/2,M1.1.1/2");
    _ = try Posix.parse("AAA4BBB,M1.1.1/2,M1.5.1/2");
    // Extreme weekday
    _ = try Posix.parse("AAA4BBB,M1.1.6/2,M2.1.1/2");
    _ = try Posix.parse("AAA4BBB,M1.1.1/2,M2.1.6/2");
    // Extreme numeric offset
    _ = try Posix.parse("AAA4BBB,0/2,20/2");
    _ = try Posix.parse("AAA4BBB,0/2,0/14");
    _ = try Posix.parse("AAA4BBB,20/2,365/2");
    _ = try Posix.parse("AAA4BBB,365/2,365/14");
    // Extreme julian offset
    _ = try Posix.parse("AAA4BBB,J1/2,J20/2");
    _ = try Posix.parse("AAA4BBB,J1/2,J1/14");
    _ = try Posix.parse("AAA4BBB,J20/2,J365/2");
    _ = try Posix.parse("AAA4BBB,J365/2,J365/14");
    // Extreme transition hour
    _ = try Posix.parse("AAA4BBB,J60/167,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/+167,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/-167,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/167");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/+167");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/-167");
    // Extreme transition minute
    _ = try Posix.parse("AAA4BBB,J60/2:00,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2:59,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/2:00");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/2:59");
    // Extreme transition second
    _ = try Posix.parse("AAA4BBB,J60/2:00:00,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2:00:59,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/2:00:00");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/2:00:59");
    // Extreme total transition time
    _ = try Posix.parse("AAA4BBB,J60/167:59:59,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/-167:59:59,J300/2");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/167:59:59");
    _ = try Posix.parse("AAA4BBB,J60/2,J300/-167:59:59");
}

// The following tests are from CPython's zoneinfo tests;
// https://github.com/python/cpython/blob/main/Lib/test/test_zoneinfo/test_zoneinfo.py
test "posix TZ invalid string, unquoted alphanumeric" {
    try std.testing.expectError(error.DesignationEmpty, Posix.parse("+11"));
}

test "posix TZ invalid string, unquoted alphanumeric in DST" {
    try std.testing.expectError(error.DesignationEmpty, Posix.parse("GMT0+11,M3.2.0/2,M11.1.0/3"));
}

test "posix TZ invalid string, only one transition rule" {
    try std.testing.expectError(error.MissingDstEndTransition, Posix.parse("PST8PDT,M3.2.0/2"));
}

test "posix TZ invalid string, transition rule but no DST" {
    try std.testing.expectError(error.MissingUtcOffset, Posix.parse("GMT,M3.2.0/2,M11.1.0/3"));
}

test "posix TZ invalid offset hours" {
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA168"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA+168"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA-168"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA168BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA+168BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA-168BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB168,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB+168,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB-168,J60/2,J300/2"));
}

test "posix TZ invalid offset minutes" {
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4:0BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4:100BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB5:0,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB5:100,J60/2,J300/2"));
}

test "posix TZ invalid offset seconds" {
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4:00:0BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4:00:100BBB,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB5:00:0,J60/2,J300/2"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB5:00:100,J60/2,J300/2"));
}

test "posix TZ completely invalid dates" {
    try std.testing.expectError(error.InvalidMonth, Posix.parse("AAA4BBB,M1443339,M11.1.0/3"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,M3.2.0/2,0349309483959c"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,,J300/2"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,z,J300/2"));
    try std.testing.expectError(error.EndOfStream, Posix.parse("AAA4BBB,J60/2,"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,J60/2,z"));
}

test "posix TZ invalid months" {
    try std.testing.expectError(error.InvalidMonth, Posix.parse("AAA4BBB,M13.1.1/2,M1.1.1/2"));
    try std.testing.expectError(error.InvalidMonth, Posix.parse("AAA4BBB,M1.1.1/2,M13.1.1/2"));
    try std.testing.expectError(error.InvalidMonth, Posix.parse("AAA4BBB,M0.1.1/2,M1.1.1/2"));
    try std.testing.expectError(error.InvalidMonth, Posix.parse("AAA4BBB,M1.1.1/2,M0.1.1/2"));
}

test "posix TZ invalid weeks" {
    try std.testing.expectError(error.InvalidWeek, Posix.parse("AAA4BBB,M1.6.1/2,M1.1.1/2"));
    try std.testing.expectError(error.InvalidWeek, Posix.parse("AAA4BBB,M1.1.1/2,M1.6.1/2"));
}

test "posix TZ invalid weekday" {
    try std.testing.expectError(error.InvalidDayOfWeek, Posix.parse("AAA4BBB,M1.1.7/2,M2.1.1/2"));
    try std.testing.expectError(error.InvalidDayOfWeek, Posix.parse("AAA4BBB,M1.1.1/2,M2.1.7/2"));
}

test "posix TZ invalid numeric offset" {
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,-1/2,20/2"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,1/2,-1/2"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,367,20/2"));
    try std.testing.expectError(error.InvalidOrdinalDay, Posix.parse("AAA4BBB,1/2,367/2"));
}

test "posix TZ invalid julian offset" {
    try std.testing.expectError(error.InvalidJulianOrdinalDay, Posix.parse("AAA4BBB,J0/2,J20/2"));
    try std.testing.expectError(error.InvalidJulianOrdinalDay, Posix.parse("AAA4BBB,J20/2,J366/2"));
}

test "posix TZ invalid transition time" {
    try std.testing.expectError(error.MissingDstEndTransition, Posix.parse("AAA4BBB,J60/2/3,J300/2"));
    try std.testing.expectError(error.UnexpectedTzStringSuffix, Posix.parse("AAA4BBB,J60/2,J300/2/3"));
}

test "posix TZ invalid transition hour" {
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/168,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/+168,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/-168,J300/2"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/2,J300/168"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/2,J300/+168"));
    try std.testing.expectError(error.InvalidHours, Posix.parse("AAA4BBB,J60/2,J300/-168"));
}

test "posix TZ invalid transition minutes" {
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB,J60/2:0,J300/2"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB,J60/2:100,J300/2"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB,J60/2,J300/2:0"));
    try std.testing.expectError(error.InvalidMinutes, Posix.parse("AAA4BBB,J60/2,J300/2:100"));
}

test "posix TZ invalid transition seconds" {
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB,J60/2:00:0,J300/2"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB,J60/2:00:100,J300/2"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB,J60/2,J300/2:00:0"));
    try std.testing.expectError(error.InvalidSeconds, Posix.parse("AAA4BBB,J60/2,J300/2:00:100"));
}

test "posix TZ EST5EDT,M3.2.0/4:00,M11.1.0/3:00 from zoneinfo_test.py" {
    // Transition to EDT on the 2nd Sunday in March at 4 AM, and
    // transition back on the first Sunday in November at 3AM
    const result = try Posix.parse("EST5EDT,M3.2.0/4:00,M11.1.0/3:00");
    try testing.expectEqual(@as(i32, -18000), result.info(1552107600, 0).utc_offset_seconds); // 2019-03-09T00:00:00-05:00
    try testing.expectEqual(@as(i32, -18000), result.info(1552208340, 0).utc_offset_seconds); // 2019-03-10T03:59:00-05:00
    try testing.expectEqual(@as(i32, -14400), result.info(1572667200, 0).utc_offset_seconds); // 2019-11-02T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1572760740, 0).utc_offset_seconds); // 2019-11-03T01:59:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1572760800, 0).utc_offset_seconds); // 2019-11-03T02:00:00-04:00
    try testing.expectEqual(@as(i32, -18000), result.info(1572764400, 0).utc_offset_seconds); // 2019-11-03T02:00:00-05:00
    try testing.expectEqual(@as(i32, -18000), result.info(1583657940, 0).utc_offset_seconds); // 2020-03-08T03:59:00-05:00
    try testing.expectEqual(@as(i32, -14400), result.info(1604210340, 0).utc_offset_seconds); // 2020-11-01T01:59:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1604210400, 0).utc_offset_seconds); // 2020-11-01T02:00:00-04:00
    try testing.expectEqual(@as(i32, -18000), result.info(1604214000, 0).utc_offset_seconds); // 2020-11-01T02:00:00-05:00
}

test "posix TZ GMT0BST-1,M3.5.0/1:00,M10.5.0/2:00 from zoneinfo_test.py" {
    // Transition to BST happens on the last Sunday in March at 1 AM GMT
    // and the transition back happens the last Sunday in October at 2AM BST
    const result = try Posix.parse("GMT0BST-1,M3.5.0/1:00,M10.5.0/2:00");
    try testing.expectEqual(@as(i32, 0), result.info(1553904000, 0).utc_offset_seconds); // 2019-03-30T00:00:00+00:00
    try testing.expectEqual(@as(i32, 0), result.info(1553993940, 0).utc_offset_seconds); // 2019-03-31T00:59:00+00:00
    try testing.expectEqual(@as(i32, 3600), result.info(1553994000, 0).utc_offset_seconds); // 2019-03-31T02:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1572044400, 0).utc_offset_seconds); // 2019-10-26T00:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1572134340, 0).utc_offset_seconds); // 2019-10-27T00:59:00+01:00
    try testing.expectEqual(@as(i32, 0), result.info(1585443540, 0).utc_offset_seconds); // 2020-03-29T00:59:00+00:00
    try testing.expectEqual(@as(i32, 3600), result.info(1585443600, 0).utc_offset_seconds); // 2020-03-29T02:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1603583940, 0).utc_offset_seconds); // 2020-10-25T00:59:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1603584000, 0).utc_offset_seconds); // 2020-10-25T01:00:00+01:00
    try testing.expectEqual(@as(i32, 0), result.info(1603591200, 0).utc_offset_seconds); // 2020-10-25T02:00:00+00:00
}

test "posix TZ AEST-10AEDT,M10.1.0/2,M4.1.0/3 from zoneinfo_test.py" {
    // Austrialian time zone - DST start is chronologically first
    const result = try Posix.parse("AEST-10AEDT,M10.1.0/2,M4.1.0/3");
    try testing.expectEqual(@as(i32, 39600), result.info(1554469200, 0).utc_offset_seconds); // 2019-04-06T00:00:00+11:00
    try testing.expectEqual(@as(i32, 39600), result.info(1554562740, 0).utc_offset_seconds); // 2019-04-07T01:59:00+11:00
    try testing.expectEqual(@as(i32, 39600), result.info(1554562740, 0).utc_offset_seconds); // 2019-04-07T01:59:00+11:00
    try testing.expectEqual(@as(i32, 39600), result.info(1554562800, 0).utc_offset_seconds); // 2019-04-07T02:00:00+11:00
    try testing.expectEqual(@as(i32, 39600), result.info(1554562860, 0).utc_offset_seconds); // 2019-04-07T02:01:00+11:00
    try testing.expectEqual(@as(i32, 36000), result.info(1554566400, 0).utc_offset_seconds); // 2019-04-07T02:00:00+10:00
    try testing.expectEqual(@as(i32, 36000), result.info(1554566460, 0).utc_offset_seconds); // 2019-04-07T02:01:00+10:00
    try testing.expectEqual(@as(i32, 36000), result.info(1554570000, 0).utc_offset_seconds); // 2019-04-07T03:00:00+10:00
    try testing.expectEqual(@as(i32, 36000), result.info(1554570000, 0).utc_offset_seconds); // 2019-04-07T03:00:00+10:00
    try testing.expectEqual(@as(i32, 36000), result.info(1570197600, 0).utc_offset_seconds); // 2019-10-05T00:00:00+10:00
    try testing.expectEqual(@as(i32, 36000), result.info(1570291140, 0).utc_offset_seconds); // 2019-10-06T01:59:00+10:00
    try testing.expectEqual(@as(i32, 39600), result.info(1570291200, 0).utc_offset_seconds); // 2019-10-06T03:00:00+11:00
}

test "posix TZ IST-1GMT0,M10.5.0,M3.5.0/1 from zoneinfo_test.py" {
    // Irish time zone - negative DST
    const result = try Posix.parse("IST-1GMT0,M10.5.0,M3.5.0/1");
    try testing.expectEqual(@as(i32, 0), result.info(1553904000, 0).utc_offset_seconds); // 2019-03-30T00:00:00+00:00
    try testing.expectEqual(@as(i32, 0), result.info(1553993940, 0).utc_offset_seconds); // 2019-03-31T00:59:00+00:00
    try testing.expectEqual(.dst, result.info(1553993940, 0).dst); // 2019-03-31T00:59:00+00:00
    try testing.expectEqual(@as(i32, 3600), result.info(1553994000, 0).utc_offset_seconds); // 2019-03-31T02:00:00+01:00
    try testing.expectEqual(.std, result.info(1553994000, 0).dst); // 2019-03-31T02:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1572044400, 0).utc_offset_seconds); // 2019-10-26T00:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1572134340, 0).utc_offset_seconds); // 2019-10-27T00:59:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1572134400, 0).utc_offset_seconds); // 2019-10-27T01:00:00+01:00
    try testing.expectEqual(@as(i32, 0), result.info(1572138000, 0).utc_offset_seconds); // 2019-10-27T01:00:00+00:00
    try testing.expectEqual(@as(i32, 0), result.info(1572141600, 0).utc_offset_seconds); // 2019-10-27T02:00:00+00:00
    try testing.expectEqual(@as(i32, 0), result.info(1585443540, 0).utc_offset_seconds); // 2020-03-29T00:59:00+00:00
    try testing.expectEqual(@as(i32, 3600), result.info(1585443600, 0).utc_offset_seconds); // 2020-03-29T02:00:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1603583940, 0).utc_offset_seconds); // 2020-10-25T00:59:00+01:00
    try testing.expectEqual(@as(i32, 3600), result.info(1603584000, 0).utc_offset_seconds); // 2020-10-25T01:00:00+01:00
    try testing.expectEqual(@as(i32, 0), result.info(1603591200, 0).utc_offset_seconds); // 2020-10-25T02:00:00+00:00
}

test "posix TZ <+11>-11 from zoneinfo_test.py" {
    // Pacific/Kosrae: Fixed offset zone with a quoted numerical tzname
    const result = try Posix.parse("<+11>-11");
    try testing.expectEqual(@as(i32, 39600), result.info(1577797200, 0).utc_offset_seconds); // 2020-01-01T00:00:00+11:00
}

test "posix TZ <-04>4<-03>,M9.1.6/24,M4.1.6/24 from zoneinfo_test.py" {
    // Quoted STD and DST, transitions at 24:00
    const result = try Posix.parse("<-04>4<-03>,M9.1.6/24,M4.1.6/24");
    try testing.expectEqual(@as(i32, -14400), result.info(1588305600, 0).utc_offset_seconds); // 2020-05-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -10800), result.info(1604199600, 0).utc_offset_seconds); // 2020-11-01T00:00:00-03:00
}

test "posix TZ EST5EDT,0/0,J365/25 from zoneinfo_test.py" {
    // Permanent daylight saving time is modeled with transitions at 0/0
    // and J365/25, as mentioned in RFC 8536 Section 3.3.1
    const result = try Posix.parse("EST5EDT,0/0,J365/25");
    try testing.expectEqual(@as(i32, -14400), result.info(1546315200, 0).utc_offset_seconds); // 2019-01-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1559361600, 0).utc_offset_seconds); // 2019-06-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1577851199, 0).utc_offset_seconds); // 2019-12-31T23:59:59.999999-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1577851200, 0).utc_offset_seconds); // 2020-01-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1583035200, 0).utc_offset_seconds); // 2020-03-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1590984000, 0).utc_offset_seconds); // 2020-06-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(1609473599, 0).utc_offset_seconds); // 2020-12-31T23:59:59.999999-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(13569480000, 0).utc_offset_seconds); // 2400-01-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(13574664000, 0).utc_offset_seconds); // 2400-03-01T00:00:00-04:00
    try testing.expectEqual(@as(i32, -14400), result.info(13601102399, 0).utc_offset_seconds); // 2400-12-31T23:59:59.999999-04:00
}

test "posix TZ AAA3BBB,J60/12,J305/12 from zoneinfo_test.py" {
    // Transitions on March 1st and November 1st of each year
    const result = try Posix.parse("AAA3BBB,J60/12,J305/12");
    try testing.expectEqual(@as(i32, -10800), result.info(1546311600, 0).utc_offset_seconds); // 2019-01-01T00:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1551322800, 0).utc_offset_seconds); // 2019-02-28T00:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1551452340, 0).utc_offset_seconds); // 2019-03-01T11:59:00-03:00
    try testing.expectEqual(@as(i32, -7200), result.info(1551452400, 0).utc_offset_seconds); // 2019-03-01T13:00:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1572613140, 0).utc_offset_seconds); // 2019-11-01T10:59:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1572613200, 0).utc_offset_seconds); // 2019-11-01T11:00:00-02:00
    try testing.expectEqual(@as(i32, -10800), result.info(1572616800, 0).utc_offset_seconds); // 2019-11-01T11:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1572620400, 0).utc_offset_seconds); // 2019-11-01T12:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1577847599, 0).utc_offset_seconds); // 2019-12-31T23:59:59.999999-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1577847600, 0).utc_offset_seconds); // 2020-01-01T00:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1582945200, 0).utc_offset_seconds); // 2020-02-29T00:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1583074740, 0).utc_offset_seconds); // 2020-03-01T11:59:00-03:00
    try testing.expectEqual(@as(i32, -7200), result.info(1583074800, 0).utc_offset_seconds); // 2020-03-01T13:00:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1604235540, 0).utc_offset_seconds); // 2020-11-01T10:59:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1604235600, 0).utc_offset_seconds); // 2020-11-01T11:00:00-02:00
    try testing.expectEqual(@as(i32, -10800), result.info(1604239200, 0).utc_offset_seconds); // 2020-11-01T11:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1604242800, 0).utc_offset_seconds); // 2020-11-01T12:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1609469999, 0).utc_offset_seconds); // 2020-12-31T23:59:59.999999-03:00
}

test "posix TZ <-03>3<-02>,M3.5.0/-2,M10.5.0/-1 from zoneinfo_test.py" {
    // Taken from America/Godthab, this rule has a transition on the
    // Saturday before the last Sunday of March and October, at 22:00 and 23:00,
    // respectively. This is encoded with negative start and end transition times.
    const result = try Posix.parse("<-03>3<-02>,M3.5.0/-2,M10.5.0/-1");
    try testing.expectEqual(@as(i32, -10800), result.info(1585278000, 0).utc_offset_seconds); // 2020-03-27T00:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1585443599, 0).utc_offset_seconds); // 2020-03-28T21:59:59-03:00
    try testing.expectEqual(@as(i32, -7200), result.info(1585443600, 0).utc_offset_seconds); // 2020-03-28T23:00:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1603580400, 0).utc_offset_seconds); // 2020-10-24T21:00:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1603584000, 0).utc_offset_seconds); // 2020-10-24T22:00:00-02:00
    try testing.expectEqual(@as(i32, -10800), result.info(1603587600, 0).utc_offset_seconds); // 2020-10-24T22:00:00-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1603591200, 0).utc_offset_seconds); // 2020-10-24T23:00:00-03:00
}

test "posix TZ AAA3BBB,M3.2.0/01:30,M11.1.0/02:15:45 from zoneinfo_test.py" {
    // Transition times with minutes and seconds
    const result = try Posix.parse("AAA3BBB,M3.2.0/01:30,M11.1.0/02:15:45");
    try testing.expectEqual(@as(i32, -10800), result.info(1331438400, 0).utc_offset_seconds); // 2012-03-11T01:00:00-03:00
    try testing.expectEqual(@as(i32, -7200), result.info(1331440200, 0).utc_offset_seconds); // 2012-03-11T02:30:00-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1351998944, 0).utc_offset_seconds); // 2012-11-04T01:15:44.999999-02:00
    try testing.expectEqual(@as(i32, -7200), result.info(1351998945, 0).utc_offset_seconds); // 2012-11-04T01:15:45-02:00
    try testing.expectEqual(@as(i32, -10800), result.info(1352002545, 0).utc_offset_seconds); // 2012-11-04T01:15:45-03:00
    try testing.expectEqual(@as(i32, -10800), result.info(1352006145, 0).utc_offset_seconds); // 2012-11-04T02:15:45-03:00
}

const Posix = tempora.Timezone.Posix;
const tzif = tempora.Timezone.tzif;
const Timezone = tempora.Timezone;
const tempora = @import("tempora");
const testing = std.testing;
const std = @import("std");
