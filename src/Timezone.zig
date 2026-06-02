id: []const u8,
transition_count: usize,
transition_timestamps: [*]i64,
transition_info_indices: [*]u8,
infos: []const Wall_Time_Info,
posix: ?Posix,

/// Normally for timestamps before the first transition listed, infos[0] would be used,
/// but for Windows timezones, we want it to use the posix TZ string instead.
use_posix_for_old_times: bool = false,

/// Note that although UTC is defined as TAI with leap seconds added, tempora is
/// based on timestamps where leap seconds are normally ignored, so only populate
/// this for timezones that are based on TAI instead of UTC.
leap_seconds: []const Leap_Second = &.{},

pub const utc: Timezone = .{
    .id = "",
    .transition_count = 0,
    .transition_timestamps = undefined,
    .transition_info_indices = undefined,
    .infos = &.{},
    .posix = .init_standard("UTC", 0),
};

pub const tai: Timezone = .{
    .id = "",
    .transition_count = 0,
    .transition_timestamps = undefined,
    .transition_info_indices = undefined,
    .infos = &.{},
    .posix = .init_standard("TAI", 0),
    .leap_seconds = Timezone.tzdata.leap_seconds,
};

pub fn clone(self: *const Timezone, arena: std.mem.Allocator) !Timezone {
    const id = try arena.dupe(u8, self.id);

    const infos = try arena.dupe(Timezone.Wall_Time_Info, self.infos);
    for (infos) |*wall| {
        wall.designation = try arena.dupe(u8, wall.designation);
    }

    const transition_timestamps = try arena.dupe(i64, self.transition_timestamps[0..self.transition_count]);
    const transition_info_indices = try arena.dupe(u8, self.transition_info_indices[0..self.transition_count]);

    const leap_seconds = try arena.dupe(Leap_Second, self.leap_seconds);

    return .{
        .id = id,
        .transition_count = self.transition_count,
        .transition_timestamps = transition_timestamps.ptr,
        .transition_info_indices = transition_info_indices.ptr,
        .infos = infos,
        .posix = self.posix,
        .use_posix_for_old_times = self.use_posix_for_old_times,
        .leap_seconds = leap_seconds,
    };
}

pub fn debug(self: *const Timezone, writer: *std.Io.Writer) !void {
    try writer.print("Timezone {f}:\n", .{ std.zig.fmtString(self.id) });
    try writer.writeAll("    Transitions:\n");
    for (0..self.transition_count, self.transition_timestamps[0..self.transition_count], self.transition_info_indices[0..self.transition_count]) |i, ts, info_idx| {
        try writer.print("        [{}] {} -> {} ({f})\n", .{ i, ts, info_idx, Date_Time.With_Offset.from_timestamp_s(ts, null).fmt(Date_Time.With_Offset.rfc2822) });
    }
    try writer.writeAll("    Infos:\n");
    for (0.., self.infos) |i, wall| {
        try writer.print("        [{}] {*} \"{f}\" {t} {} {t}\n", .{ i, wall.designation.ptr, std.zig.fmtString(wall.designation), wall.dst, wall.utc_offset_seconds, wall.source });
    }
    try writer.writeAll("    Leap Seconds:\n");
    for (0.., self.leap_seconds) |i, leap| {
        try writer.print("        [{}] {} -> {}\n", .{ i, leap.utc_timestamp_seconds, leap.utc_offset_seconds });
    }
    if (self.posix) |posix| {
        try writer.print("    Posix: {f}\n", .{ posix });
    }
    try writer.writeAll("\n");
}

pub fn utc_offset_ms(self: *const Timezone, timestamp_utc_ms: i64) i32 {
    const timestamp_utc_seconds = @divFloor(timestamp_utc_ms, 1000);
    return 1000 * (self.info(timestamp_utc_seconds).utc_offset_seconds + Leap_Second.get_utc_offset_seconds(self.leap_seconds, timestamp_utc_seconds));
}

pub fn info(self: *const Timezone, timestamp_utc_seconds: i64) Wall_Time_Info {
    const transition_count = self.transition_count;
    const transition_timestamps = self.transition_timestamps[0..transition_count];
    const transition_info_indices = self.transition_info_indices[0..transition_count];
    const next_transition = std.sort.upperBound(i64, transition_timestamps, timestamp_utc_seconds, ts_order);

    if (next_transition == transition_count or self.infos.len == 0) {
        if (self.posix) |*posix| {
            const last_transition_ts: ?i64 = if (transition_count > 0) transition_timestamps[transition_count - 1] else null;
            return posix.info(timestamp_utc_seconds, last_transition_ts);
        }
    }

    if (next_transition == 0) {
        var wall: Wall_Time_Info = if (self.infos.len > 0) self.infos[0] else .{
            .designation = "",
            .begin_ts = null,
            .end_ts = null,
            .utc_offset_seconds = 0,
            .dst = .std,
            .source = .posix_tz,
        };
        if (self.use_posix_for_old_times) {
            if (self.posix) |*posix| {
                wall = posix.info(timestamp_utc_seconds, null);
            }
        }
        if (next_transition < transition_count) {
            wall.end_ts = transition_timestamps[next_transition];
        }
        return wall;
    }

    const info_index = transition_info_indices[next_transition - 1];
    var wall = self.infos[info_index];
    wall.begin_ts = transition_timestamps[next_transition - 1];
    if (next_transition < transition_count) {
        wall.end_ts = transition_timestamps[next_transition];
    }
    return wall;
}

fn ts_order(a: i64, b: i64) std.math.Order {
    return std.math.order(a, b);
}

const Timezone = @This();

pub const tzdata = @import("Timezone/tzdata.zig");
pub const cldr = @import("Timezone/cldr.zig");
pub const Leap_Second = @import("Timezone/Leap_Second.zig");
pub const Posix = @import("Timezone/Posix.zig");
pub const TZIF_Data = @import("Timezone/TZIF_Data.zig");
pub const Wall_Time_Info = @import("Timezone/Wall_Time_Info.zig");
pub const tzif = @import("Timezone/tzif.zig");
pub const windows = @import("Timezone/windows.zig");

const Date_Time = @import("Date_Time.zig");
const std = @import("std");
