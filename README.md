# zig-remarkable

Zig target presets for cross-compiling to reMarkable tablets.

## Supported devices

| Device                    | Preset   |
| ------------------------- | -------- |
| reMarkable 1              | `.rm1`   |
| reMarkable 2              | `.rm2`   |
| reMarkable Paper Pro      | `.rmpp`  |
| reMarkable Paper Pro Move | `.rmppm` |

## Installation

Add it to your `build.zig.zon` file:

```sh
zig fetch --save git+https://github.com/0xdeb7ef/zig-remarkable
```

## Usage

In your `build.zig`:

```zig
const std = @import("std");
const remarkable = @import("zig_remarkable");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const device = b.option(remarkable.Device, "device", "reMarkable device to target") orelse .rmpp;

    const target = remarkable.resolve(b, device);

    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);
}
```

Build for a device (reMarkable Paper Pro as an example):

```sh
zig build -Ddevice=rmpp -Doptimize=ReleaseFast
```

### Customizing a target

`resolve(b, device)` returns a `std.Build.ResolvedTarget`. Use `query(device)`
to obtain a `std.Target.Query` you can adjust before resolving:

```zig
var target_query = remarkable.query(.rmpp);
target_query.glibc_version = .{ .major = 2, .minor = 38, .patch = 0 };
const target = b.resolveTargetQuery(target_query);
```
