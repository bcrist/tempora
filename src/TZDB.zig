lazy_io: std.Io,
gpa: std.mem.Allocator,
arena: std.mem.Allocator,
default_lazy_options: ?*const Add_Options = null,
lookup: std.array_hash_map.String(Timezone) = .empty,
lazy_lookup: std.StringHashMapUnmanaged(Lazy_TZIF_Data) = .empty,
designations: std.array_hash_map.String(Designation_Info) = .empty,
local: Timezone = .utc,

const Designation_Info = struct {
    utc_offset_seconds: i32,
    leap_seconds: []const Timezone.Leap_Second,
};

const Lazy_TZIF_Data = struct {
    tzif: *const Timezone.TZIF_Data,
    options: *const Add_Options,
};

/// N.B. you may also just initialize manually with .{ .lazy_io = ..., .gpa = ..., .arena = ... }
pub fn init(pi: std.process.Init) TZDB {
    return .{
        .lazy_io = pi.io,
        .gpa = pi.gpa,
        .arena = pi.arena.allocator(),
    };
}

pub fn deinit(self: *TZDB) void {
    self.designations.deinit(self.gpa);
    self.lookup.deinit(self.gpa);
    self.lazy_lookup.deinit(self.gpa);
}

/// N.B. While this will include lazy timezone IDs, TZDB.timezone() isn't necessarily guaranteed
/// to return non-null for all returned IDs, if TZDB.add_lazy() has been used
pub fn get_ids(self: *const TZDB) []const []const u8 {
    return self.lookup.keys();
}

/// N.B. Any calls to TZDB.timezone() must be externally synchronized if the TZDB is used from multiple threads
/// concurrently and contains lazy timezones (i.e. TZDB.add_lazy() or TZDB.default_lazy_options have been used)
pub fn timezone(self: *TZDB, id: []const u8) ?*const Timezone {
    const tz = self.lookup.getPtr(id) orelse tz: {
        if (self.default_lazy_options) |options| {
            _ = self.add_iana(self.lazy_io, id, .{
                .override_search_path = options.tzdata_override_search_path,
                .search_paths = options.tzdata_search_paths,
                .use_windows = options.use_windows,
                .load_leap_seconds = options.load_leap_seconds,
                .data = null,
            }) catch |err| {
                log.warn("Failed to lazy-load timezone {s}: {s}", .{ id, @errorName(err) });
                return null;
            } orelse return null;
            break :tz self.lookup.getPtr(id) orelse return null;
        }
        return null;
    };
    if (tz.infos.len > 0 or tz.posix != null) return tz;

    if (self.lazy_lookup.get(id)) |lazy| {
        tz.* = self.add_tzif_data(self.lazy_io, lazy.tzif.*, lazy.options.*) catch |err| {
            log.warn("Failed to lazy-load timezone {s}: {s}", .{ id, @errorName(err) });
            return null;
        } orelse return null;
    } else if (self.default_lazy_options) |options| {
        tz.* = self.add_iana(self.lazy_io, id, .{
            .override_search_path = options.tzdata_override_search_path,
            .search_paths = options.tzdata_search_paths,
            .use_windows = options.use_windows,
            .load_leap_seconds = options.load_leap_seconds,
            .data = null,
        }) catch |err| {
            log.warn("Failed to lazy-load timezone {s}: {s}", .{ id, @errorName(err) });
            return null;
        } orelse return null;

    } else return null;

    _ = self.lazy_lookup.remove(id);
    return tz;
}

pub fn designation_utc_offset_ms(self: *const TZDB, designation: []const u8, dto: Date_Time.With_Offset) ?i32 {
    if (self.designations.get(designation)) |designation_info| {
        var offset_seconds = designation_info.utc_offset_seconds;
        if (designation_info.leap_seconds.len > 0) {
            offset_seconds += Timezone.Leap_Second.get_utc_offset_seconds(designation_info.leap_seconds, dto.timestamp_s());
        }
        return 1000 * offset_seconds;
    }
    return null;
}

