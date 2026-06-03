const NTSTATUS = std.os.windows.NTSTATUS;
const WORD = std.os.windows.WORD;
const LONG = std.os.windows.LONG;
const ULONG = std.os.windows.ULONG;
const REG = std.os.windows.REG;
const UNICODE_STRING = std.os.windows.UNICODE_STRING;
const PCWSTR = std.os.windows.PCWSTR;

pub extern "ntdll" fn RtlQueryRegistryValues(
    RelativeTo: ULONG,
    Path: PCWSTR,
    QueryTable: [*]const RTL_QUERY_REGISTRY_TABLE,
    Context: ?*const anyopaque,
    Environment: ?*const anyopaque,
) callconv(.winapi) NTSTATUS;

pub const RTL_QUERY_REGISTRY_TABLE = extern struct {
    QueryRoutine: RTL_QUERY_REGISTRY_ROUTINE,
    Flags: ULONG,
    Name: ?PCWSTR,
    EntryContext: ?*anyopaque,
    DefaultType: REG.ValueType = .NONE,
    DefaultData: ?*anyopaque = null,
    DefaultLength: ULONG = 0,
};

pub const RTL_QUERY_REGISTRY_ROUTINE = ?*const fn (
    PCWSTR,
    ULONG,
    ?*anyopaque,
    ULONG,
    ?*anyopaque,
    ?*anyopaque,
) callconv(.winapi) NTSTATUS;

const RTL_REG = enum (ULONG) {
    ABSOLUTE = 0,
    SERVICES = 1,
    CONTROL = 2,
    WINDOWS_NT = 3,
    DEVICEMAP = 4,
    USER = 5,

    pub const OPTIONAL: ULONG = 0x80000000;
    pub const HANDLE: ULONG = 0x40000000;
};

const RTL_QUERY = struct {
    pub const SUBKEY: ULONG = 0x00000001;
    pub const REQUIRED: ULONG = 0x00000004;
    pub const NOEXPAND: ULONG = 0x00000010;
    pub const DIRECT: ULONG = 0x00000020;
    pub const TYPECHECK: ULONG = 0x00000100;
};

const REG_TZI_FORMAT = extern struct {
    Bias: LONG,
    StandardBias: LONG,
    DaylightBias: LONG,
    StandardDate: SYSTEMTIME,
    DaylightDate: SYSTEMTIME,

    pub fn less_than(_: void, a: REG_TZI_FORMAT, b: REG_TZI_FORMAT) bool {
        return a.StandardDate.Year < b.StandardDate.Year;
    }

    pub fn std_offset_seconds(self: *const REG_TZI_FORMAT) i32 {
        return -(self.Bias + self.StandardBias) * std.time.s_per_min;
    }

    pub fn dst_offset_seconds(self: *const REG_TZI_FORMAT) i32 {
        return -(self.Bias + self.DaylightBias) * std.time.s_per_min;
    }

    pub fn std_transition(self: *const REG_TZI_FORMAT) Timezone.Posix.Transition {
        return .{
            .date = .{ .month_week_day = .{
                .month = .from_number(self.StandardDate.Month),
                .week = @enumFromInt(self.StandardDate.Day - 1),
                .day = .from_number(self.StandardDate.DayOfWeek + 1),
            }},
            .time = self.StandardDate.time(),
        };
    }

    pub fn dst_transition(self: *const REG_TZI_FORMAT) Timezone.Posix.Transition {
        return .{
            .date = .{ .month_week_day = .{
                .month = .from_number(self.DaylightDate.Month),
                .week = @enumFromInt(self.DaylightDate.Day - 1),
                .day = .from_number(self.DaylightDate.DayOfWeek + 1),
            }},
            .time = self.DaylightDate.time(),
        };
    }
};

