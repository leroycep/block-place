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

export fn add_one(a: i32) i32 {
    const msg = "Hello from wasm!\n";
    api.warn(msg, msg.len);
    return a + 1;
}

export fn greeting(name_ptr: [*]u8, name_len: usize) void {
    const name = name_ptr[0..name_len];
    const msg = std.fmt.allocPrint(allocator, "Hello, {}!\n", .{name}) catch return;
    defer allocator.free(msg);
    api.warn(msg.ptr, msg.len);
}
