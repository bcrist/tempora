
test "Time.from_hmsm" {
    try std.testing.expectEqual(Time.midnight, Time.from_hmsm(0, 0, 0, 0));
    try std.testing.expectEqual(Time.@"1am", Time.from_hmsm(1, 0, 0, 0));
    try std.testing.expectEqual(Time.noon, Time.from_hmsm(12, 0, 0, 0));
    try std.testing.expect(Time.is_after(.midnight_eod, Time.from_hmsm(23, 59, 59, 999)));
    try std.testing.expect(Time.is_before(.midnight_eod, Time.from_hmsm(23, 59, 59, 999).plus_ms(2)));

    try std.testing.expectEqual(234, @intFromEnum(Time.from_hmsm(0, 0, 0, 234)));
    try std.testing.expectEqual(1000, @intFromEnum(Time.from_hmsm(0, 0, 1, 0)));
    try std.testing.expectEqual(59234, @intFromEnum(Time.from_hmsm(0, 0, 59, 234)));
    try std.testing.expectEqual(119004, @intFromEnum(Time.from_hmsm(0, 1, 59, 4)));
    try std.testing.expectEqual(3661004, @intFromEnum(Time.from_hmsm(1, 1, 1, 4)));
    try std.testing.expectEqual(86399000, @intFromEnum(Time.from_hmsm(23, 59, 59, 0)));
}

test "Time.hours" {
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 0, 234).hours());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 1, 0).hours());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 1, 59, 4).hours());
    try std.testing.expectEqual(1, Time.from_hmsm(1, 0, 0, 0).hours());
    try std.testing.expectEqual(1, Time.from_hmsm(1, 1, 1, 4).hours());
    try std.testing.expectEqual(12, Time.from_hmsm(12, 0, 0, 0).hours());
    try std.testing.expectEqual(13, Time.from_hmsm(13, 0, 0, 0).hours());
    try std.testing.expectEqual(23, Time.from_hmsm(23, 59, 59, 999).hours());
    try std.testing.expectEqual(0, Time.hours(.midnight));
    try std.testing.expectEqual(0, Time.hours(.@"12am"));
    try std.testing.expectEqual(1, Time.hours(.@"1am"));
    try std.testing.expectEqual(2, Time.hours(.@"2am"));
    try std.testing.expectEqual(3, Time.hours(.@"3am"));
    try std.testing.expectEqual(4, Time.hours(.@"4am"));
    try std.testing.expectEqual(5, Time.hours(.@"5am"));
    try std.testing.expectEqual(6, Time.hours(.@"6am"));
    try std.testing.expectEqual(7, Time.hours(.@"7am"));
    try std.testing.expectEqual(8, Time.hours(.@"8am"));
    try std.testing.expectEqual(9, Time.hours(.@"9am"));
    try std.testing.expectEqual(10, Time.hours(.@"10am"));
    try std.testing.expectEqual(11, Time.hours(.@"11am"));
    try std.testing.expectEqual(12, Time.hours(.@"12pm"));
    try std.testing.expectEqual(12, Time.hours(.noon));
    try std.testing.expectEqual(13, Time.hours(.@"1pm"));
    try std.testing.expectEqual(14, Time.hours(.@"2pm"));
    try std.testing.expectEqual(15, Time.hours(.@"3pm"));
    try std.testing.expectEqual(16, Time.hours(.@"4pm"));
    try std.testing.expectEqual(17, Time.hours(.@"5pm"));
    try std.testing.expectEqual(18, Time.hours(.@"6pm"));
    try std.testing.expectEqual(19, Time.hours(.@"7pm"));
    try std.testing.expectEqual(20, Time.hours(.@"8pm"));
    try std.testing.expectEqual(21, Time.hours(.@"9pm"));
    try std.testing.expectEqual(22, Time.hours(.@"10pm"));
    try std.testing.expectEqual(23, Time.hours(.@"11pm"));
    try std.testing.expectEqual(24, Time.hours(.midnight_eod));
}

