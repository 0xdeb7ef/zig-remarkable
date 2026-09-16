const std = @import("std");

const targets = @import("src/Targets.zig");
pub const Device = targets.Device;
pub const query = targets.query;
pub const resolve = targets.resolve;

pub fn build(b: *std.Build) void {
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/Targets.zig"),
            .target = b.graph.host,
        }),
    });
    const run_tests = b.addRunArtifact(tests);

    b.step("test", "Run tests")
        .dependOn(&run_tests.step);

    const check = b.step("check", "Check step for zls");
    check.dependOn(&run_tests.step);
}
