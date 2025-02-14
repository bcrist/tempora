// Parts of this file are based on https://github.com/leroycep/zig-tzif:

// MIT License

// Copyright (c) 2021 LeRoyce Pearson

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

pub const Version = enum(u8) {
    V1 = 0,
    V2 = '2',
    V3 = '3',

    pub fn time_size(self: Version) u32 {
        return switch (self) {
            .V1 => 4,
            .V2, .V3 => 8,
        };
    }

    pub fn leap_size(self: Version) u32 {
        return self.time_size() + 4;
    }

    pub fn string(self: Version) []const u8 {
        return switch (self) {
            .V1 => "1",
            .V2 => "2",
            .V3 => "3",
        };
    }
};

const time_type_size = 6;

pub const TZif_Header = struct {
    version: Version,
    isutcnt: u32,
    isstdcnt: u32,
    leapcnt: u32,
    timecnt: u32,
    typecnt: u32,
    charcnt: u32,

    pub fn dataSize(self: TZif_Header, data_block_version: Version) u32 {
        return self.timecnt * data_block_version.time_size() +
            self.timecnt +
            self.typecnt * time_type_size +
            self.charcnt +
            self.leapcnt * data_block_version.leap_size() +
            self.isstdcnt +
            self.isutcnt;
    }
};

pub fn parse_header(reader: anytype, seekableStream: anytype) !TZif_Header {
    var magic_buf: [4]u8 = undefined;
    try reader.readNoEof(&magic_buf);
    if (!std.mem.eql(u8, "TZif", &magic_buf)) {
        return error.InvalidFormat; // Magic number "TZif" is missing
    }

    // Check verison
    const version = reader.readEnum(Version, .little) catch |err| switch (err) {
        error.InvalidValue => return error.UnsupportedVersion,
        else => |e| return e,
    };
    if (version == .V1) {
        return error.UnsupportedVersion;
    }

    // Seek past reserved bytes
    try seekableStream.seekBy(15);

    return TZif_Header{
        .version = version,
        .isutcnt = try reader.readInt(u32, .big),
        .isstdcnt = try reader.readInt(u32, .big),
        .leapcnt = try reader.readInt(u32, .big),
        .timecnt = try reader.readInt(u32, .big),
        .typecnt = try reader.readInt(u32, .big),
        .charcnt = try reader.readInt(u32, .big),
    };
}

/// Parses hh[:mm[:ss]] to a number of seconds. Hours may be one digit long. Minutes and seconds must be two digits.
fn hhmmss_offset_to_s(_string: []const u8, idx: *usize) !i32 {
    var string = _string;
    var sign: i2 = 1;
    if (string[0] == '+') {
        sign = 1;
        string = string[1..];
        idx.* += 1;
    } else if (string[0] == '-') {
        sign = -1;
        string = string[1..];
        idx.* += 1;
    }

    for (string, 0..) |c, i| {
        if (!(std.ascii.isDigit(c) or c == ':')) {
            string = string[0..i];
            break;
        }
        idx.* += 1;
    }

    var result: i32 = 0;

    var segment_iter = std.mem.splitScalar(u8, string, ':');
    const hour_string = segment_iter.next() orelse return error.EmptyString;
    const hours = std.fmt.parseInt(u32, hour_string, 10) catch |err| switch (err) {
        error.InvalidCharacter => return error.InvalidFormat,
        error.Overflow => return error.InvalidFormat,
    };
    if (hours > 167) {
        // TODO: use diagnostics mechanism instead of logging
        return error.InvalidFormat;
    }
    result += std.time.s_per_hour * @as(i32, @intCast(hours));

    if (segment_iter.next()) |minute_string| {
        if (minute_string.len != 2) {
            // TODO: Add diagnostics when returning an error.
            return error.InvalidFormat;
        }
        const minutes = try std.fmt.parseInt(u32, minute_string, 10);
        if (minutes > 59) return error.InvalidFormat;
        result += std.time.s_per_min * @as(i32, @intCast(minutes));
    }

    if (segment_iter.next()) |second_string| {
        if (second_string.len != 2) {
            // TODO: Add diagnostics when returning an error.
            return error.InvalidFormat;
        }
        const seconds = try std.fmt.parseInt(u8, second_string, 10);
        if (seconds > 59) return error.InvalidFormat;
        result += seconds;
    }

    return result * sign;
}