pub const Add_Options = struct {
    tzdata_override_search_path: ?[]const u8,
    tzdata_search_paths: []const []const u8,
    use_windows: bool,
    use_embedded: bool,
    load_leap_seconds: bool = false,

    pub const embedded: Add_Options = .{
        .tzdata_override_search_path = null,
        .tzdata_search_paths = &.{},
        .use_windows = false,
        .use_embedded = true,
    };

    // N.B. when used with .add_lazy(), the provided environment map must remain valid at least as long as the TZDB.
    pub fn system(maybe_env: ?*std.process.Environ.Map) Add_Options {
        return .init(maybe_env, false);
    }

    // N.B. when used with .add_lazy(), the provided environment map must remain valid at least as long as the TZDB.
    pub fn system_or_embedded(maybe_env: ?*std.process.Environ.Map) Add_Options {
        return .init(maybe_env, true);
    }

    // N.B. when used with .add_lazy(), the provided environment map must remain valid at least as long as the TZDB.
    fn init(maybe_env: ?*std.process.Environ.Map, allow_embedded: bool) Add_Options {
        return .{
            .tzdata_override_search_path = if (maybe_env) |env| env.get("TZDIR") orelse env.get("TZDATA") orelse env.get("ZONEINFO") else null,
            .tzdata_search_paths = &common_zoneinfo_locations,
            .use_windows = builtin.os.tag == .windows and !allow_embedded,
            .use_embedded = allow_embedded,
        };
    }
};
/// Loads and adds one or more timezones to this TZDB, if no timezone with that ID already exists.
///     * You can pass a string or @EnumLiteral containing an IANA timezone ID (e.g. 'America/Chicago') to load from the system (subject to the passed `options`)
///     * You can pass a Timezone.TZIF_Data struct to either load an IANA timezone from the system or from embedded TZif data (subject to the passed `options`) 
///     * If you pass a Timezone struct, a cloned version of it will be added which is owned by this TZDB (`options` is ignored in this case)
///     * If you pass a tuple, struct, or enum, all fields and decls will be recursively added
///     * If you pass an array or slice, all items within will be recursively added
pub fn add(self: *TZDB, io: std.Io, comptime what: anytype, options: Add_Options) std.mem.Allocator.Error!void {
    const T = @TypeOf(what);
    if (T == Timezone.TZIF_Data) {
        _ = try self.add_tzif_data(io, what, options);
        return;
    } else if (T == Timezone) {
        try self.add_tz(what.clone(self.arena));
        return;
    } else if (T == type) {
        switch (@typeInfo(what)) {
            .@"struct" => |info| inline for (info.decl_names) |decl| {
                try self.add(io, @field(what, decl), options);
            },
            .@"enum" => |info| inline for (info.decl_names) |decl| {
                try self.add(io, @field(what, decl), options);
            },
            else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any} is {s}", .{ what, @tagName(@typeInfo(what)) })),
        }
    } else switch (@typeInfo(T)) {
        .@"struct" => |info| {
            inline for (info.field_names) |field| {
                try self.add(io, @field(what, field), options);
            }
            inline for (info.decl_names) |decl| {
                try self.add(io, @field(T, decl), options);
            }
        },
        .@"enum" => |info| {
            inline for (info.field_names) |field| {
                try self.add(io, field, options);
            }
            inline for (info.decl_names) |decl| {
                try self.add(io, @field(T, decl), options);
            }
        },
        .pointer => |info| {
            switch (info.size) {
                .slice => {
                    if (info.child == u8) {
                        if (!self.lookup.contains(what)) {
                            try self.add_iana(io, what, .{
                                .override_search_path = options.tzdata_override_search_path,
                                .search_paths = options.tzdata_search_paths,
                                .use_windows = options.use_windows,
                                .data = null,
                            });
                        }
                    } else for (what) |item| {
                        try self.add(io, item, options);
                    }
                },
                .one => {
                    try self.add(io, what.*, options);
                },
                else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any}", .{ what })),
            }
        },
        .array => {
            for (what) |item| {
                try self.add(io, item, options);
            }
        },
        .enum_literal => {
            try self.add(io, @tagName(what), options);
        },
        else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any} is {s}", .{ what, @tagName(@typeInfo(T)) })),
    }
}

