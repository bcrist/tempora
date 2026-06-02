pub fn read_memory(arena: std.mem.Allocator, id: []const u8, data: []const u8, read_leap_seconds: bool) !Timezone {
    var reader = std.Io.Reader.fixed(data);
    return try read(arena, id, &reader, read_leap_seconds);
}

pub fn read(arena: std.mem.Allocator, id: []const u8, reader: *std.Io.Reader, read_leap_seconds: bool) !Timezone {
    var header: Header = try .read(reader);
    if (header.version == .v1) {
        return read_v(.v1, arena, id, reader, read_leap_seconds, header);
    }

    try reader.discardAll(Version.v1.payload_size(header));

    header = try .read(reader);
    if (header.version == .v1) {
        return read_v(.v1, arena, id, reader, read_leap_seconds, header);
    } else {
        return read_v(.v4, arena, id, reader, read_leap_seconds, header);
    }
}

fn read_v(comptime version: Version, arena: std.mem.Allocator, id: []const u8, reader: *std.Io.Reader, read_leap_seconds: bool, header: Header) !Timezone {
    if (header.std_wall_count != 0 and header.std_wall_count != header.type_count) return error.InvalidStdWallIndicatorCount;
    if (header.utc_local_count != 0 and header.utc_local_count != header.type_count) return error.InvalidUtcLocalIndicatorCount;

    var transitions: std.MultiArrayList(Transition(.v4)) = .empty;
    try transitions.ensureTotalCapacity(arena, header.time_count);
    errdefer transitions.deinit(arena);

    const designation_data = try arena.alloc(u8, header.char_count);
    errdefer arena.free(designation_data);
    @memset(designation_data, 0);

    const infos = try arena.alloc(Timezone.Wall_Time_Info, header.type_count);
    errdefer arena.free(infos);

    var leap_seconds: []Timezone.Leap_Second = &.{};
    if (read_leap_seconds) leap_seconds = try arena.alloc(Timezone.Leap_Second, header.leap_count);
    errdefer if (read_leap_seconds) arena.free(leap_seconds);

    transitions.len = header.time_count;
    if (transitions.len > 0) {
        var timestamps = transitions.items(.timestamp);
        timestamps[0] = try reader.takeInt(Timestamp(version), .big);
        for (timestamps[0 .. timestamps.len - 1], timestamps[1..]) |previous_timestamp, *timestamp| {
            const ts = try reader.takeInt(Timestamp(version), .big);
            if (ts <= previous_timestamp) return error.TransitionsNotSorted;
            timestamp.* = ts;
        }
    }

    if (@sizeOf(Local_Time_Type_Index) != @sizeOf(u8)) @compileError("Expected Local_Time_Type_Index to be 1 byte");
    const transition_types = transitions.items(.type_index);
    try reader.readSliceAll(@ptrCast(transition_types));
    for (transition_types) |i| if (i >= header.type_count) return error.InvalidLocalTimeTypeIndex;

    for (infos) |*info| {
        const record: Local_Time_Type_Record = try .read(reader);
        info.* = try record.to_info(designation_data);
        // note designation lengths will be incorrect at this point and need to be updated after designation_data has been populated.
    }

    try reader.readSliceAll(designation_data);
    for (infos) |*info| info.designation = std.mem.span(@as([*:0]const u8, @ptrCast(info.designation.ptr)));

    if (read_leap_seconds and header.leap_count > 0) {
        const first_record: Leap_Second_Record(version) = try .read(reader);
        leap_seconds[0] = first_record.to_leap_second();
        for (leap_seconds[0 .. leap_seconds.len - 1], leap_seconds[1..]) |previous, *leap| {
            const record: Leap_Second_Record(version) = try .read(reader);
            if (record.timestamp < previous.utc_timestamp_seconds) return error.LeapSecondsNotSorted;
            leap.* = record.to_leap_second();
        }
    } else {
        try reader.discardAll(Leap_Second_Record(version).size * header.leap_count);
    }

    if (header.std_wall_count > 0) {
        for (infos) |*info| {
            const indicator = reader.takeEnum(Std_Wall_Indicator, .big) catch |err| switch (err) {
                error.InvalidEnumTag => return error.InvalidStdWallIndicator,
                else => |e| return e,
            };
            info.source = switch (indicator) {
                .std => .tzdata_standard,
                .wall => .tzdata_wall,
            };
        }
    }

    if (header.utc_local_count > 0) {
        for (infos) |*info| {
            const indicator = reader.takeEnum(UTC_Local_Indicator, .big) catch |err| switch (err) {
                error.InvalidEnumTag => return error.InvalidUtcLocalIndicator,
                else => |e| return e,
            };
            switch (indicator) {
                .utc => switch (info.source) {
                    .tzdata_standard => info.source = .tzdata_utc,
                    else => return error.InvalidStdWallIndicator,
                },
                .local => {},
            }
        }
    }

    var posix: ?Timezone.Posix = null;
    if (version != .v1) {
        if ((try reader.takeByte()) != '\n') return error.MissingFooter;

        const tz_string = reader.takeDelimiter('\n') catch |err| switch (err) {
            error.StreamTooLong => return error.FooterTooLong,
            else => return err,
        } orelse "";

        if (tz_string.len > 0) posix = try Timezone.Posix.parse(tz_string);
    }

    return .{
        .id = id,
        .transition_count = transitions.len,
        .transition_timestamps = transitions.items(.timestamp).ptr,
        .transition_info_indices = transitions.items(.type_index).ptr,
        .infos = infos,
        .posix = posix,
        .leap_seconds = leap_seconds,
    };
}

