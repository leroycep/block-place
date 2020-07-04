const std = @import("std");
usingnamespace @import("./c.zig");

pub const MemoryView = struct {
    memory: *wasm_memory_t,
    ptr: u32,
    len: u32,

    pub fn span(self: @This()) []u8 {
        const data_ptr = wasm_memory_data(self.memory);
        const data_len = wasm_memory_data_size(self.memory);
        return data_ptr[self.ptr .. self.ptr + self.len];
    }
};

pub fn read_global(comptime T: type, memory: []const u8, ext: *wasm_extern_t) !T {
    switch (T) {
        u32 => return read_global_u32(memory, ext),
        []const u8 => return read_global_cstr(memory, ext),
        else => @compileError("Type not supported"),
    }
}

pub fn read_global_cstr(memory: []const u8, ext: *wasm_extern_t) ![]const u8 {
    var val: wasm_val_t = undefined;
    const global = wasm_extern_as_global(ext);
    wasm_global_get(global, &val);
    std.debug.assert(val.kind == WASM_I32);

    const ptr = @bitCast(u32, val.of.i32);
    const start = std.mem.readIntNative(u32, memory[ptr..][0..4]);

    const len = std.mem.indexOf(u8, memory[start..], "\x00") orelse return error.InvalidCStr;

    return memory[start .. start + len];
}

pub fn read_global_u32(memory: []const u8, ext: *wasm_extern_t) !u32 {
    var val: wasm_val_t = undefined;
    const global = wasm_extern_as_global(ext) orelse return error.ExternNotGlobal;
    wasm_global_get(global, &val);
    std.debug.assert(val.kind == WASM_I32);
    const ptr = @bitCast(u32, val.of.i32);
    return std.mem.readIntNative(u32, memory[ptr..][0..4]);
}