/// Adds one or more timezones to this TZDB, if no timezone with that ID already exists.
/// Timezones added this way will not be loaded/parsed until the first time they are requested with TZDB.timezone().
/// This function accepts all the same items for `what` as TZDB.add(), except `Timezone` structs.
/// N.B. `options` must be static or have a lifetime at least as long as this TZDB
pub fn add_lazy(self: *TZDB, comptime what: anytype, options: *const Add_Options) std.mem.Allocator.Error!void {
    const T = @TypeOf(what);
    if (T == Timezone.TZIF_Data) {
        const tzif = try self.arena.create(Timezone.TZIF_Data);
        tzif.* = what;
        return try self.add_lazy_tzif_data(tzif, options);
    } else if (T == Timezone) {
        @compileError("Use TZDB.add() if you want to add a Timezone instance directly");
    } else if (T == type) {
        switch (@typeInfo(what)) {
            .@"struct" => |info| inline for (info.decl_names) |decl| {
                try self.add_lazy(&@field(what, decl), options);
            },
            .@"enum" => |info| inline for (info.decl_names) |decl| {
                try self.add_lazy(&@field(what, decl), options);
            },
            else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any} is {s}", .{ what, @tagName(@typeInfo(what)) })),
        }
    } else switch (@typeInfo(T)) {
        .@"struct" => |info| {
            inline for (info.field_names) |field| {
                try self.add_lazy(&@field(what, field), options);
            }
            inline for (info.decl_names) |decl| {
                try self.add_lazy(&@field(T, decl), options);
            }
        },
        .@"enum" => |info| {
            inline for (info.field_names) |field| {
                try self.add_lazy(field, options);
            }
            inline for (info.decl_names) |decl| {
                try self.add_lazy(&@field(T, decl), options);
            }
        },
        .pointer => |info| {
            switch (info.size) {
                .slice => {
                    if (info.child == u8) {
                        try self.add_lazy_system_tz(what, options);
                    } else for (what) |item| {
                        try self.add_lazy(&item, options);
                    }
                },
                .one => {
                    if (info.child == Timezone.TZIF_Data) {
                        try self.add_lazy_tzif_data(what, options);
                    } else {
                        try self.add_lazy(what.*, options);
                    }
                },
                else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any}", .{ what })),
            }
        },
        .array => {
            for (what) |item| {
                try self.add_lazy(item, options);
            }
        },
        .enum_literal => {
            try self.add_lazy(@tagName(what), options);
        },
        else => @compileError(std.fmt.comptimePrint("Invalid timezone spec: {any} is {s}", .{ what, @tagName(@typeInfo(T)) })),
    }
}

fn add_lazy_system_tz(self: *TZDB, id: []const u8, options: *const Add_Options) std.mem.Allocator.Error!void {
    if (self.lookup.contains(id) or self.lazy_lookup.contains(id)) return;
    const tzif = try self.arena.create(Timezone.TZIF_Data);
    tzif.* = .{
        .id = id,
        .kind = .system,
    };
    try self.add_lazy_tzif_data(tzif, options);
}

fn add_lazy_tzif_data(self: *TZDB, tzif: *const Timezone.TZIF_Data, options: *const Add_Options) std.mem.Allocator.Error!void {
    if (self.lookup.contains(tzif.id)) return;
    try self.lazy_lookup.put(self.gpa, tzif.id, .{
        .tzif = tzif,
        .options = options,
    });
    // add a placeholder to self.lookup so that self.get_ids() includes this ID:
    try self.lookup.put(self.gpa, tzif.id, .{
        .id = tzif.id,
        .transition_count = 0,
        .transition_timestamps = undefined,
        .transition_info_indices = undefined,
        .infos = &.{},
        .posix = null,
    });
}