pub const Write_Options = struct {
    version: Version = .v4,
    include_v1_data: bool = true,
};
pub fn write(tz: *const Timezone, writer: *std.Io.Writer, comptime options: Write_Options) !void {
    var header: Header = .{
        .version = options.version,
        .utc_local_count = @intCast(tz.infos.len),
        .std_wall_count = @intCast(tz.infos.len),
        .leap_count = @intCast(tz.leap_seconds.len),
        .time_count = @intCast(tz.transition_count),
        .type_count = @intCast(tz.infos.len),
        .char_count = undefined,
    };

    var all_wall = true;
    var all_local = true;
    var designations_buf: [256]u8 = undefined;
    var designations_writer = std.Io.Writer.fixed(&designations_buf);
    for (tz.infos) |info| {
        _ = try Local_Time_Type_Record.from_info(info, &designations_writer);
        if (info.source != .tzdata_wall) all_wall = false;
        if (info.source != .tzdata_utc) all_local = false;
    }

    header.char_count = @intCast(designations_writer.end);
    if (all_wall) header.std_wall_count = 0;
    if (all_local) header.utc_local_count = 0;

    var leap_seconds = tz.leap_seconds;

    if (header.version == .v4) {
        if (!leap_seconds_has_expiration(leap_seconds)) header.version = .v3;
    } else if (leap_seconds_has_expiration(leap_seconds)) {
        leap_seconds = leap_seconds[0 .. leap_seconds.len - 1];
        header.leap_count = @intCast(leap_seconds.len);
    }

    if (header.version == .v3) {
        if (tz.posix) |posix| {
            if (!posix.requires_tzif_v3()) header.version = .v2;
        } else header.version = .v2;
    } else if (header.version == .v2) {
        if (tz.posix) |posix| {
            if (posix.requires_tzif_v3()) header.version = .v3;
        }
    }

    if (options.version == .v1 or options.include_v1_data) {
        var v1_header = header;

        var v1_transition_timestamps = tz.transition_timestamps[0..tz.transition_count];
        var v1_transition_info_indices = tz.transition_info_indices[0..tz.transition_count];
        while (v1_transition_timestamps.len > 0 and v1_transition_timestamps[0] < std.math.minInt(i32)) {
            v1_transition_timestamps = v1_transition_timestamps[1..];
            v1_transition_info_indices = v1_transition_info_indices[1..];
        }
        for (0.., v1_transition_timestamps) |i, ts| {
            if (ts > std.math.maxInt(i32)) {
                v1_transition_timestamps = v1_transition_timestamps[0..i];
                v1_transition_info_indices = v1_transition_info_indices[0..i];
                break;
            }
        }

        var v1_leap_seconds = leap_seconds;
        while (v1_leap_seconds.len > 0 and v1_leap_seconds[0] < std.math.minInt(i32)) {
            v1_leap_seconds = v1_leap_seconds[1..];
        }
        for (0.., v1_leap_seconds) |i, ls| {
            if (ls.utc_timestamp_seconds > std.math.maxInt(i32)) {
                v1_leap_seconds = v1_leap_seconds[0..i];
                break;
            }
        }

        v1_header.time_count = @intCast(v1_transition_timestamps.len);
        v1_header.leap_count = @intCast(v1_leap_seconds.len);

        try header.write(writer);
        try write_v(
            options.version,
            v1_header,
            v1_transition_timestamps,
            v1_transition_info_indices,
            tz.infos,
            v1_leap_seconds,
            tz.posix,
            &designations_writer,
            writer,
        );
    } else if (options.version != .v1) {
        const v1_header: Header = .empty(header.version);
        try v1_header.write(writer);
        try writer.splatByteAll(0, Version.v1.payload_size(v1_header));
    }

    if (options.version != .v1) {
        try header.write(writer);
        try write_v(
            options.version,
            header,
            tz.transition_timestamps[0..tz.transition_count],
            tz.transition_info_indices[0..tz.transition_count],
            tz.infos,
            leap_seconds,
            tz.posix,
            &designations_writer,
            writer,
        );
    }
}

