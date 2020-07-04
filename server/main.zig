const std = @import("std");
usingnamespace @import("./c.zig");
const Plugin = @import("./plugin.zig").Plugin;

const MAX_WASM_SIZE = 10 * 1024 * 1024;

const Listener = struct {
    plugin: *Plugin,
    function: u32,
};

const Server = struct {
    allocator: *std.mem.Allocator,
    host: *ENetHost,
    next_client_id: u32,
    plugins: std.AutoHashMap(u32, *Plugin),
    player_join_listeners: std.ArrayList(Listener),

    pub fn init(allocator: *std.mem.Allocator) @This() {
        return @This(){
            .allocator = allocator,
            .host = undefined,
            .next_client_id = 1,
            .plugins = std.AutoHashMap(u32, *Plugin).init(allocator),
            .player_join_listeners = std.ArrayList(Listener).init(allocator),
        };
    }

    pub fn deinit(self: @This()) void {
        self.player_join_listeners.deinit();
    }
};

pub fn main() anyerror!void {
    const allocator = std.heap.c_allocator;

    const engine_config = wasm_config_new();
    wasmtime_config_wasm_bulk_memory_set(engine_config, true);

    const engine = wasm_engine_new_with_config(engine_config) orelse return error.WasmEngine;
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
        var message: wasm_name_t = undefined;
        wasmtime_error_message(err, &message);
        const message_slice = message.data[0..message.size];
        std.debug.warn("Wasm error: {}\n", .{message_slice});
        return error.WasmCompile;
    }
    defer wasm_module_delete(module_opt);
    const module = module_opt.?;

    var server = Server.init(allocator);

    // define env::warn
    const warn_func = try create_wasm_func_with_caller(store, &[_]ValKind{ .i32, .i32 }, &[_]ValKind{}, warn_callback);
    try linker_define(linker, "env", "warn", warn_func);

    const register_player_join_listener_func = try create_wasm_func_with_env(store, &[_]ValKind{ .i32, .i32 }, &[_]ValKind{}, register_player_join_listener_callback, &server);
    try linker_define(linker, "env", "register_player_join_listener", register_player_join_listener_func);

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

    var plugin = try Plugin.from_module_and_instance(allocator, module, instance);
    defer plugin.deinit(allocator);

    std.debug.warn("Loading plugin \"{}\" version {}\n", .{ plugin.name, plugin.version });

    const name = "geemili";
    const name_wasm = try plugin.wasm_alloc(name.len);
    std.mem.copy(u8, name_wasm.span(), name);

    const greeting_params = [_]wasm_val_t{
        .{ .kind = WASM_I32, .of = .{ .i32 = @bitCast(u32, name_wasm.ptr) } },
        .{ .kind = WASM_I32, .of = .{ .i32 = @bitCast(u32, name_wasm.len) } },
    };
    if (wasmtime_func_call(plugin.greeting_fn, &greeting_params, greeting_params.len, null, 0, &trap)) |err| {
        var message: wasm_name_t = undefined;
        wasmtime_error_message(err, &message);
        const message_slice = message.data[0..message.size];
        std.debug.warn("Wasm error: {}\n", .{message_slice});
        return error.WasmCallGreeting;
    }

    // Initialize enet library
    if (enet_initialize() != 0) {
        return error.ENetInitialize;
    }
    defer enet_deinitialize();

    var address: ENetAddress = undefined;

    address.host = ENET_HOST_ANY;
    address.port = 41800;

    server.host = enet_host_create(&address, 32, 2, 0, 0) orelse return error.ENetCreateHost;
    defer enet_host_destroy(server.host);

    std.debug.warn(" == Server started at {}:{} == \n", .{ address.host, address.port });

    var next_client_id: usize = 0;

    const plugin_id = 1234;
    plugin.id = plugin_id;
    _ = try server.plugins.put(plugin_id, &plugin);

    std.debug.warn("Enabling \"{}\"\n", .{plugin.name});
    const on_enable_params = [_]wasm_val_t{.{ .kind = WASM_I32, .of = .{ .i32 = plugin_id } }};
    if (wasmtime_func_call(plugin.on_enable_fn, &on_enable_params, on_enable_params.len, null, 0, &trap)) |err| {
        return error.PluginEnable;
    }

    var event: ENetEvent = undefined;
    while (true) {
        _ = enet_host_service(server.host, &event, 5000);
        switch (event.type) {
            .ENET_EVENT_TYPE_CONNECT => {
                std.debug.warn("A new client (id={}) connected from {}:{}.\n", .{ next_client_id, event.peer.*.address.host, event.peer.*.address.port });

                event.peer.*.data = @intToPtr(?*c_void, next_client_id);
                defer next_client_id += 1;

                for (server.player_join_listeners.items) |listener| {
                    const func = listener.plugin.get_callback(listener.function);

                    const callback_params = [_]wasm_val_t{
                        .{ .kind = WASM_I32, .of = .{ .i32 = @bitCast(u32, listener.plugin.id) } },
                        .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
                        .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
                        .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
                    };
                    if (wasmtime_func_call(func, &callback_params, callback_params.len, null, 0, &trap)) |err| {
                        var message: wasm_name_t = undefined;
                        wasmtime_error_message(err, &message);
                        const message_slice = message.data[0..message.size];
                        std.debug.warn("Wasm error: {}\n", .{message_slice});
                        return error.WasmPlayerJoinCallback;
                    }
                }

                const msg = try std.fmt.allocPrint(allocator, "{} has joined the server", .{next_client_id});
                const packet = enet_packet_create(msg.ptr, msg.len, ENET_PACKET_FLAG_RELIABLE);
                enet_host_broadcast(server.host, 0, packet);
            },
            .ENET_EVENT_TYPE_RECEIVE => {
                defer enet_packet_destroy(event.packet);

                const id = @ptrToInt(event.peer.*.data);
                const data = event.packet.*.data[0..event.packet.*.dataLength];

                std.debug.warn("A packet of length {} received from {} on channel {}.\n", .{ event.packet.*.dataLength, id, event.channelID });

                if (event.channelID == 0) {
                    const msg = try std.fmt.allocPrint(allocator, "<{}> {}", .{ id, data });
                    const packet = enet_packet_create(msg.ptr, msg.len, ENET_PACKET_FLAG_RELIABLE);
                    enet_host_broadcast(server.host, 0, packet);
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

fn register_player_join_listener_callback(env: ?*c_void, args: ?[*]const wasm_val_t, results: ?[*]wasm_val_t) callconv(.C) ?*wasm_trap_t {
    const server = @ptrCast(*Server, @alignCast(@alignOf(*Server), env));

    const plugin_id = @bitCast(u32, args.?[0].of.i32);
    const plugin = server.plugins.getValue(plugin_id) orelse {
        std.debug.warn("`register_player_join_listener` called with invalid plugin id\n", .{});
        return null;
    };
    const function = @bitCast(u32, args.?[1].of.i32);

    server.player_join_listeners.append(.{ .plugin = plugin, .function = function }) catch |err| {
        std.debug.warn("`register_player_join_listener` failed to add listener: {}\n", .{err});
        return null;
    };

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

const WasmCallbackWithCaller = fn (caller: ?*const wasmtime_caller_t, args: ?[*]const wasm_val_t, results: ?[*]wasm_val_t) callconv(.C) ?*wasm_trap_t;

fn create_wasm_func_with_caller(store: *wasm_store_t, params: []const ValKind, results: []const ValKind, callback: WasmCallbackWithCaller) !*wasm_extern_t {
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

fn create_wasm_func_with_env(store: *wasm_store_t, params: []const ValKind, results: []const ValKind, callback: wasm_func_callback_with_env_t, env: ?*c_void) !*wasm_extern_t {
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