fn add_tzif_data(self: *TZDB, io: std.Io, tzif: Timezone.TZIF_Data, options: Add_Options) std.mem.Allocator.Error!?Timezone {
    if (tzif.id.len == 0) return null;
    if (self.lookup.get(tzif.id)) |tz| if (tz.infos.len > 0 or tz.posix != null) return tz;
    
    const data: @FieldType(Add_IANA_Options, "data") = if (options.use_embedded) switch (tzif.kind) {
        .system => null,
        .uncompressed => |bytes| .{
            .bytes = bytes,
            .compression = .none,
        },
        .compressed_zlib => |bytes| .{
            .bytes = bytes,
            .compression = .zlib,
        },
        .link => |linked| {
            var tz = (try self.add_tzif_data(io, linked.*, options)) orelse return null;
            tz.id = try self.arena.dupe(u8, tzif.id);
            try self.lookup.put(self.gpa, tz.id, tz);
            _ = self.lazy_lookup.remove(tzif.id);
            return tz;
        },
    } else null;

    return try self.add_iana(io, tzif.id, .{
        .override_search_path = options.tzdata_override_search_path,
        .search_paths = options.tzdata_search_paths,
        .use_windows = options.use_windows,
        .load_leap_seconds = options.load_leap_seconds,
        .data = data,
    });
}

const Add_IANA_Options = struct {
    override_search_path: ?[]const u8,
    search_paths: []const []const u8,
    use_windows: bool,
    load_leap_seconds: bool,
    data: ?struct {
        bytes: []const u8,
        compression: enum {
            none,
            zlib,
        },
    },
};
fn add_iana(self: *TZDB, io: std.Io, id: []const u8, options: Add_IANA_Options) std.mem.Allocator.Error!?Timezone {
    if (options.override_search_path) |path| {
        if (try self.load_iana(io, path, id, id, options.load_leap_seconds)) |tz| return tz;
    }

    for (options.search_paths) |path| {
        if (try self.load_iana(io, path, id, id, options.load_leap_seconds)) |tz| return tz;
    }

    if (builtin.os.tag == .windows and options.use_windows) {
        if (try self.load_windows(io, id)) |tz| return tz;
    }

    if (options.data) |data| {
        var reader: std.Io.Reader = .fixed(data.bytes);
        switch (data.compression) {
            .none => {
                return try self.read_iana(id, &reader, true);
            },
            .zlib => {
                var buf: [std.compress.flate.max_window_len]u8 = undefined;
                var decompressor = std.compress.flate.Decompress.init(&reader, .zlib, &buf);
                return try self.read_iana(id, &decompressor.reader, true);
            },
        }
    }

    return null;
}

fn load_iana(self: *TZDB, io: std.Io, search_path: []const u8, filename: []const u8, id: []const u8, load_leap_seconds: bool) std.mem.Allocator.Error!?Timezone {
    if (std.mem.indexOf(u8, filename, "..") != null or search_path.len == 0) return null;

    const dir = std.Io.Dir.cwd().openDir(io, search_path, .{}) catch return null;
    defer dir.close(io);

    const f = dir.openFile(io, id, .{}) catch return null;
    defer f.close(io);

    var buf: [8192]u8 = undefined;
    var reader = f.reader(io, &buf);

    return try self.read_iana(id, &reader.interface, load_leap_seconds);
}

fn read_iana(self: *TZDB, id: []const u8, reader: *std.Io.Reader, read_leap_seconds: bool) std.mem.Allocator.Error!?Timezone {
    var tz = Timezone.tzif.read(self.arena, id, reader, read_leap_seconds) catch |err| switch (err) {
        error.OutOfMemory => |e| return e,
        else => {
            log.warn("Failed to read tzif for {s}: {s}", .{ id, @errorName(err) });
            return null;
        },
    };
    tz.id = try self.arena.dupe(u8, id);
    try self.add_tz(id, tz);
    return tz;
}