fn leap_seconds_has_expiration(leap_seconds: []const Timezone.Leap_Second) bool {
    if (leap_seconds.len < 2) return false;
    const len = leap_seconds.len;
    const last = leap_seconds[len - 1].utc_offset_seconds;
    const prev = leap_seconds[len - 2].utc_offset_seconds;
    return last == prev;
}

fn write_v(
    comptime version: Version,
    header: Header,
    transition_timestamps: []const i64,
    transition_types: []const Local_Time_Type_Index,
    infos: []const Timezone.Wall_Time_Info,
    leap_seconds: []const Timezone.Leap_Second,
    maybe_posix: ?Timezone.Posix,
    designations_writer: *std.Io.Writer,
    writer: *std.Io.Writer,
) !void {
    for (transition_timestamps) |ts| {
        try writer.writeInt(Timestamp(version), @intCast(ts), .big);
    }

    if (@sizeOf(Local_Time_Type_Index) != @sizeOf(u8)) @compileError("Expected Local_Time_Type_Index to be 1 byte");
    try writer.writeAll(@ptrCast(transition_types));

    for (infos) |info| {
        const record = Local_Time_Type_Record.from_info(info, designations_writer) catch unreachable; // any error should have been handled already in write()
        try record.write(writer);
    }

    try writer.writeAll(designations_writer.buffered());

    for (leap_seconds) |leap| {
        const record: Leap_Second_Record(version) = .from_leap_second(leap);
        try record.write(writer);
    }

    if (header.std_wall_count > 0) {
        for (infos) |info| {
            try writer.writeInt(u8, @intFromEnum(Std_Wall_Indicator.from_source(info.source)), .big);
        }
    }

    if (header.utc_local_count > 0) {
        for (infos) |info| {
            try writer.writeInt(u8, @intFromEnum(UTC_Local_Indicator.from_source(info.source)), .big);
        }
    }

    if (version != .v1) {
        if (maybe_posix) |posix| {
            try writer.print("\n{f}\n", .{ posix });
        } else {
            try writer.splatByteAll('\n', 2);
        }
    }
}

