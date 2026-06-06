test "TZDB (embedded)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add(std.testing.io, .{ tempora.tz.america.chicago, tempora.tz.etc.utc }, .embedded);

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("UTC", utc.posix.?.std_designation());
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB (system)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add(std.testing.io, .{ tempora.tz.america.chicago, tempora.tz.etc.utc }, .system(null));

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB (system or embedded)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add(std.testing.io, .{ tempora.tz.america.chicago, tempora.tz.etc.utc }, .system_or_embedded(null));

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB (lazy, embedded)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.all, &.embedded);

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("UTC", utc.posix.?.std_designation());
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB (lazy, system)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.all, &.system(null));

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB (lazy, system or embedded)" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_lazy(tempora.tz.all, &.system_or_embedded(null));

    const ct = db.timezone("America/Chicago").?;
    try std.testing.expectEqualStrings("America/Chicago", ct.id);
    try std.testing.expect(ct.infos.len > 1);
    try std.testing.expectEqualStrings("CST", ct.posix.?.std_designation());
    try std.testing.expectEqualStrings("CDT", ct.posix.?.dst_designation());
    try std.testing.expectEqual(-6 * std.time.s_per_hour, ct.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(-5 * std.time.s_per_hour, ct.posix.?.dst.?.info.utc_offset_seconds);
    
    const utc = db.timezone("Etc/UTC").?;
    try std.testing.expectEqualStrings("Etc/UTC", utc.id);
    try std.testing.expectEqualStrings("", utc.posix.?.dst_designation());
    try std.testing.expectEqual(0, utc.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqual(null, utc.posix.?.dst);
}

test "TZDB.designation_utc_offset_ms" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var db: TZDB = .{
        .lazy_io = std.testing.io,
        .gpa = std.testing.allocator,
        .arena = arena.allocator(),
    };
    defer db.deinit();
    try db.add_designations(tempora.tz.designations.common);

    try std.testing.expect(db.designations.count() > 0);

    const dto = Date.epoch.with_time(.midnight).with_offset(0);

    try std.testing.expectEqual(-6 * 60 * 60 * 1000, db.designation_utc_offset_ms("CST", dto).?);
    try std.testing.expectEqual(1 * 60 * 60 * 1000, db.designation_utc_offset_ms("BST", dto).?);
    try std.testing.expectEqual(13 * 60 * 60 * 1000, db.designation_utc_offset_ms("NZDT", dto).?);
}

test "Timezone.utc" {
    const tz = Timezone.utc;
    try std.testing.expect(tz.posix != null);
    try std.testing.expect(!tz.use_posix_for_old_times);
    try std.testing.expectEqual(0, tz.transition_count);
    try std.testing.expectEqual(0, tz.infos.len);
    try std.testing.expectEqual(0, tz.leap_seconds.len);
    try std.testing.expectEqual(null, tz.posix.?.dst);
    try std.testing.expectEqual(0, tz.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqualStrings("UTC", tz.posix.?.std_designation());
    try std.testing.expectEqual(0, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
}

test "Timezone.tai" {
    const tz = Timezone.tai;
    try std.testing.expect(tz.posix != null);
    try std.testing.expect(!tz.use_posix_for_old_times);
    try std.testing.expectEqual(0, tz.transition_count);
    try std.testing.expectEqual(0, tz.infos.len);
    try std.testing.expect(tz.leap_seconds.len > 0);
    try std.testing.expectEqual(null, tz.posix.?.dst);
    try std.testing.expectEqual(0, tz.posix.?.standard.utc_offset_seconds);
    try std.testing.expectEqualStrings("TAI", tz.posix.?.std_designation());
    try std.testing.expectEqual(32000, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
}

test "Timezone.fixed" {
    {
        const tz = Timezone.fixed(0, 0);
        try std.testing.expect(tz.posix != null);
        try std.testing.expect(!tz.use_posix_for_old_times);
        try std.testing.expectEqual(0, tz.transition_count);
        try std.testing.expectEqual(0, tz.infos.len);
        try std.testing.expectEqual(0, tz.leap_seconds.len);
        try std.testing.expectEqual(null, tz.posix.?.dst);
        try std.testing.expectEqual(0, tz.posix.?.standard.utc_offset_seconds);
        try std.testing.expectEqualStrings("+00", tz.posix.?.std_designation());
        try std.testing.expectEqual(0, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
    }
    {
        const tz = Timezone.fixed(1, 0);
        try std.testing.expect(tz.posix != null);
        try std.testing.expect(!tz.use_posix_for_old_times);
        try std.testing.expectEqual(0, tz.transition_count);
        try std.testing.expectEqual(0, tz.infos.len);
        try std.testing.expectEqual(0, tz.leap_seconds.len);
        try std.testing.expectEqual(null, tz.posix.?.dst);
        try std.testing.expectEqual(3600, tz.posix.?.standard.utc_offset_seconds);
        try std.testing.expectEqualStrings("+01", tz.posix.?.std_designation());
        try std.testing.expectEqual(3600000, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
    }
    {
        const tz = Timezone.fixed(-1, 0);
        try std.testing.expect(tz.posix != null);
        try std.testing.expect(!tz.use_posix_for_old_times);
        try std.testing.expectEqual(0, tz.transition_count);
        try std.testing.expectEqual(0, tz.infos.len);
        try std.testing.expectEqual(0, tz.leap_seconds.len);
        try std.testing.expectEqual(null, tz.posix.?.dst);
        try std.testing.expectEqual(-3600, tz.posix.?.standard.utc_offset_seconds);
        try std.testing.expectEqualStrings("-01", tz.posix.?.std_designation());
        try std.testing.expectEqual(-3600000, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
    }
    {
        const tz = Timezone.fixed(12, 15);
        try std.testing.expect(tz.posix != null);
        try std.testing.expect(!tz.use_posix_for_old_times);
        try std.testing.expectEqual(0, tz.transition_count);
        try std.testing.expectEqual(0, tz.infos.len);
        try std.testing.expectEqual(0, tz.leap_seconds.len);
        try std.testing.expectEqual(null, tz.posix.?.dst);
        try std.testing.expectEqual(44100, tz.posix.?.standard.utc_offset_seconds);
        try std.testing.expectEqualStrings("+12:15", tz.posix.?.std_designation());
        try std.testing.expectEqual(44100000, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
    }
    {
        const tz = Timezone.fixed(-6, 15);
        try std.testing.expect(tz.posix != null);
        try std.testing.expect(!tz.use_posix_for_old_times);
        try std.testing.expectEqual(0, tz.transition_count);
        try std.testing.expectEqual(0, tz.infos.len);
        try std.testing.expectEqual(0, tz.leap_seconds.len);
        try std.testing.expectEqual(null, tz.posix.?.dst);
        try std.testing.expectEqual(-22500, tz.posix.?.standard.utc_offset_seconds);
        try std.testing.expectEqualStrings("-06:15", tz.posix.?.std_designation());
        try std.testing.expectEqual(-22500000, tz.utc_offset_ms(Date.epoch.with_time(.noon).with_offset(0).timestamp_ms()));
    }
}

const Date = tempora.Date;
const Timezone = tempora.Timezone;
const TZDB = tempora.TZDB;
const tempora = @import("tempora");
const std = @import("std");
