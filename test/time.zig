test "Time.from_hmsm_numbers" {
    try std.testing.expectEqual(Time.midnight, Time.from_hmsm_numbers(0, 0, 0, 0));
    try std.testing.expectEqual(Time.@"1am", Time.from_hmsm_numbers(1, 0, 0, 0));
    try std.testing.expectEqual(Time.noon, Time.from_hmsm_numbers(12, 0, 0, 0));
    try std.testing.expect(Time.is_after(.midnight_eod, Time.from_hmsm_numbers(23, 59, 59, 999)));
    try std.testing.expect(Time.is_before(.midnight_eod, Time.from_hmsm_numbers(23, 59, 59, 999).plus_ms(2)));

    try std.testing.expectEqual(234, @backingInt(Time.from_hmsm_numbers(0, 0, 0, 234)));
    try std.testing.expectEqual(1000, @backingInt(Time.from_hmsm_numbers(0, 0, 1, 0)));
    try std.testing.expectEqual(59234, @backingInt(Time.from_hmsm_numbers(0, 0, 59, 234)));
    try std.testing.expectEqual(119004, @backingInt(Time.from_hmsm_numbers(0, 1, 59, 4)));
    try std.testing.expectEqual(3661004, @backingInt(Time.from_hmsm_numbers(1, 1, 1, 4)));
    try std.testing.expectEqual(86399000, @backingInt(Time.from_hmsm_numbers(23, 59, 59, 0)));
}

test "Time.from_hmsm" {
    try std.testing.expectEqual(Time.midnight, Time.from_hmsm(.from_numbers(0, 0, 0, 0)));
    try std.testing.expectEqual(Time.@"1am", Time.from_hmsm(.from_numbers(1, 0, 0, 0)));
    try std.testing.expectEqual(Time.noon, Time.from_hmsm(.from_numbers(12, 0, 0, 0)));
    try std.testing.expect(Time.is_after(.midnight_eod, Time.from_hmsm(.from_numbers(23, 59, 59, 999))));
    try std.testing.expect(Time.is_before(.midnight_eod, Time.from_hmsm(.from_numbers(23, 59, 59, 999)).plus_ms(2)));

    try std.testing.expectEqual(234, @backingInt(Time.from_hmsm(.from_numbers(0, 0, 0, 234))));
    try std.testing.expectEqual(1000, @backingInt(Time.from_hmsm(.from_numbers(0, 0, 1, 0))));
    try std.testing.expectEqual(59234, @backingInt(Time.from_hmsm(.from_numbers(0, 0, 59, 234))));
    try std.testing.expectEqual(119004, @backingInt(Time.from_hmsm(.from_numbers(0, 1, 59, 4))));
    try std.testing.expectEqual(3661004, @backingInt(Time.from_hmsm(.from_numbers(1, 1, 1, 4))));
    try std.testing.expectEqual(86399000, @backingInt(Time.from_hmsm(.from_numbers(23, 59, 59, 0))));
}

test "Time.HMSM.h" {
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 0, 234).hmsm().h);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 1, 0).hmsm().h);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 1, 59, 4).hmsm().h);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(1, 0, 0, 0).hmsm().h);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(1, 1, 1, 4).hmsm().h);
    try std.testing.expectEqual(12, Time.from_hmsm_numbers(12, 0, 0, 0).hmsm().h);
    try std.testing.expectEqual(13, Time.from_hmsm_numbers(13, 0, 0, 0).hmsm().h);
    try std.testing.expectEqual(23, Time.from_hmsm_numbers(23, 59, 59, 999).hmsm().h);
    try std.testing.expectEqual(0, Time.hmsm(.midnight).h);
    try std.testing.expectEqual(0, Time.hmsm(.@"12am").h);
    try std.testing.expectEqual(1, Time.hmsm(.@"1am").h);
    try std.testing.expectEqual(2, Time.hmsm(.@"2am").h);
    try std.testing.expectEqual(3, Time.hmsm(.@"3am").h);
    try std.testing.expectEqual(4, Time.hmsm(.@"4am").h);
    try std.testing.expectEqual(5, Time.hmsm(.@"5am").h);
    try std.testing.expectEqual(6, Time.hmsm(.@"6am").h);
    try std.testing.expectEqual(7, Time.hmsm(.@"7am").h);
    try std.testing.expectEqual(8, Time.hmsm(.@"8am").h);
    try std.testing.expectEqual(9, Time.hmsm(.@"9am").h);
    try std.testing.expectEqual(10, Time.hmsm(.@"10am").h);
    try std.testing.expectEqual(11, Time.hmsm(.@"11am").h);
    try std.testing.expectEqual(12, Time.hmsm(.@"12pm").h);
    try std.testing.expectEqual(12, Time.hmsm(.noon).h);
    try std.testing.expectEqual(13, Time.hmsm(.@"1pm").h);
    try std.testing.expectEqual(14, Time.hmsm(.@"2pm").h);
    try std.testing.expectEqual(15, Time.hmsm(.@"3pm").h);
    try std.testing.expectEqual(16, Time.hmsm(.@"4pm").h);
    try std.testing.expectEqual(17, Time.hmsm(.@"5pm").h);
    try std.testing.expectEqual(18, Time.hmsm(.@"6pm").h);
    try std.testing.expectEqual(19, Time.hmsm(.@"7pm").h);
    try std.testing.expectEqual(20, Time.hmsm(.@"8pm").h);
    try std.testing.expectEqual(21, Time.hmsm(.@"9pm").h);
    try std.testing.expectEqual(22, Time.hmsm(.@"10pm").h);
    try std.testing.expectEqual(23, Time.hmsm(.@"11pm").h);
    try std.testing.expectEqual(24, Time.hmsm(.midnight_eod).h);
}

