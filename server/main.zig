const std = @import("std");
usingnamespace @import("./c.zig");

const MAX_WASM_SIZE = 10 * 1024 * 1024;

pub fn main() anyerror!void {
    const allocator = std.heap.c_allocator;

    const engine = wasm_engine_new() orelse return error.WasmEngine;
    defer wasm_engine_delete(engine);

    const store = wasm_store_new(engine) orelse return error.WasmStore;
    defer wasm_store_delete(store);

    const linker = wasmtime_linker_new(store) orelse return error.WasmtimeLinker;
    defer wasmtime_linker_delete(linker);

    std.debug.warn("Loading plugins\n", .{});

    const wasm_byte_slice = try std.fs.cwd().readFileAlloc(allocator, "plugins/default-plugin.wasm", MAX_WASM_SIZE);
    defer allocator.free(wasm_byte_slice);
    const wasm_bytes = wasm_byte_vec_t{ .data = wasm_byte_slice.ptr, .size = wasm_byte_slice.len };

    var module_opt: ?*wasm_module_t = null;
    if (wasmtime_module_new(store, &wasm_bytes, &module_opt)) |err| {
        return error.WasmCompile;
    }
    defer wasm_module_delete(module_opt);
    const module = module_opt.?;

    // define env::warn
    const warn_func = try create_wasm_func(store, &[_]ValKind{ .i32, .i32 }, &[_]ValKind{}, warn_callback);
    try linker_define(linker, "env", "warn", warn_func);

    var trap: ?*wasm_trap_t = null;
    var instance_opt: ?*wasm_instance_t = null;
    if (wasmtime_linker_instantiate(linker, module, &instance_opt, &trap)) |err| {
        var message: wasm_name_t = undefined;
        wasmtime_error_message(err, &message);
        const message_slice = message.data[0..message.size];
        std.debug.warn("Wasm error: {}\n", .{message_slice});
        return error.WasmInstantiate;
    }
    const instance = instance_opt.?;

    const plugin = try get_plugin(allocator, module, instance);
    defer plugin.deinit(allocator);

    std.debug.warn("Loading plugin \"{}\" version {}\n", .{ plugin.name, plugin.version });

    std.debug.warn("Calling wasm function `add_one`\n", .{});

    const add_one_params = [_]wasm_val_t{.{ .kind = WASM_I32, .of = .{ .i32 = 24 } }};
    var add_one_results = [_]wasm_val_t{std.mem.zeroes(wasm_val_t)};
    if (wasmtime_func_call(plugin.add_one_fn, &add_one_params, add_one_params.len, &add_one_results, add_one_results.len, &trap)) |err| {
        return error.WasmCallAddOne;
    }

    std.debug.warn("add_one({}) = {}\n", .{ add_one_params[0].of.i32, add_one_results[0].of.i32 });

    // Initialize enet library
    if (enet_initialize() != 0) {
        return error.ENetInitialize;
    }
    defer enet_deinitialize();

    var address: ENetAddress = undefined;

    address.host = ENET_HOST_ANY;
    address.port = 41800;

    var server = enet_host_create(&address, 32, 2, 0, 0) orelse return error.ENetCreateHost;
    defer enet_host_destroy(server);

    std.debug.warn(" == Server started at {}:{} == \n", .{ address.host, address.port });

    var next_client_id: usize = 0;

    var event: ENetEvent = undefined;
    while (true) {
        _ = enet_host_service(server, &event, 5000);
        switch (event.type) {
            .ENET_EVENT_TYPE_CONNECT => {
                std.debug.warn("A new client (id={}) connected from {}:{}.\n", .{ next_client_id, event.peer.*.address.host, event.peer.*.address.port });

                event.peer.*.data = @intToPtr(?*c_void, next_client_id);
                defer next_client_id += 1;

                const msg = try std.fmt.allocPrint(allocator, "{} has joined the server", .{next_client_id});
                const packet = enet_packet_create(msg.ptr, msg.len, ENET_PACKET_FLAG_RELIABLE);
                enet_host_broadcast(server, 0, packet);
            },
            .ENET_EVENT_TYPE_RECEIVE => {
                defer enet_packet_destroy(event.packet);

                const id = @ptrToInt(event.peer.*.data);
                const data = event.packet.*.data[0..event.packet.*.dataLength];

                std.debug.warn("A packet of length {} received from {} on channel {}.\n", .{ event.packet.*.dataLength, id, event.channelID });

                if (event.channelID == 0) {
                    const msg = try std.fmt.allocPrint(allocator, "<{}> {}", .{ id, data });
                    const packet = enet_packet_create(msg.ptr, msg.len, ENET_PACKET_FLAG_RELIABLE);
                    enet_host_broadcast(server, 0, packet);
                }
            },
            .ENET_EVENT_TYPE_DISCONNECT => {
                const id = @ptrToInt(event.peer.*.data);
                std.debug.warn("{} has disconnected.\n", .{id});
                event.peer.*.data = null;
            },
            else => {},
        }
    }
}

