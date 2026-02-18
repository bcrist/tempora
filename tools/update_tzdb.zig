
pub fn main(init: std.process.Init) !void {
    const aa = init.arena.allocator();

    const Sha256 = std.crypto.hash.sha2.Sha256;
    const Digest = [Sha256.digest_length]u8;

    var id_to_digest: std.StringHashMapUnmanaged(Digest) = .empty;
    defer id_to_digest.deinit(init.gpa);

    var digest_to_data: std.AutoHashMapUnmanaged(Digest, []const u8) = .empty;
    defer digest_to_data.deinit(init.gpa);

    var designation_to_offset: std.StringHashMapUnmanaged(i32) = .empty;
    defer designation_to_offset.deinit(init.gpa);

    const designation_override_kvs = .{
        .{ "LMT", null }, // "Local mean time" - not a standard designation
        .{ "CMT", null },
        .{ "PMT", null },
        .{ "SMT", null },
        .{ "BMT", null },
        .{ "RMT", null },
        .{ "NWT", null },
        .{ "KMT", null },
        .{ "KDT", null },
        .{ "APT", null },
        .{ "AWT", null },
        .{ "IMT", null },
        .{ "HST", -10 * 60 * 60 }, // Hawaii-Aleutian Standard Time
        .{ "HDT", -9 * 60 * 60 }, // Hawaii-Aleutian Standard Time
        .{ "PST", -8 * 60 * 60 }, // Pacific Standard Time
        .{ "PDT", -7 * 60 * 60 }, // Pacific Daylight Time
        .{ "MST", -7 * 60 * 60 }, // Mountain Standard Time
        .{ "MDT", -6 * 60 * 60 }, // Mountain Daylight Time
        .{ "CST", -6 * 60 * 60 }, // Central Standard Time
        .{ "CDT", -5 * 60 * 60 }, // Central Daylight Time
        .{ "EST", -5 * 60 * 60 }, // Eastern Standard Time
        .{ "EDT", -4 * 60 * 60 }, // Eastern Daylight Time
        .{ "AST", -4 * 60 * 60 }, // Atlantic Standard Time
        .{ "ADT", -3 * 60 * 60 }, // Atlantic Daylight Time
        .{ "NST", -(3 * 60 + 30) * 60 }, // Newfoundland Standard Time
        .{ "NDT", -(2 * 60 + 30) * 60 }, // Newfoundland Daylight Time
        .{ "BST", 1 * 60 * 60 }, // British Summer Time
        .{ "SAST", 2 * 60 * 60 }, // South African Standard Time
        .{ "MSK", 3 * 60 * 60 }, // Moscow Time
        .{ "AMT", 4 * 60 * 60 }, // Armenia Time
        .{ "HMT", 5 * 60 * 60 }, // Heard and McDonald Islands Time
        .{ "TMT", 5 * 60 * 60 }, // Turkmenistan Time
        .{ "IST", (5 * 60 + 30) * 60 }, // Indian Standard Time
        .{ "NPT", (5 * 60 + 45) * 60 }, // Nepal Time
        .{ "MMT", (6 * 60 + 30) * 60 }, // Myanmar Standard Time
        .{ "KST", 9 * 60 * 60 }, // Korea Standard Time
        .{ "ACST", (9 * 60 + 30) * 60 }, // Australian Central Standard Time
        .{ "NZST", 12 * 60 * 60 }, // New Zealand Standard Time
    };

    const designation_overrides = std.StaticStringMap(?i32).initComptime(designation_override_kvs);

    const ignored_zones = std.StaticStringMap(void).initComptime(.{
        .{ "localtime", {} },
        .{ "leapseconds", {} },
        .{ "posixrules", {} },
        .{ "Zulu", .{} },
        .{ "UCT", .{} },
        .{ "Universal", .{} },
        .{ "CET", {} },
        .{ "CST6CDT", {} },
        .{ "EET", {} },
        .{ "EST", {} },
        .{ "EST5EDT", {} },
        .{ "Cuba", {} },
        .{ "Egypt", {} },
        .{ "Eire", {} },
        .{ "Factory", .{} },
        .{ "GB", {} },
        .{ "GB-Eire", {} },
        .{ "Greenwich", {} },
        .{ "HST", {} },
        .{ "Hongkong", {} },
        .{ "Iceland", {} },
        .{ "Iran", {} },
        .{ "Israel", {} },
        .{ "Jamaica", {} },
        .{ "Japan", {} },
        .{ "Kwajalein", {} },
        .{ "Libya", {} },
        .{ "MET", {} },
        .{ "MST", {} },
        .{ "MST7MDT", {} },
        .{ "NZ", {} },
        .{ "NZ-CHAT", {} },
        .{ "Navajo", {} },
        .{ "PRC", {} },
        .{ "PST8PDT", {} },
        .{ "Poland", {} },
        .{ "Portugal", {} },
        .{ "ROC", {} },
        .{ "ROK", {} },
        .{ "Singapore", {} },
        .{ "Turkey", {} },
        .{ "W-SU", {} },
        .{ "WET", {} },
    });

    const zoneinfo: std.Io.Dir = for (tempora.tzdb.common_tzdata_locations) |tzdata_root| {
        break std.Io.Dir.openDirAbsolute(init.io, tzdata_root, .{ .iterate = true }) catch continue;
    } else return error.ZoneinfoNotFound;

    var walker = try zoneinfo.walk(init.gpa);
    defer walker.deinit();

    while (try walker.next(init.io)) |entry| {
        if (entry.kind == .file or entry.kind == .sym_link) {
            if (std.mem.startsWith(u8, entry.path, "right/")) continue;
            if (std.mem.startsWith(u8, entry.path, "posix/")) continue;
            if (std.mem.startsWith(u8, entry.path, "GMT")) continue;
            if (std.fs.path.extension(entry.path).len > 0) continue;
            if (ignored_zones.has(entry.path)) continue;

            //std.log.info("{s}", .{ entry.path });
            const id = try aa.dupe(u8, entry.path);
            const stat = try zoneinfo.statFile(init.io, id, .{ .follow_symlinks = true });

            const data = try zoneinfo.readFileAllocOptions(init.io, id, aa, .limited(1_000_000), .@"1", null);

            var compressed = try std.Io.Writer.Allocating.initCapacity(aa, (stat.size / 2) * 3);
            var buf: [flate.max_window_len]u8 = undefined;
            var compressor = try flate.Compress.init(&compressed.writer, &buf, .zlib, .best);
            try compressor.writer.writeAll(data);
            try compressor.writer.flush();
            const compressed_data = compressed.written();

            var digest: Digest = undefined;
            Sha256.hash(compressed_data, &digest, .{});

            const tz = try tempora.tzdb.parse_tzif.parse_memory(aa, data);

            for (tz.zones) |zi| {
                if (zi.designation.len == 0) continue;
                if (std.mem.startsWith(u8, zi.designation, "+")) continue;
                if (std.mem.startsWith(u8, zi.designation, "-")) continue;
                if (designation_overrides.get(zi.designation)) |_| continue;

                const result = try designation_to_offset.getOrPut(init.gpa, zi.designation);
                if (result.found_existing) {
                    if (result.value_ptr.* != zi.offset) {
                        std.log.warn("Multiple offsets found for designation {s}: first saw {}, now {}", .{
                            zi.designation,
                            result.value_ptr.*,
                            zi.offset,
                        });
                    }
                } else {
                    result.key_ptr.* = try aa.dupe(u8, zi.designation);
                    result.value_ptr.* = zi.offset;
                }
            }

            try id_to_digest.put(init.gpa, id, digest);
            try digest_to_data.put(init.gpa, digest, compressed_data);
        }
    }

    inline for (designation_override_kvs) |entry| {
        if (@typeInfo(@TypeOf(entry[1])) != .null) {
            try designation_to_offset.putNoClobber(init.gpa, entry[0], entry[1]);
        }
    }

    try id_to_digest.put(init.gpa, "GMT", id_to_digest.get("Etc/GMT").?);

    for (0..13) |neg_utc_offset| {
        var buf1: [32]u8 = undefined;
        var buf2: [32]u8 = undefined;
        const src_id = try std.fmt.bufPrint(&buf1, "Etc/GMT+{}", .{ neg_utc_offset });
        const dest_id = try std.fmt.bufPrint(&buf2, "GMT-{}", .{ neg_utc_offset });
        const duped = try aa.dupe(u8, dest_id);
        try id_to_digest.put(init.gpa, duped, id_to_digest.get(src_id).?);
    }

    for (0..15) |utc_offset| {
        var buf1: [32]u8 = undefined;
        var buf2: [32]u8 = undefined;
        const src_id = try std.fmt.bufPrint(&buf1, "Etc/GMT-{}", .{ utc_offset });
        const dest_id = try std.fmt.bufPrint(&buf2, "GMT+{}", .{ utc_offset });
        const duped = try aa.dupe(u8, dest_id);
        try id_to_digest.put(init.gpa, duped, id_to_digest.get(src_id).?);
    }

    const sorted_designations: [][]const u8 = try aa.alloc([]const u8, designation_to_offset.count());
    {
        var iter = designation_to_offset.keyIterator();
        var i: usize = 0;
        while (iter.next()) |designation| {
            sorted_designations[i] = designation.*;
            i += 1;
        }

        std.sort.block([]const u8, sorted_designations, {}, sort_string);
    }

    const sorted_ids: [][]const u8 = try aa.alloc([]const u8, id_to_digest.count());
    {
        var iter = id_to_digest.keyIterator();
        var i: usize = 0;
        while (iter.next()) |id| {
            sorted_ids[i] = id.*;
            i += 1;
        }

        std.sort.block([]const u8, sorted_ids, {}, sort_string);
    }


    const data_dir = try std.Io.Dir.cwd().openDir(init.io, "src/tzdb/data", .{ .iterate = true });
    var data_walker = try data_dir.walk(init.gpa);
    defer data_walker.deinit();
    while (try data_walker.next(init.io)) |entry| {
        if (entry.kind == .file) {
            try data_dir.deleteFile(init.io, entry.path);
        }
    }

    var file = try std.Io.Dir.cwd().createFile(init.io, "src/tzdb/data.zig", .{});
    defer file.close(init.io);
    var buf: [16384]u8 = undefined;
    var file_writer = file.writer(init.io, &buf);
    var writer = &file_writer.interface;

    try writer.writeAll(
        \\pub const ids = [_][]const u8 {
        \\    
    );

    var col: usize = 0;
    for (sorted_ids) |id| {
        if (col > 0) {
            try writer.writeAll(", ");
            col += 2;
        }
        if (col + id.len + 2 >= 110) {
            try writer.writeAll("\n    ");
            col = 4;
        }
        try writer.print("\"{f}\"", .{ std.zig.fmtString(id) });
        col += id.len + 2;
    }

    try writer.writeAll(
        \\
        \\};
        \\
        \\pub fn designations(allocator: std.mem.Allocator) !std.StringArrayHashMapUnmanaged(i32) {
        \\    var m: std.StringArrayHashMapUnmanaged(i32) = .empty;
        \\    errdefer m.deinit(allocator);
        \\    try m.ensureUnusedCapacity(allocator, 
    );
    try writer.print("{}", .{ sorted_designations.len });
    try writer.writeAll(
        \\);
        \\
    );

    for (sorted_designations) |designation| {
        try writer.print("    m.putAssumeCapacityNoClobber(\"{f}\", {});\n", .{
            std.zig.fmtString(designation),
            designation_to_offset.get(designation).?,
        });
    }

    try writer.writeAll(
        \\    return m;
        \\}
        \\
        \\pub fn db(allocator: std.mem.Allocator) !std.StringArrayHashMapUnmanaged([]const u8) {
        \\    var m: std.StringArrayHashMapUnmanaged([]const u8) = .empty;
        \\    errdefer m.deinit(allocator);
        \\    try m.ensureUnusedCapacity(allocator, 
    );
    try writer.print("{}", .{ sorted_ids.len });
    try writer.writeAll(
        \\);
        \\
    );

    for (sorted_ids) |id| {
        const digest = id_to_digest.get(id).?;
        try writer.print("    m.putAssumeCapacityNoClobber(\"{f}\", data._{x});\n", .{
            std.zig.fmtString(id),
            &digest,
        });
    }

    try writer.writeAll(
        \\    return m;
        \\}
        \\
        \\const data = struct {
        \\
    );


    var total_size: usize = 0;
    {
        var iter = digest_to_data.iterator();
        while (iter.next()) |entry| {
            const digest = entry.key_ptr.*;
            const compressed_data = entry.value_ptr.*;
            var hex_buf: [digest.len*2]u8 = undefined;
            const hex = try std.fmt.bufPrint(&hex_buf, "{x}", .{ &digest });

            var dir = try data_dir.createDirPathOpen(init.io, hex[0..1], .{});
            defer dir.close(init.io);

            try dir.writeFile(init.io, .{
                .sub_path = hex,
                .data = compressed_data,
            });

            total_size += compressed_data.len;

            try writer.print("    pub const _{s} = @embedFile(\"data/{s}/{s}\");\n", .{
                hex,
                hex[0..1],
                hex,
            });
        }
    }

    try writer.writeAll(
        \\};
        \\
        \\const std = @import("std");
        \\
    );

    try writer.flush();

    std.log.info("Found {} designations, {} unique files ({} bytes compressed) and {} ids", .{
        designation_to_offset.count(),
        digest_to_data.count(),
        total_size,
        id_to_digest.count(),
    });
}

fn sort_string(_: void, left: []const u8, right: []const u8) bool {
    return std.mem.lessThan(u8, left, right);
}

const flate = @import("flate.zig");
const tempora = @import("tempora");
const std = @import("std");
