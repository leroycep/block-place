const std = @import("std");
const api = @import("block-place-api");

export const PLUGIN_INFO_NAME = "xyz.geemili.default";
export const PLUGIN_INFO_VERSION_MAJOR: u32 = 0;
export const PLUGIN_INFO_VERSION_MINOR: u32 = 1;
export const PLUGIN_INFO_VERSION_PATCH: u32 = 0;

pub const allocator = std.heap.page_allocator;

export fn realloc(old_ptr: [*]u8, old_len: usize, new_byte_count: usize) ?[*]u8 {
    const old_mem = old_ptr[0..old_len];
    const new_mem = allocator.realloc(old_mem, new_byte_count) catch {
        const msg = "OutOfMemory error!";
        api.warn(msg, msg.len);
        return null;
    };
    return new_mem.ptr;
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