const Header = struct {
    version: Version,
    utc_local_count: u32,
    std_wall_count: u32,
    leap_count: u32,
    time_count: u32,
    type_count: u32,
    char_count: u32,

    pub const magic = "TZif";

    pub fn empty(version: Version) Header {
        return .{
            .version = version,
            .utc_local_count = 0,
            .std_wall_count = 0,
            .leap_count = 0,
            .time_count = 0,
            .type_count = 0,
            .char_count = 0,
        };
    }

    pub fn read(reader: *std.Io.Reader) !Header {
        var magic_buf: [4]u8 = undefined;
        try reader.readSliceAll(&magic_buf);
        if (!std.mem.eql(u8, magic, &magic_buf)) {
            return error.InvalidFormat; // Magic number "TZif" is missing
        }

        const version = try reader.takeEnumNonexhaustive(Version, .big);
        try reader.discardAll(15);

        var result: Header = undefined;
        result.version = version;
        result.utc_local_count = try reader.takeInt(u32, .big);
        result.std_wall_count = try reader.takeInt(u32, .big);
        result.leap_count = try reader.takeInt(u32, .big);
        result.time_count = try reader.takeInt(u32, .big);
        result.type_count = try reader.takeInt(u32, .big);
        result.char_count = try reader.takeInt(u32, .big);
        return result;
    }

    pub fn write(self: Header, writer: *std.Io.Writer) !void {
        try writer.writeAll(magic);
        try writer.writeInt(u8, @intFromEnum(self.version), .big);
        try writer.splatByteAll(0, 15);
        try writer.writeInt(u32, self.utc_local_count, .big);
        try writer.writeInt(u32, self.std_wall_count, .big);
        try writer.writeInt(u32, self.leap_count, .big);
        try writer.writeInt(u32, self.time_count, .big);
        try writer.writeInt(u32, self.type_count, .big);
        try writer.writeInt(u32, self.char_count, .big);
    }
};

fn Transition(comptime version: Version) type {
    return struct {
        timestamp: Timestamp(version),
        type_index: Local_Time_Type_Index,
    };
}

const Local_Time_Type_Record = struct {
    utc_offset_seconds: UTC_Offset,
    dst: Wall_Time_Info.DST_Indicator,
    designation: Designation_String_Offset,

    pub const size = @sizeOf(UTC_Offset) + @sizeOf(Wall_Time_Info.DST_Indicator) + @sizeOf(Designation_String_Offset);

    /// Note: designation_writer should be:
    ///    var buf: [256]u8 = undefined;
    ///    var designation_writer = std.Io.Writer.fixed(&buf);
    pub fn from_info(info: Timezone.Wall_Time_Info, designation_writer: *std.Io.Writer) !Local_Time_Type_Record {
        var designation_offset: ?Designation_String_Offset = null;
        var temp_buf: [64]u8 = undefined;
        if (std.fmt.bufPrint(&temp_buf, "{s}\x00", .{ info.designation })) |designation_z| {
            if (std.mem.find(u8, designation_writer.buffered(), designation_z)) |index| {
                designation_offset = @intCast(index);
            }
        } else |_| {
            // should be impossible, but just ignore and append designation if it happens
        }

        if (designation_offset == null) {
            designation_offset = @intCast(designation_writer.end);
            designation_writer.writeAll(info.designation) catch return error.TooManyDesignationStrings;
            designation_writer.writeByte(0) catch return error.TooManyDesignationStrings;
        }
        
        return .{
            .utc_offset_seconds = info.utc_offset_seconds,
            .dst = info.dst,
            .designation = designation_offset.?,
        };
    }

    pub fn to_info(self: Local_Time_Type_Record, owned_designation_data: []const u8) !Timezone.Wall_Time_Info {
        if (self.designation >= owned_designation_data.len) return error.InvalidLocalTimeDesignationOffset;
        const designation: []const u8 = std.mem.sliceTo(owned_designation_data[self.designation..], 0);
        return .{
            .designation = designation,
            .begin_ts = null,
            .end_ts = null,
            .utc_offset_seconds = self.utc_offset_seconds,
            .dst = self.dst,
            .source = .tzdata_wall,
        };
    }

    pub fn read(reader: *std.Io.Reader) !Local_Time_Type_Record {
        const offset = try reader.takeInt(UTC_Offset, .big);
        const dst = reader.takeEnum(Wall_Time_Info.DST_Indicator, .big) catch |err| switch (err) {
            error.InvalidEnumTag => return error.InvalidLocalTimeDstIndicator,
            else => |e| return e,
        };
        const designation = try reader.takeInt(Designation_String_Offset, .big);
        return .{
            .utc_offset_seconds = offset,
            .dst = dst,
            .designation = designation,
        };
    }

    pub fn write(self: Local_Time_Type_Record, writer: *std.Io.Writer) !void {
        try writer.writeInt(UTC_Offset, self.utc_offset_seconds, .big);
        try writer.writeInt(u8, @intFromEnum(self.dst), .big);
        try writer.writeInt(Designation_String_Offset, self.designation, .big);
    }
};