fn print_wasmer_error(allocator: *std.mem.Allocator) !void {
    const error_len = wasmer.wasmer_last_error_length();
    var error_str = try allocator.alloc(u8, @intCast(usize, error_len));
    defer allocator.free(error_str);

    _ = wasmer.wasmer_last_error_message(error_str.ptr, @intCast(c_int, error_str.len));

    std.debug.warn("Error compiling plugin: {}\n", .{error_str});
}

const Plugin = struct {
    name: []const u8,
    version: struct {
        major: u32,
        minor: u32,
        patch: u32,

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: var) @TypeOf(writer).Error!void {
            return std.fmt.format(writer, "{}.{}.{}", .{ self.major, self.minor, self.patch });
        }
    },
    add_one_fn: *wasm_func_t,

    fn deinit(self: @This(), allocator: *std.mem.Allocator) void {
        allocator.free(self.name);
    }
};

fn get_plugin(allocator: *std.mem.Allocator, module: *wasm_module_t, instance: *wasm_instance_t) !Plugin {
    var memory_idx_opt: ?usize = null;
    var plugin_info_name_idx_opt: ?usize = null;
    var plugin_info_version_major_idx_opt: ?usize = null;
    var plugin_info_version_minor_idx_opt: ?usize = null;
    var plugin_info_version_patch_idx_opt: ?usize = null;
    var add_one_func_idx_opt: ?usize = null;

    {
        var exports: wasm_exporttype_vec_t = undefined;
        defer wasm_exporttype_vec_delete(&exports);
        wasm_module_exports(module, &exports);
        const exports_slice = exports.data[0..exports.size];
        for (exports_slice) |exp, idx| {
            const export_name_bytes = wasm_exporttype_name(exp);
            const export_name = export_name_bytes.*.data[0..export_name_bytes.*.size];
            const export_externtype = wasm_exporttype_type(exp);
            const export_externtype_kind = wasm_externtype_kind(export_externtype);
            const kind = @intToEnum(wasm_externkind_enum, export_externtype_kind);

            if (std.mem.eql(u8, export_name, "add_one")) {
                if (kind != .WASM_EXTERN_FUNC) {
                    return error.InvalidFormat; // add_one must be a function
                }
                add_one_func_idx_opt = idx;
            } else if (std.mem.eql(u8, export_name, "memory")) {
                if (kind != .WASM_EXTERN_MEMORY) {
                    return error.InvalidFormat; // "memory" must be memory
                }
                memory_idx_opt = idx;
            } else if (std.mem.eql(u8, export_name, "PLUGIN_INFO_NAME")) {
                if (kind != .WASM_EXTERN_GLOBAL) {
                    return error.InvalidFormat; // plugin info name must be a global
                }
                plugin_info_name_idx_opt = idx;
            } else if (std.mem.eql(u8, export_name, "PLUGIN_INFO_VERSION_MAJOR")) {
                if (kind != .WASM_EXTERN_GLOBAL) {
                    return error.InvalidFormat; // plugin info version major must be a global
                }
                plugin_info_version_major_idx_opt = idx;
            } else if (std.mem.eql(u8, export_name, "PLUGIN_INFO_VERSION_MINOR")) {
                if (kind != .WASM_EXTERN_GLOBAL) {
                    return error.InvalidFormat; // plugin info version minor must be a global
                }
                plugin_info_version_minor_idx_opt = idx;
            } else if (std.mem.eql(u8, export_name, "PLUGIN_INFO_VERSION_PATCH")) {
                if (kind != .WASM_EXTERN_GLOBAL) {
                    return error.InvalidFormat; // plugin info version patch must be a global
                }
                plugin_info_version_patch_idx_opt = idx;
            }
        }
    }

    const memory_idx = memory_idx_opt orelse return error.InvalidFormat;
    const plugin_info_name_idx = plugin_info_name_idx_opt orelse return error.InvalidFormat;
    const plugin_info_version_major_idx = plugin_info_version_major_idx_opt orelse return error.InvalidFormat;
    const plugin_info_version_minor_idx = plugin_info_version_minor_idx_opt orelse return error.InvalidFormat;
    const plugin_info_version_patch_idx = plugin_info_version_patch_idx_opt orelse return error.InvalidFormat;
    const add_one_func_idx = add_one_func_idx_opt orelse return error.InvalidFormat;

    var externs_vec: wasm_extern_vec_t = undefined;
    wasm_instance_exports(instance, &externs_vec);
    defer wasm_extern_vec_delete(&externs_vec);

    const externs = externs_vec.data[0..externs_vec.size];

    const memory_struct = wasm_extern_as_memory(externs[memory_idx]) orelse return error.WasmMemoryNotFirstExport;
    const memory_ptr = wasm_memory_data(memory_struct);
    const memory_len = wasm_memory_data_size(memory_struct);
    const memory = memory_ptr[0..memory_len];

    return Plugin{
        .name = try std.mem.dupe(allocator, u8, try read_global_cstr(memory, externs[plugin_info_name_idx].?)),
        .version = .{
            .major = try read_global_u32(memory, externs[plugin_info_version_major_idx].?),
            .minor = try read_global_u32(memory, externs[plugin_info_version_minor_idx].?),
            .patch = try read_global_u32(memory, externs[plugin_info_version_patch_idx].?),
        },
        .add_one_fn = wasm_extern_as_func(externs[add_one_func_idx]).?,
    };
}

