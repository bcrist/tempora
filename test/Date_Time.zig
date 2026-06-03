test "Date_Time.with_timezone" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add(std.testing.io, tempora.tz.america.chicago, .embedded);

    const tz = db.timezone("America/Chicago").?;

    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = Date.unix_epoch.with_time(.midnight),
        .timezone = tz,
        .utc_offset_ms = -6 * std.time.ms_per_hour,
    }, Date.unix_epoch.with_time(.midnight).with_timezone(tz));

    try std.testing.expectEqual(6 * std.time.ms_per_hour, Date.unix_epoch.with_time(.midnight).with_timezone(tz).timestamp_ms());
}

test "Date_Time.duration_since" {
    try std.testing.expectEqual(std.Io.Duration.fromSeconds(1 * std.time.s_per_day), Date_Time.duration_since(.{
        .date = (Date.epoch).next(),
        .time = .noon,
    }, .{
        .date = .epoch,
        .time = .noon,
    }));
    try std.testing.expectEqual(std.Io.Duration.fromSeconds(4 * std.time.s_per_day), Date_Time.duration_since(.{
        .date = (Date.epoch).plus_days(3),
        .time = .midnight_eod,
    }, .{
        .date = .epoch,
        .time = .midnight,
    }));
}

test "Date_Time.ms_since" {
    try std.testing.expectEqual(1 * std.time.ms_per_day, Date_Time.ms_since(.{
        .date = (Date.epoch).next(),
        .time = .noon,
    }, .{
        .date = .epoch,
        .time = .noon,
    }));
    try std.testing.expectEqual(4 * std.time.ms_per_day, Date_Time.ms_since(.{
        .date = (Date.epoch).plus_days(3),
        .time = .midnight_eod,
    }, .{
        .date = .epoch,
        .time = .midnight,
    }));
}

test "Date_Time.is_before" {
    try std.testing.expect(!Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = (Date.epoch).prev(), .time = .noon }));
    try std.testing.expect(!Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .noon }));
    try std.testing.expect(Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = (Date.epoch).next(), .time = .noon }));

    try std.testing.expect(!Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .@"11am" }));
    try std.testing.expect(!Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .noon }));
    try std.testing.expect(Date_Time.is_before(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .@"1pm" }));
}

test "Date_Time.is_after" {
    try std.testing.expect(Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = (Date.epoch).prev(), .time = .noon }));
    try std.testing.expect(!Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .noon }));
    try std.testing.expect(!Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = (Date.epoch).next(), .time = .noon }));

    try std.testing.expect(Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .@"11am" }));
    try std.testing.expect(!Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .noon }));
    try std.testing.expect(!Date_Time.is_after(.{ .date = .epoch, .time = .noon }, .{ .date = .epoch, .time = .@"1pm" }));
}

test "Date_Time.plus_duration" {
    try std.testing.expectEqual(Date_Time{
        .date = .epoch,
        .time = .noon,
    }, Date_Time.plus_duration(.{
        .date = .epoch,
        .time = .midnight,
    }, .fromSeconds(12 * std.time.s_per_hour)));
}

test "Date_Time.minus_duration" {
    try std.testing.expectEqual(Date_Time{
        .date = (Date.epoch).prev(),
        .time = .noon,
    }, Date_Time.minus_duration(.{
        .date = .epoch,
        .time = .midnight,
    }, .fromSeconds(12 * std.time.s_per_hour)));
}

test "Date_Time.plus_days_and_ms" {
    try std.testing.expectEqual(Date_Time{
        .date = (Date.epoch).plus_days(2),
        .time = .noon,
    }, Date_Time.plus_days_and_ms(.{
        .date = .epoch,
        .time = .midnight,
    }, 2, 12 * std.time.ms_per_hour));

    try std.testing.expectEqual(Date_Time{
        .date = (Date.epoch).plus_days(-3),
        .time = .noon,
    }, Date_Time.plus_days_and_ms(.{
        .date = .epoch,
        .time = .midnight,
    }, -2, -12 * std.time.ms_per_hour));
}

