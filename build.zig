pub const Date_Time = tempora.Date_Time;
pub const Date = tempora.Date;
pub const Time = tempora.Time;
pub const Year = tempora.Year;
pub const Month = tempora.Month;
pub const Day = tempora.Day;
pub const Week_Day = tempora.Week_Day;
pub const Ordinal_Week = tempora.Ordinal_Week;
pub const Ordinal_Day = tempora.Ordinal_Day;
pub const ISO_Week_Date = tempora.ISO_Week_Date;
pub const ISO_Week = tempora.ISO_Week;
pub const Timezone = tempora.Timezone;
pub const TZDB = tempora.TZDB;
pub const tz = Timezone.tzdata;
pub const now_utc = tempora.now_utc;
pub const now_local = tempora.now_local;
pub const now = tempora.now;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("tempora", .{
        .root_source_file = b.path("src/tempora.zig"),
    });

    if (b.option(bool, "codegen", "Rebuild src/Timezone/tzdata.zig and src/Timezone/cldr.zig") orelse false) {
        codegen(b, module);
    }

    if (b.option(bool, "benchmarks", "Build benchmark executables") orelse false) {
        build_benchmarks(b, module);
    }

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

    const dump = b.addRunArtifact(dump_exe);
    if (@import("builtin").zig_version.minor >= 17) {
        dump.addPassthruArgs();
    } else {
        if (b.args) |args| dump.addArgs(args);
    }
    _ = b.step("dump", "Run dump utility").dependOn(&dump.step);

    const tempora_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "tempora", .module = module },
            },
        }),
    });

    const civil_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/civil.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "civil",
                    .module = b.createModule(.{
                        .root_source_file = b.path("src/civil.zig"),
                    }),
                },
            },
        }),
    });

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&b.addRunArtifact(tempora_tests).step);
    test_step.dependOn(&b.addRunArtifact(civil_tests).step);
}

fn codegen(b: *std.Build, tempora_module: *std.Build.Module) void {
    const generate_tzdb_options = b.addOptions();
    generate_tzdb_options.addOption(usize, "min_deflate_bytes_saved",
        b.option(usize, "min_deflate_bytes_saved", "If deflating a TZif file does not save at least this many bytes, it will be embedded uncompressed.  Defaults to 50") orelse 5);

    const generate_tzdb_exe = b.addExecutable(.{
        .name = "generate_tzdb",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/generate_tzdb.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
            .imports = &.{
                .{ .name = "tempora", .module = tempora_module },
                .{ .name = "build_options", .module = generate_tzdb_options.createModule() },
            },
        }),
    });
    b.installArtifact(generate_tzdb_exe);

    if (b.lazyDependency("tzdata", .{})) |tzdata| {
        const generate = b.addRunArtifact(generate_tzdb_exe);
        const data_zig = generate.addOutputFileArg("tzdata.zig");

        generate.addFileArg(tzdata.path("version"));
        generate.addFileArg(tzdata.path("backward"));
        generate.addFileArg(tzdata.path("africa"));
        generate.addFileArg(tzdata.path("antarctica"));
        generate.addFileArg(tzdata.path("asia"));
        generate.addFileArg(tzdata.path("australasia"));
        generate.addFileArg(tzdata.path("etcetera"));
        generate.addFileArg(tzdata.path("europe"));
        generate.addFileArg(tzdata.path("factory"));
        generate.addFileArg(tzdata.path("northamerica"));
        generate.addFileArg(tzdata.path("southamerica"));
        generate.addFileArg(tzdata.path("leapseconds"));

        const update = b.addUpdateSourceFiles();
        update.addCopyFileToSource(data_zig, "src/Timezone/tzdata.zig");

        b.getInstallStep().dependOn(&update.step);
    }

    const generate_cldr_exe = if (b.lazyDependency("xmlread", .{})) |xml_dep| exe: {
        const generate_cldr_exe = b.addExecutable(.{
            .name = "generate_cldr",
            .root_module = b.createModule(.{
                .root_source_file = b.path("tools/generate_cldr.zig"),
                .target = b.graph.host,
                .optimize = .Debug,
                .imports = &.{
                    .{ .name = "xml", .module = xml_dep.module("xml") },
                },
            }),
        });
        b.installArtifact(generate_cldr_exe);
        break :exe generate_cldr_exe;
    } else null;

    if (b.lazyDependency("cldr", .{})) |cldr| {
        if (generate_cldr_exe) |exe| {
            const generate = b.addRunArtifact(exe);
            const cldr_zig = generate.addOutputFileArg("cldr.zig");
            generate.addFileArg(cldr.path("common/supplemental/windowsZones.xml"));

            const update = b.addUpdateSourceFiles();
            update.addCopyFileToSource(cldr_zig, "src/Timezone/cldr.zig");

            b.getInstallStep().dependOn(&update.step);
        }
    }
}

fn build_benchmarks(b: *std.Build, tempora_module: *std.Build.Module) void {
    _ = tempora_module;
    const console_helper_dep = b.lazyDependency("console_helper", .{});
    if (b.lazyDependency("zbench", .{})) |zbench_dep| {
        const civil_module = b.createModule(.{
            .root_source_file = b.path("src/civil.zig"),
        });

        inline for ([_]std.builtin.OptimizeMode { .Debug, .ReleaseSafe, .ReleaseFast }) |optimize| {
            const civil_bench = b.addExecutable(.{
                .name = "benchmark_civil_" ++ @tagName(optimize),
                .root_module = b.createModule(.{
                    .root_source_file = b.path("bench/civil.zig"),
                    .target = b.graph.host,
                    .optimize = optimize,
                    .imports = &.{
                        .{ .name = "console", .module = console_helper_dep.?.module("console") },
                        .{ .name = "zbench", .module = zbench_dep.module("zbench") },
                        .{ .name = "civil", .module = civil_module },
                    },
                }),
            });
            b.installArtifact(civil_bench);
        }
    }
}

const tempora = @import("src/tempora.zig");
const std = @import("std");
