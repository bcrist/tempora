pub const parse_tzif = @import("tzdb/parse_tzif.zig");

var cache: ?Cache = null;
const Cache = struct {
    mutex: std.Thread.Mutex = .{},
    current: ?*const Timezone = null,

    arena: std.heap.ArenaAllocator,
    designation_offsets: std.StringArrayHashMapUnmanaged(i32),
    db: std.StringArrayHashMapUnmanaged([]const u8),

    gpa: std.mem.Allocator,
    cache: std.StringHashMapUnmanaged(*const Timezone),
    temp: std.ArrayList(u8),
};

pub fn init_cache(gpa: std.mem.Allocator) !void {
    std.debug.assert(cache == null);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const aa = arena.allocator();

    var designation_offsets = try data.designations(aa);
    errdefer designation_offsets.deinit(aa);

    var db = try data.db(aa);
    errdefer db.deinit(aa);

    cache = .{
        .gpa = gpa,
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

pub fn timezone(id: []const u8) !?*const Timezone {
    if (cache) |*c| {
        c.mutex.lock();
        defer c.mutex.unlock();

        return timezone_from_cache(id, c);
    } else return error.TzdbCacheNotInitialized; // call tempora.tzdb.init_cache(allocator) once during program initialization
}

fn timezone_from_cache(id: []const u8, c: *Cache) !?*const Timezone {
    if (c.cache.get(id)) |tz| {
        return tz;
    }

    if (c.db.getEntry(id)) |entry| {
        var reader = std.io.Reader.fixed(entry.value_ptr.*);
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

test "timezone" {
    // TODO diagnose leak when using std.testing.allocator for tz cache
    try init_cache(std.heap.smp_allocator);
    defer deinit_cache();

    const ct = (try timezone("America/Chicago")).?;
    try expectEqualStrings("America/Chicago", ct.id);
    try expect(ct.zones.len > 1);
    try expectEqualStrings("CST", ct.posix_tz.?.std_designation);
    try expectEqualStrings("CDT", ct.posix_tz.?.dst_designation.?);

    const utc = (try timezone("UTC")).?;
    try expectEqualStrings("UTC", utc.id);
    try expectEqualStrings("UTC", utc.posix_tz.?.std_designation);
    try expect(utc.posix_tz.?.dst_designation == null);
}

pub const current_timezone_id = current.current_timezone_id;

pub fn current_timezone() !?*const Timezone {
    if (cache) |*c| {
        c.mutex.lock();
        defer c.mutex.unlock();

        if (c.current) |tz| return tz;
        const id = try current_timezone_id();
        const tz = try timezone_from_cache(id, c);
        c.current = tz;
        return tz;
    } else return error.TzdbCacheNotInitialized; // call tempora.tzdb.init_cache(allocator) once during program initialization
}

test "current_timezone" {
    try init_cache(std.testing.allocator);
    defer deinit_cache();

    var current_tz_id: []const u8 = undefined;
    current_tz_id = try current_timezone_id();
    try expect(current_tz_id.len > 0);
    //try expectEqualStrings("America/New_York", current_tz_id);
    //try expectEqualStrings("America/Chicago", current_tz_id);
    //try expectEqualStrings("America/Denver", current_tz_id);
    //try expectEqualStrings("America/Los_Angeles", current_tz_id);

    try expect(null != try current_timezone());
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
    try init_cache(std.testing.allocator);
    defer deinit_cache();

    try expectEqual(-6 * 60 * 60 * 1000, (try designation_offset_ms("CST")).?);
    try expectEqual(1 * 60 * 60 * 1000, (try designation_offset_ms("BST")).?);
    try expectEqual(13 * 60 * 60 * 1000, (try designation_offset_ms("NZDT")).?);
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const current = @import("tzdb/current.zig");
const data = @import("tzdb/data.zig");

const Timezone = @import("Timezone.zig");
const std = @import("std");
