test "current timezone (system)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_current(std.testing.io, .system(null));


    try std.testing.expect(db.local.infos.len > 0);
}

test "current timezone (link, override)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.africa, &.embedded);
    try db.add_current(std.testing.io, .{
        .override = "Africa/Cairo",
        .search_paths = &.{},
        .tzdata_override_search_path = null,
        .tzdata_search_paths = &.{},
        .link_existing = true,
    });

    try std.testing.expectEqualStrings("Africa/Cairo", db.local.id);
}

const Date = tempora.Date;
const Timezone = tempora.Timezone;
const TZDB = tempora.TZDB;
const tempora = @import("tempora");
const std = @import("std");