test "Time.minutes_since_midnight" {
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 0, 234).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 1, 0).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 59, 999).minutes_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 1, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 1, 59, 4).minutes_since_midnight());
    try std.testing.expectEqual(60, Time.from_hmsm_numbers(1, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(61, Time.from_hmsm_numbers(1, 1, 1, 4).minutes_since_midnight());
    try std.testing.expectEqual(12 * 60, Time.from_hmsm_numbers(12, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(13 * 60, Time.from_hmsm_numbers(13, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(24 * 60 - 1, Time.from_hmsm_numbers(23, 59, 59, 999).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.minutes_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.minutes_since_midnight(.@"12am"));
    try std.testing.expectEqual(60 * 1, Time.minutes_since_midnight(.@"1am"));
    try std.testing.expectEqual(60 * 2, Time.minutes_since_midnight(.@"2am"));
    try std.testing.expectEqual(60 * 3, Time.minutes_since_midnight(.@"3am"));
    try std.testing.expectEqual(60 * 4, Time.minutes_since_midnight(.@"4am"));
    try std.testing.expectEqual(60 * 5, Time.minutes_since_midnight(.@"5am"));
    try std.testing.expectEqual(60 * 6, Time.minutes_since_midnight(.@"6am"));
    try std.testing.expectEqual(60 * 7, Time.minutes_since_midnight(.@"7am"));
    try std.testing.expectEqual(60 * 8, Time.minutes_since_midnight(.@"8am"));
    try std.testing.expectEqual(60 * 9, Time.minutes_since_midnight(.@"9am"));
    try std.testing.expectEqual(60 * 10, Time.minutes_since_midnight(.@"10am"));
    try std.testing.expectEqual(60 * 11, Time.minutes_since_midnight(.@"11am"));
    try std.testing.expectEqual(60 * 12, Time.minutes_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60 * 12, Time.minutes_since_midnight(.noon));
    try std.testing.expectEqual(60 * 13, Time.minutes_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60 * 14, Time.minutes_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60 * 15, Time.minutes_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60 * 16, Time.minutes_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60 * 17, Time.minutes_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60 * 18, Time.minutes_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60 * 19, Time.minutes_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60 * 20, Time.minutes_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60 * 21, Time.minutes_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60 * 22, Time.minutes_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60 * 23, Time.minutes_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60 * 24, Time.minutes_since_midnight(.midnight_eod));
}

test "Time.HMSM.m" {
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 0, 234).hmsm().m);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 1, 0).hmsm().m);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 59, 999).hmsm().m);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 1, 0, 0).hmsm().m);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 1, 59, 4).hmsm().m);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(1, 0, 0, 0).hmsm().m);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(1, 1, 1, 4).hmsm().m);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(12, 0, 0, 0).hmsm().m);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(13, 0, 0, 0).hmsm().m);
    try std.testing.expectEqual(59, Time.from_hmsm_numbers(23, 59, 59, 999).hmsm().m);
    try std.testing.expectEqual(0, Time.hmsm(.midnight).m);
    try std.testing.expectEqual(0, Time.hmsm(.@"12am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"1am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"2am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"3am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"4am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"5am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"6am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"7am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"8am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"9am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"10am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"11am").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"12pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.noon).m);
    try std.testing.expectEqual(0, Time.hmsm(.@"1pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"2pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"3pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"4pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"5pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"6pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"7pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"8pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"9pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"10pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.@"11pm").m);
    try std.testing.expectEqual(0, Time.hmsm(.midnight_eod).m);
}

