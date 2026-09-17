test "oracle2" {
    try run_test_range(wd.oracle2, .min, .max);
}

test "hinnant" {
    try run_test_range(wd.hinnant, .plus_days(.min, 14), .plus_days(.max, -14));
}

test "neri" {
    try run_test_range(wd.neri, .min, .max);
}

test "joffe_limited max" {
    // This test is for determining the maximum supported value for joffe_limited if `offset` is changed
    if (true) return error.SkipZigTest;
    try run_test_range(wd.joffe_limited, .plus_days(.epoch, -1), .max);
}
test "joffe_limited min" {
    // This test is for determining the minimum supported value for joffe_limited if `offset` is changed
    if (true) return error.SkipZigTest;
    try run_test_range(wd.joffe_limited, .min, .plus_days(.epoch, 1));
}
test "joffe_limited" {
    try std.testing.expect(wd.joffe_limited_min <= std.math.minInt(i27));
    try std.testing.expect(wd.joffe_limited_max >= std.math.maxInt(i27));
    try run_test_range(wd.joffe_limited, @enumFromInt(wd.joffe_limited_min), @enumFromInt(wd.joffe_limited_max));
}

test "joffe_shift" {
    try run_test_range(wd.joffe_shift, .min, .max);
}

test "joffe_mul2" {
    try run_test_range(wd.joffe_mul2, .min, .max);
}

test "joffe_split" {
    try run_test_range(wd.joffe_split, .min, .max);
}

test "joffe_64b" {
    try run_test_range(wd.joffe_64b, .min, .max);
}

fn run_test_range(comptime func: anytype, comptime min: Date, comptime max: Date) !void {
    std.debug.assert(min.is_before(.epoch));
    std.debug.assert(max.is_after(.epoch));

    if (is_debug()) {
        var d: Date = .epoch;
        for (0..4_000_000) |_| {
            try run_test(func, d);
            if (d == max) break;
            d = d.next();
        } else {
            var d2 = max;
            for (0..1_000_000) |_| {
                try run_test(func, d2);
                if (d2 == d) break;
                d2 = d2.prev();
            }
        }

        d = .epoch;
        for (0..4_000_000) |_| {
            d = d.prev();
            try run_test(func, d);
            if (d == min) break;
        } else {
            var d2 = min;
            for (0..1_000_000) |_| {
                if (d2 == d) break;
                try run_test(func, d2);
                d2 = d2.next();
            }
        }
    } else {
        var d: Date = .epoch;
        while (true)  {
            try run_test(func, d);
            if (d == max) break;
            d = d.next();
        }
        d = .epoch;
        while (true)  {
            d = d.prev();
            try run_test(func, d);
            if (d == min) break;
        }
    }
}

inline fn run_test(comptime func: anytype, d: Date) !void {
    errdefer {
        const d_u32: u32 = @bitCast(@intFromEnum(d));
        std.log.err("For date: {f} (0x{x:0>8})", .{ d.fmt(Date.uk), d_u32 });
    }
    try std.testing.expectEqual(wd.oracle(d), func(d));
}

fn is_debug() bool {
    return if (@hasDecl(std.builtin, "Optimize")) builtin.optimize == .debug else builtin.mode == .Debug;
}

const Date = wd.Date;
const Week_Day = wd.Week_Day;
const wd = @import("week_day");
const builtin = @import("builtin");
const std = @import("std");