fn load_windows(self: *TZDB, io: std.Io, id: []const u8) std.mem.Allocator.Error!?Timezone {
    _ = io;
    if (Timezone.cldr.iana_to_windows_registry_key.get(id)) |registry_key| {
        if (Timezone.windows.timezone(self.gpa, self.arena, id, registry_key) catch return null) |tz| {
            try self.add_tz(tz.id, tz);
            return tz;
        }
    }
    return null;
}

fn add_tz(self: *TZDB, id: []const u8, tz: Timezone) std.mem.Allocator.Error!void {
    if (id.len > 0 and !self.lookup.contains(id)) {
        try self.lookup.put(self.gpa, id, tz);
        _ = self.lazy_lookup.remove(id);
    }
}

pub fn add_designation(self: *TZDB, designation: []const u8, utc_offset_seconds: i32) std.mem.Allocator.Error!void {
    const designation_duped = try self.arena.dupe(designation);
    try self.add_designation_owned(designation_duped, utc_offset_seconds, &.{}, std.math.maxInt(i32));
}

pub fn add_designations(self: *TZDB, what: anytype) std.mem.Allocator.Error!void {
    const T = @TypeOf(what);
    if (T == type) {
        const decls = @typeInfo(what).@"struct".decl_names;
        inline for (decls) |decl| {
            const val = @field(what, decl);
            switch (@typeInfo(@TypeOf(val))) {
                .@"struct" => {
                    try self.add_designations(@field(what, decl));
                },
                else => {
                    try self.add_designation_owned(decl, val, &.{});
                },
            }
        }
    } else switch (@typeInfo(T)) {
        .@"struct" => |info| {
            try self.add_designations(T);
            inline for (info.field_names) |field| {
                try self.add_designation_owned(field, @field(what, field), &.{});
            }
        },
        else => @compileError(std.fmt.comptimePrint("Invalid designation spec: {any} is {s}", .{ what, @tagName(@typeInfo(T)) })),
    }
}

fn add_designation_owned(self: *TZDB, designation: []const u8, utc_offset_seconds: i32, leap_seconds: []const Timezone.Leap_Second) std.mem.Allocator.Error!void {
    const gop = try self.designations.getOrPut(self.gpa, designation);
    if (gop.found_existing) {
        if (gop.value_ptr.utc_offset_seconds != utc_offset_seconds or gop.value_ptr.leap_seconds.len != leap_seconds.len) {
            log.err("Multiple offset designations found named '{s}'; previously {}, now {}", .{ designation, gop.value_ptr.utc_offset_seconds, utc_offset_seconds });
        }
    } else {
        gop.key_ptr.* = designation;
        gop.value_ptr.* = .{
            .utc_offset_seconds = utc_offset_seconds,
            .leap_seconds = leap_seconds,
        };
    }
}