const SYSTEMTIME = extern struct {
    Year: WORD,
    Month: WORD,
    DayOfWeek: WORD,
    Day: WORD,
    Hour: WORD,
    Minute: WORD,
    Second: WORD,
    Milliseconds: WORD,

    pub fn start_of_year(self: SYSTEMTIME) Date_Time {
        return Year.from_number(self.Year).starting_date().with_time(self.time());
    }

    pub fn transition_dt(self: SYSTEMTIME) Date_Time {
        var date = Date.from_ymd(.from_numbers(self.Year, self.Month, 1));
        const required_week_day: Week_Day = .from_number(self.DayOfWeek + 1);
        date = required_week_day.on_or_after(date);
        if (self.Day > 1) {
            for (1..self.Day) |_| {
                const next = date.plus_days(7);
                if (next.month().as_number() != self.Month) break;
                date = next;
            }
        }
        return date.with_time(self.time());
    }

    pub fn time(self: SYSTEMTIME) Time {
        return .from_hmsm(
            self.Hour,
            @intCast(self.Minute),
            @intCast(self.Second),
            @intCast(self.Milliseconds),
        );
    }
};

const Timezone_Info = struct {
    registry_key: []const u8,
    region: []const u8,
};

pub fn current_timezone_info(buf: []u8) !Timezone_Info {
    var timezone_key_buf: [40]u16 = undefined;
    var timezone_key: UNICODE_STRING = .{
        .Length = 0,
        .MaximumLength = @sizeOf(@TypeOf(timezone_key_buf)),
        .Buffer = &timezone_key_buf,
    };

    const timezone_key_query_table: []const RTL_QUERY_REGISTRY_TABLE = &.{
        .{
            .QueryRoutine = null,
            .Flags = RTL_QUERY.DIRECT | RTL_QUERY.TYPECHECK,
            .Name = comptime std.unicode.wtf8ToWtf16LeStringLiteral("TimeZoneKeyName"),
            .EntryContext = &timezone_key,
            .DefaultType = @enumFromInt(@intFromEnum(REG.ValueType.SZ) << 24),
        },
        .{
            .QueryRoutine = null,
            .Flags = 0,
            .Name = null,
            .EntryContext = null,
        },
    };

    var region_buf: [8]u16 = undefined;
    var region: UNICODE_STRING = .{
        .Length = 0,
        .MaximumLength = @sizeOf(@TypeOf(region_buf)),
        .Buffer = &region_buf,
    };

    const region_query_table: []const RTL_QUERY_REGISTRY_TABLE = &.{
        .{
            .QueryRoutine = null,
            .Flags = RTL_QUERY.DIRECT | RTL_QUERY.TYPECHECK,
            .Name = comptime std.unicode.wtf8ToWtf16LeStringLiteral("Name"),
            .EntryContext = &region,
            .DefaultType = @enumFromInt(@intFromEnum(REG.ValueType.SZ) << 24),
        },
        .{
            .QueryRoutine = null,
            .Flags = 0,
            .Name = null,
            .EntryContext = null,
        },
    };

    if (RtlQueryRegistryValues(@intFromEnum(RTL_REG.CONTROL), comptime std.unicode.wtf8ToWtf16LeStringLiteral("TimeZoneInformation"), timezone_key_query_table.ptr, null, null) != .SUCCESS) return error.Unexpected;
    if (RtlQueryRegistryValues(@intFromEnum(RTL_REG.USER), comptime std.unicode.wtf8ToWtf16LeStringLiteral("Control Panel\\International\\Geo"), region_query_table.ptr, null, null) != .SUCCESS) return error.Unexpected;

    var result: Timezone_Info = undefined;

    const end_index = std.unicode.wtf16LeToWtf8(buf, timezone_key.slice());
    result.registry_key = buf[0..end_index];

    const region_end_index = std.unicode.wtf16LeToWtf8(buf[end_index..], region.slice());
    result.region = buf[end_index..][0..region_end_index];

    log.debug("Detected current windows timezone registry key: {s} ({s})", .{ result.registry_key, result.region });

    return result;
}

