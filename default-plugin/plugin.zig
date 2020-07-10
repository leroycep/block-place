const std = @import("std");
const api = @import("block-place-api");
const zee_alloc = @import("zee_alloc");

export const PLUGIN_INFO_NAME = "xyz.geemili.default";
export const PLUGIN_INFO_VERSION_MAJOR: u32 = 0;
export const PLUGIN_INFO_VERSION_MINOR: u32 = 1;
export const PLUGIN_INFO_VERSION_PATCH: u32 = 0;

pub const allocator = zee_alloc.ZeeAllocDefaults.wasm_allocator;

comptime {
    (zee_alloc.ExportC{
        .allocator = allocator,
        .realloc = true,
    }).run();
}

export fn on_enable(plugin: *api.Plugin) void {
    api.register_player_join_listener(plugin, on_player_join);
}

fn on_player_join(plugin: *api.Plugin, server: *api.Server, event: *api.Event, player: *api.Player) callconv(.C) void {
    var player_name_ptr: [*]u8 = undefined;
    var player_name_len: usize = undefined;
    api.player_name(player, plugin, &player_name_ptr, &player_name_len);
    const player_name = player_name_ptr[0..player_name_len];
    defer allocator.free(player_name);

    const msg = std.fmt.allocPrint(allocator, "{} has joined the server!", .{player_name}) catch return;
    defer allocator.free(msg);

    api.warn(msg.ptr, msg.len);
    api.server_broadcast_message(server, msg.ptr, msg.len);
}
