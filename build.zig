const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("tempora", .{
        .root_source_file = b.path("src/tempora.zig"),
    });

    const update_tzdb_exe = b.addExecutable(.{
        .name = "update_tzdb",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/update_tzdb.zig"),
            .target = b.graph.host,
            .optimize = .ReleaseSafe,
            .imports = &.{
                .{ .name = "tempora", .module = module },
            },
        }),
    });
    b.installArtifact(update_tzdb_exe);

    _ = b.step("update_tzdb", "Rebuild tzdb data from the current host's /usr/share/zoneinfo/").dependOn(&b.addRunArtifact(update_tzdb_exe).step);

    const dump_exe = b.addExecutable(.{
        .name = "dump",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/dump.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "tempora", .module = module },
            },
        }),
    });
    b.installArtifact(dump_exe);

    const run_all_tests = b.step("test", "Run all tests");

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/tempora.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    run_all_tests.dependOn(&b.addRunArtifact(tests).step);

    const parser_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/parse_tzif.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "tempora", .module = module },
            },
        }),
    });
    run_all_tests.dependOn(&b.addRunArtifact(parser_tests).step);
}