fn parse_tzi(
    Name: PCWSTR,
    Type: ULONG,
    Data: ?*anyopaque,
    Bytes: ULONG,
    Context: ?*anyopaque,
    EntryContext: ?*anyopaque,
) callconv(.winapi) NTSTATUS {
    _ = Name;
    _ = Context;
    if (Type != @intFromEnum(REG.ValueType.BINARY)) return .SUCCESS;
    if (Data) |opaque_data| {
        if (Bytes != @sizeOf(REG_TZI_FORMAT)) return .BUFFER_TOO_SMALL;
        const tzi: *REG_TZI_FORMAT = @ptrCast(@alignCast(EntryContext.?));
        @memcpy(std.mem.asBytes(tzi), @as([*]const u8, @ptrCast(opaque_data)));
    }
    return .SUCCESS;
}

fn parse_dynamic_dst(
    Name: PCWSTR,
    Type: ULONG,
    Data: ?*anyopaque,
    Bytes: ULONG,
    Context: ?*anyopaque,
    EntryContext: ?*anyopaque,
) callconv(.winapi) NTSTATUS {
    if (Type != @intFromEnum(REG.ValueType.BINARY)) return .SUCCESS;
    const name_slice = std.mem.sliceTo(Name, 0);
    var year: WORD = 0;
    for (name_slice) |ch| {
        if (ch > 127 or !std.ascii.isDigit(@intCast(ch))) return .SUCCESS;
        year = year * 10 + (ch - '0');
    }
    if (Data) |opaque_data| {
        if (Bytes != @sizeOf(REG_TZI_FORMAT)) return .BUFFER_TOO_SMALL;
    
        const alloc: *std.mem.Allocator = @ptrCast(@alignCast(Context.?));
        const list: *std.ArrayList(REG_TZI_FORMAT) = @ptrCast(@alignCast(EntryContext.?));

        var tzi: REG_TZI_FORMAT = undefined;
        @memcpy(std.mem.asBytes(&tzi), @as([*]const u8, @ptrCast(opaque_data)));

        tzi.StandardDate.Year = year;
        tzi.DaylightDate.Year = year;

        list.append(alloc.*, tzi) catch return .NO_MEMORY;
    }
    return .SUCCESS;
}

