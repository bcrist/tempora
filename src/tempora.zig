pub const Date_Time = @import("Date_Time.zig");
pub const Date = @import("date.zig").Date;
pub const Time = @import("time.zig").Time;
pub const Year = @import("year.zig").Year;
pub const Month = @import("month.zig").Month;
pub const Day = @import("day.zig").Day;
pub const Week_Day = @import("week_day.zig").Week_Day;
pub const Ordinal_Week = @import("ordinal_week.zig").Ordinal_Week;
pub const Ordinal_Day = @import("ordinal_day.zig").Ordinal_Day;
pub const ISO_Week_Date = @import("iso_week.zig").ISO_Week_Date;
pub const ISO_Week = @import("iso_week.zig").ISO_Week;
pub const Timezone = @import("Timezone.zig");
pub const tzdb = @import("tzdb.zig");

pub fn now() Date_Time.With_Offset {
    return now_tz(null);
}

pub fn now_local() !Date_Time.With_Offset {
    return now_tz(try tzdb.current_timezone());
}

pub fn now_tz(tz: ?*const Timezone) Date_Time.With_Offset {
    return Date_Time.With_Offset.from_timestamp_ms(std.time.milliTimestamp(), tz);
}

const std = @import("std");

test {
    _ = tzdb;
    _ = Date_Time;
    _ = @import("date.zig");
    _ = @import("time.zig");
}