fn parse_posix_tz_rule(_string: []const u8) !Timezone.POSIX_TZ.Rule {
    var string = _string;
    if (string.len < 2) return error.InvalidFormat;

    const time: i32 = if (std.mem.indexOf(u8, string, "/")) |start_of_time| parse_time: {
        const time_string = string[start_of_time + 1 ..];

        var i: usize = 0;
        const time = try hhmmss_offset_to_s(time_string, &i);

        // The time at the end of the rule should be the last thing in the string. Fixes the parsing to return
        // an error in cases like "/2/3", where they have some extra characters.
        if (i != time_string.len) {
            return error.InvalidFormat;
        }

        string = string[0..start_of_time];

        break :parse_time time;
    } else 2 * std.time.s_per_hour;

    if (string[0] == 'J') {
        const julian_day1 = std.fmt.parseInt(u16, string[1..], 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidFormat,
            error.Overflow => return error.InvalidFormat,
        };

        if (julian_day1 < 1 or julian_day1 > 365) return error.InvalidFormat;
        return .{ .julian_day = .{ .day = julian_day1, .time = time } };
    } else if (std.ascii.isDigit(string[0])) {
        const julian_day0 = std.fmt.parseInt(u16, string[0..], 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidFormat,
            error.Overflow => return error.InvalidFormat,
        };

        if (julian_day0 > 365) return error.InvalidFormat;
        return .{ .julian_day_zero = .{ .day = julian_day0, .time = time } };
    } else if (string[0] == 'M') {
        var split_iter = std.mem.splitScalar(u8, string[1..], '.');
        const m_str = split_iter.next() orelse return error.InvalidFormat;
        const n_str = split_iter.next() orelse return error.InvalidFormat;
        const d_str = split_iter.next() orelse return error.InvalidFormat;

        const m = std.fmt.parseInt(u8, m_str, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidFormat,
            error.Overflow => return error.InvalidFormat,
        };
        const n = std.fmt.parseInt(u8, n_str, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidFormat,
            error.Overflow => return error.InvalidFormat,
        };
        const d = std.fmt.parseInt(u8, d_str, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidFormat,
            error.Overflow => return error.InvalidFormat,
        };

        if (m < 1 or m > 12) return error.InvalidFormat;
        if (n < 1 or n > 5) return error.InvalidFormat;
        if (d > 6) return error.InvalidFormat;

        return .{ .month_nth_week_day = .{ .month = m, .n = n, .day = d, .time = time } };
    } else {
        return error.InvalidFormat;
    }
}

fn parse_posix_tz_designation(string: []const u8, idx: *usize) ![]const u8 {
    const quoted = string[idx.*] == '<';
    if (quoted) idx.* += 1;
    const start = idx.*;
    while (idx.* < string.len) : (idx.* += 1) {
        if ((quoted and string[idx.*] == '>') or
            (!quoted and !std.ascii.isAlphabetic(string[idx.*])))
        {
            const designation = string[start..idx.*];

            // The designation must be at least one character long!
            if (designation.len == 0) return error.InvalidFormat;

            if (quoted) idx.* += 1;
            return designation;
        }
    }
    return error.InvalidFormat;
}

pub fn parse_posix_tz(string: []const u8) !Timezone.POSIX_TZ {
    var result: Timezone.POSIX_TZ = .{ .std_designation = undefined, .std_offset = undefined };
    var idx: usize = 0;

    result.std_designation = try parse_posix_tz_designation(string, &idx);

    // multiply by -1 to get offset as seconds East of Greenwich as TZif specifies it:
    result.std_offset = try hhmmss_offset_to_s(string[idx..], &idx) * -1;
    if (idx >= string.len) {
        return result;
    }

    if (string[idx] != ',') {
        result.dst_designation = try parse_posix_tz_designation(string, &idx);

        if (idx < string.len and string[idx] != ',') {
            // multiply by -1 to get offset as seconds East of Greenwich as TZif specifies it:
            result.dst_offset = try hhmmss_offset_to_s(string[idx..], &idx) * -1;
        } else {
            result.dst_offset = result.std_offset + std.time.s_per_hour;
        }

        if (idx >= string.len) {
            return result;
        }
    }

    std.debug.assert(string[idx] == ',');
    idx += 1;

    if (std.mem.indexOf(u8, string[idx..], ",")) |_end_of_start_rule| {
        const end_of_start_rule = idx + _end_of_start_rule;
        result.dst_range = .{
            .start = try parse_posix_tz_rule(string[idx..end_of_start_rule]),
            .end = try parse_posix_tz_rule(string[end_of_start_rule + 1 ..]),
        };
    } else {
        return error.InvalidFormat;
    }

    return result;
}

