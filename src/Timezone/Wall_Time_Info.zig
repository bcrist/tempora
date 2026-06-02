/// e.g. EST or EDT; may be empty.
designation: []const u8,

/// UTC seconds timestamp for the first instant when this record became valid.
begin_ts: ?i64,
/// UTC seconds timestamp for the first instant when this record is no longer valid.
end_ts: ?i64,

/// The number of seconds to be added to UTC in order to determine local wall clock time.
/// Note this does not include any leap second adjustments if the local time is supposed to be based on TAI instead of UTC.
utc_offset_seconds: i32,

/// Indicates whether local time is currently Standard or Daylight Saving Time.
dst: DST_Indicator,

/// Indicates how begin_ts was specified in the tzdata source.
/// Typically this is only needed when you want to write a timezone back to a TZif file.
source: Source,

pub const Source = enum {
    tzdata_utc,
    tzdata_standard, // local time, ignoring DST
    tzdata_wall, // local time, either standard or DST depending on time of year
    posix_tz, // predicted future transition
};

pub const DST_Indicator = enum (u8) {
    std = 0,
    dst = 1,
};

const std = @import("std");
