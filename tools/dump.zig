pub fn main(init: std.process.Init) !void {
    const now = std.Io.Clock.real.now(init.io).toSeconds();

    var tzdb: tempora.TZDB = .init(init);
    defer tzdb.deinit();

    var stdout_buf: [64]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &stdout_buf);
    var writer = &stdout.interface;

    var args_iter = try init.minimal.args.iterateAllocator(init.arena.allocator());
    defer args_iter.deinit();
    _ = args_iter.skip();
    const args_iter_initial = args_iter;

    var debug = false;
    var system = false;
    var dump_count: usize = 0;
    var exit_code: u8 = 0;

    while (args_iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "--debug")) {
            debug = true;
            continue;
        }
        if (std.mem.eql(u8, arg, "--system")) {
            system = true;
            continue;
        }
        if (std.mem.startsWith(u8, arg, "--")) {
            cli_log.err("Unrecognized option: {s}", .{ arg });
        }
    }

    if (system) {
        tzdb.default_lazy_options = &.system(init.environ_map);
    } else {
        try tzdb.add_lazy(tempora.tz.all, &.embedded);
    }

    args_iter = args_iter_initial;
    while (args_iter.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "--")) continue;
        dump_count += 1;
        if (tzdb.timezone(arg)) |tz| {
            try dump_zone(tz, now, debug, writer);
        } else {
            cli_log.warn("No timezone found with name {s}", .{ arg });
            exit_code = 1;
        }
    }

    if (dump_count == 0) {
        try tzdb.add_current(init.io, .system(init.environ_map));
        try dump_zone(&tzdb.local, now, debug, writer);
    }

    try writer.flush();
    if (exit_code != 0) std.process.exit(exit_code);
}

fn dump_zone(tz: *const tempora.Timezone, now: i64, show_debug: bool, writer: *std.Io.Writer) !void {
    const wall = tz.info(now);
    try writer.print("Current Time: {f}  offset={}s  dst={t}  source={t}\n", .{
        tempora.Date_Time.With_Offset.from_timestamp_s(now, null).in_timezone(tz).fmt("YYYY-MM-DD HH:mm:ss z"),
        wall.utc_offset_seconds,
        wall.dst,
        wall.source,
    });

    if (wall.end_ts) |end_ts| {
        const end_dt = tempora.Date_Time.With_Offset.from_timestamp_s(end_ts, null).in_timezone(tz);
        if (wall.begin_ts) |begin_ts| {
            const begin_dt = tempora.Date_Time.With_Offset.from_timestamp_s(begin_ts, null).in_timezone(tz);

            if (wall.dst == .dst) {
                try writer.print("    DST began: {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                try writer.print("    DST ends:  {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
            } else {
                try writer.print("    DST ended:  {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                try writer.print("    DST begins: {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
            }
        } else if (wall.dst == .dst) {
            try writer.print("    DST ends:  {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
        } else {
            try writer.print("    DST begins: {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
        }
    } else if (wall.begin_ts) |begin_ts| {
        const begin_dt = tempora.Date_Time.With_Offset.from_timestamp_s(begin_ts, null).in_timezone(tz);
        if (wall.dst == .dst) {
            try writer.print("    This timezone has permanent daylight time\n", .{});
        } else {
            try writer.print("    This timezone has permanent standard time\n", .{});
        }
        try writer.print("    The current time rules for this zone began on {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
    } else {
        if (wall.dst == .dst) {
            try writer.print("    This timezone has permanent daylight time\n", .{});
        } else {
            try writer.print("    This timezone has permanent standard time\n", .{});
        }
    }

    if (show_debug) {
        try tz.debug(writer);
    }

    try writer.flush();
}

const cli_log = std.log.scoped(.cli);

const tempora = @import("tempora");
const std = @import("std");
