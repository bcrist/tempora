pub const parse_tzif = @import("tzdb/parse_tzif.zig");

pub const common_tzdata_locations: []const []const u8 = &.{
    "/usr/share/zoneinfo",
    "/usr/share/lib/zoneinfo",
    "/etc/zoneinfo",
    "/usr/lib/locale/TZ",
    "/share/zoneinfo",
};

var cache: ?Cache = null;
const Cache = struct {
    current_tz: []const u8,
    tzdata_path: []const u8,
    additional_tzdata_search_paths: []const []const u8,

    mutex: std.Io.Mutex = .init,
    current: ?*const Timezone = null,

    arena: std.heap.ArenaAllocator,
    designation_offsets: std.StringArrayHashMapUnmanaged(i32),
    db: std.StringArrayHashMapUnmanaged([]const u8),

    gpa: std.mem.Allocator,
    cache: std.StringHashMapUnmanaged(*const Timezone),
    temp: std.ArrayList(u8),
};

pub const Init_Options = struct {
    gpa: std.mem.Allocator,
    arena_backing: std.mem.Allocator = std.heap.page_allocator,
    current_tz: []const u8 = "",
    tzdata_path: []const u8 = "",
    additional_tzdata_paths: []const []const u8 = switch (builtin.os.tag) {
        .windows => &.{},
        else => common_tzdata_locations,
    },

    pub fn init(pi: std.process.Init) Init_Options {
        return .{
            .gpa = pi.gpa,
            .current_tz = pi.environ_map.get("TZ") orelse "",
            .tzdata_path = pi.environ_map.get("TZDIR")
                orelse pi.environ_map.get("TZDATA")
                orelse pi.environ_map.get("ZONEINFO")
                orelse "",
        };
    }
};

pub fn init_cache(options: Init_Options) !void {
    std.debug.assert(cache == null);

    var arena = std.heap.ArenaAllocator.init(options.arena_backing);
    const aa = arena.allocator();

    var designation_offsets = try data.designations(aa);
    errdefer designation_offsets.deinit(aa);

    var db = try data.db(aa);
    errdefer db.deinit(aa);

    cache = .{
        .current_tz = options.current_tz,
        .tzdata_path = options.tzdata_path,
        .additional_tzdata_search_paths = options.additional_tzdata_paths,
        .gpa = options.gpa,
        .arena = arena,
        .designation_offsets = designation_offsets,
        .db = db,
        .cache = .empty,
        .temp = .empty,
    };
}

pub fn deinit_cache() void {
    if (cache) |*c| {
        c.arena.deinit();
        c.cache.deinit(c.gpa);
        c.temp.deinit(c.gpa);
        cache = null;
    }
}

pub fn timezone(io: std.Io, id: []const u8) !?*const Timezone {
    if (cache) |*c| {
        try c.mutex.lock(io);
        defer c.mutex.unlock(io);

        return timezone_from_cache(io, id, c);
    } else return error.TzdbCacheNotInitialized; // call tempora.tzdb.init_cache() once during program initialization
}

fn timezone_from_cache(io: std.Io, id: []const u8, c: *Cache) !?*const Timezone {
    if (c.cache.get(id)) |tz| {
        return tz;
    }

    if (c.tzdata_path.len > 0 or c.additional_tzdata_search_paths.len > 0) {
        if (std.mem.indexOf(u8, id, "..") == null) {
            if (c.tzdata_path.len > 0) {
                if (timezone_from_file(io, c.tzdata_path, id, c)) |tz| return tz else |_| {}
            }
            for (c.additional_tzdata_search_paths) |path| {
                if (timezone_from_file(io, path, id, c)) |tz| return tz else |_| {}
            }
        }
    }

    if (c.db.getEntry(id)) |entry| {
        var reader = std.Io.Reader.fixed(entry.value_ptr.*);
        c.temp.clearRetainingCapacity();
        var buf: [std.compress.flate.max_window_len]u8 = undefined;
        var decompressor = std.compress.flate.Decompress.init(&reader, .zlib, &buf);
        try decompressor.reader.appendRemainingUnlimited(c.gpa, &c.temp);
        const tz = try parse_tzif.parse_memory(c.arena.allocator(), c.temp.items);

        const stable_id = entry.key_ptr.*;
        var stable_tz = try c.arena.allocator().create(Timezone);
        stable_tz.* = tz;
        stable_tz.id = stable_id;

        const result = try c.cache.getOrPut(c.gpa, stable_id);
        result.value_ptr.* = stable_tz;
        return stable_tz;
    }

    return null;
}

fn timezone_from_file(io: std.Io, path: []const u8, id: []const u8, c: *Cache) !*const Timezone {
    const dir = try std.Io.Dir.openDirAbsolute(io, path, .{});
    defer dir.close(io);
    return timezone_from_dir_file(io, dir, id, id, c);
}
fn timezone_from_dir_file(io: std.Io, dir: std.Io.Dir, subpath: []const u8, id: []const u8, c: *Cache) !*const Timezone {
    const f = try dir.openFile(io, subpath, .{});
    defer f.close(io);

    var buf: [8192]u8 = undefined;
    var reader = f.reader(io, &buf);

    const tz = try parse_tzif.parse(c.arena.allocator(), &reader.interface);

    var stable_tz = try c.arena.allocator().create(Timezone);
    stable_tz.* = tz;
    stable_tz.id = try c.arena.allocator().dupe(u8, id);

    const result = try c.cache.getOrPut(c.gpa, stable_tz.id);
    result.value_ptr.* = stable_tz;
    return stable_tz;
}