pub const Add_Current_Options = struct {
    override: ?[]const u8,
    search_paths: []const []const u8,
    tzdata_override_search_path: ?[]const u8,
    tzdata_search_paths: []const []const u8,
    link_existing: bool,
    load_leap_seconds: bool = false,

    /// Get all information about the current timezone from the OS, not just the name.
    pub fn system(maybe_env: ?*std.process.Environ.Map) Add_Current_Options {
        return .init(maybe_env, false);
    }

    /// If possible, try to retrieve only the name of the current timezone from the OS, but load the actual timezone data from the embedded IANA db.
    pub fn system_link(maybe_env: ?*std.process.Environ.Map) Add_Current_Options {
        return .init(maybe_env, true);
    }

    pub fn init(maybe_env: ?*std.process.Environ.Map, link_existing: bool) Add_Current_Options {
        return .{
            .override = if (maybe_env) |env| env.get("TZ") else null,
            .search_paths = if (builtin.os.tag == .windows) &.{} else &.{ "/etc/localtime" },
            .tzdata_override_search_path = if (maybe_env) |env| env.get("TZDIR") orelse env.get("TZDATA") orelse env.get("ZONEINFO") else null,
            .tzdata_search_paths = &common_zoneinfo_locations,
            .link_existing = link_existing,
        };
    }
};
pub fn add_current(self: *TZDB, io: std.Io, options: Add_Current_Options) std.mem.Allocator.Error!void {
    if (options.override) |override| {
        if (std.mem.startsWith(u8, override, ":")) {
            if (try self.read_current_timezone_link(io, override[1..], options.link_existing)) |tz| {
                self.local = tz;
                return;
            }
        } else if (Timezone.Posix.parse(override)) |tz| {
            self.local = .{
                .id = "",
                .transition_count = 0,
                .transition_timestamps = undefined,
                .transition_info_indices = undefined,
                .infos = &.{},
                .posix = tz,
            };
            return;
        } else |_| {
            // probably wasn't a posix TZ string
            if (options.link_existing) {
                if (self.timezone(override)) |tz| {
                    self.local = tz.*;
                    return;
                }
            }

            if (try self.add_iana(io, override, .{
                .override_search_path = options.tzdata_override_search_path,
                .search_paths = options.tzdata_search_paths,
                .use_windows = true,
                .load_leap_seconds = options.load_leap_seconds,
                .data = null,
            })) |tz| {
                self.local = tz;
                return;
            }
        }
    }

    for (options.search_paths) |path| {
        if (try self.read_current_timezone_link(io, path, options.link_existing)) |tz| {
            self.local = tz;
            return;
        }
    }

    if (builtin.os.tag == .windows) {
        var info_buf: [44]u8 = undefined;
        if (Timezone.windows.current_timezone_info(&info_buf)) |info| {
            if (options.link_existing) {
                if (Timezone.cldr.windows_registry_key_to_iana(info.registry_key, info.region)) |id| {
                    if (self.timezone(id)) |tz| {
                        self.local = tz.*;
                        return;
                    }
                }
            }

            if (Timezone.windows.timezone(self.gpa, self.arena, "", info.registry_key)) |maybe_tz| {
                if (maybe_tz) |tz| {
                    self.local = tz;
                    return;
                }
            } else |err| {
                log.warn("Failed to read current windows timezone: {s}", .{ @errorName(err) });
            }
        } else |err| {
            log.warn("Failed to read current windows timezone: {s}", .{ @errorName(err) });
        }
    }

    // alas, we couldn't figure it out, so just use UTC:
    self.local = .utc;
}

fn read_current_timezone_link(self: *TZDB, io: std.Io, path: []const u8, link_existing: bool) std.mem.Allocator.Error!?Timezone {
    if (link_existing) {
        var link_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
        if (std.Io.Dir.cwd().readLink(io, path, &link_buf)) |link_len| {
            const link = link_buf[0..link_len];
            if (self.timezone(std.Io.Dir.path.basename(link))) |tz| {
                return tz.*;
            }
        } else |err| switch (err) {
            error.NotLink, error.FileNotFound => {},
            else => |e| {
                log.warn("Failed to read current timezone link {s}: {s}", .{ path, @errorName(e) });
            },
        }
    }

    if (try self.load_iana(io, ".", path, "", false)) |tz| {
        return tz;
    }

    return null;
}

pub const common_zoneinfo_locations = switch (builtin.os.tag) {
    .windows => common_zoneinfo_locations_windows,
    else => common_zoneinfo_locations_posix,
};
const common_zoneinfo_locations_windows = [_][]const u8 {};
const common_zoneinfo_locations_posix = [_][]const u8 {
    "/usr/share/zoneinfo",
    "/usr/share/lib/zoneinfo",
    "/etc/zoneinfo",
    "/usr/lib/locale/TZ",
    "/share/zoneinfo",
    "/var/db/zoneinfo",
};

const TZDB = @This();

const log = std.log.scoped(.tempora);

const Date_Time = @import("Date_Time.zig");
const Date = @import("Date.zig");
const Timezone = @import("Timezone.zig");
const builtin = @import("builtin");
const std = @import("std");