test "Time.minutes_since_midnight" {
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 0, 234).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 1, 0).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 59, 999).minutes_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 1, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 1, 59, 4).minutes_since_midnight());
    try std.testing.expectEqual(60, Time.from_hmsm(1, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(61, Time.from_hmsm(1, 1, 1, 4).minutes_since_midnight());
    try std.testing.expectEqual(12*60, Time.from_hmsm(12, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(13*60, Time.from_hmsm(13, 0, 0, 0).minutes_since_midnight());
    try std.testing.expectEqual(24*60-1, Time.from_hmsm(23, 59, 59, 999).minutes_since_midnight());
    try std.testing.expectEqual(0, Time.minutes_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.minutes_since_midnight(.@"12am"));
    try std.testing.expectEqual(60*1, Time.minutes_since_midnight(.@"1am"));
    try std.testing.expectEqual(60*2, Time.minutes_since_midnight(.@"2am"));
    try std.testing.expectEqual(60*3, Time.minutes_since_midnight(.@"3am"));
    try std.testing.expectEqual(60*4, Time.minutes_since_midnight(.@"4am"));
    try std.testing.expectEqual(60*5, Time.minutes_since_midnight(.@"5am"));
    try std.testing.expectEqual(60*6, Time.minutes_since_midnight(.@"6am"));
    try std.testing.expectEqual(60*7, Time.minutes_since_midnight(.@"7am"));
    try std.testing.expectEqual(60*8, Time.minutes_since_midnight(.@"8am"));
    try std.testing.expectEqual(60*9, Time.minutes_since_midnight(.@"9am"));
    try std.testing.expectEqual(60*10, Time.minutes_since_midnight(.@"10am"));
    try std.testing.expectEqual(60*11, Time.minutes_since_midnight(.@"11am"));
    try std.testing.expectEqual(60*12, Time.minutes_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60*12, Time.minutes_since_midnight(.noon));
    try std.testing.expectEqual(60*13, Time.minutes_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60*14, Time.minutes_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60*15, Time.minutes_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60*16, Time.minutes_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60*17, Time.minutes_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60*18, Time.minutes_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60*19, Time.minutes_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60*20, Time.minutes_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60*21, Time.minutes_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60*22, Time.minutes_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60*23, Time.minutes_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60*24, Time.minutes_since_midnight(.midnight_eod));
}

test "Time.minutes" {
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 0, 234).minutes());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 1, 0).minutes());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 59, 999).minutes());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 1, 0, 0).minutes());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 1, 59, 4).minutes());
    try std.testing.expectEqual(0, Time.from_hmsm(1, 0, 0, 0).minutes());
    try std.testing.expectEqual(1, Time.from_hmsm(1, 1, 1, 4).minutes());
    try std.testing.expectEqual(0, Time.from_hmsm(12, 0, 0, 0).minutes());
    try std.testing.expectEqual(0, Time.from_hmsm(13, 0, 0, 0).minutes());
    try std.testing.expectEqual(59, Time.from_hmsm(23, 59, 59, 999).minutes());
    try std.testing.expectEqual(0, Time.minutes(.midnight));
    try std.testing.expectEqual(0, Time.minutes(.@"12am"));
    try std.testing.expectEqual(0, Time.minutes(.@"1am"));
    try std.testing.expectEqual(0, Time.minutes(.@"2am"));
    try std.testing.expectEqual(0, Time.minutes(.@"3am"));
    try std.testing.expectEqual(0, Time.minutes(.@"4am"));
    try std.testing.expectEqual(0, Time.minutes(.@"5am"));
    try std.testing.expectEqual(0, Time.minutes(.@"6am"));
    try std.testing.expectEqual(0, Time.minutes(.@"7am"));
    try std.testing.expectEqual(0, Time.minutes(.@"8am"));
    try std.testing.expectEqual(0, Time.minutes(.@"9am"));
    try std.testing.expectEqual(0, Time.minutes(.@"10am"));
    try std.testing.expectEqual(0, Time.minutes(.@"11am"));
    try std.testing.expectEqual(0, Time.minutes(.@"12pm"));
    try std.testing.expectEqual(0, Time.minutes(.noon));
    try std.testing.expectEqual(0, Time.minutes(.@"1pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"2pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"3pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"4pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"5pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"6pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"7pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"8pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"9pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"10pm"));
    try std.testing.expectEqual(0, Time.minutes(.@"11pm"));
    try std.testing.expectEqual(0, Time.minutes(.midnight_eod));
}

test "Time.seconds_since_midnight" {
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 0, 234).seconds_since_midnight());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 0, 1, 0).seconds_since_midnight());
    try std.testing.expectEqual(59, Time.from_hmsm(0, 0, 59, 999).seconds_since_midnight());
    try std.testing.expectEqual(60, Time.from_hmsm(0, 1, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(119, Time.from_hmsm(0, 1, 59, 4).seconds_since_midnight());
    try std.testing.expectEqual(3600, Time.from_hmsm(1, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(3661, Time.from_hmsm(1, 1, 1, 4).seconds_since_midnight());
    try std.testing.expectEqual(12*60*60, Time.from_hmsm(12, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(13*60*60, Time.from_hmsm(13, 0, 0, 0).seconds_since_midnight());
    try std.testing.expectEqual(24*60*60-1, Time.from_hmsm(23, 59, 59, 999).seconds_since_midnight());
    try std.testing.expectEqual(0, Time.seconds_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.seconds_since_midnight(.@"12am"));
    try std.testing.expectEqual(60*60*1, Time.seconds_since_midnight(.@"1am"));
    try std.testing.expectEqual(60*60*2, Time.seconds_since_midnight(.@"2am"));
    try std.testing.expectEqual(60*60*3, Time.seconds_since_midnight(.@"3am"));
    try std.testing.expectEqual(60*60*4, Time.seconds_since_midnight(.@"4am"));
    try std.testing.expectEqual(60*60*5, Time.seconds_since_midnight(.@"5am"));
    try std.testing.expectEqual(60*60*6, Time.seconds_since_midnight(.@"6am"));
    try std.testing.expectEqual(60*60*7, Time.seconds_since_midnight(.@"7am"));
    try std.testing.expectEqual(60*60*8, Time.seconds_since_midnight(.@"8am"));
    try std.testing.expectEqual(60*60*9, Time.seconds_since_midnight(.@"9am"));
    try std.testing.expectEqual(60*60*10, Time.seconds_since_midnight(.@"10am"));
    try std.testing.expectEqual(60*60*11, Time.seconds_since_midnight(.@"11am"));
    try std.testing.expectEqual(60*60*12, Time.seconds_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60*60*12, Time.seconds_since_midnight(.noon));
    try std.testing.expectEqual(60*60*13, Time.seconds_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60*60*14, Time.seconds_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60*60*15, Time.seconds_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60*60*16, Time.seconds_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60*60*17, Time.seconds_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60*60*18, Time.seconds_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60*60*19, Time.seconds_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60*60*20, Time.seconds_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60*60*21, Time.seconds_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60*60*22, Time.seconds_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60*60*23, Time.seconds_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60*60*24, Time.seconds_since_midnight(.midnight_eod));
}

test "Time.seconds" {
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 0, 234).seconds());
    try std.testing.expectEqual(1, Time.from_hmsm(0, 0, 1, 0).seconds());
    try std.testing.expectEqual(59, Time.from_hmsm(0, 0, 59, 999).seconds());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 1, 0, 0).seconds());
    try std.testing.expectEqual(59, Time.from_hmsm(0, 1, 59, 4).seconds());
    try std.testing.expectEqual(0, Time.from_hmsm(1, 0, 0, 0).seconds());
    try std.testing.expectEqual(1, Time.from_hmsm(1, 1, 1, 4).seconds());
    try std.testing.expectEqual(0, Time.from_hmsm(12, 0, 0, 0).seconds());
    try std.testing.expectEqual(0, Time.from_hmsm(13, 0, 0, 0).seconds());
    try std.testing.expectEqual(59, Time.from_hmsm(23, 59, 59, 999).seconds());
    try std.testing.expectEqual(0, Time.seconds(.midnight));
    try std.testing.expectEqual(0, Time.seconds(.@"12am"));
    try std.testing.expectEqual(0, Time.seconds(.@"1am"));
    try std.testing.expectEqual(0, Time.seconds(.@"2am"));
    try std.testing.expectEqual(0, Time.seconds(.@"3am"));
    try std.testing.expectEqual(0, Time.seconds(.@"4am"));
    try std.testing.expectEqual(0, Time.seconds(.@"5am"));
    try std.testing.expectEqual(0, Time.seconds(.@"6am"));
    try std.testing.expectEqual(0, Time.seconds(.@"7am"));
    try std.testing.expectEqual(0, Time.seconds(.@"8am"));
    try std.testing.expectEqual(0, Time.seconds(.@"9am"));
    try std.testing.expectEqual(0, Time.seconds(.@"10am"));
    try std.testing.expectEqual(0, Time.seconds(.@"11am"));
    try std.testing.expectEqual(0, Time.seconds(.@"12pm"));
    try std.testing.expectEqual(0, Time.seconds(.noon));
    try std.testing.expectEqual(0, Time.seconds(.@"1pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"2pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"3pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"4pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"5pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"6pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"7pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"8pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"9pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"10pm"));
    try std.testing.expectEqual(0, Time.seconds(.@"11pm"));
    try std.testing.expectEqual(0, Time.seconds(.midnight_eod));
}

test "Time.ms_since_midnight" {
    try std.testing.expectEqual(234, Time.from_hmsm(0, 0, 0, 234).ms_since_midnight());
    try std.testing.expectEqual(1000, Time.from_hmsm(0, 0, 1, 0).ms_since_midnight());
    try std.testing.expectEqual(59999, Time.from_hmsm(0, 0, 59, 999).ms_since_midnight());
    try std.testing.expectEqual(60000, Time.from_hmsm(0, 1, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(119004, Time.from_hmsm(0, 1, 59, 4).ms_since_midnight());
    try std.testing.expectEqual(3600000, Time.from_hmsm(1, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(3661004, Time.from_hmsm(1, 1, 1, 4).ms_since_midnight());
    try std.testing.expectEqual(12*60*60000, Time.from_hmsm(12, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(13*60*60000, Time.from_hmsm(13, 0, 0, 0).ms_since_midnight());
    try std.testing.expectEqual(24*60*60000-1, Time.from_hmsm(23, 59, 59, 999).ms_since_midnight());
    try std.testing.expectEqual(0, Time.ms_since_midnight(.midnight));
    try std.testing.expectEqual(0, Time.ms_since_midnight(.@"12am"));
    try std.testing.expectEqual(60*60000*1, Time.ms_since_midnight(.@"1am"));
    try std.testing.expectEqual(60*60000*2, Time.ms_since_midnight(.@"2am"));
    try std.testing.expectEqual(60*60000*3, Time.ms_since_midnight(.@"3am"));
    try std.testing.expectEqual(60*60000*4, Time.ms_since_midnight(.@"4am"));
    try std.testing.expectEqual(60*60000*5, Time.ms_since_midnight(.@"5am"));
    try std.testing.expectEqual(60*60000*6, Time.ms_since_midnight(.@"6am"));
    try std.testing.expectEqual(60*60000*7, Time.ms_since_midnight(.@"7am"));
    try std.testing.expectEqual(60*60000*8, Time.ms_since_midnight(.@"8am"));
    try std.testing.expectEqual(60*60000*9, Time.ms_since_midnight(.@"9am"));
    try std.testing.expectEqual(60*60000*10, Time.ms_since_midnight(.@"10am"));
    try std.testing.expectEqual(60*60000*11, Time.ms_since_midnight(.@"11am"));
    try std.testing.expectEqual(60*60000*12, Time.ms_since_midnight(.@"12pm"));
    try std.testing.expectEqual(60*60000*12, Time.ms_since_midnight(.noon));
    try std.testing.expectEqual(60*60000*13, Time.ms_since_midnight(.@"1pm"));
    try std.testing.expectEqual(60*60000*14, Time.ms_since_midnight(.@"2pm"));
    try std.testing.expectEqual(60*60000*15, Time.ms_since_midnight(.@"3pm"));
    try std.testing.expectEqual(60*60000*16, Time.ms_since_midnight(.@"4pm"));
    try std.testing.expectEqual(60*60000*17, Time.ms_since_midnight(.@"5pm"));
    try std.testing.expectEqual(60*60000*18, Time.ms_since_midnight(.@"6pm"));
    try std.testing.expectEqual(60*60000*19, Time.ms_since_midnight(.@"7pm"));
    try std.testing.expectEqual(60*60000*20, Time.ms_since_midnight(.@"8pm"));
    try std.testing.expectEqual(60*60000*21, Time.ms_since_midnight(.@"9pm"));
    try std.testing.expectEqual(60*60000*22, Time.ms_since_midnight(.@"10pm"));
    try std.testing.expectEqual(60*60000*23, Time.ms_since_midnight(.@"11pm"));
    try std.testing.expectEqual(60*60000*24, Time.ms_since_midnight(.midnight_eod));
}

test "Time.ms" {
    try std.testing.expectEqual(234, Time.from_hmsm(0, 0, 0, 234).ms());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 0, 1, 0).ms());
    try std.testing.expectEqual(999, Time.from_hmsm(0, 0, 59, 999).ms());
    try std.testing.expectEqual(0, Time.from_hmsm(0, 1, 0, 0).ms());
    try std.testing.expectEqual(4, Time.from_hmsm(0, 1, 59, 4).ms());
    try std.testing.expectEqual(0, Time.from_hmsm(1, 0, 0, 0).ms());
    try std.testing.expectEqual(4, Time.from_hmsm(1, 1, 1, 4).ms());
    try std.testing.expectEqual(0, Time.from_hmsm(12, 0, 0, 0).ms());
    try std.testing.expectEqual(0, Time.from_hmsm(13, 0, 0, 0).ms());
    try std.testing.expectEqual(999, Time.from_hmsm(23, 59, 59, 999).ms());
    try std.testing.expectEqual(0, Time.ms(.midnight));
    try std.testing.expectEqual(0, Time.ms(.@"12am"));
    try std.testing.expectEqual(0, Time.ms(.@"1am"));
    try std.testing.expectEqual(0, Time.ms(.@"2am"));
    try std.testing.expectEqual(0, Time.ms(.@"3am"));
    try std.testing.expectEqual(0, Time.ms(.@"4am"));
    try std.testing.expectEqual(0, Time.ms(.@"5am"));
    try std.testing.expectEqual(0, Time.ms(.@"6am"));
    try std.testing.expectEqual(0, Time.ms(.@"7am"));
    try std.testing.expectEqual(0, Time.ms(.@"8am"));
    try std.testing.expectEqual(0, Time.ms(.@"9am"));
    try std.testing.expectEqual(0, Time.ms(.@"10am"));
    try std.testing.expectEqual(0, Time.ms(.@"11am"));
    try std.testing.expectEqual(0, Time.ms(.@"12pm"));
    try std.testing.expectEqual(0, Time.ms(.noon));
    try std.testing.expectEqual(0, Time.ms(.@"1pm"));
    try std.testing.expectEqual(0, Time.ms(.@"2pm"));
    try std.testing.expectEqual(0, Time.ms(.@"3pm"));
    try std.testing.expectEqual(0, Time.ms(.@"4pm"));
    try std.testing.expectEqual(0, Time.ms(.@"5pm"));
    try std.testing.expectEqual(0, Time.ms(.@"6pm"));
    try std.testing.expectEqual(0, Time.ms(.@"7pm"));
    try std.testing.expectEqual(0, Time.ms(.@"8pm"));
    try std.testing.expectEqual(0, Time.ms(.@"9pm"));
    try std.testing.expectEqual(0, Time.ms(.@"10pm"));
    try std.testing.expectEqual(0, Time.ms(.@"11pm"));
    try std.testing.expectEqual(0, Time.ms(.midnight_eod));
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
    try std.testing.expectEqual(Time.@"1pm", Time.plus_duration(.noon, .fromSeconds(60*60)));
    try std.testing.expectEqual(Time.@"11am", Time.plus_duration(.noon, .fromSeconds(-60*60)));
}

test "Time.minus_duration" {
    try std.testing.expectEqual(Time.@"11am", Time.minus_duration(.noon, .fromSeconds(60*60)));
    try std.testing.expectEqual(Time.@"1pm", Time.minus_duration(.noon, .fromSeconds(-60*60)));
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

const Date = tempora.Date;
const Time = tempora.Time;
const Timezone = tempora.Timezone;
const TZDB = tempora.TZDB;
const tempora = @import("tempora");
const std = @import("std");
