
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const aa = arena.allocator();

    var gpa_alloc: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa_alloc.deinit();
    const gpa = gpa_alloc.allocator();

    const Sha256 = std.crypto.hash.sha2.Sha256;
    const Digest = [Sha256.digest_length]u8;

    var id_to_digest = std.StringHashMap(Digest).init(gpa);
    defer id_to_digest.deinit();

    var digest_to_data = std.AutoHashMap(Digest, []const u8).init(gpa);
    defer digest_to_data.deinit();

    var designation_to_offset = std.StringHashMap(i32).init(gpa);
    defer designation_to_offset.deinit();

    const designation_overrides = std.ComptimeStringMap(?i32, .{
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
    });

    const zoneinfo = try std.fs.cwd().openDir("/usr/share/zoneinfo", .{ .iterate = true });
    var walker = try zoneinfo.walk(gpa);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind == .file or entry.kind == .sym_link) {
            if (std.mem.startsWith(u8, entry.path, "right/")) continue;
            if (std.mem.startsWith(u8, entry.path, "posix/")) continue;
            if (std.fs.path.extension(entry.path).len > 0) continue;
            if (std.mem.eql(u8, entry.path, "localtime")) continue;
            if (std.mem.eql(u8, entry.path, "leapseconds")) continue;

            //std.log.info("{s}", .{ entry.path });
            const id = try aa.dupe(u8, entry.path);
            const stat = try zoneinfo.statFile(id);

            const data = try zoneinfo.readFileAllocOptions(aa, id, 1_000_000, stat.size, 1, null);
            var data_stream = std.io.fixedBufferStream(data);

            var compressed = try std.ArrayList(u8).initCapacity(aa, (stat.size / 2) * 3);
            try std.compress.zlib.compress(data_stream.reader(), compressed.writer(), .{ .level = .best });
            const compressed_data = compressed.items;

            var digest: Digest = undefined;
            Sha256.hash(compressed_data, &digest, .{});

            const tz = try tempora.tzdb.parse_tzif.parse_memory(aa, data);

            for (tz.zones) |zi| {
                if (zi.designation.len == 0) continue;
                if (std.mem.startsWith(u8, zi.designation, "+")) continue;
                if (std.mem.startsWith(u8, zi.designation, "-")) continue;
                if (designation_overrides.get(zi.designation)) |_| continue;

                const result = try designation_to_offset.getOrPut(zi.designation);
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

            try id_to_digest.put(id, digest);
            try digest_to_data.put(digest, compressed_data);
        }
    }

    for (designation_overrides.kvs) |entry| {
        if (entry.value) |offset| {
            try designation_to_offset.putNoClobber(entry.key, offset);
        }
    }

    for (1..13) |neg_utc_offset| {
        var buf1: [32]u8 = undefined;
        var buf2: [32]u8 = undefined;
        const src_id = try std.fmt.bufPrint(&buf1, "Etc/GMT+{}", .{ neg_utc_offset });
        const dest_id = try std.fmt.bufPrint(&buf2, "GMT-{}", .{ neg_utc_offset });
        const duped = try aa.dupe(u8, dest_id);
        try id_to_digest.put(duped, id_to_digest.get(src_id).?);
    }

    for (1..15) |utc_offset| {
        var buf1: [32]u8 = undefined;
        var buf2: [32]u8 = undefined;
        const src_id = try std.fmt.bufPrint(&buf1, "Etc/GMT-{}", .{ utc_offset });
        const dest_id = try std.fmt.bufPrint(&buf2, "GMT+{}", .{ utc_offset });
        const duped = try aa.dupe(u8, dest_id);
        try id_to_digest.put(duped, id_to_digest.get(src_id).?);
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


    const data_dir = try std.fs.cwd().openDir("src/tzdb/data", .{ .iterate = true });
    var data_walker = try data_dir.walk(gpa);
    defer data_walker.deinit();
    while (try data_walker.next()) |entry| {
        if (entry.kind == .file) {
            try data_dir.deleteFile(entry.path);
        }
    }

    var file = try std.fs.cwd().createFile("src/tzdb/data.zig", .{});
    defer file.close();
    const writer = file.writer();

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
        try writer.print("\"{}\"", .{ std.zig.fmtEscapes(id) });
        col += id.len + 2;
    }

    try writer.writeAll(
        \\
        \\};
        \\
        \\pub fn designations(allocator: std.mem.Allocator) !std.StringArrayHashMap(i32) {
        \\    var m = std.StringArrayHashMap(i32).init(allocator);
        \\    errdefer m.deinit();
        \\    try m.ensureUnusedCapacity(
    );
    try writer.print("{}", .{ sorted_designations.len });
    try writer.writeAll(
        \\);
        \\
    );

    for (sorted_designations) |designation| {
        try writer.print("    try m.put(\"{}\", {});\n", .{
            std.zig.fmtEscapes(designation),
            designation_to_offset.get(designation).?,
        });
    }

    try writer.writeAll(
        \\    return m;
        \\}
        \\
        \\pub fn db(allocator: std.mem.Allocator) !std.StringArrayHashMap([]const u8) {
        \\    var m = std.StringArrayHashMap([]const u8).init(allocator);
        \\    errdefer m.deinit();
        \\    try m.ensureUnusedCapacity(
    );
    try writer.print("{}", .{ sorted_ids.len });
    try writer.writeAll(
        \\);
        \\
    );

    for (sorted_ids) |id| {
        const digest = id_to_digest.get(id).?;
        var hex_buf: [digest.len*2]u8 = undefined;
        const hex = try std.fmt.bufPrint(&hex_buf, "{s}", .{ std.fmt.fmtSliceHexLower(&digest) });

        try writer.print("    try m.put(\"{}\", data._{s});\n", .{
            std.zig.fmtEscapes(id),
            hex,
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
            const hex = try std.fmt.bufPrint(&hex_buf, "{s}", .{ std.fmt.fmtSliceHexLower(&digest) });

            var dir = try data_dir.makeOpenPath(hex[0..1], .{});
            defer dir.close();
            try dir.writeFile(hex, compressed_data);

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

const tempora = @import("tempora");
const std = @import("std");