test "Date_Time.With_Offset from/to timestamp" {
    const ts1: std.Io.Timestamp = .fromNanoseconds(0);
    const dto1: Date_Time.With_Offset = .{
        .dt = .{
            .date = .unix_epoch,
            .time = .midnight,
        },
    };

    const ts2: std.Io.Timestamp = .fromNanoseconds(std.time.ns_per_day * 10);
    const dto2: Date_Time.With_Offset = .{
        .dt = .{
            .date = (Date.unix_epoch).plus_days(10),
            .time = .midnight,
        },
    };

    const tz: Timezone = .fixed(-6, 0);
    const ts3: std.Io.Timestamp = .fromNanoseconds(std.time.ns_per_day * 10);
    const dto3: Date_Time.With_Offset = .{
        .dt = .{
            .date = (Date.unix_epoch).plus_days(9),
            .time = .@"6pm",
        },
        .utc_offset_ms = -6 * std.time.ms_per_hour,
        .timezone = &tz,
    };

    try std.testing.expectEqual(dto1, Date_Time.With_Offset.from_timestamp(ts1, null));
    try std.testing.expectEqual(dto2, Date_Time.With_Offset.from_timestamp(ts2, null));
    try std.testing.expectEqual(dto3, Date_Time.With_Offset.from_timestamp(ts3, &tz));

    try std.testing.expectEqual(ts1, dto1.timestamp());
    try std.testing.expectEqual(ts2, dto2.timestamp());
    try std.testing.expectEqual(ts3, dto3.timestamp());

    try std.testing.expectEqual(dto1, Date_Time.With_Offset.from_timestamp_ms(ts1.toMilliseconds(), null));
    try std.testing.expectEqual(dto2, Date_Time.With_Offset.from_timestamp_ms(ts2.toMilliseconds(), null));
    try std.testing.expectEqual(dto3, Date_Time.With_Offset.from_timestamp_ms(ts3.toMilliseconds(), &tz));

    try std.testing.expectEqual(ts1.toMilliseconds(), dto1.timestamp_ms());
    try std.testing.expectEqual(ts2.toMilliseconds(), dto2.timestamp_ms());
    try std.testing.expectEqual(ts3.toMilliseconds(), dto3.timestamp_ms());

    try std.testing.expectEqual(dto1, Date_Time.With_Offset.from_timestamp_s(ts1.toSeconds(), null));
    try std.testing.expectEqual(dto2, Date_Time.With_Offset.from_timestamp_s(ts2.toSeconds(), null));
    try std.testing.expectEqual(dto3, Date_Time.With_Offset.from_timestamp_s(ts3.toSeconds(), &tz));

    try std.testing.expectEqual(ts1.toSeconds(), dto1.timestamp_s());
    try std.testing.expectEqual(ts2.toSeconds(), dto2.timestamp_s());
    try std.testing.expectEqual(ts3.toSeconds(), dto3.timestamp_s());
}

test "Date_Time.With_Offset.fmt, from_string, in_timezone" {
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

    const dt1 = (Date_Time{
        .date = .from_ymd(.{ .year = .from_number(2024), .month = .february, .day = .first }),
        .time = .from_hmsm(12, 34, 56, 789),
    }).with_offset(0);
    const dt2 = (Date_Time{
        .date = .from_ymd(.from_numbers(1928, 12, 24)),
        .time = .from_hmsm(0, 30, 0, 0),
    }).with_offset(0);

    const DTO = Date_Time.With_Offset;

    try std.testing.expectFmt("2024-02-01 12:34:56.789 +00:00", "{f}", .{dt1.fmt(DTO.sql_ms)});
    try std.testing.expectFmt("2024-02-01 12:34:56.789 GMT", "{f}", .{dt1.in_timezone(gmt).fmt(DTO.sql_ms)});
    try std.testing.expectFmt("2024-02-01 06:34:56.789 CST", "{f}", .{dt1.in_timezone(tz).fmt(DTO.sql_ms)});

    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 +0000", "{f}", .{dt2.in_timezone(gmt).fmt(DTO.rfc2822)});
    try std.testing.expectFmt("Mon, 24 Dec 1928 00:30:00 GMT", "{f}", .{dt2.in_timezone(gmt).fmt(DTO.http)});
    try std.testing.expectFmt("1928-12-24T00:30:00.000+00:00", "{f}", .{dt2.in_timezone(gmt).fmt(DTO.iso8601)});

    try std.testing.expectEqual(dt1, try DTO.from_string(DTO.sql_ms, "2024-02-01 12:34:56.789 +00:00"));
    try std.testing.expectEqual(dt1, (try DTO.from_string_tzdb(DTO.sql_ms, "2024-02-01 06:34:56.789 CST", &db)).in_timezone(null));
}

test "Date_Time.With_Offset.canonical" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = (Date.epoch).prev(),
            .time = .midnight,
        },
    }, Date_Time.With_Offset.canonical(.{
        .dt = .{
            .date = .epoch,
            .time = .from_hours(-24),
        },
    }));
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = (Date.epoch).next(),
            .time = .midnight,
        },
    }, Date_Time.With_Offset.canonical(.{
        .dt = .{
            .date = .epoch,
            .time = .from_hours(24),
        },
    }));
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = (Date.epoch).next(),
            .time = .@"1am",
        },
    }, Date_Time.With_Offset.canonical(.{
        .dt = .{
            .date = .epoch,
            .time = .from_hours(25),
        },
    }));
}