pub fn timezone(temp: std.mem.Allocator, arena: std.mem.Allocator, id: []const u8, registry_key: []const u8) !?Timezone {
    var reg_key_buf: [80]u16 = @splat(0);
    const end = try std.unicode.wtf8ToWtf16Le(reg_key_buf[0 .. reg_key_buf.len - 1], registry_key);
    const registry_key_wide: [:0]u16 = @ptrCast(std.mem.sliceTo(reg_key_buf[0..end], 0));
    
    var tzi: REG_TZI_FORMAT = undefined;

    const query_table: []const RTL_QUERY_REGISTRY_TABLE = &.{
        .{
            .QueryRoutine = null,
            .Flags = RTL_QUERY.SUBKEY,
            .Name = registry_key_wide,
            .EntryContext = null,
        },
        .{
            .QueryRoutine = &parse_tzi,
            .Flags = RTL_QUERY.REQUIRED,
            .Name = comptime std.unicode.wtf8ToWtf16LeStringLiteral("TZI"),
            .EntryContext = &tzi,
        },
        .{
            .QueryRoutine = null,
            .Flags = 0,
            .Name = null,
            .EntryContext = null,
        },
    };

    switch (RtlQueryRegistryValues(@intFromEnum(RTL_REG.WINDOWS_NT), comptime std.unicode.wtf8ToWtf16LeStringLiteral("Time Zones"), query_table.ptr, &temp, null)) {
        .SUCCESS => {},
        .OBJECT_NAME_NOT_FOUND, .OBJECT_TYPE_MISMATCH, .BUFFER_TOO_SMALL => |tag| {
            log.err("Error reading windows timezone from registry key {s}: {t}", .{ registry_key, tag });
            return null;
        },
        else => return error.Unexpected,
    }

    var posix: Timezone.Posix = .init(
        cldr.windows_registry_key_to_designation(registry_key, false),
        tzi.std_offset_seconds(),
        cldr.windows_registry_key_to_designation(registry_key, true),
        tzi.dst_offset_seconds(),
        .default_start,
        .default_end,
    );

    if (tzi.StandardBias == tzi.DaylightBias or tzi.DaylightDate.Month == 0 or tzi.StandardDate.Month == 0) {
        posix.dst = null;
    } else {
        posix.dst.?.start = tzi.dst_transition();
        posix.dst.?.end = tzi.std_transition();
    }

    var dynamic_tzis: std.ArrayList(REG_TZI_FORMAT) = .empty;
    defer dynamic_tzis.deinit(temp);

    reg_key_buf[end] = '\\';
    const dynamic_end = try std.unicode.wtf8ToWtf16Le(reg_key_buf[end + 1 .. reg_key_buf.len - 1], "Dynamic DST");
    const dynamic_registry_key_wide: [:0]u16 = @ptrCast(std.mem.sliceTo(reg_key_buf[0..dynamic_end], 0));

    const query_table_2: []const RTL_QUERY_REGISTRY_TABLE = &.{
        .{
            .QueryRoutine = null,
            .Flags = RTL_QUERY.SUBKEY,
            .Name = dynamic_registry_key_wide,
            .EntryContext = null,
        },
        .{
            .QueryRoutine = &parse_dynamic_dst,
            .Flags = 0,
            .Name = null,
            .EntryContext = &dynamic_tzis,
        },
        .{
            .QueryRoutine = null,
            .Flags = 0,
            .Name = null,
            .EntryContext = null,
        },
    };

    switch (RtlQueryRegistryValues(@intFromEnum(RTL_REG.WINDOWS_NT), comptime std.unicode.wtf8ToWtf16LeStringLiteral("Time Zones"), query_table_2.ptr, &temp, null)) {
        .SUCCESS => {},
        .OBJECT_NAME_NOT_FOUND => {}, // not all timezones have a Dynamic DST subkey
        .OBJECT_TYPE_MISMATCH, .BUFFER_TOO_SMALL => |tag| {
            log.err("Windows timezone Dynamic DST: {t}", .{ tag });
            return null;
        },
        else => return error.Unexpected,
    }

    std.sort.pdq(REG_TZI_FORMAT, dynamic_tzis.items, {}, REG_TZI_FORMAT.less_than);

    var infos: []Wall_Time_Info = &.{};
    var transition_timestamps: []i64 = &.{};
    var transition_info_indices: []u8 = &.{}; 
    if (dynamic_tzis.items.len > 0) {
        var builder: Timezone_Builder = .init(temp, registry_key);
        defer builder.deinit();

        for (dynamic_tzis.items) |dynamic_tzi| {
            if (dynamic_tzi.DaylightBias == dynamic_tzi.StandardBias or dynamic_tzi.DaylightDate.Month == 0 or dynamic_tzi.StandardDate.Month == 0) {
                try builder.add_transition(dynamic_tzi.StandardDate.start_of_year().with_offset(dynamic_tzi.std_offset_seconds()), .std, &dynamic_tzi);
            } else if (dynamic_tzi.DaylightDate.Month < dynamic_tzi.StandardDate.Month) {
                try builder.add_transition(dynamic_tzi.DaylightDate.transition_dt().with_offset(dynamic_tzi.std_offset_seconds()), .dst, &dynamic_tzi);
                try builder.add_transition(dynamic_tzi.StandardDate.transition_dt().with_offset(dynamic_tzi.dst_offset_seconds()), .std, &dynamic_tzi);
            } else {
                try builder.add_transition(dynamic_tzi.StandardDate.transition_dt().with_offset(dynamic_tzi.dst_offset_seconds()), .std, &dynamic_tzi);
                try builder.add_transition(dynamic_tzi.DaylightDate.transition_dt().with_offset(dynamic_tzi.std_offset_seconds()), .dst, &dynamic_tzi);
            }
        }

        const next_year = Year.from_number(dynamic_tzis.items[dynamic_tzis.items.len - 1].StandardDate.Year + 1);
        try builder.add_transition(next_year.starting_date().with_time(.midnight).with_offset(tzi.std_offset_seconds()), .std, &tzi);

        infos = (try builder.info_dedup.clone(arena)).items;
        transition_timestamps = try arena.dupe(i64, builder.transitions.items(.timestamp));
        transition_info_indices = try arena.dupe(u8, builder.transitions.items(.info_index));
    }
    
    return .{
        .id = try arena.dupe(u8, id),
        .transition_count = transition_timestamps.len,
        .transition_timestamps = transition_timestamps.ptr,
        .transition_info_indices = transition_info_indices.ptr,
        .infos = infos,
        .posix = posix,
        .use_posix_for_old_times = true,
    };
}

