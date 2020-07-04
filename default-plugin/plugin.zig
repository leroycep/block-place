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
        return null;
    };
    return new_mem.ptr;
}

export fn on_enable(plugin: *api.Plugin) void {
    api.register_player_join_listener(plugin, on_player_join);
}

fn on_player_join(plugin: *api.Plugin, server: *api.Server, event: *api.Event, player: *api.Player) callconv(.C) void {
    const msg = "A player has joined the server!\n";
    api.warn(msg, msg.len);
}
