const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("block-place", "client/main.zig");
    exe.linkLibC();
    exe.linkSystemLibrary("pathfinder_c");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("enet");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const server_exe = b.addExecutable("block-place-server", "server/main.zig");
    server_exe.linkLibC();
    server_exe.linkSystemLibrary("enet");
    server_exe.setTarget(target);
    server_exe.setBuildMode(mode);
    server_exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const run_server_cmd = server_exe.run();
    run_server_cmd.step.dependOn(b.getInstallStep());

    const run_server_step = b.step("run-server", "Run the server");
    run_server_step.dependOn(&run_server_cmd.step);
}