test "Time.seconds_since_midnight" {
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 0, 234).seconds_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 0, 1, 0).seconds_since_midnight());
    try std.testing.expectEqual(59, Time.from_hmsm_numbers(0, 0, 59, 999).seconds_since_midnight());
    try std.testing.expectEqual(60, Time.from_hmsm_numbers(0, 1, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(119, Time.from_hmsm_numbers(0, 1, 59, 4).seconds_since_midnight());
    try std.testing.expectEqual(3600, Time.from_hmsm_numbers(1, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(3661, Time.from_hmsm_numbers(1, 1, 1, 4).seconds_since_midnight());
    try std.testing.expectEqual(12 * 60 * 60, Time.from_hmsm_numbers(12, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(13 * 60 * 60, Time.from_hmsm_numbers(13, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(24 * 60 * 60 - 1, Time.from_hmsm_numbers(23, 59, 59, 999).seconds_since_midnight());
    try std.testing.expectEqual(0, Time.seconds_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.seconds_since_midnight(.@"12am"));
    try std.testing.expectEqual(60 * 60 * 1, Time.seconds_since_midnight(.@"1am"));
    try std.testing.expectEqual(60 * 60 * 2, Time.seconds_since_midnight(.@"2am"));
    try std.testing.expectEqual(60 * 60 * 3, Time.seconds_since_midnight(.@"3am"));
    try std.testing.expectEqual(60 * 60 * 4, Time.seconds_since_midnight(.@"4am"));
    try std.testing.expectEqual(60 * 60 * 5, Time.seconds_since_midnight(.@"5am"));
    try std.testing.expectEqual(60 * 60 * 6, Time.seconds_since_midnight(.@"6am"));
    try std.testing.expectEqual(60 * 60 * 7, Time.seconds_since_midnight(.@"7am"));
    try std.testing.expectEqual(60 * 60 * 8, Time.seconds_since_midnight(.@"8am"));
    try std.testing.expectEqual(60 * 60 * 9, Time.seconds_since_midnight(.@"9am"));
    try std.testing.expectEqual(60 * 60 * 10, Time.seconds_since_midnight(.@"10am"));
    try std.testing.expectEqual(60 * 60 * 11, Time.seconds_since_midnight(.@"11am"));
    try std.testing.expectEqual(60 * 60 * 12, Time.seconds_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60 * 60 * 12, Time.seconds_since_midnight(.noon));
    try std.testing.expectEqual(60 * 60 * 13, Time.seconds_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60 * 60 * 14, Time.seconds_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60 * 60 * 15, Time.seconds_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60 * 60 * 16, Time.seconds_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60 * 60 * 17, Time.seconds_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60 * 60 * 18, Time.seconds_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60 * 60 * 19, Time.seconds_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60 * 60 * 20, Time.seconds_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60 * 60 * 21, Time.seconds_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60 * 60 * 22, Time.seconds_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60 * 60 * 23, Time.seconds_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60 * 60 * 24, Time.seconds_since_midnight(.midnight_eod));
}

test "Time.HMSM.s" {
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 0, 234).hmsm().s);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(0, 0, 1, 0).hmsm().s);
    try std.testing.expectEqual(59, Time.from_hmsm_numbers(0, 0, 59, 999).hmsm().s);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 1, 0, 0).hmsm().s);
    try std.testing.expectEqual(59, Time.from_hmsm_numbers(0, 1, 59, 4).hmsm().s);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(1, 0, 0, 0).hmsm().s);
    try std.testing.expectEqual(1, Time.from_hmsm_numbers(1, 1, 1, 4).hmsm().s);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(12, 0, 0, 0).hmsm().s);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(13, 0, 0, 0).hmsm().s);
    try std.testing.expectEqual(59, Time.from_hmsm_numbers(23, 59, 59, 999).hmsm().s);
    try std.testing.expectEqual(0, Time.hmsm(.midnight).s);
    try std.testing.expectEqual(0, Time.hmsm(.@"12am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"1am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"2am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"3am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"4am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"5am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"6am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"7am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"8am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"9am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"10am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"11am").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"12pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.noon).s);
    try std.testing.expectEqual(0, Time.hmsm(.@"1pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"2pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"3pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"4pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"5pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"6pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"7pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"8pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"9pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"10pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.@"11pm").s);
    try std.testing.expectEqual(0, Time.hmsm(.midnight_eod).s);
}

