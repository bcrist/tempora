test {
    _ = @import("Date_Time.zig");
    _ = @import("date.zig");
    _ = @import("day.zig");
    _ = @import("iso.zig");
    _ = @import("month.zig");
    _ = @import("ordinal_day.zig");
    _ = @import("ordinal_week.zig");
    _ = @import("time.zig");
    _ = @import("posix_tz.zig");
    _ = @import("tzif.zig");
    _ = @import("tzdb.zig");
    _ = @import("week_day.zig");
    _ = @import("year.zig");

    try std.testing.expect(tempora.now_utc(std.testing.io).dt.date.is_after(.epoch));
}

const tempora = @import("tempora");
const std = @import("std");