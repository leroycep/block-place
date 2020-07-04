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

pub fn linker_define(linker: *wasmtime_linker_t, module: [:0]const u8, name: [:0]const u8, item: *const wasm_extern_t) !void {
    var module_bytes = to_byte_vec(module);
    defer wasm_byte_vec_delete(&module_bytes);

    var name_bytes = to_byte_vec(name);
    defer wasm_byte_vec_delete(&name_bytes);

    if (wasmtime_linker_define(linker, &module_bytes, &name_bytes, item)) |err| {
        var message: wasm_name_t = undefined;
        wasmtime_error_message(err, &message);
        defer wasm_byte_vec_delete(&message);

        const message_slice = message.data[0..message.size];
        std.debug.warn("Wasm error: {}\n", .{message_slice});

        return error.WasmLinker;
    }
}

pub fn to_byte_vec(slice: [:0]const u8) wasm_byte_vec_t {
    var vec: wasm_byte_vec_t = undefined;
    wasm_byte_vec_new(&vec, slice.len, slice.ptr);
    return vec;
}

pub const ValKind = enum(u8) {
    i32 = WASM_I32,
    i64 = WASM_I64,
    f32 = WASM_F32,
    f64 = WASM_F64,
    AnyRef = WASM_ANYREF,
    FuncRef = WASM_FUNCREF,
    _,
};

const WasmCallbackWithCaller = fn (caller: ?*const wasmtime_caller_t, args: ?[*]const wasm_val_t, results: ?[*]wasm_val_t) callconv(.C) ?*wasm_trap_t;

pub fn create_func_with_caller(store: *wasm_store_t, params: []const ValKind, results: []const ValKind, callback: WasmCallbackWithCaller) !*wasm_extern_t {
    var params_vec: wasm_valtype_vec_t = undefined;
    wasm_valtype_vec_new_uninitialized(&params_vec, params.len);
    defer wasm_valtype_vec_delete(&params_vec);
    for (params) |param_kind, idx| {
        params_vec.data[idx] = wasm_valtype_new(@enumToInt(param_kind));
    }

    var results_vec: wasm_valtype_vec_t = undefined;
    wasm_valtype_vec_new_uninitialized(&results_vec, results.len);
    defer wasm_valtype_vec_delete(&results_vec);
    for (results) |result_kind, idx| {
        results_vec.data[idx] = wasm_valtype_new(@enumToInt(result_kind));
    }

    const func_type = wasm_functype_new(&params_vec, &results_vec);
    const func = wasmtime_func_new(store, func_type, callback);
    return wasm_func_as_extern(func) orelse {
        return error.FuncAsExtern;
    };
}

pub fn create_func_with_env(store: *wasm_store_t, params: []const ValKind, results: []const ValKind, callback: wasm_func_callback_with_env_t, env: ?*c_void) !*wasm_extern_t {
    var params_vec: wasm_valtype_vec_t = undefined;
    wasm_valtype_vec_new_uninitialized(&params_vec, params.len);
    defer wasm_valtype_vec_delete(&params_vec);
    for (params) |param_kind, idx| {
        params_vec.data[idx] = wasm_valtype_new(@enumToInt(param_kind));
    }

    var results_vec: wasm_valtype_vec_t = undefined;
    wasm_valtype_vec_new_uninitialized(&results_vec, results.len);
    defer wasm_valtype_vec_delete(&results_vec);
    for (results) |result_kind, idx| {
        results_vec.data[idx] = wasm_valtype_new(@enumToInt(result_kind));
    }

    const func_type = wasm_functype_new(&params_vec, &results_vec);
    const func = wasm_func_new_with_env(store, func_type, callback, env, null);
    return wasm_func_as_extern(func) orelse {
        return error.FuncAsExtern;
    };
}