test "Date_Time.With_Offset.is_before" {
    try std.testing.expect(!Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = (Date.epoch).prev(), .time = .noon } }));
    try std.testing.expect(!Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .noon } }));
    try std.testing.expect(Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = (Date.epoch).next(), .time = .noon } }));

    try std.testing.expect(!Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .@"11am" } }));
    try std.testing.expect(!Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .noon } }));
    try std.testing.expect(Date_Time.With_Offset.is_before(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .@"1pm" } }));
}

test "Date_Time.With_Offset.is_after" {
    try std.testing.expect(Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = (Date.epoch).prev(), .time = .noon } }));
    try std.testing.expect(!Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .noon } }));
    try std.testing.expect(!Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = (Date.epoch).next(), .time = .noon } }));

    try std.testing.expect(Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .@"11am" } }));
    try std.testing.expect(!Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .noon } }));
    try std.testing.expect(!Date_Time.With_Offset.is_after(.{ .dt = .{ .date = .epoch, .time = .noon } }, .{ .dt = .{ .date = .epoch, .time = .@"1pm" } }));
}

test "Date_Time.With_Offset.duration_since_ignore_leap_seconds" {
    try std.testing.expectEqual(std.Io.Duration.fromSeconds(36 * std.time.s_per_hour), Date_Time.With_Offset.duration_since_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }));
}

test "Date_Time.With_Offset.ms_since_ignore_leap_seconds" {
    try std.testing.expectEqual(36 * std.time.ms_per_hour, Date_Time.With_Offset.ms_since_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }));
}

test "Date_Time.With_Offset.plus_duration_ignore_leap_seconds" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, Date_Time.With_Offset.plus_duration_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }, .fromSeconds(36 * std.time.s_per_hour)));
}

test "Date_Time.With_Offset.minus_duration_ignore_leap_seconds" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }, Date_Time.With_Offset.minus_duration_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .fromSeconds(36 * std.time.s_per_hour)));
}

test "Date_Time.With_Offset.plus_days_and_ms_ignore_leap_seconds" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 2)),
            .time = .noon,
        },
    }, Date_Time.With_Offset.plus_days_and_ms_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 28)),
            .time = .midnight,
        },
    }, 5, 12 * std.time.ms_per_hour));

    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 27)),
            .time = .noon,
        },
    }, Date_Time.With_Offset.plus_days_and_ms_ignore_leap_seconds(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 2)),
            .time = .midnight,
        },
    }, -5, -12 * std.time.ms_per_hour));
}

test "Date_Time.With_Offset.duration_since" {
    try std.testing.expectEqual(std.Io.Duration.fromSeconds(36 * std.time.s_per_hour + 1), Date_Time.With_Offset.duration_since(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }));
}

test "Date_Time.With_Offset.ms_since" {
    try std.testing.expectEqual(36 * std.time.ms_per_hour + 1000, Date_Time.With_Offset.ms_since(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }));
}

test "Date_Time.With_Offset.plus_duration" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = (Time.noon).plus_seconds(-1),
        },
    }, Date_Time.With_Offset.plus_duration(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = .midnight,
        },
    }, .fromSeconds(36 * std.time.s_per_hour)));
}

test "Date_Time.With_Offset.minus_duration" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 31)),
            .time = (Time.midnight).plus_seconds(1),
        },
    }, Date_Time.With_Offset.minus_duration(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 1)),
            .time = .noon,
        },
    }, .fromSeconds(36 * std.time.s_per_hour)));
}

test "Date_Time.With_Offset.plus_days_and_ms" {
    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 2)),
            .time = (Time.noon).plus_seconds(-1),
        },
    }, Date_Time.With_Offset.plus_days_and_ms(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 28)),
            .time = .midnight,
        },
    }, 5, 12 * std.time.ms_per_hour));

    try std.testing.expectEqual(Date_Time.With_Offset{
        .dt = .{
            .date = .from_ymd(.from_numbers(2008, 12, 27)),
            .time = (Time.noon).plus_seconds(1),
        },
    }, Date_Time.With_Offset.plus_days_and_ms(.{
        .dt = .{
            .date = .from_ymd(.from_numbers(2009, 1, 2)),
            .time = .midnight,
        },
    }, -5, -12 * std.time.ms_per_hour));
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
