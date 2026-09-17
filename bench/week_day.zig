pub fn main(init: std.process.Init) !void {
    try console.init(init.io);
    defer console.deinit(init.io);

    const stdout: std.Io.File = .stdout();

    var bench = zbench.Benchmark.init(init.gpa, .{});
    defer bench.deinit();

    try bench.addParam("oracle", @as(*const Bench(wd.oracle), &.{}), .{});
    try bench.addParam("oracle2", @as(*const Bench(wd.oracle2), &.{}), .{});
    try bench.addParam("hinnant", @as(*const Bench(wd.hinnant), &.{}), .{});
    try bench.addParam("neri", @as(*const Bench(wd.neri), &.{}), .{});
    try bench.addParam("joffe_limited", @as(*const Bench(wd.joffe_limited), &.{}), .{});
    try bench.addParam("joffe_shift", @as(*const Bench(wd.joffe_shift), &.{}), .{});
    try bench.addParam("joffe_mul2", @as(*const Bench(wd.joffe_mul2), &.{}), .{});
    try bench.addParam("joffe_split", @as(*const Bench(wd.joffe_split), &.{}), .{});
    try bench.addParam("joffe_64b", @as(*const Bench(wd.joffe_64b), &.{}), .{});

    try bench.run(init.io, stdout);
}

fn Bench(comptime func: anytype) type {
    return struct {
        pub fn run(self: *@This(), _: std.mem.Allocator) void {
            _ = self;
            var n: wd.Date = @enumFromInt(wd.joffe_limited_min);
            while (@intFromEnum(n) <= wd.joffe_limited_max) : (n = n.next()) {
                std.mem.doNotOptimizeAway(func(n));
            }
        }
    };
}

const console = @import("console");
const zbench = @import("zbench");
const wd = @import("week_day");
const std = @import("std");