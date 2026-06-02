utc_timestamp_seconds: i64, // "NTP Time" column from tzdata's leap-seconds.list, adjusted for unix epoch instead of NTP epoch
utc_offset_seconds: i32, // "DTAI" column from tzdata's leap-seconds.list

pub fn get_utc_offset_seconds(data: []const Leap_Second, timestamp_utc_seconds: i64) i32 {
    if (data.len == 0) return 0;
    const next_change_index = std.sort.upperBound(Leap_Second, data, timestamp_utc_seconds, order);
    if (next_change_index == 0) return 10;
    const current_index = next_change_index - 1;
    if (next_change_index == data.len) {
        log.warn("Timestamp {} exceeds expiration of leap-second data at {}", .{
            timestamp_utc_seconds,
            data[current_index].utc_offset_seconds,
        });
    }
    return data[current_index].utc_offset_seconds;
}

pub fn get_utc_offset_seconds_from_tai(data: []const Leap_Second, timestamp_tai_seconds: i64) i32 {
    var offset: i32 = 10;
    for (0..10) |_| {
        const new_offset = get_utc_offset_seconds(data, timestamp_tai_seconds - offset);
        if (new_offset == offset) {
            return new_offset;
        }
        offset = new_offset;
    } else unreachable;
}

fn order(ts: i64, leap: Leap_Second) std.math.Order {
    return std.math.order(ts, leap.utc_timestamp_seconds);
}

const log = std.log.scoped(.tempora_leap_seconds);

const Leap_Second = @This();
const std = @import("std");