fn read_global_cstr(memory: []const u8, ext: *wasm_extern_t) ![]const u8 {
    var val: wasm_val_t = undefined;
    const global = wasm_extern_as_global(ext);
    wasm_global_get(global, &val);
    std.debug.assert(val.kind == WASM_I32);

    const ptr = @bitCast(u32, val.of.i32);
    const start = std.mem.readIntNative(u32, memory[ptr..][0..4]);

    const len = std.mem.indexOf(u8, memory[start..], "\x00") orelse return error.InvalidCStr;

    return memory[start .. start + len];
}

fn read_global_u32(memory: []const u8, ext: *wasm_extern_t) !u32 {
    var val: wasm_val_t = undefined;
    const global = wasm_extern_as_global(ext) orelse return error.ExternNotGlobal;
    wasm_global_get(global, &val);
    std.debug.assert(val.kind == WASM_I32);
    const ptr = @bitCast(u32, val.of.i32);
    return std.mem.readIntNative(u32, memory[ptr..][0..4]);
}

const WasmCallback = fn (caller: ?*const wasmtime_caller_t, args: ?[*]const wasm_val_t, results: ?[*]wasm_val_t) callconv(.C) ?*wasm_trap_t;

fn warn_callback(caller: ?*const wasmtime_caller_t, args: ?[*]const wasm_val_t, results: ?[*]wasm_val_t) callconv(.C) ?*wasm_trap_t {
    const mem_extern = wasmtime_caller_export_get(caller, &to_byte_vec("memory"));
    const memory = wasm_extern_as_memory(mem_extern);
    const data_ptr = wasm_memory_data(memory);
    const data_len = wasm_memory_data_size(memory);
    const data = data_ptr[0..data_len];

    const str_ptr = @bitCast(u32, args.?[0].of.i32);
    const str_len = @bitCast(u32, args.?[1].of.i32);

    const str = data[str_ptr .. str_ptr + str_len];

    std.debug.warn("{}", .{str});

    return null;
}

fn to_byte_vec(slice: [:0]const u8) wasm_byte_vec_t {
    var vec: wasm_byte_vec_t = undefined;
    wasm_byte_vec_new(&vec, slice.len, slice.ptr);
    return vec;
}

fn linker_define(linker: *wasmtime_linker_t, module: [:0]const u8, name: [:0]const u8, item: *const wasm_extern_t) !void {
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

const ValKind = enum(u8) {
    i32 = WASM_I32,
    i64 = WASM_I64,
    f32 = WASM_F32,
    f64 = WASM_F64,
    AnyRef = WASM_ANYREF,
    FuncRef = WASM_FUNCREF,
    _,
};

fn create_wasm_func(store: *wasm_store_t, params: []const ValKind, results: []const ValKind, callback: WasmCallback) !*wasm_extern_t {
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
