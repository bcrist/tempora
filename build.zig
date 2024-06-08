const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("tempora", .{
        .root_source_file = b.path("src/tempora.zig"),
    });

    const update_tzdb_exe = b.addExecutable(.{
        .name = "update_tzdb",
        .target = b.host,
        .optimize = .ReleaseSafe,
        .root_source_file = b.path("tools/update_tzdb.zig"),
    });
    update_tzdb_exe.root_module.addImport("tempora", module);
    const update_tzdb = b.addRunArtifact(update_tzdb_exe);
    _ = b.step("update_tzdb", "Rebuild tzdb data from the current host's /usr/share/zoneinfo/").dependOn(&update_tzdb.step);
    b.installArtifact(update_tzdb_exe);

    const dump_exe = b.addExecutable(.{
        .name = "dump",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("tools/dump.zig"),
    });
    dump_exe.root_module.addImport("tempora", module);
    b.installArtifact(dump_exe);

    const run_all_tests = b.step("test", "Run all tests");

    const tests = b.addTest(.{
        .root_source_file = b.path("src/tempora.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    run_all_tests.dependOn(&run_tests.step);

    const parser_tests = b.addTest(.{
        .root_source_file = b.path("test/parse_tzif.zig"),
        .target = target,
        .optimize = optimize,
    });
    parser_tests.root_module.addImport("tempora", module);
    const run_parser_tests = b.addRunArtifact(parser_tests);
    run_all_tests.dependOn(&run_parser_tests.step);
}