fn Leap_Second_Record(comptime version: Version) type {
    return struct {
        timestamp: Timestamp(version),
        correction: Leap_Correction,

        pub const size = @sizeOf(Timestamp(version)) + @sizeOf(Leap_Correction);

        pub fn from_leap_second(ls: Timezone.Leap_Second) @This() {
            return .{
                .timestamp = @intCast(ls.utc_timestamp_seconds),
                .correction = ls.utc_offset_seconds - 10,
            };
        }

        pub fn to_leap_second(self: @This()) Timezone.Leap_Second {
            return .{
                .utc_timestamp_seconds = self.timestamp,
                .utc_offset_seconds = self.correction + 10,
            };
        }

        pub fn read(reader: *std.Io.Reader) !@This() {
            const ts = try reader.takeInt(Timestamp(version), .big);
            const correction = try reader.takeInt(Leap_Correction, .big);
            return .{
                .timestamp = ts,
                .correction = correction,
            };
        }

        pub fn write(self: @This(), writer: *std.Io.Writer) !void {
            try writer.writeInt(Timestamp(version), self.timestamp, .big);
            try writer.writeInt(Leap_Correction, self.correction, .big);
        }
    };
}

fn Timestamp(comptime version: Version) type {
    return switch (version) {
        .v1 => i32,
        else => i64,
    };
}

const UTC_Offset = i32;
const Leap_Correction = i32;
const Local_Time_Type_Index = u8;
const Designation_String_Offset = u8;

const Std_Wall_Indicator = enum (u8) {
    wall = 0,
    std = 1,

    pub fn from_source(source: Wall_Time_Info.Source) Std_Wall_Indicator {
        return switch (source) {
            .tzdata_utc => .std,
            .tzdata_standard => .std,
            .tzdata_wall => .wall,
            .posix_tz => .wall,
        };
    }
};

const UTC_Local_Indicator = enum (u8) {
    local = 0,
    utc = 1,

    pub fn from_source(source: Wall_Time_Info.Source) UTC_Local_Indicator {
        return switch (source) {
            .tzdata_utc => .utc,
            .tzdata_standard => .local,
            .tzdata_wall => .local,
            .posix_tz => .local,
        };
    }
};

const Version = enum (u8) {
    v1 = 0,
    v2 = '2',
    v3 = '3',
    v4 = '4',
    _,

    pub fn payload_size(comptime self: Version, header: Header) usize {
        var size: usize = header.time_count * @sizeOf(Timestamp(self));
        size += header.time_count * @sizeOf(Local_Time_Type_Index);
        size += header.type_count * Local_Time_Type_Record.size;
        size += header.char_count * @sizeOf(u8);
        size += header.leap_count * Leap_Second_Record(self).size;
        size += header.std_wall_count * @sizeOf(Std_Wall_Indicator);
        size += header.utc_local_count * @sizeOf(UTC_Local_Indicator);
        return size;
    }
};

const Wall_Time_Info = Timezone.Wall_Time_Info;
const Timezone = @import("../Timezone.zig");
const std = @import("std");
