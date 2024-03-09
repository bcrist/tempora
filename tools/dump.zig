pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try tempora.tzdb.init_cache(gpa.allocator());
    defer tempora.tzdb.deinit_cache();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var writer = std.io.getStdOut().writer();

    if (args.len < 2) {
        std.log.err("Timezone name is required", .{});
        return 1;
    }

    const show_transitions = args.len >= 3 and std.mem.eql(u8, "--transitions", args[2]);

    if (try tempora.tzdb.timezone(args[1])) |tz| {
        if (tz.posix_tz) |ptz| {
            try writer.print("POSIX timezone string: {}\n", .{ ptz });
        }

        const now = std.time.timestamp();
        const zi = tz.zone_info(now);
        try writer.print("Current Time: {YYYY-MM-DD HH;mm;ss z}  offset={}s  dst={}  source={s}\n", .{
            tempora.Date_Time.from_timestamp_s(now, null).fmt_utc(tz),
            zi.offset,
            zi.is_dst,
            @tagName(zi.source),
        });

        if (zi.end_ts) |end_ts| {
            if (zi.begin_ts) |begin_ts| {
                if (zi.is_dst) {
                    try writer.print("    DST began: {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(begin_ts, null).fmt_utc(tz) });
                    try writer.print("    DST ends:  {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(end_ts, null).fmt_utc(tz) });
                } else {
                    try writer.print("    DST ended:  {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(begin_ts, null).fmt_utc(tz) });
                    try writer.print("    DST begins: {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(end_ts, null).fmt_utc(tz) });
                }
            } else if (zi.is_dst) {
                try writer.print("    DST ends:  {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(end_ts, null).fmt_utc(tz) });
            } else {
                try writer.print("    DST begins: {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(end_ts, null).fmt_utc(tz) });
            }
        } else if (zi.begin_ts) |begin_ts| {
            if (zi.is_dst) {
                try writer.print("    This timezone has permanent daylight time\n", .{});
            } else {
                try writer.print("    This timezone has permanent standard time\n", .{});
            }
            try writer.print("    The current time rules for this zone began on {YYYY-MM-DD HH;mm;ss z}\n", .{ tempora.Date_Time.from_timestamp_s(begin_ts, null).fmt_utc(tz) });
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

        return 0;
    } else {
        try writer.print("No timezone found with name {s}.  Valid IDs are:\n", .{ args[1] });

        for (tempora.tzdb.ids) |id| {
            try writer.print("    {s}\n", .{ id });
        }
        return 1;
    }
}

const tempora = @import("tempora");
const std = @import("std");
