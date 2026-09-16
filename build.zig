const std = @import("std");

const targets = @import("src/Targets.zig");
pub const Device = targets.Device;
pub const query = targets.query;
pub const resolve = targets.resolve;

pub fn build(_: *std.Build) void {}
