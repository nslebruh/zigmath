const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zigmath", .{
        .root_source_file = .{.path = "./src/lib.zig"},
        .target = target,
        .optimize = optimize
    });

    _ = b.addModule("zglm", .{
        .root_source_file = .{.path = "./src/zglm.zig"},
        .target = target,
        .optimize = optimize
    });

    const vec_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/vec.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_vec_tests = b.addRunArtifact(vec_tests);

    const mat_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/mat.zig" },
        .target = target,
        .optimize = optimize
    });

    const run_mat_tests = b.addRunArtifact(mat_tests);

    const zglm_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/zglm.zig" },
        .target = target,
        .optimize = optimize
    });

    const run_zglm_tests = b.addRunArtifact(zglm_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_vec_tests.step);
    test_step.dependOn(&run_mat_tests.step);
    test_step.dependOn(&run_zglm_tests.step);
}
