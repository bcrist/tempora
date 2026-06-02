const america_denver: Posix = .init("MST", -25200, "MDT", -21600,
    .{
        .date = .{ .month_week_day = .{
            .month = .march,
            .week = .second,
            .day = .sunday,
        }},
        .time = .@"2am",
    },
    .{
        .date = .{ .month_week_day = .{
            .month = .november,
            .week = .first,
            .day = .sunday,
        }},
        .time = .@"2am",
    }
);

const europe_berlin: Posix = .init("CET", 3600, "CEST", 7200,
    .{
        .date = .{ .month_week_day = .{
            .month = .march,
            .week = .last,
            .day = .sunday,
        }},
        .time = .@"2am",
    },
    .{
        .date = .{ .month_week_day = .{
            .month = .october,
            .week = .last,
            .day = .sunday,
        }},
        .time = .@"3am",
    }
);

const antarctica_syowa: Posix = .init_standard("+03", 3 * std.time.s_per_hour);

const pacific_chatham: Posix = .init(
    "+1245", 12 * std.time.s_per_hour + 45 * std.time.s_per_min,
    "+1345", 13 * std.time.s_per_hour + 45 * std.time.s_per_min,
    .{
        .date = .{ .month_week_day = .{
            .month = .september,
            .week = .last,
            .day = .sunday,
        }},
        .time = .from_hmsm(2, 45, 0, 0),
    },
    .{
        .date = .{ .month_week_day = .{
            .month = .april,
            .week = .first,
            .day = .sunday,
        }},
        .time = .from_hmsm(3, 45, 0, 0),
    },
);

test {
    try std.testing.expectEqualDeep(america_denver, try Posix.parse("MST7MDT,M3.2.0,M11.1.0"));
    try test_posix("MST7MDT", america_denver);
    try test_posix("CET-1CEST,M3.5.0,M10.5.0/3", europe_berlin);
    try test_posix("<+03>-3", antarctica_syowa);
    try test_posix("<+1245>-12:45<+1345>,M9.5.0/2:45,M4.1.0/3:45", pacific_chatham);
}

fn test_posix(str: []const u8, tz: Posix) !void {
    try std.testing.expectFmt(str, "{f}", .{ tz });
    try std.testing.expectEqualDeep(tz, try Posix.parse(str));
}

const Posix = @import("tempora").Timezone.Posix;
const std = @import("std");
