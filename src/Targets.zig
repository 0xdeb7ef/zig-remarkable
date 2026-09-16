const std = @import("std");

pub const Device = enum {
    rm1,
    rm2,
    rmpp,
    rmppm,
};

/// Returns the target query for the specified reMarkable device, including its
/// CPU architecture, model, features, operating system, ABI, and glibc version.
pub fn query(device: Device) std.Target.Query {
    return switch (device) {
        .rm1 => comptime fromZon(@import("targets/rm1.zon")),
        .rm2 => comptime fromZon(@import("targets/rm2.zon")),
        .rmpp => comptime fromZon(@import("targets/rmpp.zon")),
        .rmppm => comptime fromZon(@import("targets/rmppm.zon")),
    };
}

/// Resolves the target query for the specified reMarkable device using the build
/// system and returns the resolved target.
pub fn resolve(b: *std.Build, device: Device) std.Build.ResolvedTarget {
    return b.resolveTargetQuery(query(device));
}

fn fromZon(comptime data: anytype) std.Target.Query {
    const arch = @field(std.Target.Cpu.Arch, data.cpu.arch);
    const model = arch.parseCpuModel(data.cpu.name) catch
        @compileError("Unknown CPU model: " ++ data.cpu.name);

    const marker = "-" ++ data.abi ++ ".";
    const abi_start = std.mem.lastIndexOf(u8, data.triple, marker).?;

    const version_text = data.triple[abi_start + marker.len ..];
    const glibc_version = std.Target.Query.parseVersion(version_text) catch
        @compileError("Invalid glibc version: " ++ version_text);

    const cpu_defs = @field(std.Target, data.cpu.arch);

    var features: std.Target.Cpu.Feature.Set = .empty;
    inline for (data.cpu.features) |name| {
        features.addFeature(@intFromEnum(@field(cpu_defs.Feature, name)));
    }

    const model_features = model.toCpu(arch).features;

    var features_add = features;
    features_add.removeFeatureSet(model_features);

    return .{
        .abi = @field(std.Target.Abi, data.abi),
        .cpu_arch = arch,
        .cpu_model = .{ .explicit = model },
        .cpu_features_add = features_add,
        .cpu_features_sub = .empty,
        .os_tag = @field(std.Target.Os.Tag, data.os),
        .glibc_version = glibc_version,
    };
}