pub fn parse(allocator: std.mem.Allocator, reader: anytype, seekableStream: anytype) !Timezone {
    const v1_header = try parse_header(reader, seekableStream);
    try seekableStream.seekBy(v1_header.dataSize(.V1));

    const v2_header = try parse_header(reader, seekableStream);

    var transitions: std.MultiArrayList(Timezone.Transition) = .{};
    try transitions.ensureTotalCapacity(allocator, v2_header.timecnt);
    errdefer transitions.deinit(allocator);

    // Parse transition times
    {
        var prev: i64 = -(2 << 59); // Earliest time supported, this is earlier than the big bang
        for (0..v2_header.timecnt) |_| {
            const ts = try reader.readInt(i64, .big);
            if (ts <= prev) {
                return error.InvalidFormat;
            }

            transitions.appendAssumeCapacity(.{
                .ts = ts,
                .zone_index = 0,
            });
            
            prev = ts;
        }
    }

    // Parse transition types
    const transition_zones = transitions.items(.zone_index);
    try reader.readNoEof(transition_zones);
    for (transition_zones) |zone_index| {
        if (zone_index >= v2_header.typecnt) {
            return error.InvalidFormat;
        }
    }

    // Parse local time type records
    const zone_infos = try allocator.alloc(Timezone.Zone_Info, v2_header.typecnt);
    errdefer allocator.free(zone_infos);
    for (zone_infos) |*zi| {
        const offset = try reader.readInt(i32, .big);
        const is_dst = switch (try reader.readByte()) {
            0 => false,
            1 => true,
            else => return error.InvalidFormat,
        };

        const designation_index = try reader.readByte(); // will be replaced below
        var designation_temp: []const u8 = &.{};
        designation_temp.len = designation_index;

        zi.* = .{
            .designation = designation_temp,
            .begin_ts = null,
            .end_ts = null,
            .offset = offset,
            .is_dst = is_dst,
            .source = .tzdata_wall,
        };
    }

    // Read designations
    const designations = try allocator.alloc(u8, v2_header.charcnt);
    errdefer allocator.free(designations);
    try reader.readNoEof(designations);

    // Update local time type records with a valid designation string
    for (zone_infos) |*zi| {
        const start_index = zi.designation.len;
        if (start_index > v2_header.charcnt) {
            return error.InvalidFormat;
        }
        zi.designation = std.mem.sliceTo(designations[start_index..], 0);
    }

    // Parse and ignore leap seconds records
    for (0..v2_header.leapcnt) |_| {
        _ = try reader.readInt(i64, .big);
        _ = try reader.readInt(i32, .big);
    }

    // Parse standard/wall indicators
    if (v2_header.isstdcnt > 0) {
        if (v2_header.isstdcnt != v2_header.typecnt) {
            return error.InvalidFormat;
        }
        for (zone_infos) |*zi| {
            zi.source = switch (try reader.readByte()) {
                1 => .tzdata_standard,
                0 => .tzdata_wall,
                else => return error.InvalidFormat,
            };
        }
    }

    // Parse UT/local indicators
    if (v2_header.isutcnt > 0) {
        if (v2_header.isutcnt != v2_header.typecnt) {
            return error.InvalidFormat;
        }
        for (zone_infos) |*zi| {
            zi.source = switch (try reader.readByte()) {
                1 => switch (zi.source) {
                    .tzdata_standard => .tzdata_utc,
                    else => return error.InvalidFormat,
                },
                0 => zi.source,
                else => return error.InvalidFormat,
            };
        }
    }

    // Parse TZ string from footer
    if ((try reader.readByte()) != '\n') return error.InvalidFormat;

    const tz_string = blk: {
        var buf: [60]u8 = undefined;
        const tz_string = try reader.readUntilDelimiter(&buf, '\n');
        break :blk try allocator.dupe(u8, tz_string);
    };
    errdefer allocator.free(tz_string);

    const posix_tz: ?Timezone.POSIX_TZ = if (tz_string.len > 0)
        try parse_posix_tz(tz_string)
    else
        null;

    return Timezone{
        .id = tz_string,
        .transitions = transitions,
        .zones = zone_infos,
        .posix_tz = posix_tz,
        .designations = designations,
    };
}

pub fn parse_file(allocator: std.mem.Allocator, path: []const u8) !Timezone {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    return parse(allocator, file.reader(), file.seekableStream());
}

pub fn parse_memory(allocator: std.mem.Allocator, data: []const u8) !Timezone {
    var stream = std.io.fixedBufferStream(data);
    return parse(allocator, stream.reader(), stream.seekableStream());
}

const log = std.log.scoped(.tempora);

const Timezone = @import("../Timezone.zig");
const testing = std.testing;
const std = @import("std");
