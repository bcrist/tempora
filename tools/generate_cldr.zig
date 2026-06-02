const Mapping = struct {
    region: []const u8,
    iana_ids: []const u8,
};

pub fn main(init: std.process.Init) !void {
    var args_iter = try init.minimal.args.iterateAllocator(init.gpa);
    defer args_iter.deinit();

    _ = args_iter.next(); // exe
    const cldr_zig_path = args_iter.next() orelse return error.ExpectedCldrZigPath;
    const windowszones_xml_path = args_iter.next() orelse return error.ExpectedWindowsZonesXmlPath;

    var mappings: std.array_hash_map.String(std.ArrayList(Mapping)) = .empty;
    defer mappings.deinit(init.gpa);
    defer for (mappings.values()) |*list| {
        list.deinit(init.gpa);
    };

    const registry_version = try load_mappings(init.io, init.arena.allocator(), init.gpa, windowszones_xml_path, &mappings);

    var reverse_mappings: std.array_hash_map.String([]const u8) = .empty;
    defer reverse_mappings.deinit(init.gpa);

    for (mappings.keys(), mappings.values()) |key, key_mappings| {
        for (key_mappings.items) |mapping| {
            var iter = std.mem.tokenizeScalar(u8, mapping.iana_ids, ' ');
            while (iter.next()) |iana_id| {
                try reverse_mappings.put(init.gpa, iana_id, key);
            }
        }
    }

    var output_file_atomic = try std.Io.Dir.cwd().createFileAtomic(init.io, cldr_zig_path, .{ .replace = true });
    defer output_file_atomic.deinit(init.io);

    var out_buf: [4096]u8 = undefined;
    var out_writer = output_file_atomic.file.writer(init.io, &out_buf);
    const out = &out_writer.interface;

    try out.writeAll(
        \\//! This file is generated based on information from the Unicode Common Locale Data Repository:
        \\//! https://github.com/unicode-org/cldr/blob/main/common/supplemental/windowsZones.xml
        \\
        \\
    );
    try out.print("pub const registry_version = \"{f}\";\n", .{ std.zig.fmtString(registry_version) });
    try out.writeAll(
        \\
        \\pub fn windows_registry_key_to_iana(key: []const u8, region: []const u8) ?[]const u8 {
        \\    if (key.len == 0) return null;
        \\    switch (key[0] | 0x20) {
    );

    var keys_handled: usize = 0;
    for ('a' .. 'z' + 1) |first_char| {
        var first_key_for_letter = true;
        for (mappings.keys(), mappings.values()) |key, key_mappings| {
            if (key.len == 0 or (key[0] | 0x20) != first_char) continue;
            keys_handled += 1;

            if (first_key_for_letter) {
                first_key_for_letter = false;
                try out.print(
                    \\
                    \\        '{c}' => {{
                    , .{ @as(u8, @intCast(first_char)) }
                );
            }

            try out.print(
                \\
                \\            if (std.mem.eql(u8, key, "{f}")) {{
                , .{ std.zig.fmtString(key) }
            );

            var default_mapping: ?Mapping = null;
            for (key_mappings.items) |mapping| {
                if (std.mem.eql(u8, mapping.region, "001")) {
                    default_mapping = mapping;
                } else {
                    var iter = std.mem.tokenizeScalar(u8, mapping.iana_ids, ' ');
                    const first = iter.next().?;
                    if (default_mapping) |default| {
                        var default_iter = std.mem.tokenizeScalar(u8, default.iana_ids, ' ');
                        const default_first = default_iter.next().?;
                        if (std.mem.eql(u8, first, default_first)) continue;
                    }
                    try out.print(
                        \\
                        \\                if (std.mem.eql(u8, region, "{f}")) return "{f}";
                        , .{
                            std.zig.fmtString(mapping.region),
                            std.zig.fmtString(first),
                        }
                    );
                }
            }
            if (default_mapping) |mapping| {
                var iter = std.mem.tokenizeScalar(u8, mapping.iana_ids, ' ');
                const first = iter.next().?;
                try out.print(
                    \\
                    \\                return "{f}";
                    , .{ std.zig.fmtString(first) }
                );
            }

            try out.writeAll(
                \\
                \\            }
            );
        }
        
        if (!first_key_for_letter) {
            try out.writeAll(
                \\
                \\        },
            );
        }
    }

    if (keys_handled != mappings.count()) return error.BadRegistryKeyFound;

    try out.writeAll(
        \\
        \\        else => {},
        \\    }
        \\
        \\    return null;
        \\}
        \\
        \\pub fn windows_registry_key_to_designation(key: []const u8, is_dst: bool) []const u8 {
        \\    return (if (is_dst) dst_designators.get(key) else std_designators.get(key)) orelse "";
        \\}
        \\
        \\const std_designators: std.StaticStringMap([]const u8) = .initComptime(.{
        \\    .{ "Alaskan Standard Time", "AKST" },
        \\    .{ "Aleutian Standard Time", "HST" },
        \\    .{ "Atlantic Standard Time", "AST" },
        \\    .{ "AUS Central Standard Time", "ACST" },
        \\    .{ "AUS Eastern Standard Time", "AEST" },
        \\    .{ "Canada Central Standard Time", "CST" },
        \\    .{ "Cen. Australia Standard Time", "ACST" },
        \\    .{ "Central America Standard Time", "CST" },
        \\    .{ "Central Europe Standard Time", "CET" },
        \\    .{ "Central European Standard Time", "CET" },
        \\    .{ "Central Standard Time (Mexico)", "CST" },
        \\    .{ "Central Standard Time", "CST" },
        \\    .{ "China Standard Time", "CST" },
        \\    .{ "Cuba Standard Time", "CST" },
        \\    .{ "E. Africa Standard Time", "EAT" },
        \\    .{ "E. Australia Standard Time", "AEST" },
        \\    .{ "E. Europe Standard Time", "EET" },
        \\    .{ "Eastern Standard Time (Mexico)", "EST" },
        \\    .{ "Eastern Standard Time", "EST" },
        \\    .{ "Egypt Standard Time", "EET" },
        \\    .{ "FLE Standard Time", "EET" },
        \\    .{ "GMT Standard Time", "WET" },
        \\    .{ "Greenwich Standard Time", "GMT" },
        \\    .{ "GTB Standard Time", "EET" },
        \\    .{ "Haiti Standard Time", "EST" },
        \\    .{ "Hawaiian Standard Time", "HST" },
        \\    .{ "India Standard Time", "IST" },
        \\    .{ "Israel Standard Time", "IST" },
        \\    .{ "Kaliningrad Standard Time", "EET" },
        \\    .{ "Korea Standard Time", "KST" },
        \\    .{ "Libya Standard Time", "EET" },
        \\    .{ "Middle East Standard Time", "EET" },
        \\    .{ "Mountain Standard Time (Mexico)", "MST" },
        \\    .{ "Mountain Standard Time", "MST" },
        \\    .{ "Namibia Standard Time", "CAT" },
        \\    .{ "New Zealand Standard Time", "NZST" },
        \\    .{ "Newfoundland Standard Time", "NST" },
        \\    .{ "North Korea Standard Time", "KST" },
        \\    .{ "Pacific Standard Time (Mexico)", "PST" },
        \\    .{ "Pacific Standard Time", "PST" },
        \\    .{ "Pakistan Standard Time", "PKT" },
        \\    .{ "Romance Standard Time", "CET" },
        \\    .{ "Russian Standard Time", "MSK" },
        \\    .{ "Sao Tome Standard Time", "GMT" },
        \\    .{ "South Africa Standard Time", "SAST" },
        \\    .{ "South Sudan Standard Time", "CAT" },
        \\    .{ "Sudan Standard Time", "CAT" },
        \\    .{ "Taipei Standard Time", "CST" },
        \\    .{ "Tasmania Standard Time", "AEST" },
        \\    .{ "Tokyo Standard Time", "JST" },
        \\    .{ "Turks And Caicos Standard Time", "EST" },
        \\    .{ "US Eastern Standard Time", "EST" },
        \\    .{ "US Mountain Standard Time", "MST" },
        \\    .{ "Volgograd Standard Time", "MSK" },
        \\    .{ "W. Australia Standard Time", "AWST" },
        \\    .{ "W. Central Africa Standard Time", "WAT" },
        \\    .{ "W. Europe Standard Time", "CET" },
        \\    .{ "West Bank Standard Time", "EET" },
        \\    .{ "Yukon Standard Time", "MST" },
        \\});
        \\
        \\const dst_designators: std.StaticStringMap([]const u8) = .initComptime(.{
        \\    .{ "Alaskan Standard Time", "AKDT" },
        \\    .{ "Aleutian Standard Time", "HDT" },
        \\    .{ "Atlantic Standard Time", "ADT" },
        \\    .{ "AUS Eastern Standard Time", "AEDT" },
        \\    .{ "Cen. Australia Standard Time", "ACDT" },
        \\    .{ "Central Europe Standard Time", "CEST" },
        \\    .{ "Central European Standard Time", "CEST" },
        \\    .{ "Central Standard Time", "CDT" },
        \\    .{ "Cuba Standard Time", "CDT" },
        \\    .{ "E. Europe Standard Time", "EEST" },
        \\    .{ "Eastern Standard Time", "EDT" },
        \\    .{ "Egypt Standard Time", "EEST" },
        \\    .{ "FLE Standard Time", "EEST" },
        \\    .{ "GMT Standard Time", "WEST" },
        \\    .{ "GTB Standard Time", "EEST" },
        \\    .{ "Haiti Standard Time", "EDT" },
        \\    .{ "Israel Standard Time", "IDT" },
        \\    .{ "Middle East Standard Time", "EEST" },
        \\    .{ "Mountain Standard Time", "MDT" },
        \\    .{ "New Zealand Standard Time", "NZDT" },
        \\    .{ "Newfoundland Standard Time", "NDT" },
        \\    .{ "Pacific Standard Time (Mexico)", "PDT" },
        \\    .{ "Pacific Standard Time", "PDT" },
        \\    .{ "Romance Standard Time", "CEST" },
        \\    .{ "Tasmania Standard Time", "AEDT" },
        \\    .{ "Turks And Caicos Standard Time", "EDT" },
        \\    .{ "US Eastern Standard Time", "EDT" },
        \\    .{ "W. Europe Standard Time", "CEST" },
        \\    .{ "West Bank Standard Time", "EEST" },
        \\});
        \\
        \\pub const iana_to_windows_registry_key: std.StaticStringMap([]const u8) = .initComptime(.{
    );

    for (reverse_mappings.keys(), reverse_mappings.values()) |iana_id, key| {
        try out.print(
            \\
            \\    .{{ "{f}", "{f}" }},
            , .{
                std.zig.fmtString(iana_id),
                std.zig.fmtString(key),
            }
        );
    }

    try out.writeAll(
        \\
        \\});
        \\
        \\const std = @import("std");
        \\
    );

    try out.flush();
    try output_file_atomic.replace(init.io);
}

fn load_mappings(io: std.Io, arena: std.mem.Allocator, gpa: std.mem.Allocator, path: []const u8, out: *std.array_hash_map.String(std.ArrayList(Mapping))) ![]const u8  {
    var input_file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer input_file.close(io);

    var input_buf: [4096]u8 = undefined;
    var input_reader = input_file.reader(io, &input_buf);

    var doc = try xml.tree.parse(gpa, &input_reader.interface, null);
    defer doc.deinit(gpa);

    var registry_version: []const u8 = "unknown";

    var windows_zones_iter = doc.root().childElementsByName("windowsZones");
    while (windows_zones_iter.next()) |windows_zones_node| {
        var map_timezones_iter = windows_zones_node.childElementsByName("mapTimezones");
        while (map_timezones_iter.next()) |map_timezones_node| {
            if (map_timezones_node.attr("otherVersion")) |version| {
                registry_version = try arena.dupe(u8, version);
            }
            var map_zone_iter = map_timezones_node.childElementsByName("mapZone");
            while (map_zone_iter.next()) |node| {
                if (node.attr("other")) |other| {
                    if (node.attr("type")) |_type| {
                        if (node.attr("territory")) |territory| {
                            const windows_registry_key = try arena.dupe(u8, other);
                            const iana_ids = try arena.dupe(u8, _type);
                            const region = try arena.dupe(u8, territory);

                            const gop = try out.getOrPut(gpa, windows_registry_key);
                            if (!gop.found_existing) {
                                gop.key_ptr.* = windows_registry_key;
                                gop.value_ptr.* = .empty;
                            }

                            try gop.value_ptr.append(gpa, .{
                                .region = region,
                                .iana_ids = iana_ids,
                            });
                        }
                    }
                }
            }
        }
    }

    return registry_version;
}

const log = std.log.scoped(.generate_cldr);

const xml = @import("xml");
const std = @import("std");
