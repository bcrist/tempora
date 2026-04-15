pub fn main(init: std.process.Init) !u8 {
    try tempora.tzdb.init_cache(.init(init));
    defer tempora.tzdb.deinit_cache();

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var stdout_buf: [64]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &stdout_buf);
    var writer = &stdout.interface;

    if (args.len < 2) {
        std.log.err("Timezone name is required", .{});
        return 1;
    }

    const show_transitions = args.len >= 3 and std.mem.eql(u8, "--transitions", args[2]);

    if (try tempora.tzdb.timezone(init.io, args[1])) |tz| {
        if (tz.posix_tz) |ptz| {
            try writer.print("POSIX timezone string: {f}\n", .{ ptz });
        }

        const now = std.Io.Clock.real.now(init.io).toSeconds();
        const zi = tz.zone_info(now);
        try writer.print("Current Time: {f}  offset={}s  dst={}  source={s}\n", .{
            tempora.Date_Time.With_Offset.from_timestamp_s(now, null).in_timezone(tz).fmt("YYYY-MM-DD HH:mm:ss z"),
            zi.offset,
            zi.is_dst,
            @tagName(zi.source),
        });

        if (zi.end_ts) |end_ts| {
            const end_dt = tempora.Date_Time.With_Offset.from_timestamp_s(end_ts, null).in_timezone(tz);
            if (zi.begin_ts) |begin_ts| {
                const begin_dt = tempora.Date_Time.With_Offset.from_timestamp_s(begin_ts, null).in_timezone(tz);

                if (zi.is_dst) {
                    try writer.print("    DST began: {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                    try writer.print("    DST ends:  {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                } else {
                    try writer.print("    DST ended:  {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                    try writer.print("    DST begins: {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
                }
            } else if (zi.is_dst) {
                try writer.print("    DST ends:  {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
            } else {
                try writer.print("    DST begins: {f}\n", .{ end_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
            }
        } else if (zi.begin_ts) |begin_ts| {
            const begin_dt = tempora.Date_Time.With_Offset.from_timestamp_s(begin_ts, null).in_timezone(tz);
            if (zi.is_dst) {
                try writer.print("    This timezone has permanent daylight time\n", .{});
            } else {
                try writer.print("    This timezone has permanent standard time\n", .{});
            }
            try writer.print("    The current time rules for this zone began on {f}\n", .{ begin_dt.fmt("YYYY-MM-DD HH:mm:ss z") });
        } else {
            if (zi.is_dst) {
                try writer.print("    This timezone has permanent daylight time\n", .{});
            } else {
                try writer.print("    This timezone has permanent standard time\n", .{});
            }
        }

        if (show_transitions) {
            try writer.print("{} transition times\n", .{tz.transitions.len});
            for (0.., tz.transitions.items(.ts), tz.transitions.items(.zone_index)) |n, ts, index| {
                const info = tz.zones[index];
                try writer.print("    [{}]: ts={}s  offset={}s  dst={}  designation={s}  source={s}\n", .{
                    n,
                    ts,
                    info.offset,
                    info.is_dst,
                    info.designation,
                    @tagName(info.source),
                });
            }
        }

        try writer.flush();
        return 0;
    } else {
        try writer.print("No timezone found with name {s}.  Valid IDs are:\n", .{ args[1] });

        for (tempora.tzdb.ids) |id| {
            try writer.print("    {s}\n", .{ id });
        }

        try writer.flush();
        return 1;
    }
}

const tempora = @import("tempora");
const std = @import("std");
