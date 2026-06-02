pub fn main(init: std.process.Init) !void {
    try console.init(init.io);
    defer console.deinit(init.io);

    const years1k = try init.arena.allocator().alloc(i16, 1000);
    const years10k = try init.arena.allocator().alloc(i16, 10_000);
    const years100k = try init.arena.allocator().alloc(i16, 100_000);
    const years1M = try init.arena.allocator().alloc(i16, 1_000_000);

    @memset(years1k, 2000);
    @memset(years10k, 2000);
    @memset(years100k, 2000);
    @memset(years1M, 2000);

    var seed: u64 = undefined;
    init.io.random(std.mem.asBytes(&seed));
    var prng: std.Random.Xoshiro256 = .init(seed);
    var rnd = prng.random();
    for (years1k) |*y| {
        y.* += rnd.int(i15);
    }
    for (years10k) |*y| {
        y.* += rnd.int(i15);
    }
    for (years100k) |*y| {
        y.* += rnd.int(i15);
    }
    for (years1M) |*y| {
        y.* += rnd.int(i15);
    }
    // years1k[0] = 5_881_610;
    // years1k[1] = -5_877_610;

    const stdout: std.Io.File = .stdout();

    var bench = zbench.Benchmark.init(init.gpa, .{});
    defer bench.deinit();

    try bench.addParam("civil.years_to_days_alt (1k * 1000)", &Year_To_Days_Alt{ .years = years1k, .iterations = 1000 }, .{});
    try bench.addParam("civil.years_to_days_alt (10k * 100)", &Year_To_Days_Alt{ .years = years10k, .iterations = 100 }, .{});
    try bench.addParam("civil.years_to_days_alt (100k * 10)", &Year_To_Days_Alt{ .years = years100k, .iterations = 10 }, .{});
    try bench.addParam("civil.years_to_days_alt (1M)", &Year_To_Days_Alt{ .years = years1M, .iterations = 1 }, .{});

    try bench.addParam("civil.years_to_days (1k * 1000)", &Year_To_Days{ .years = years1k, .iterations = 1000 }, .{});
    try bench.addParam("civil.years_to_days (10k * 100)", &Year_To_Days{ .years = years10k, .iterations = 100 }, .{});
    try bench.addParam("civil.years_to_days (100k * 10)", &Year_To_Days{ .years = years100k, .iterations = 10 }, .{});
    try bench.addParam("civil.years_to_days (1M)", &Year_To_Days{ .years = years1M, .iterations = 1 }, .{});

    try bench.run(init.io, stdout);
}

const Year_To_Days_Alt = struct {
    years: []const i16,
    iterations: usize,

    pub fn run(self: *@This(), _: std.mem.Allocator) void {
        for (0..self.iterations) |_| {
            for (self.years) |y| {
                std.mem.doNotOptimizeAway(civil.year_to_days_alt(y));
            }
        }
    }
};

const Year_To_Days = struct {
    years: []const i16,
    iterations: usize,

    pub fn run(self: *@This(), _: std.mem.Allocator) void {
        for (0..self.iterations) |_| {
            for (self.years) |y| {
                std.mem.doNotOptimizeAway(civil.year_to_days(y));
            }
        }
    }
};

const console = @import("console");
const zbench = @import("zbench");
const civil = @import("civil");
const std = @import("std");