test "Time.ms_since_midnight" {
    try std.testing.expectEqual(234, Time.from_hmsm_numbers(0, 0, 0, 234).ms_since_midnight());
    try std.testing.expectEqual(1000, Time.from_hmsm_numbers(0, 0, 1, 0).ms_since_midnight());
    try std.testing.expectEqual(59999, Time.from_hmsm_numbers(0, 0, 59, 999).ms_since_midnight());
    try std.testing.expectEqual(60000, Time.from_hmsm_numbers(0, 1, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(119004, Time.from_hmsm_numbers(0, 1, 59, 4).ms_since_midnight());
    try std.testing.expectEqual(3600000, Time.from_hmsm_numbers(1, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(3661004, Time.from_hmsm_numbers(1, 1, 1, 4).ms_since_midnight());
    try std.testing.expectEqual(12 * 60 * 60000, Time.from_hmsm_numbers(12, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(13 * 60 * 60000, Time.from_hmsm_numbers(13, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(24 * 60 * 60000 - 1, Time.from_hmsm_numbers(23, 59, 59, 999).ms_since_midnight());
    try std.testing.expectEqual(0, Time.ms_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.ms_since_midnight(.@"12am"));
    try std.testing.expectEqual(60 * 60000 * 1, Time.ms_since_midnight(.@"1am"));
    try std.testing.expectEqual(60 * 60000 * 2, Time.ms_since_midnight(.@"2am"));
    try std.testing.expectEqual(60 * 60000 * 3, Time.ms_since_midnight(.@"3am"));
    try std.testing.expectEqual(60 * 60000 * 4, Time.ms_since_midnight(.@"4am"));
    try std.testing.expectEqual(60 * 60000 * 5, Time.ms_since_midnight(.@"5am"));
    try std.testing.expectEqual(60 * 60000 * 6, Time.ms_since_midnight(.@"6am"));
    try std.testing.expectEqual(60 * 60000 * 7, Time.ms_since_midnight(.@"7am"));
    try std.testing.expectEqual(60 * 60000 * 8, Time.ms_since_midnight(.@"8am"));
    try std.testing.expectEqual(60 * 60000 * 9, Time.ms_since_midnight(.@"9am"));
    try std.testing.expectEqual(60 * 60000 * 10, Time.ms_since_midnight(.@"10am"));
    try std.testing.expectEqual(60 * 60000 * 11, Time.ms_since_midnight(.@"11am"));
    try std.testing.expectEqual(60 * 60000 * 12, Time.ms_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60 * 60000 * 12, Time.ms_since_midnight(.noon));
    try std.testing.expectEqual(60 * 60000 * 13, Time.ms_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60 * 60000 * 14, Time.ms_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60 * 60000 * 15, Time.ms_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60 * 60000 * 16, Time.ms_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60 * 60000 * 17, Time.ms_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60 * 60000 * 18, Time.ms_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60 * 60000 * 19, Time.ms_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60 * 60000 * 20, Time.ms_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60 * 60000 * 21, Time.ms_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60 * 60000 * 22, Time.ms_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60 * 60000 * 23, Time.ms_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60 * 60000 * 24, Time.ms_since_midnight(.midnight_eod));
}

test "Time.HMSM.ms" {
    try std.testing.expectEqual(234, Time.from_hmsm_numbers(0, 0, 0, 234).hmsm().ms);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 0, 1, 0).hmsm().ms);
    try std.testing.expectEqual(999, Time.from_hmsm_numbers(0, 0, 59, 999).hmsm().ms);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(0, 1, 0, 0).hmsm().ms);
    try std.testing.expectEqual(4, Time.from_hmsm_numbers(0, 1, 59, 4).hmsm().ms);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(1, 0, 0, 0).hmsm().ms);
    try std.testing.expectEqual(4, Time.from_hmsm_numbers(1, 1, 1, 4).hmsm().ms);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(12, 0, 0, 0).hmsm().ms);
    try std.testing.expectEqual(0, Time.from_hmsm_numbers(13, 0, 0, 0).hmsm().ms);
    try std.testing.expectEqual(999, Time.from_hmsm_numbers(23, 59, 59, 999).hmsm().ms);
    try std.testing.expectEqual(0, Time.hmsm(.midnight).ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"12am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"1am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"2am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"3am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"4am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"5am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"6am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"7am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"8am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"9am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"10am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"11am").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"12pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.noon).ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"1pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"2pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"3pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"4pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"5pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"6pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"7pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"8pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"9pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"10pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.@"11pm").ms);
    try std.testing.expectEqual(0, Time.hmsm(.midnight_eod).ms);
}

test "Time.is_before" {
    try std.testing.expect(Time.is_before(.@"1am", .noon));
    try std.testing.expect(Time.is_before(.@"12am", .noon));
    try std.testing.expect(!Time.is_before(.noon, .noon));
    try std.testing.expect(!Time.is_before(.@"1pm", .noon));
    try std.testing.expect(!Time.is_before(.midnight_eod, .noon));
}

test "Time.is_after" {
    try std.testing.expect(!Time.is_after(.@"1am", .noon));
    try std.testing.expect(!Time.is_after(.@"12am", .noon));
    try std.testing.expect(!Time.is_after(.noon, .noon));
    try std.testing.expect(Time.is_after(.@"1pm", .noon));
    try std.testing.expect(Time.is_after(.midnight_eod, .noon));
}

test "Time.plus_duration" {
    try std.testing.expectEqual(Time.@"1pm", Time.plus_duration(.noon, .fromSeconds(60 * 60)));
    try std.testing.expectEqual(Time.@"11am", Time.plus_duration(.noon, .fromSeconds(-60 * 60)));
}

test "Time.minus_duration" {
    try std.testing.expectEqual(Time.@"11am", Time.minus_duration(.noon, .fromSeconds(60 * 60)));
    try std.testing.expectEqual(Time.@"1pm", Time.minus_duration(.noon, .fromSeconds(-60 * 60)));
}

test "Time.plus_hmsm" {
    try std.testing.expectEqual(Time.@"1am", Time.plus_hmsm(.midnight, .from_numbers(1, 0, 0, 0)));
    try std.testing.expectEqual(Time.@"11pm", Time.plus_hmsm(.midnight, .@"11pm"));
}

test "Time.plus_ms" {
    try std.testing.expectEqual(10, Time.plus_ms(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(-1234, Time.plus_ms(.midnight, -1234).ms_since_midnight());
}

test "Time.plus_seconds" {
    try std.testing.expectEqual(10000, Time.plus_seconds(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(-10000, Time.plus_seconds(.midnight, -10).ms_since_midnight());
}

test "Time.plus_minutes" {
    try std.testing.expectEqual(600000, Time.plus_minutes(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(-600000, Time.plus_minutes(.midnight, -10).ms_since_midnight());
}

test "Time.plus_hours" {
    try std.testing.expectEqual(3600000, Time.plus_hours(.midnight, 1).ms_since_midnight());
    try std.testing.expectEqual(-3600000, Time.plus_hours(.midnight, -1).ms_since_midnight());
}

test "Time.With_Offset" {
    try std.testing.expectEqual(Date.with_time(.epoch, .midnight), Time.with_date(.midnight, .epoch));
    try std.testing.expectEqual(Date.with_time(.unix_epoch, .noon), Time.with_date(.noon, .unix_epoch));
}

test "Time.With_Offset.in_timezone" {
    const tz1 = Timezone.utc;
    const offset1 = tz1.utc_offset_ms(0);

    const tz2 = Timezone.fixed(-5, 0);
    const offset2 = tz2.utc_offset_ms(0);

    try std.testing.expectEqual(
        Time.with_timezone(.noon, &tz2, offset2),
        Time.with_timezone(.@"5pm", &tz1, offset1).in_timezone(&tz2, offset2),
    );

    try std.testing.expectEqual(
        Time.with_timezone(.@"5pm", &tz1, offset1),
        Time.with_timezone(.noon, &tz2, offset2).in_timezone(&tz1, offset1),
    );
}

test "Time.With_Offset.fmt, from_string" {
    const t1: Time = .from_hmsm_numbers(0, 0, 0, 0);
    const t2: Time = .from_hmsm_numbers(1, 2, 3, 4);
    const t3: Time = .from_hmsm_numbers(23, 59, 59, 999);
    const t4: Time = .from_hmsm_numbers(12, 0, 0, 0);
    const t5: Time = .from_hmsm_numbers(4, 45, 0, 0);
    const t6: Time = .from_hmsm_numbers(20, 15, 0, 0);

    try std.testing.expectFmt("00:00:00.000+00:00", "{f}", .{t1.with_offset(0)});

    try std.testing.expectFmt("00:00:00.000", "{f}", .{t1.with_offset(0).fmt(Time.With_Offset.iso8601_local)});
    try std.testing.expectFmt("01:02:03.004", "{f}", .{t2.with_offset(0).fmt(Time.With_Offset.iso8601_local)});
    try std.testing.expectFmt("23:59:59.999", "{f}", .{t3.with_offset(0).fmt(Time.With_Offset.iso8601_local)});
    try std.testing.expectFmt("12:00:00.000", "{f}", .{t4.with_offset(0).fmt(Time.With_Offset.iso8601_local)});
    try std.testing.expectFmt("04:45:00.000", "{f}", .{t5.with_offset(0).fmt(Time.With_Offset.iso8601_local)});
    try std.testing.expectFmt("20:15:00.000", "{f}", .{t6.with_offset(0).fmt(Time.With_Offset.iso8601_local)});

    try std.testing.expectFmt("12:00:00 am", "{f}", .{t1.with_offset(0).fmt(Time.With_Offset.hms)});
    try std.testing.expectFmt("1:02:03 am", "{f}", .{t2.with_offset(0).fmt(Time.With_Offset.hms)});
    try std.testing.expectFmt("11:59:59 pm", "{f}", .{t3.with_offset(0).fmt(Time.With_Offset.hms)});
    try std.testing.expectFmt("12:00:00 pm", "{f}", .{t4.with_offset(0).fmt(Time.With_Offset.hms)});
    try std.testing.expectFmt("4:45:00 am", "{f}", .{t5.with_offset(0).fmt(Time.With_Offset.hms)});
    try std.testing.expectFmt("8:15:00 pm", "{f}", .{t6.with_offset(0).fmt(Time.With_Offset.hms)});

    try std.testing.expectFmt("12:00 am", "{f}", .{t1.with_offset(0).fmt("kk:mm a")});
    try std.testing.expectFmt(" 1:02 am", "{f}", .{t2.with_offset(0).fmt("kk:mm a")});
    try std.testing.expectFmt("11:59 pm", "{f}", .{t3.with_offset(0).fmt("kk:mm a")});
    try std.testing.expectFmt("12:00 pm", "{f}", .{t4.with_offset(0).fmt("kk:mm a")});
    try std.testing.expectFmt(" 4:45 am", "{f}", .{t5.with_offset(0).fmt("kk:mm a")});
    try std.testing.expectFmt(" 8:15 pm", "{f}", .{t6.with_offset(0).fmt("kk:mm a")});

    try std.testing.expectFmt(" 0:00", "{f}", .{t1.with_offset(0).fmt("KK:mm")});
    try std.testing.expectFmt(" 1:02", "{f}", .{t2.with_offset(0).fmt("KK:mm")});
    try std.testing.expectFmt("23:59", "{f}", .{t3.with_offset(0).fmt("KK:mm")});
    try std.testing.expectFmt("12:00", "{f}", .{t4.with_offset(0).fmt("KK:mm")});
    try std.testing.expectFmt(" 4:45", "{f}", .{t5.with_offset(0).fmt("KK:mm")});
    try std.testing.expectFmt("20:15", "{f}", .{t6.with_offset(0).fmt("KK:mm")});

    try std.testing.expectEqual(t1.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601, "00:00:00.000+00:00"));

    try std.testing.expectEqual(t1.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "00:00:00.000"));
    try std.testing.expectEqual(t2.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "01:02:03.004"));
    try std.testing.expectEqual(t3.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "23:59:59.999"));
    try std.testing.expectEqual(t4.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "12:00:00.000"));
    try std.testing.expectEqual(t5.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "04:45:00.000"));
    try std.testing.expectEqual(t6.with_offset(0), Time.With_Offset.from_string(Time.With_Offset.iso8601_local, "20:15:00.000"));

    try std.testing.expectEqual(t1.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "12:00:00.000 am"));
    try std.testing.expectEqual(t2.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "1:02:03.004 am"));
    try std.testing.expectEqual(t3.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "11:59:59.999 pm"));
    try std.testing.expectEqual(t4.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "12:00:00.000 pm"));
    try std.testing.expectEqual(t5.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "4:45:00.000 am"));
    try std.testing.expectEqual(t6.with_offset(0), Time.With_Offset.from_string("h:mm:ss.SSS a", "8:15:00.000 pm"));

    try std.testing.expectEqual(t1.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", " 0:00:00.000"));
    try std.testing.expectEqual(t2.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", " 1:02:03.004"));
    try std.testing.expectEqual(t3.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", "23:59:59.999"));
    try std.testing.expectEqual(t4.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", "12:00:00.000"));
    try std.testing.expectEqual(t5.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", " 4:45:00.000"));
    try std.testing.expectEqual(t6.with_offset(0), Time.With_Offset.from_string("KK:mm:ss.SSS", "20:15:00.000"));

    try std.testing.expectEqual(t1.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", "12:00:00.000 am"));
    try std.testing.expectEqual(t2.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", " 1:02:03.004 am"));
    try std.testing.expectEqual(t3.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", "11:59:59.999 pm"));
    try std.testing.expectEqual(t4.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", "12:00:00.000 pm"));
    try std.testing.expectEqual(t5.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", " 4:45:00.000 am"));
    try std.testing.expectEqual(t6.with_offset(0), Time.With_Offset.from_string("kk:mm:ss.SSS a", " 8:15:00.000 pm"));

    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_designations(tempora.tz.designations.north_america);

    const tz = Timezone.fixed(-5, 0);
    const offset = tz.utc_offset_ms(0);

    try std.testing.expectEqual(t1.with_timezone(&tz, offset), Time.With_Offset.from_string_tz("HHmm", "0000", &tz));
    try std.testing.expectEqual(t4.with_timezone(&tz, offset), Time.With_Offset.from_string_tz("HHmm", "1200", &tz));
    try std.testing.expectEqual(t5.with_timezone(&tz, offset), Time.With_Offset.from_string_tz("HHmm", "0445", &tz));
    try std.testing.expectEqual(t6.with_timezone(&tz, offset), Time.With_Offset.from_string_tz("HHmm", "2015", &tz));

    try std.testing.expectEqual(t1.with_timezone(&tz, 3600_000), Time.With_Offset.from_string_tz("HHmmZZ", "0000+0100", &tz));
    try std.testing.expectEqual(t4.with_timezone(&tz, 7200_000), Time.With_Offset.from_string_tz("HHmmZZ", "1200+0200", &tz));
    try std.testing.expectEqual(t5.with_timezone(&tz, -3600_000), Time.With_Offset.from_string_tz("HHmmZZ", "0445-0100", &tz));
    try std.testing.expectEqual(t6.with_timezone(&tz, -7200_000), Time.With_Offset.from_string_tz("HHmmZZ", "2015-0200", &tz));

    try std.testing.expectEqual(t1.with_timezone(&db.local, db.designation_utc_offset_ms("CST", .{ .dt = .epoch }).?), Time.With_Offset.from_string_tzdb("HHmm z", "0000 CST", &db));
    try std.testing.expectEqual(t4.with_timezone(&db.local, db.designation_utc_offset_ms("CST", .{ .dt = .epoch }).?), Time.With_Offset.from_string_tzdb("HHmm z", "1200 CST", &db));
    try std.testing.expectEqual(t5.with_timezone(&db.local, db.designation_utc_offset_ms("CDT", .{ .dt = .epoch }).?), Time.With_Offset.from_string_tzdb("HHmm z", "0445 CDT", &db));
    try std.testing.expectEqual(t6.with_timezone(&db.local, db.designation_utc_offset_ms("CDT", .{ .dt = .epoch }).?), Time.With_Offset.from_string_tzdb("HHmm z", "2015 CDT", &db));
}

test "Time.HMSM.from_time, Time.HMSM.time" {
    for (0..24 * 60 * 60 * 1000) |ms| {
        const t: Time = .from_ms(@intCast(ms));
        const hmsm: Time.HMSM = .from_time(t);
        try std.testing.expectEqual(t, hmsm.time());
    }
}

test "Time.HMSM.minutes_since_midnight" {
    var ms: u32 = 0;
    while (ms < 24 * 60 * 60 * 1000) {
        defer ms += 1234;
        const t: Time = .from_ms(@intCast(ms));
        const hmsm: Time.HMSM = .from_time(t);
        try std.testing.expectEqual(t.minutes_since_midnight(), hmsm.minutes_since_midnight());
    }
}

test "Time.HMSM.seconds_since_midnight" {
    var ms: u32 = 0;
    while (ms < 24 * 60 * 60 * 1000) {
        defer ms += 1234;
        const t: Time = .from_ms(@intCast(ms));
        const hmsm: Time.HMSM = .from_time(t);
        try std.testing.expectEqual(t.seconds_since_midnight(), hmsm.seconds_since_midnight());
    }
}

test "Time.HMSM.ms_since_midnight" {
    var ms: u32 = 0;
    while (ms < 24 * 60 * 60 * 1000) {
        defer ms += 1234;
        const t: Time = .from_ms(@intCast(ms));
        const hmsm: Time.HMSM = .from_time(t);
        try std.testing.expectEqual(t.ms_since_midnight(), hmsm.ms_since_midnight());
    }
}

test "Time.HMSM.is_before" {
    try std.testing.expect(Time.HMSM.is_before(.@"1am", .noon));
    try std.testing.expect(Time.HMSM.is_before(.@"12am", .noon));
    try std.testing.expect(!Time.HMSM.is_before(.noon, .noon));
    try std.testing.expect(!Time.HMSM.is_before(.@"1pm", .noon));
    try std.testing.expect(!Time.HMSM.is_before(.midnight_eod, .noon));
}

test "Time.HMSM.is_after" {
    try std.testing.expect(!Time.HMSM.is_after(.@"1am", .noon));
    try std.testing.expect(!Time.HMSM.is_after(.@"12am", .noon));
    try std.testing.expect(!Time.HMSM.is_after(.noon, .noon));
    try std.testing.expect(Time.HMSM.is_after(.@"1pm", .noon));
    try std.testing.expect(Time.HMSM.is_after(.midnight_eod, .noon));
}

test "Time.HMSM.plus_duration" {
    try std.testing.expectEqual(Time.HMSM.from_numbers(12, 0, 2, 0), Time.HMSM.plus_duration(.noon, .fromSeconds(2)));
    try std.testing.expectEqual(Time.HMSM.from_numbers(12, 1, 0, 0), Time.HMSM.plus_duration(.noon, .fromSeconds(60)));
    try std.testing.expectEqual(Time.HMSM.@"1pm", Time.HMSM.plus_duration(.noon, .fromSeconds(60 * 60)));
    try std.testing.expectEqual(Time.HMSM.@"11am", Time.HMSM.plus_duration(.noon, .fromSeconds(-60 * 60)));
}

test "Time.HMSM.minus_duration" {
    try std.testing.expectEqual(Time.HMSM.@"11am", Time.HMSM.minus_duration(.noon, .fromSeconds(60 * 60)));
    try std.testing.expectEqual(Time.HMSM.@"1pm", Time.HMSM.minus_duration(.noon, .fromSeconds(-60 * 60)));
}

test "Time.HMSM.plus_ms" {
    try std.testing.expectEqual(10, Time.HMSM.plus_ms(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(Time.HMSM.from_numbers(11, 59, 58, 766), Time.HMSM.plus_ms(.noon, -1234));
}

test "Time.HMSM.plus_seconds" {
    try std.testing.expectEqual(10000, Time.HMSM.plus_seconds(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(Time.HMSM.from_numbers(11, 59, 50, 0), Time.HMSM.plus_seconds(.noon, -10));
}

test "Time.HMSM.plus_minutes" {
    try std.testing.expectEqual(600000, Time.HMSM.plus_minutes(.midnight, 10).ms_since_midnight());
    try std.testing.expectEqual(Time.HMSM.from_numbers(19, 50, 0, 0), Time.HMSM.plus_minutes(.@"8pm", -10));
}

test "Time.HMSM.plus_hours" {
    try std.testing.expectEqual(3600000, Time.HMSM.plus_hours(.midnight, 1).ms_since_midnight());
    try std.testing.expectEqual(Time.HMSM.@"11am", Time.HMSM.plus_hours(.noon, -1));
}

const Date = tempora.Date;
const Time = tempora.Time;
const Timezone = tempora.Timezone;
const TZDB = tempora.TZDB;
const tempora = @import("tempora");
const std = @import("std");
