//! This is a reimplementation of zic.c from the tzcode repository
//! which outputs data directly into a generated `tzdata.zig` file.
//! 
//! Note that unnecessary zic features and validation have been removed;
//! it is designed to work only with well-formed official tzdata releases.

/// If compressing the tzif data for a zone doesn't save at least this many bytes, it will be embedded as-is.
/// Setting this to a higher number may reduce TZDB initialization time, but at a cost of increased binary size.
const min_deflate_bytes_saved: usize = build_options.min_deflate_bytes_saved;

const designations_common: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "HST", "America/Adak" },
    .{ "HDT", "America/Adak" },
    .{ "AKST", "America/Anchorage" },
    .{ "AKDT", "America/Anchorage" },
    .{ "PST", "America/Los_Angeles" },
    .{ "PDT", "America/Los_Angeles" },
    .{ "MST", "America/Denver" },
    .{ "MDT", "America/Denver" },
    .{ "CST", "America/Chicago" },
    .{ "CDT", "America/Chicago" },
    .{ "EST", "America/New_York" },
    .{ "EDT", "America/New_York" },
    .{ "AST", "America/Halifax" },
    .{ "ADT", "America/Halifax" },
    .{ "NST", "America/St_Johns" },
    .{ "NDT", "America/St_Johns" },
    .{ "BST", "Europe/London" },
    .{ "WET", "Europe/Lisbon" },
    .{ "WEST", "Europe/Lisbon" },
    .{ "CET", "Europe/Berlin" },
    .{ "CEST", "Europe/Berlin" },
    .{ "EET", "Europe/Bucharest" },
    .{ "EEST", "Europe/Bucharest" },
    .{ "MSK", "Europe/Moscow" },
    .{ "PKT", "Asia/Karachi" },
    .{ "WAT", "Africa/Lagos" },
    .{ "CAT", "Africa/Maputo" },
    .{ "SAST", "Africa/Johannesburg" },
    .{ "EAT", "Africa/Nairobi" },
    .{ "KST", "Asia/Seoul" },
    .{ "JST", "Asia/Tokyo" },
    .{ "AWST", "Australia/Perth" },
    .{ "AWDT", "Australia/Perth" },
    .{ "ACST", "Australia/Adelaide" },
    .{ "ACDT", "Australia/Adelaide" },
    .{ "AEST", "Australia/Sydney" },
    .{ "AEDT", "Australia/Sydney" },
    .{ "NZST", "Pacific/Auckland" },
    .{ "NZDT", "Pacific/Auckland" },
    .{ "SST", "Pacific/Pago_Pago" },
});

const designations_north_america: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "HST", "America/Adak" },
    .{ "HDT", "America/Adak" },

    .{ "AKST", "America/Anchorage" },
    .{ "AKDT", "America/Anchorage" },

    .{ "PST", "America/Los_Angeles" },
    .{ "PDT", "America/Los_Angeles" },

    .{ "MST", "America/Denver" },
    .{ "MDT", "America/Denver" },

    .{ "CST", "America/Chicago" },
    .{ "CDT", "America/Chicago" },

    .{ "EST", "America/New_York" },
    .{ "EDT", "America/New_York" },

    .{ "AST", "America/Halifax" },
    .{ "ADT", "America/Halifax" },

    .{ "NST", "America/St_Johns" },
    .{ "NDT", "America/St_Johns" },
});

const designations_cuba: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "CST", "America/Havana" },
    .{ "CDT", "America/Havana" },
});

const designations_africa: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "CET", "Africa/Algiers" },

    .{ "WAT", "Africa/Lagos" },

    .{ "CAT", "Africa/Maputo" },

    .{ "SAST", "Africa/Johannesburg" },

    .{ "EAT", "Africa/Nairobi" },

    .{ "EET", "Africa/Cairo" },
    .{ "EEST", "Africa/Cairo" },
});

const designations_europe: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "BST", "Europe/London" },
    .{ "IST", "Europe/Dublin" },

    .{ "WET", "Europe/Lisbon" },
    .{ "WEST", "Europe/Lisbon" },

    .{ "CET", "Europe/Berlin" },
    .{ "CEST", "Europe/Berlin" },

    .{ "EET", "Europe/Bucharest" },
    .{ "EEST", "Europe/Bucharest" },

    .{ "MSK", "Europe/Moscow" },
});

const designations_middle_east: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "EET", "Asia/Beirut" },
    .{ "EEST", "Asia/Beirut" },

    .{ "IST", "Asia/Jerusalem" },
    .{ "IDT", "Asia/Jerusalem" },

    .{ "PKT", "Asia/Karachi" },
});

const designations_asia: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "PKT", "Asia/Karachi" },

    .{ "CST", "Asia/Shanghai" },
    .{ "CDT", "Asia/Shanghai" },

    .{ "IST", "Asia/Kolkata" },

    .{ "KST", "Asia/Seoul" },

    .{ "JST", "Asia/Tokyo" },
});

const designations_oceania: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "GMT", "Etc/GMT" },
    .{ "UTC", "Etc/UTC" },
    .{ "Z", "" },

    .{ "AWST", "Australia/Perth" },
    .{ "AWDT", "Australia/Perth" },

    .{ "ACST", "Australia/Adelaide" },
    .{ "ACDT", "Australia/Adelaide" },

    .{ "AEST", "Australia/Sydney" },
    .{ "AEDT", "Australia/Sydney" },

    .{ "NZST", "Pacific/Auckland" },
    .{ "NZDT", "Pacific/Auckland" },

    .{ "SST", "Pacific/Pago_Pago" },

    .{ "HST", "America/Adak" },
    .{ "HDT", "America/Adak" },
});