test "timezone" {
    try init_cache(.{
        .gpa = std.testing.allocator,
        .additional_tzdata_paths = &.{},
    });
    defer deinit_cache();

    const ct = (try timezone(std.testing.io, "America/Chicago")).?;
    try expectEqualStrings("America/Chicago", ct.id);
    try expect(ct.zones.len > 1);
    try expectEqualStrings("CST", ct.posix_tz.?.std_designation);
    try expectEqualStrings("CDT", ct.posix_tz.?.dst_designation.?);

    const utc = (try timezone(std.testing.io, "Etc/UTC")).?;
    try expectEqualStrings("Etc/UTC", utc.id);
    try expectEqualStrings("UTC", utc.posix_tz.?.std_designation);
    try expect(utc.posix_tz.?.dst_designation == null);
}

pub fn current_timezone(io: std.Io) !?*const Timezone {
    if (cache) |*c| {
        try c.mutex.lock(io);
        defer c.mutex.unlock(io);

        if (c.current) |tz| return tz;

        if (c.current_tz.len > 0) {
            if (c.current_tz[0] == ':') {
                if (timezone_from_dir_file(io, std.Io.Dir.cwd(), c.current_tz[1..], "(Current)", c)) |tz| {
                    c.current = tz;
                    return tz;
                } else |_| {}
            }
            if (try timezone_from_cache(io, c.current_tz, c)) |tz| {
                c.current = tz;
                return tz;
            }
            if (parse_tzif.parse_posix_tz(c.current_tz)) |posix_tz| {
                var stable_tz = try c.arena.allocator().create(Timezone);
                stable_tz.* = .{
                    .id = "(Current)",
                    .transitions = .empty,
                    .zones = &.{},
                    .posix_tz = posix_tz,
                    .designations = &.{},
                };

                const result = try c.cache.getOrPut(c.gpa, stable_tz.id);
                result.value_ptr.* = stable_tz;
                c.current = stable_tz;
                return stable_tz;
            } else |_| {}
        }

        switch (builtin.os.tag) {
            .windows => {
                const id = try windows.current_timezone_id();
                const tz = try timezone_from_cache(io, id, c);
                c.current = tz;
                return tz;
            },
            else => {
                var buf: [std.fs.max_path_bytes]u8 = undefined;
                const raw_bytes = try std.Io.Dir.cwd().readLink(io, "/etc/localtime", &buf);
                var raw = buf[0..raw_bytes];

                var id = "(Current)";

                if (c.tzdata_path.len > 0 and std.mem.startsWith(u8, raw, c.tzdata_path)) {
                    id = try c.arena.allocator().dupe(u8, raw[c.tzdata_path.len..]);
                } else for (c.additional_tzdata_search_paths) |path| {
                    if (path.len > 0 and std.mem.startsWith(u8, raw, path)) {
                        id = try c.arena.allocator().dupe(u8, raw[path.len..]);
                        break;
                    }
                }

                if (std.mem.startsWith(u8, id, "/")) {
                    id = id[1..];
                }

                const tz = try timezone_from_dir_file(io, std.Io.Dir.cwd(), "/etc/localtime", id, c);
                c.current = tz;
                return tz;
            },
        }

        
    } else return error.TzdbCacheNotInitialized; // call tempora.tzdb.init_cache(allocator) once during program initialization
}

test "current_timezone" {
    try init_cache(.{
        .gpa = std.testing.allocator,
        .additional_tzdata_paths = &.{},
    });
    defer deinit_cache();

    try expect(null != try current_timezone(std.testing.io));
}

pub const ids = data.ids;

pub fn designation_offset_ms(designation: []const u8) !?i32 {
    if (cache) |*c| {
        // designation_offsets is immutable, so we don't grab the mutex for this
        if (c.designation_offsets.get(designation)) |offset_s| {
            return offset_s * 1000;
        } else return null;
    } else return error.TzdbCacheNotInitialized; // call tempora.tzdb.init_cache(allocator) once during program initialization
}

test "designation_offset_ms" {
    try init_cache(.{
        .gpa = std.testing.allocator,
        .additional_tzdata_paths = &.{},
    });
    defer deinit_cache();

    try expectEqual(-6 * 60 * 60 * 1000, (try designation_offset_ms("CST")).?);
    try expectEqual(1 * 60 * 60 * 1000, (try designation_offset_ms("BST")).?);
    try expectEqual(13 * 60 * 60 * 1000, (try designation_offset_ms("NZDT")).?);
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const windows = @import("tzdb/windows.zig");
const data = @import("tzdb/data.zig");

const Timezone = @import("Timezone.zig");

const builtin = @import("builtin");
const std = @import("std");
