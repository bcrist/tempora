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
pub const TZDB = @import("TZDB.zig");
pub const tz = Timezone.tzdata;

pub fn now_utc(io: std.Io) Date_Time.With_Offset {
    return now(io, &Timezone.utc);
}

pub fn now_local(io: std.Io, tzdb: *const TZDB) Date_Time.With_Offset {
    return now(io, &tzdb.local);
}

pub fn now(io: std.Io, timezone: ?*const Timezone) Date_Time.With_Offset {
    return .from_timestamp(.now(io, .real), timezone);
}

const std = @import("std");