pub fn main(init: std.process.Init) !void {
    var file_buf: [16384]u8 = undefined;
    var cwd = std.Io.Dir.cwd();

    var args_iter = try init.minimal.args.iterateAllocator(init.arena.allocator());
    _ = args_iter.next(); // exe
    const data_zig_path = args_iter.next() orelse return error.ExpectedDataZigPath;

    var db: DB = .init(init.gpa, init.arena.allocator());
    defer db.deinit();

    var version: []const u8 = "unknown";

    while (args_iter.next()) |input_path| {
        errdefer log.info("Input file: {s}", .{ std.Io.Dir.path.basename(input_path) });
        var f = try cwd.openFile(init.io, input_path, .{});
        defer f.close(init.io);
        var r = f.reader(init.io, &file_buf);

        if (std.mem.eql(u8, std.Io.Dir.path.basename(input_path), "version")) {
            if (try r.interface.takeDelimiter('\n')) |line| {
                version = try init.arena.allocator().dupe(u8, std.mem.trim(u8, line, &std.ascii.whitespace));
            }
        } else {
            try parse_tzdata(init.arena.allocator(), init.gpa, &r.interface, &db);
        }
    }

    try db.compile();

    var data_zig_file = try cwd.createFile(init.io, data_zig_path, .{});
    defer data_zig_file.close(init.io);
    var data_zig_writer = data_zig_file.writer(init.io, &file_buf);
    const w: *std.Io.Writer = &data_zig_writer.interface;

    try w.print(
        \\//! This file is generated based on information from the IANA tzdata repository:
        \\//! https://www.iana.org/time-zones/repository/tzdata-latest.tar.gz
        \\
        \\pub const version = "{f}";
        \\
        , .{ std.zig.fmtString(version) }
    );

    try db.write_zig(w);

    try w.writeAll(
        \\
        \\pub const designations = struct {
        \\    pub const nato = struct {
    );
    try w.print("\n        pub const {c} = {};", .{ 'A', 1 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'B', 2 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'C', 3 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'D', 4 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'E', 5 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'F', 6 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'G', 7 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'H', 8 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'I', 9 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'K', 10 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'L', 11 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'M', 12 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'N', -1 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'O', -2 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'P', -3 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'Q', -4 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'R', -5 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'S', -6 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'T', -7 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'U', -8 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'V', -9 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'W', -10 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'X', -11 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'Y', -12 * std.time.s_per_hour });
    try w.print("\n        pub const {c} = {};", .{ 'Z', 0 });
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const common = struct {
    );
    try db.write_designation_offsets_zig(designations_common, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const north_america = struct {
    );
    try db.write_designation_offsets_zig(designations_north_america, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const cuba = struct {
    );
    try db.write_designation_offsets_zig(designations_cuba, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const africa = struct {
    );
    try db.write_designation_offsets_zig(designations_africa, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const europe = struct {
    );
    try db.write_designation_offsets_zig(designations_europe, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const middle_east = struct {
    );
    try db.write_designation_offsets_zig(designations_middle_east, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const asia = struct {
    );
    try db.write_designation_offsets_zig(designations_asia, w);
    try w.writeAll(
        \\
        \\    };
        \\
        \\    pub const oceania = struct {
    );
    try db.write_designation_offsets_zig(designations_oceania, w);
    try w.writeAll(
        \\
        \\    };
        \\};
        \\
        \\const tzdata = @This();
        \\
        \\const TZIF_Data = @import("TZIF_Data.zig");
        \\const Leap_Second = @import("Leap_Second.zig");
        \\
    );

    try w.flush();
}

fn parse_tzdata(arena: std.mem.Allocator, gpa: std.mem.Allocator, reader: *std.Io.Reader, db: *DB) !void {
    var line_number: usize = 1;
    var maybe_current_zone_name: ?[]const u8 = null;
    var found_leap = false;
    while (true) {
        defer line_number += 1;
        var raw_line = try reader.takeDelimiter('\n') orelse return;
        if (found_leap and std.mem.startsWith(u8, raw_line, "#Expires")) raw_line = raw_line[1..];

        const start_of_comment = std.mem.findScalar(u8, raw_line, '#') orelse raw_line.len;
        const trimmed_line = std.mem.trim(u8, raw_line[0..start_of_comment], &std.ascii.whitespace);

        if (trimmed_line.len == 0) continue;

        errdefer log.info("L{}: {s}", .{ line_number, trimmed_line });

        var field_iter = std.mem.tokenizeAny(u8, trimmed_line, &std.ascii.whitespace);

        if (maybe_current_zone_name) |zone_name| {
            const zone = try Zone.parse_continuation(arena, zone_name, &field_iter);
            try db.zones.getPtr(zone_name).?.append(gpa, zone);
            if (zone.until == null) {
                maybe_current_zone_name = null;
            }
        } else {
            const first = field_iter.next().?;
            if (std.mem.eql(u8, first, "Rule")) {
                const rule = try Rule.parse(arena, &field_iter);
                const gop = try db.rules.getOrPut(gpa, rule.name);
                if (!gop.found_existing) {
                    gop.key_ptr.* = rule.name;
                    gop.value_ptr.* = .empty;
                }
                try gop.value_ptr.append(gpa, rule);
            } else if (std.mem.eql(u8, first, "Zone")) {
                const zone = try Zone.parse(arena, &field_iter);
                const gop = try db.zones.getOrPut(gpa, zone.name);
                if (!gop.found_existing) {
                    gop.key_ptr.* = zone.name;
                    gop.value_ptr.* = .empty;
                }
                try gop.value_ptr.append(gpa, zone);
                if (zone.until == null) {
                    maybe_current_zone_name = null;
                } else {
                    maybe_current_zone_name = zone.name;
                }
            } else if (std.mem.eql(u8, first, "Link")) {
                try db.links.append(gpa, try .parse(arena, &field_iter));
            } else if (std.mem.eql(u8, first, "Leap")) {
                found_leap = true;
                try db.leap_seconds.append(gpa, try .parse(&field_iter));
            } else if (std.mem.eql(u8, first, "Expires")) {
                db.leap_seconds_expire = try .parse(&field_iter);
            } else {
                log.warn("Unrecognized line type: {s}", .{ first });
            }
        }
    }
}

// see outzone() in zic.c
fn compile_zone(alloc: std.mem.Allocator, zone_lines: []Zone, leapsecond_years: ?Year_Range) !Timezone {
    var years: Year_Range = .init(.from_number(1970));
    if (leapsecond_years) |range| years = years.union_year(range.min).union_year(.from_number(range.max.as_number() + 1));

    for (zone_lines) |zone| {
        for (zone.rules) |rule| {
            years = years.union_year(rule.years.min);
            if (rule.years.max.as_number() < std.math.maxInt(i32)) {
                years = years.union_year(rule.years.max);
            }
        }
        if (zone.until) |until| {
            years = years.union_year(until.rule.years.min);
        }
    }

    var builder: Timezone_Builder = .init(alloc);
    if (zone_lines.len > 0) builder.id = zone_lines[0].name;

    builder.posix = compile_posix(zone_lines) catch |err| switch (err) {
        error.Unsupported => posix: {
            years.min = years.min.plus(-402);
            years.max = years.max.plus(402);
            log.info("No posix TZ string for zone {s}", .{ builder.id });
            break :posix null;
        },
        else => |e| return e,
    };

    var start_time: i64 = 0;
    var start_is_std = false;
    var start_is_utc = false;

    var non_tz_lim_time: i64 = std.math.minInt(i64);
    var non_tz_lim_type: u8 = 0;

    var default_time_type: ?u8 = null;

    var processed_rules: std.DynamicBitSetUnmanaged = try .initEmpty(alloc, 64);

    for (0.., zone_lines) |i, zone| {
        var dst_save_seconds: i32 = 0; // a guess that may be corrected later
        const std_offset_seconds: i32 = zone.std_offset_seconds;
        var start_offset_seconds: i32 = std_offset_seconds;
        var start_designation: ?[]const u8 = null;

        var use_start = i > 0;
        std.debug.assert((zone.until != null) == (i < zone_lines.len - 1));

        if (zone.rules.len == 0) {
            dst_save_seconds = zone.dst_save_seconds;

            start_designation = try builder.get_designation(&zone, "%s", zone.is_dst, dst_save_seconds);
            const type_index = try builder.add_time_type(zone.std_offset_seconds + dst_save_seconds, start_designation, zone.is_dst, start_is_std, start_is_utc);
            if (use_start) {
                try builder.add_transition(start_time, type_index, .{});
                if (non_tz_lim_time < start_time) {
                    non_tz_lim_time = start_time;
                    non_tz_lim_type = type_index;
                }
                use_start = false;
            } else {
                default_time_type = type_index;
            }
        } else {
            var year = years.min;

            if (processed_rules.bit_length < zone.rules.len) {
                try processed_rules.resize(alloc, std.mem.alignForward(usize, zone.rules.len + 10, 64), false);
            }

            while (year != years.max.next()) : (year = year.next()) {
                if (zone.until) |until| {
                    if (year.is_after(until.rule.years.max)) break;
                }

                processed_rules.unsetAll();

                while (true) {
                    // find the next unprocessed transition rule for this year (chronologically)
                    var rule_index: ?usize = null;
                    var rule_time: i64 = 0;
                    for (0.., zone.rules) |j, rule| {
                        if (processed_rules.isSet(j)) continue;
                        if (!rule.years.contains(year)) continue;

                        var utc_offset_seconds = if (rule.time_is_utc) 0 else std_offset_seconds;
                        if (!rule.time_is_std) utc_offset_seconds += dst_save_seconds;

                        const time = try rule.ts_for_year(year) - utc_offset_seconds;

                        if (rule_index == null or time < rule_time) {
                            rule_index = j;
                            rule_time = time;
                        } else std.debug.assert(time != rule_time);
                    }
                    const rule = zone.rules[rule_index orelse break];
                    processed_rules.set(rule_index.?);

                    // if we've reached the end of this zone line's valid time range, stop processing this line
                    if (zone.until) |until| {
                        var until_time = until.time;
                        if (!until.rule.time_is_utc) until_time -= std_offset_seconds;
                        if (!until.rule.time_is_std) until_time -= dst_save_seconds;

                        if (rule_time >= until_time) {
                            if (start_designation == null and std_offset_seconds + rule.dst_save_seconds == start_offset_seconds) {
                                start_designation = try builder.get_designation(&zone, rule.letters, rule.is_dst, rule.dst_save_seconds);
                            }
                            break;
                        }
                    }
                    dst_save_seconds = rule.dst_save_seconds;

                    if (use_start and rule_time == start_time) {
                        use_start = false;
                    }

                    if (use_start) {
                        if (rule_time < start_time) {
                            start_offset_seconds = std_offset_seconds + dst_save_seconds;
                            start_designation = try builder.get_designation(&zone, rule.letters, rule.is_dst, rule.dst_save_seconds);
                            continue;
                        } else if (start_designation == null and std_offset_seconds + dst_save_seconds == start_offset_seconds) {
                            start_designation = try builder.get_designation(&zone, rule.letters, rule.is_dst, rule.dst_save_seconds);
                        }
                    }

                    const designation = try builder.get_designation(&zone, rule.letters, rule.is_dst, rule.dst_save_seconds);
                    const utc_offset_seconds = std_offset_seconds + rule.dst_save_seconds;
                    const type_index = try builder.add_time_type(utc_offset_seconds, designation, rule.is_dst, rule.time_is_std, rule.time_is_utc);

                    if (default_time_type == null and !rule.is_dst) {
                        default_time_type = type_index;
                    }

                    try builder.add_transition(rule_time, type_index, .{});

                    if (non_tz_lim_time < rule_time and (zone.until != null or rule.years.max.as_number() < std.math.maxInt(i32))) {
                        non_tz_lim_time = rule_time;
                        non_tz_lim_type = type_index;
                    }
                }
            }
        }

        if (use_start) {
            const is_dst = start_offset_seconds != zone.std_offset_seconds;
            if (start_designation == null and zone.format.len > 0) {
                start_designation = try builder.get_designation(&zone, null, is_dst, dst_save_seconds);
            }

            const type_index = try builder.add_time_type(start_offset_seconds, start_designation.?, is_dst, start_is_std, start_is_utc);

            if (default_time_type == null and !is_dst) {
                default_time_type = type_index;
            }

            try builder.add_transition(start_time, type_index, .{});
        }

        if (zone.until) |until| {
            start_is_std = until.rule.time_is_std;
            start_is_utc = until.rule.time_is_utc;
            start_time = until.time;
            if (!start_is_std) start_time -= dst_save_seconds;
            if (!start_is_utc) start_time -= std_offset_seconds;
        }
    }

    if (default_time_type == null) default_time_type = 0;

    if (builder.posix != null) {
        var tz_start_time: i64 = std.math.maxInt(i64);
        for (builder.transitions.items(.ts)) |transition| {
            if (non_tz_lim_time < transition and transition < tz_start_time) {
                tz_start_time = transition;
            }
        }

        if (tz_start_time == std.math.maxInt(i64)) {
            tz_start_time = non_tz_lim_time;
        }

        var j: usize = 0;
        const transition_time_types = builder.transitions.items(.time_type_index);
	    for (0.., builder.transitions.items(.ts)) |i, transition| {
            if (transition <= tz_start_time) {
                const time_type = transition_time_types[i];
                builder.transitions.set(j, .{
                    .ts = transition,
                    .dont_merge = transition == tz_start_time and (non_tz_lim_type != time_type or builder.posix.?.dst != null),
                    .time_type_index = time_type,
                });
                j += 1;
            }
        }
	    builder.transitions.len = j;
    } else if (builder.transitions.len > 1) {
        // do_extend
        const rule: Rule = .{
            .name = "",
            .years = .init(.from_number(0)),
            .month = .january,
            .day_of_week = .none,
            .day_of_month = .first,
            .time = .midnight,
            .time_is_std = false,
            .time_is_utc = false,
            .is_dst = false,
            .dst_save_seconds = 0,
            .letters = "",
        };
        var last_transition = builder.transitions.get(0);
		for (1.., builder.transitions.items(.ts)[1..]) |i, transition| {
			if (transition > last_transition.ts) {
                last_transition = builder.transitions.get(i);
            }
        }
		if (last_transition.ts < try rule.ts_for_year(years.max.prev())) {
            const time = try rule.ts_for_year(years.max.next());
            try builder.add_transition(time, last_transition.time_type_index, .{ .dont_merge = true });
        }
    }

    return try builder.build();
}

// see stringzone() in zic.c
fn compile_posix(zone_lines: []Zone) !Timezone.Posix {
    const zone = zone_lines[zone_lines.len - 1];
    var std_zone = zone;
    var dst_zone = zone;

    var std_rule: ?*const Rule = null;
    var dst_rule: ?*const Rule = null;
    for (zone.rules) |*rule| {
        if (rule.is_dst) {
            switch (Rule.cmp(dst_rule, rule)) {
                .lt => dst_rule = rule,
                .eq => return error.Unsupported,
                .gt => {},
            }
        } else {
            switch (Rule.cmp(std_rule, rule)) {
                .lt => std_rule = rule,
                .eq => return error.Unsupported,
                .gt => {},
            }
        }
    }

    var temp_std_rule: Rule = undefined;
    var temp_dst_rule: Rule = undefined;

    switch (if (zone.rules.len > 0) Rule.cmp(dst_rule, std_rule) else if (zone.is_dst) std.math.Order.gt else std.math.Order.lt) {
        .lt => {
            // standard time all year
            dst_rule = null;
        },
        .eq => {},
        .gt => {
            // DST all year.  Use an abbreviation like "XXX3EDT4,0/0,J365/23" for EDT (-04) all year.
            const dst_save_seconds = if (dst_rule) |r| r.dst_save_seconds else zone.dst_save_seconds;

            if (dst_save_seconds >= 0) {
                // Positive DST, the typical case for all-year DST.
		        // Fake a timezone with negative DST.
                std_zone = .{
                    .name = "",
                    .std_offset_seconds = zone.std_offset_seconds + 2 * dst_save_seconds,
                    .rule_name = "",
                    .rules = &.{},
                    .format = "XXX",
                    .until = null,
                };
                dst_zone = .{
                    .name = "",
                    .std_offset_seconds = zone.std_offset_seconds + 2 * dst_save_seconds,
                    .rule_name = "",
                    .rules = &.{},
                    .format = zone.format,
                    .until = null,
                };
            }
            temp_dst_rule = .{
                .name = "",
                .years = .init(.epoch),
                .month = .january,
                .day_of_month = .first,
                .day_of_week = .none,
                .time = .midnight,
                .time_is_std = false,
                .time_is_utc = false,
                .is_dst = true,
                .dst_save_seconds = if (dst_save_seconds < 0) dst_save_seconds else -dst_save_seconds,
                .letters = if (dst_rule) |r| r.letters else "%s",
            };
            temp_std_rule = .{
                .name = "",
                .years = .init(.epoch),
                .month = .december,
                .day_of_month = .from_number(31),
                .day_of_week = .none,
                .time = @enumFromInt(24 * std.time.ms_per_day + temp_dst_rule.dst_save_seconds * 1000),
                .time_is_std = false,
                .time_is_utc = false,
                .is_dst = false,
                .dst_save_seconds = 0,
                .letters = "%s",
            };
            if (dst_save_seconds < 0) {
                if (std_rule) |r| {
                    temp_std_rule.letters = r.letters;
                }
            }
            dst_rule = &temp_dst_rule;
            std_rule = &temp_std_rule;
        },
    }

    var std_designation_buf: [32]u8 = undefined;
    var std_designation_writer: std.Io.Writer = .fixed(&std_designation_buf);
    try std_zone.write_designation(if (std_rule) |r| r.letters else "%s", false, 0, &std_designation_writer);
    const std_designation = std_designation_writer.buffered();
    if (std_designation.len == 0) return error.Unsupported;

    if (dst_rule) |dr| {
        if (std_rule) |sr| {
            var dst_designation_buf: [32]u8 = undefined;
            var dst_designation_writer: std.Io.Writer = .fixed(&dst_designation_buf);
            try dst_zone.write_designation(dr.letters, dr.is_dst, dr.dst_save_seconds, &dst_designation_writer);
            const dst_designation = dst_designation_writer.buffered();

            return .init(
                std_designation, std_zone.std_offset_seconds,
                dst_designation, std_zone.std_offset_seconds + dr.dst_save_seconds,
                try dr.posix_transition(dr.dst_save_seconds, std_zone.std_offset_seconds),
                try sr.posix_transition(dr.dst_save_seconds, std_zone.std_offset_seconds),
            );
        }
    }
    
    return .init_standard(std_designation, std_zone.std_offset_seconds);
}

const Rule = struct {
    name: []const u8, // r_name
    years: Year_Range, // r_loyear, r_hiyear
    month: Month, // r_month
    day_of_month: Day, // r_dayofmonth
    day_of_week: DOW, // r_dycode, r_wday
    time: Time, // r_tod
    time_is_std: bool, // r_todisstd
    time_is_utc: bool, // r_todisut
    is_dst: bool, // r_isdst
    dst_save_seconds: i32, // r_save
    letters: []const u8, // r_abbrvar

    processed: bool = false,

    const DOW = union (enum) {
        none,
        gt_eq: Week_Day,
        lt_eq: Week_Day,
    };

    // see inrule() in zic.c
    pub fn parse(arena: std.mem.Allocator, iter: *std.mem.TokenIterator(u8, .any)) !Rule {
        const name = iter.next() orelse return error.ExpectedRuleName;
        const from_str = iter.next() orelse return error.ExpectedRuleFromYear;
        const to_str = iter.next() orelse return error.ExpectedRuleToYear;
        const year_type = iter.next() orelse return error.ExpectedRuleYearType;
        if (!std.mem.eql(u8, year_type, "-")) return error.UnsupportedRuleYearType;
        const in_str = iter.next() orelse return error.ExpectedRuleInMonth;
        const on_str = iter.next() orelse return error.ExpectedRuleOnDay;
        const at_str = iter.next() orelse return error.ExpectedRuleAtTime;
        const save_str = iter.next() orelse return error.ExpectedRuleSaveDuration;
        const letters_str = iter.next() orelse return error.ExpectedRuleLetters;
        return try parse_fields(arena, name, from_str, to_str, in_str, on_str, at_str, save_str, letters_str);
    }

    pub fn parse_fields(arena: std.mem.Allocator, name: []const u8, from: []const u8, to: []const u8, in: []const u8, on: []const u8, at: []const u8, save: []const u8, letters: []const u8) !Rule {
        // note "minimum" keyword is deprecated and doesn't appear in current tzdata files, so we're not checking for it
        const low_year: Year = y: {
            errdefer log.info("low year: \"{f}\"", .{ std.zig.fmtString(from) });
            break :y .from_number(try std.fmt.parseInt(i32, from, 10));
        };
        const high_year: Year = y: {
            errdefer log.info("high year: \"{f}\"", .{ std.zig.fmtString(to) });
            if (std.mem.eql(u8, to, "only")) break :y low_year;
            if (std.mem.eql(u8, to, "max")) break :y .from_number(std.math.maxInt(i32));
            break :y .from_number(try std.fmt.parseInt(i32, to, 10));
        };

        if (low_year.as_number() > high_year.as_number()) return error.InvalidRuleYearRange;

        const month: Month = try .from_string(in, .{});

        var day_of_week: DOW = undefined;
        var day_of_month: Day = undefined;
        const last_dow_map: std.StaticStringMap(Week_Day) = .initComptime(.{
            .{ "last-Sunday", .sunday },
            .{ "last-Sun", .sunday },
            .{ "lastSunday", .sunday },
            .{ "lastSun", .sunday },
            .{ "last-Monday", .monday },
            .{ "last-Mon", .monday },
            .{ "lastMonday", .monday },
            .{ "lastMon", .monday },
            .{ "last-Tuesday", .tuesday },
            .{ "last-Tue", .tuesday },
            .{ "lastTuesday", .tuesday },
            .{ "lastTue", .tuesday },
            .{ "last-Wednesday", .wednesday },
            .{ "last-Wed", .wednesday },
            .{ "lastWednesday", .wednesday },
            .{ "lastWed", .wednesday },
            .{ "last-Thursday", .thursday },
            .{ "last-Thu", .thursday },
            .{ "lastThursday", .thursday },
            .{ "lastThu", .thursday },
            .{ "last-Friday", .friday },
            .{ "last-Fri", .friday },
            .{ "lastFriday", .friday },
            .{ "lastFri", .friday },
            .{ "last-Saturday", .saturday },
            .{ "last-Sat", .saturday },
            .{ "lastSaturday", .saturday },
            .{ "lastSat", .saturday },
        });
        if (last_dow_map.get(on)) |dow| {
            day_of_week = .{ .lt_eq = dow };
            day_of_month = .from_number(month.days(.epoch));
        } else if (std.mem.find(u8, on, "<=")) |split_pos| {
            day_of_week = .{ .lt_eq = try Week_Day.from_string(on[0..split_pos], .{ .allow_numeric = false }) };
            day_of_month = .from_number(try std.fmt.parseInt(u8, on[split_pos + 2 ..], 10));
        } else if (std.mem.find(u8, on, ">=")) |split_pos| {
            day_of_week = .{ .gt_eq = try Week_Day.from_string(on[0..split_pos], .{ .allow_numeric = false }) };
            day_of_month = .from_number(try std.fmt.parseInt(u8, on[split_pos + 2 ..], 10));
        } else {
            day_of_week = .none;
            day_of_month = .from_number(try std.fmt.parseInt(u8, on, 10));
        }

        const time = try parse_hms(std.mem.trimEnd(u8, at, "swguzSWGUZ"));
        var time_is_std = false;
        var time_is_utc = false;
        switch (if (at.len > 0) at[at.len - 1] else 0) {
            'S', 's' => { // standard
                time_is_std = true;
            },
            'G', 'g', // Greenwich
            'U', 'u', // Universal
            'Z', 'z', // Zulu
            => {
                time_is_std = true;
                time_is_utc = true;
            },
            'W', 'w' => {}, // wall
            else => {},
        }

        const dst_save_seconds: i32 = (try parse_hms(std.mem.trimEnd(u8, save, "sdSD"))).seconds_since_midnight();
        const is_dst = switch (if (save.len > 0) save[save.len - 1] else 0) {
            'D', 'd' => true, // dst
            'S', 's' => false, // standard
            else => dst_save_seconds != 0,
        };

        const letters_clean = if (std.mem.eql(u8, letters, "-")) "" else letters;
        
        const name_owned = try arena.dupe(u8, name);
        const letters_owned = try arena.dupe(u8, letters_clean);

        return .{
            .name = name_owned,
            .years = .{
                .min = low_year,
                .max = high_year,
            },
            .month = month,
            .day_of_month = day_of_month,
            .day_of_week = day_of_week,
            .time = time,
            .time_is_std = time_is_std,
            .time_is_utc = time_is_utc,
            .is_dst = is_dst,
            .dst_save_seconds = dst_save_seconds,
            .letters = letters_owned,
        };
    }

    // rpytime from zic.c
    pub fn ts_for_year(self: *const Rule, year: Year) !i64 {
        var ymd: Date.YMD = .{
            .year = year,
            .month = self.month,
            .day = self.day_of_month,
        };

        if (ymd.month == .february and ymd.day.as_number() == 29 and !ymd.year.is_leap()) {
            if (self.day_of_week == .lt_eq) {
                ymd.day = .from_number(ymd.day.as_number() - 1);
            } else {
                return error.InvalidDate;
            }
        }

        const date = switch (self.day_of_week) {
            .none => ymd.date(),
            .lt_eq => |weekday| weekday.on_or_before(ymd.date()),
            .gt_eq => |weekday| weekday.on_or_after(ymd.date()),
        };

        return date.with_time(self.time).with_offset(0).timestamp_s();
    }

    // rule_cmp in zic.c
    pub fn cmp(self: ?*const Rule, other: ?*const Rule) std.math.Order {
        if (self) |a| {
            if (other) |b| {
                if (a.years.max != b.years.max) {
                    return std.math.order(a.years.max.as_number(), b.years.max.as_number());
                }
                if (a.years.max.as_number() == std.math.maxInt(i32)) {
                    return .eq;
                }
                if (a.month != b.month) {
                    return std.math.order(a.month.as_number(), b.month.as_number());
                }
                return std.math.order(a.day_of_month.as_number(), b.day_of_month.as_number());
            } else return .gt;
        } else if (other) |_| {
            return .lt;
        } else return .eq;
    }

    pub fn posix_transition(self: *const Rule, dst_save_seconds: i32, std_offset_seconds: i32) !Timezone.Posix.Transition {
        var tod = self.time.seconds_since_midnight();
        const date: Timezone.Posix.Transition_Date = switch (self.day_of_week) {
            .none => d: {
                if (self.month == .february and self.day_of_month.as_number() == 29) return error.Unsupported;
                const od = tempora.Ordinal_Day.from_md_assume_non_leap_year(self.month, self.day_of_month);
                break :d switch (self.month) {
                    .january, .february => .{ .ordinal_day = od },
                    else => .{ .ordinal_day_no_leap = od },
                };
            },
            .gt_eq => |weekday| d: {
                const weekday_offset = (self.day_of_month.as_unsigned() - 1) % 7;
                tod += @as(i32, @intCast(weekday_offset * std.time.s_per_day));
                break :d .{ .month_week_day = .{
                    .month = self.month,
                    .week = @enumFromInt((self.day_of_month.as_unsigned() - 1) / 7),
                    .day = @enumFromInt(((weekday.as_unsigned() + 6 - weekday_offset) % 7) + 1),
                }};
            },
            .lt_eq => |weekday| d: {
                if (self.day_of_month.as_number() == self.month.days_assume_leap_year()) {
                    break :d .{ .month_week_day = .{
                        .month = self.month,
                        .week = .last,
                        .day = weekday,
                    }};
                } else {
                    const weekday_offset = self.day_of_month.as_unsigned() % 7;
                    tod += @as(i32, @intCast(weekday_offset * std.time.s_per_day));
                    break :d .{ .month_week_day = .{
                        .month = self.month,
                        .week = @enumFromInt(self.day_of_month.as_unsigned() / 7),
                        .day = @enumFromInt(((weekday.as_unsigned() + 6 - weekday_offset) % 7) + 1),
                    }};
                }
            },
        };

        if (self.time_is_utc) {
            tod += std_offset_seconds;
        }

        if (self.time_is_std and !self.is_dst) {
            tod += dst_save_seconds;
        }

        return .{
            .date = date,
            .time = @enumFromInt(tod * 1000),
        };
    }
};

const Zone = struct {
    name: []const u8, // z_name
    std_offset_seconds: i32, // z_stdoff
    rule_name: []const u8, // z_rule
    rules: []const Rule, // z_rules, z_nrules; not populated initially
    format: []const u8, // z_format, z_format_specifier
    until: ?Until = null,

    is_dst: bool = false, // populated by collect_rules()
    dst_save_seconds: i32 = 0, // populated by collect_rules()

    pub const Until = struct {
        rule: Rule, // z_untilrule
        time: i64, // z_untiltime
    };

    // see inzone() in zic.c
    pub fn parse(arena: std.mem.Allocator, iter: *std.mem.TokenIterator(u8, .any)) !Zone {
        const name = iter.next() orelse return error.ExpectedZoneName;
        const name_owned = try arena.dupe(u8, name);
        return try parse_continuation(arena, name_owned, iter);
    }

    pub fn parse_continuation(arena: std.mem.Allocator, name: []const u8, iter: *std.mem.TokenIterator(u8, .any)) !Zone {
        const std_offset_str = iter.next() orelse return error.ExpectedZoneStdOffsetSeconds;
        const std_offset_seconds = (try parse_hms(std_offset_str)).seconds_since_midnight();

        const rule = iter.next() orelse return error.ExpectedZoneRule;

        const format = iter.next() orelse return error.ExpectedZoneFormat;

        errdefer log.info("std_offset: \"{f}\"  rule: \"{f}\"  format: \"{f}\"", .{
            std.zig.fmtString(std_offset_str),
            std.zig.fmtString(rule),
            std.zig.fmtString(format),
        });
        
        var until: ?Until = null;
        if (iter.next()) |til_year_str| {
            const til_month_str = iter.next() orelse "Jan";
            const til_day_str = iter.next() orelse "1";
            const til_time_str = iter.next() orelse "0";

            const til_rule = try Rule.parse_fields(arena, "", til_year_str, "only", til_month_str, til_day_str, til_time_str, "", "");
            until = .{
                .rule = til_rule,
                .time = try til_rule.ts_for_year(til_rule.years.min),
            };
        }

        const rule_owned = try arena.dupe(u8, rule);
        const format_owned = try arena.dupe(u8, format);

        return .{
            .name = name,
            .std_offset_seconds = std_offset_seconds,
            .rule_name = rule_owned,
            .rules = &.{},
            .format = format_owned,
            .until = until,
        };
    }

    pub fn collect_rules(self: *Zone, rule_map: *std.array_hash_map.String(std.ArrayList(Rule))) !void {
        if (rule_map.get(self.rule_name)) |rules| {
            self.rules = rules.items;
        } else {
            // local standard time offset
            self.dst_save_seconds = (try parse_hms(std.mem.trimEnd(u8, self.rule_name, "sdSD"))).seconds_since_midnight();
            self.is_dst = switch (if (self.rule_name.len > 0) self.rule_name[self.rule_name.len - 1] else 0) {
                'D', 'd' => true, // dst
                'S', 's' => false, // standard
                else => self.dst_save_seconds != 0,
            };
        }
    }

    // doabbr() in zic.c
    pub fn write_designation(self: *const Zone, maybe_letters: ?[]const u8, is_dst: bool, dst_save_seconds: i32, w: *std.Io.Writer) std.Io.Writer.Error!void {
        if (std.mem.findScalar(u8, self.format, '/')) |slash_index| {
            const str = if (is_dst) self.format[slash_index + 1 ..] else self.format[0..slash_index];
            try w.writeAll(str);
            return;
        }
        
        var letters_or_offset = maybe_letters;

        var buf: [8]u8 = undefined;
        if (std.mem.find(u8, self.format, "%z") != null) {
            var letter_writer = std.Io.Writer.fixed(&buf);

            const offset_signed = self.std_offset_seconds + dst_save_seconds;
            letter_writer.writeByte(if (offset_signed < 0) '+' else '-') catch unreachable;

            var offset_abs: u32 = @intCast(@abs(offset_signed));
            const seconds = offset_abs % 60;
            offset_abs /= 60;
            const minutes = offset_abs % 60;
            offset_abs /= 60;
            if (offset_abs >= 100) {
                letter_writer.writeAll("??????") catch unreachable;
            } else {
                letter_writer.print("{d:0>2}", .{ offset_abs }) catch unreachable;
                if (minutes != 0 or seconds != 0) letter_writer.print("{d:0>2}", .{ minutes }) catch unreachable;
                if (seconds != 0) letter_writer.print("{d:0>2}", .{ seconds }) catch unreachable;
            }

            letters_or_offset = letter_writer.buffered();
        }

        if (letters_or_offset) |letters| {
            if (std.mem.findScalar(u8, self.format, '%')) |interp_pos| {
                if (self.format.len > interp_pos + 1) {
                    const mode = self.format[interp_pos + 1];
                    if (mode == 's' or mode == 'z') {
                        const prefix = self.format[0..interp_pos];
                        const suffix = self.format[interp_pos + 2 ..];
                        try w.print("{s}{s}{s}", .{ prefix, letters, suffix });
                        return;
                    }
                }
            }
            try w.writeAll(self.format);
        }
    }
};

const Link = struct {
    source: []const u8,
    target: []const u8,
    is_region: bool,

    pub fn parse(arena: std.mem.Allocator, iter: *std.mem.TokenIterator(u8, .any)) !Link {
        const target = iter.next() orelse return error.ExpectedLinkTarget;
        const source = iter.next() orelse return error.ExpectedLinkSource;

        const target_owned = try arena.dupe(u8, target);
        const source_owned = try arena.dupe(u8, source);

        return .{
            .source = source_owned,
            .target = target_owned,
            .is_region = false,
        };
    }

    pub fn write_zig(self: Link, name: []const u8, indent: usize, w: *std.Io.Writer, prefix: []const u8) std.Io.Writer.Error!void {
        const alias = self.is_region or std.mem.eql(u8, self.source, self.target);

        try w.writeByte('\n');
        try w.splatBytesAll("    ", indent);
        if (alias) {
            try w.print("pub const {f} = {s}", .{
                fmt_id_lower(name),
                prefix,
            });
        } else {
            try w.print("pub const {f}: TZIF_Data = .init_link(\"{f}\", &{s}", .{
                fmt_id_lower(name),
                std.zig.fmtString(self.source),
                prefix,
            });
        }
        var iter = std.mem.tokenizeScalar(u8, self.target, '/');
        while (iter.next()) |part| {
            try w.print(".{f}", .{
                fmt_id_lower(part),
            });
        }
        try w.writeAll(if (alias) ";" else ");");
    }
};

const Leap = struct {
    year: Year,
    month: Month,
    day: Day,
    time: Time,
    delta: i2,
    dtai: i32 = 0, // populated in DB.compile()

    pub fn parse(iter: *std.mem.TokenIterator(u8, .any)) !Leap {
        const year_str = iter.next() orelse return error.ExpectedLeapSecondYear;
        const month_str = iter.next() orelse return error.ExpectedLeapSecondMonth;
        const day_str = iter.next() orelse return error.ExpectedLeapSecondDay;
        const time_str = iter.next() orelse return error.ExpectedLeapSecondTime;
        const delta_str = iter.next() orelse "";

        return .{
            .year = try .from_string(year_str, .{}),
            .month = try .from_string(month_str, .{}),
            .day = .from_number(try std.fmt.parseInt(i32, day_str, 10)),
            .time = try parse_hms(time_str),
            .delta = if (delta_str.len == 0) 0 else if (std.mem.eql(u8, delta_str, "+")) 1 else if (std.mem.eql(u8, delta_str, "-")) -1 else return error.InvalidLeapSecondDelta,
        };
    }

    pub fn write_zig(self: Leap, indent: usize, w: *std.Io.Writer) !void {
        try w.writeByte('\n');
        try w.splatBytesAll("    ", indent);
        try w.print(".{{ .utc_timestamp_seconds = {d}, .utc_offset_seconds = {d} }},", .{
            Date.from_ymd(.init(self.year, self.month, self.day)).with_time(self.time).with_offset(0).timestamp_s(),
            self.dtai,
        });
    }
};

const Timezone_Builder = struct {
    arena: std.mem.Allocator,
    transitions: std.MultiArrayList(Transition) = .empty,
    time_types: std.ArrayList(Timezone.Wall_Time_Info) = .empty,
    posix: ?Timezone.Posix = null,
    id: []const u8 = "",

    pub fn init(alloc: std.mem.Allocator) Timezone_Builder {
        return .{
            .arena = alloc,
        };
    }

    pub fn get_designation(self: *Timezone_Builder, zone: *const Zone, maybe_letters: ?[]const u8, is_dst: bool, dst_save_seconds: i32) ![]const u8 {
        var writer: std.Io.Writer.Allocating = .init(self.arena);
        try zone.write_designation(maybe_letters, is_dst, dst_save_seconds, &writer.writer);
        return writer.written();
    }

    // addtt in zic.c
    pub fn add_transition(self: *Timezone_Builder, ts: i64, time_type_index: u8, options: struct { dont_merge: bool = false }) !void {
        try self.transitions.append(self.arena, .{
            .ts = ts,
            .time_type_index = time_type_index,
            .dont_merge = options.dont_merge,
        });
    }

    // addtype in zic.c
    pub fn add_time_type(self: *Timezone_Builder, utc_offset_seconds: i32, maybe_designation: ?[]const u8, is_dst: bool, is_std: bool, is_utc: bool) !u8 {
	    //if (!want_bloat()) ttisstd = ttisut = false;

        const designation = maybe_designation orelse "";

        const source: Timezone.Wall_Time_Info.Source = if (is_utc) .tzdata_utc else if (is_std) .tzdata_standard else .tzdata_wall;
        const dst: Timezone.Wall_Time_Info.DST_Indicator = if (is_dst) .dst else .std;

        for (0.., self.time_types.items) |i, tt| {
            if (tt.utc_offset_seconds == utc_offset_seconds and tt.source == source and tt.dst == dst and std.mem.eql(u8, tt.designation, designation)) {
                return @intCast(i);
            }
        }

        const index = self.time_types.items.len;
        try self.time_types.append(self.arena, .{
            .designation = designation,
            .begin_ts = null,
            .end_ts = null,
            .utc_offset_seconds = utc_offset_seconds,
            .dst = dst,
            .source = source,
        });

        return @intCast(index);
    }

    pub fn build(self: *Timezone_Builder) !Timezone {
        const Sort_Context = struct {
            timestamps: []const i64,
            pub fn lessThan(ctx: @This(), ai: usize, bi: usize) bool {
                return ctx.timestamps[ai] < ctx.timestamps[bi];
            }
        };
        self.transitions.sort(Sort_Context { .timestamps = self.transitions.items(.ts) });

        // Optimize and skip unwanted transitions.
        {
            const times = self.transitions.items(.ts);
            const types = self.transitions.items(.time_type_index);
            const dont_merges = self.transitions.items(.dont_merge);
            const type_infos = self.time_types.items;

            var toi: usize = 0;
            var fromi: usize = 0;
            while (fromi < self.transitions.len) : (fromi += 1) {

                if (toi != 0) {
                    const type_2: u8 = if (toi == 1) 0 else types[toi - 2];
                    if ((times[fromi] + type_infos[types[toi - 1]].utc_offset_seconds) <= times[toi - 1] + type_infos[type_2].utc_offset_seconds) {
                        if (types[fromi] == type_2) toi -= 1 else types[toi - 1] = types[fromi];
                        continue;
                    }
                }

                if (toi == 0
                    or dont_merges[fromi]
                    or (type_infos[types[toi - 1]].utc_offset_seconds != type_infos[types[fromi]].utc_offset_seconds)
                    or (type_infos[types[toi - 1]].dst != type_infos[types[fromi]].dst)
                    or (!std.mem.eql(u8, type_infos[types[toi - 1]].designation, type_infos[types[fromi]].designation))
                ) {
                    self.transitions.set(toi, self.transitions.get(fromi));
                    toi += 1;
                }
            }
            self.transitions.len = toi;
        }

        return .{
            .id = self.id,
            .transition_count = self.transitions.len,
            .transition_timestamps = self.transitions.items(.ts).ptr,
            .transition_info_indices = self.transitions.items(.time_type_index).ptr,
            .infos = self.time_types.items,
            .posix = self.posix,
        };
    }
};

const DB = struct {
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
    temp: std.heap.ArenaAllocator,

    zones: std.array_hash_map.String(std.ArrayList(Zone)) = .empty,
    rules: std.array_hash_map.String(std.ArrayList(Rule)) = .empty,
    links: std.ArrayList(Link) = .empty,
    regions: std.ArrayList(Region) = .empty,
    top_level: std.array_hash_map.String(Zone_Or_Region) = .empty,

    leap_seconds: std.ArrayList(Leap) = .empty,
    leap_seconds_expire: ?Leap = null,

    compiled_zones: std.StringHashMapUnmanaged(Timezone) = .empty,

    pub fn init(gpa: std.mem.Allocator, arena: std.mem.Allocator) DB {
        return .{
            .gpa = gpa,
            .arena = arena,
            .temp = .init(gpa),
        };
    }

    pub fn deinit(self: *DB) void {
        self.compiled_zones.deinit(self.gpa);
        
        self.leap_seconds.deinit(self.gpa);

        self.top_level.deinit(self.gpa);

        for (self.regions.items) |*region| region.children.deinit(self.gpa);
        self.regions.deinit(self.gpa);

        for (self.zones.values()) |*list| list.deinit(self.gpa);
        self.zones.deinit(self.gpa);

        for (self.rules.values()) |*list| list.deinit(self.gpa);
        self.rules.deinit(self.gpa);

        self.links.deinit(self.gpa);

        self.temp.deinit();
    }

    pub fn compile(self: *DB) !void {
        if (self.regions.items.len == 0) {
            try self.regions.append(self.gpa, .{ .name = "" }); // top level items
        }

        for (self.zones.values()) |list| {
            if (list.items.len == 0) continue;

            try self.add_zone_to_region(list.items[0].name);

            for (list.items) |*zone| {
                try zone.collect_rules(&self.rules);
            }

            _ = self.temp.reset(.retain_capacity);
            const tz = try compile_zone(self.temp.allocator(), list.items, null);
            const cloned = try tz.clone(self.arena);
            try self.compiled_zones.put(self.gpa, cloned.id, cloned);
        }

        for (self.links.items) |*link| {
            try self.add_link_to_region(link);
        }

        for (self.regions.items) |*region| {
            region.sort_children(self.regions.items);
        }

        var dtai: i32 = 10;
        for (self.leap_seconds.items) |*leap| {
            dtai += leap.delta;
            leap.dtai = dtai;
        }
        if (self.leap_seconds_expire) |*leap| {
            leap.dtai = dtai;
        }
    }
    
    fn add_zone_to_region(self: *DB, zone_name: []const u8) !void {
        try self.add_to_region(zone_name, .{ .zone = zone_name });
    }

    fn add_link_to_region(self: *DB, link: *const Link) !void {
        try self.add_to_region(link.source, .{ .link = link });
    }

    fn add_to_region(self: *DB, zone_name: []const u8, what: Zone_Or_Region) !void {
        var region: u32 = 0;
        var iter = std.mem.tokenizeScalar(u8, zone_name, '/');
        while (iter.next()) |region_or_city_name| {
            if (iter.peek() == null) {
                try self.regions.items[region].children.append(self.gpa, what);
            } else {
                const region_name = region_or_city_name;
                for (self.regions.items[region].children.items) |child| {
                    switch (child) {
                        .region => |region_index| {
                            if (std.mem.eql(u8, region_name, self.regions.items[region_index].name)) {
                                region = region_index;
                                break;
                            }
                        },
                        else => {},
                    }
                } else {
                    const region_index: u32 = @intCast(self.regions.items.len);
                    try self.regions.append(self.gpa, .{ .name = region_name });
                    try self.regions.items[region].children.append(self.gpa, .{ .region = region_index });
                    region = region_index;
                }
            }
        }
    }

    pub fn write_zig(self: *DB, w: *std.Io.Writer) !void {
        try self.write_region_zig(&self.regions.items[0], 0, w, .top);
        try w.writeAll(
            \\
            \\
            \\pub const all = struct {
        );
        try self.write_region_zig(&self.regions.items[0], 1, w, .all);
        try w.writeAll(
            \\
            \\};
            \\
            \\pub const uncompressed = struct {
        );
        try self.write_region_zig(&self.regions.items[0], 1, w, .uncompressed);
        try w.writeAll(
            \\
            \\};
            \\
            \\pub const canonical = struct {
        );
        try self.write_region_zig(&self.regions.items[0], 1, w, .without_links);
        try w.writeAll(
            \\
            \\};
            \\
            \\pub const canonical_uncompressed = struct {
        );
        try self.write_region_zig(&self.regions.items[0], 1, w, .without_links_uncompressed);
        try w.writeAll(
            \\
            \\};
            \\
            \\pub const leap_seconds: []const Leap_Second = &.{
        );
        for (self.leap_seconds.items) |leap| try leap.write_zig(1, w);
        if (self.leap_seconds_expire) |leap| try leap.write_zig(1, w);
        try w.writeAll(
            \\
            \\};
            \\
        );
    }

    pub const DB_Variant = enum {
        top,
        all,
        uncompressed,
        without_links,
        without_links_uncompressed,
    };

    pub fn count_children(self: *DB, region: *Region, variant: DB_Variant) usize {
        var count: usize = 0;
        for (region.children.items) |child| switch (child) {
            .zone => |zone_name| {
                if (self.zones.contains(zone_name)) count += 1;
            },
            .region => |child_region_index| switch (variant) {
                .all => count += 1,
                else => if (self.count_children(&self.regions.items[child_region_index], variant) > 0) {
                    count += 1;
                },
            },
            .link => switch (variant) {
                .without_links, .without_links_uncompressed => {},
                .top, .all => count += 1,
                .uncompressed => count += 1,
            },
        };
        return count;
    }

    pub fn write_region_zig(self: *DB, region: *Region, indent: usize, w: *std.Io.Writer, variant: DB_Variant) !void {
        if (self.count_children(region, variant) == 0) return;

        if (region.name.len > 0) {
            try w.writeByte('\n');
            try w.splatBytesAll("    ", indent);
            try w.print("pub const {f} = struct {{", .{ fmt_id_lower(region.name) });
        }

        const inner_indent = if (region.name.len > 0) indent + 1 else indent;

        for (region.children.items) |child| switch (child) {
            .zone => |zone_name| try self.write_zone_zig(zone_name, inner_indent, w, variant),
            .region => |child_region_index| switch (variant) {
                .all => {
                    const name = self.regions.items[child_region_index].name;
                    try Link.write_zig(.{
                        .source = name,
                        .target = name,
                        .is_region = true,
                    }, last_part(name), inner_indent, w, "tzdata");
                },
                else => try self.write_region_zig(&self.regions.items[child_region_index], inner_indent, w, variant),
            },
            .link => |link| switch (variant) {
                .without_links, .without_links_uncompressed => {},
                .top, .all => try link.write_zig(last_part(link.source), inner_indent, w, "tzdata"),
                .uncompressed => try link.write_zig(last_part(link.source), inner_indent, w, "tzdata.uncompressed"),
            },
        };

        if (region.name.len > 0) {
            try w.writeByte('\n');
            try w.splatBytesAll("    ", indent);
            try w.writeAll("};");
        }
    }

    pub fn write_zone_zig(self: *DB, zone_name: []const u8, indent: usize, w: *std.Io.Writer, variant: DB_Variant) !void {
        const tz = self.compiled_zones.get(zone_name) orelse return;
        switch (variant) {
            .top => {
                _ = self.temp.reset(.retain_capacity);

                var raw_tzif: std.Io.Writer.Allocating = .init(self.temp.allocator());
                try tempora.Timezone.tzif.write(&tz, &raw_tzif.writer, .{ .include_v1_data = false });
                const tzif_bytes = raw_tzif.writer.buffered();

                var compressed_tzif: std.Io.Writer.Allocating = try .initCapacity(self.temp.allocator(), 256);
                var compress_buf: [std.compress.flate.max_window_len]u8 = undefined;
                var compressor: std.compress.flate.Compress = try .init(&compressed_tzif.writer, &compress_buf, .zlib, .best);
                try compressor.writer.writeAll(raw_tzif.writer.buffered());
                try compressor.finish();
                const compressed_tzif_bytes = compressed_tzif.writer.buffered();

                if (compressed_tzif_bytes.len + min_deflate_bytes_saved <= tzif_bytes.len) {
                    try w.writeByte('\n');
                    try w.splatBytesAll("    ", indent);
                    try w.print("pub const {f}: TZIF_Data = .init_compressed(\"{f}\", \"{f}\");", .{
                        fmt_id_lower(last_part(zone_name)),
                        std.zig.fmtString(zone_name),
                        std.zig.fmtString(compressed_tzif_bytes),
                    });
                } else {
                    try Link.write_zig(.{
                        .source = zone_name,
                        .target = zone_name,
                        .is_region = false,
                    }, last_part(zone_name), indent, w, "tzdata.uncompressed");
                }
            },
            .uncompressed => {
                _ = self.temp.reset(.retain_capacity);

                var raw_tzif: std.Io.Writer.Allocating = .init(self.temp.allocator());
                try tempora.Timezone.tzif.write(&tz, &raw_tzif.writer, .{ .include_v1_data = false });
                const tzif_bytes = raw_tzif.writer.buffered();

                try w.writeByte('\n');
                try w.splatBytesAll("    ", indent);
                try w.print("pub const {f}: TZIF_Data = .init(\"{f}\", \"{f}\");", .{
                    fmt_id_lower(last_part(zone_name)),
                    std.zig.fmtString(zone_name),
                    std.zig.fmtString(tzif_bytes),
                });
            },
            .all, .without_links => {
                try Link.write_zig(.{
                    .source = zone_name,
                    .target = zone_name,
                    .is_region = false,
                }, last_part(zone_name), indent, w, "tzdata");
            },
            .without_links_uncompressed => {
                try Link.write_zig(.{
                    .source = zone_name,
                    .target = zone_name,
                    .is_region = false,
                }, last_part(zone_name), indent, w, "tzdata.uncompressed");
            },
        }
    }

    pub fn write_designation_offsets_zig(self: *DB, comptime map: std.StaticStringMap([]const u8), w: *std.Io.Writer) !void {
        var keys: [map.kvs.len][]const u8 = undefined;
        var vals: [map.kvs.len][]const u8 = undefined;
        @memcpy(&keys, map.keys());
        @memcpy(&vals, map.values());

        const SortContext = struct {
            keys: [][]const u8,
            vals: [][]const u8,

            pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                return std.mem.lessThan(u8, ctx.keys[a], ctx.keys[b]);
            }

            pub fn swap(ctx: @This(), a: usize, b: usize) void {
                std.mem.swap([]const u8, &ctx.keys[a], &ctx.keys[b]);
                std.mem.swap([]const u8, &ctx.vals[a], &ctx.vals[b]);
            }
        };
        std.mem.sortUnstableContext(0, map.kvs.len, SortContext {
            .keys = &keys,
            .vals = &vals,
        });

        for (keys, vals) |designation, zone| {
            try self.write_designation_offset_zig(designation, zone, w);
        }
    }

    pub fn write_designation_offset_zig(self: *DB, designation: []const u8, zone: []const u8, w: *std.Io.Writer) !void {
        const utc_offset_seconds = offset: {
            if (zone.len == 0) break :offset 0;
            const tz = self.compiled_zones.get(zone) orelse {
                log.warn("Failed to find {s} offset: Zone {s} does not exist", .{ designation, zone });
                return;
            };
            if (tz.posix) |posix| {
                if (std.mem.eql(u8, posix.std_designation(), designation)) {
                    break :offset posix.standard.utc_offset_seconds;
                } else if (std.mem.eql(u8, posix.dst_designation(), designation)) {
                    break :offset posix.dst.?.info.utc_offset_seconds;
                }
            }
            var i = tz.infos.len;
            while (i > 0) {
                i -= 1;
                const info = tz.infos[i];
                if (std.mem.eql(u8, info.designation, designation)) {
                    break :offset info.utc_offset_seconds;
                }
            }
            log.warn("Failed to find {s} offset: Zone {s} does not use this designation", .{ designation, zone });
            return;
        };
        try w.print(
            \\
            \\        pub const {f} = {};
            , .{ std.zig.fmtId(designation), utc_offset_seconds }
        );
    }
};

const Zone_Or_Region = union (enum) {
    zone: []const u8,
    link: *const Link,
    region: u32,
};

const Region = struct {
    name: []const u8,
    children: std.ArrayList(Zone_Or_Region) = .empty,

    pub fn sort_children(self: *Region, regions: []const Region) void {
        const Region_Child_Sort_Context = struct {
            regions: []const Region,

            pub fn lessThan(ctx: @This(), a: Zone_Or_Region, b: Zone_Or_Region) bool {
                return std.ascii.lessThanIgnoreCase(ctx.name(a), ctx.name(b));
            }

            fn name(ctx: @This(), a: Zone_Or_Region) []const u8 {
                return switch (a) {
                    .zone => |zone_name| last_part(zone_name),
                    .link => |l| last_part(l.source),
                    .region => |index| return ctx.regions[index].name,
                };
            }
        };
        const ctx: Region_Child_Sort_Context = .{
            .regions = regions,
        };
        std.sort.block(Zone_Or_Region, self.children.items, ctx, Region_Child_Sort_Context.lessThan);
    }
};

const Transition = struct {
    ts: i64,
    time_type_index: u8,
    dont_merge: bool,
};

const Year_Range = struct {
    min: Year,
    max: Year,

    pub fn init(year: Year) Year_Range {
        return .{
            .min = year,
            .max = year,
        };
    }

    pub fn union_year(self: Year_Range, year: Year) Year_Range {
        return .{
            .min = .from_number(@min(self.min.as_number(), year.as_number())),
            .max = .from_number(@max(self.max.as_number(), year.as_number())),
        };
    }

    pub fn union_range(self: Year_Range, other: Year_Range) Year_Range {
        return .{
            .min = .from_number(@min(self.min.as_number(), other.min.as_number())),
            .max = .from_number(@max(self.max.as_number(), other.max.as_number())),
        };
    }

    pub fn contains(self: Year_Range, year: Year) bool {
        return !year.is_before(self.min) and !year.is_after(self.max);
    }
};

fn parse_hms(str: []const u8) !Time {
    errdefer log.info("Parsing hms: \"{f}\"", .{ std.zig.fmtString(str) });
    const negative = std.mem.startsWith(u8, str, "-");
    const abs_str = if (negative) str[1..] else str;
    var seconds: i32 = 0;
    var iter = std.mem.splitScalar(u8, abs_str, ':');
    if (iter.next()) |h_str| {
        if (h_str.len > 0) {
            seconds += @as(i32, std.time.s_per_hour) * try std.fmt.parseInt(u8, h_str, 10);
        }
    }
    if (iter.next()) |m_str| {
        if (m_str.len > 0) {
            seconds += @as(i32, std.time.s_per_min) * try std.fmt.parseInt(u8, m_str, 10);
        }
    }
    if (iter.next()) |s_str| {
        if (s_str.len > 0) {
            seconds += try std.fmt.parseInt(u8, s_str, 10);
        }
    }
    if (iter.next()) |_| return error.ExpectedEndOfHmsField;
    if (negative) seconds *= -1;
    return @enumFromInt(seconds * std.time.ms_per_s);
}

fn last_part(bytes: []const u8) []const u8 {
    if (std.mem.findScalarLast(u8, bytes, '/')) |slash| {
        return bytes[slash + 1 ..];
    }
    return bytes;
}

fn fmt_id_lower(bytes: []const u8) Format_Identifier_Lowercase {
    return .{ .bytes = bytes };
}

const Format_Identifier_Lowercase = struct {
    bytes: []const u8,

    /// Print the string as a Zig identifier, escaping it with `@""` syntax if needed.
    /// All uppercase ASCII characters are replaced with lowercase.
    pub fn format(ctx: Format_Identifier_Lowercase, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        const bytes = ctx.bytes;
        if (is_valid_id(bytes) and !std.zig.isPrimitive(bytes) and !std.zig.isUnderscore(bytes)) {
            for (bytes) |byte| {
                try writer.writeByte(std.ascii.toLower(byte));
            }
            return;
        }
        try writer.writeAll("@\"");
        try string_escape(bytes, writer);
        try writer.writeByte('"');
    }

    pub fn is_valid_id(bytes: []const u8) bool {
        if (bytes.len == 0) return false;
        for (bytes, 0..) |c, i| {
            switch (c) {
                '_', 'a'...'z', 'A'...'Z' => {},
                '0'...'9' => if (i == 0) return false,
                else => return false,
            }
        }
        return std.zig.Token.getKeyword(bytes) == null;
    }

    pub fn string_escape(bytes: []const u8, w: *std.Io.Writer) std.Io.Writer.Error!void {
        for (bytes) |byte| switch (byte) {
            '\n' => try w.writeAll("\\n"),
            '\r' => try w.writeAll("\\r"),
            '\t' => try w.writeAll("\\t"),
            '\\' => try w.writeAll("\\\\"),
            '"' => try w.writeAll("\\\""),
            '\'' => try w.writeByte('\''),
            ' ', '!', '#'...'&', '('...'[', ']'...'~' => try w.writeByte(std.ascii.toLower(byte)),
            else => {
                try w.writeAll("\\x");
                try w.printInt(byte, 16, .lower, .{ .width = 2, .fill = '0' });
            },
        };
    }

};

const log = std.log.scoped(.generate_tzdb);

const Week_Day = tempora.Week_Day;
const Month = tempora.Month;
const Day = tempora.Day;
const Year = tempora.Year;
const Time = tempora.Time;
const Date = tempora.Date;
const Date_Time = tempora.Date_Time;
const Timezone = tempora.Timezone;
const tempora = @import("tempora");
const build_options = @import("build_options");
const std = @import("std");