const Transition = struct {
    timestamp: i64,
    info_index: u8,
};

const Timezone_Builder = struct {
    gpa: std.mem.Allocator,
    info_dedup: std.ArrayList(Wall_Time_Info),
    transitions: std.MultiArrayList(Transition),
    std_designation: []const u8,
    dst_designation: []const u8,

    pub fn init(gpa: std.mem.Allocator, registry_key: []const u8) Timezone_Builder {
        return .{
            .gpa = gpa,
            .info_dedup = .empty,
            .transitions = .empty,
            .std_designation = cldr.windows_registry_key_to_designation(registry_key, false),
            .dst_designation = cldr.windows_registry_key_to_designation(registry_key, true),
        };
    }

    pub fn deinit(self: *Timezone_Builder) void {
        self.info_dedup.deinit(self.gpa);
        self.transitions.deinit(self.gpa);
    }

    fn get_info_index(self: *Timezone_Builder, info: Wall_Time_Info) !u8 {
        for (0.., self.info_dedup.items) |i, existing| {
            if (info.utc_offset_seconds != existing.utc_offset_seconds) continue;
            if (info.dst != existing.dst) continue;
            if (info.source != existing.source) continue;
            if (!std.mem.eql(u8, info.designation, existing.designation)) continue;
            return @intCast(i);
        } else {
            const index = self.info_dedup.items.len;
            try self.info_dedup.append(self.gpa, info);
            return @intCast(index);
        }
    }

    pub fn add_transition(self: *Timezone_Builder, dto: Date_Time.With_Offset, dst: Wall_Time_Info.DST_Indicator, tzi: *const REG_TZI_FORMAT) !void {
        const info_index = try self.get_info_index(.{
            .designation = switch (dst) {
                .std => self.std_designation,
                .dst => self.dst_designation,
            },
            .begin_ts = null,
            .end_ts = null,
            .utc_offset_seconds = switch (dst) {
                .std => tzi.std_offset_seconds(),
                .dst => tzi.dst_offset_seconds(),
            },
            .dst = dst,
            .source = .tzdata_wall,
        });
        try self.transitions.append(self.gpa, .{
            .timestamp = dto.timestamp_s(),
            .info_index = info_index,
        });
    }
};

const log = std.log.scoped(.tempora);

const Wall_Time_Info = @import("Wall_Time_Info.zig");
const Timezone = @import("../Timezone.zig");
const Date = @import("../date.zig").Date;
const Time = @import("../time.zig").Time;
const Date_Time = @import("../Date_Time.zig");
const Year = @import("../year.zig").Year;
const Week_Day = @import("../week_day.zig").Week_Day;
const cldr = @import("cldr.zig");
const std = @import("std");
