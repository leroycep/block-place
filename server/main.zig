const std = @import("std");
usingnamespace @import("./c.zig");
const wasmer = @import("wasmer");
const wasmer_import_t = wasmer.wasmer_import_t;
const wasmer_instance_t = wasmer.wasmer_instance_t;
const wasmer_instantiate = wasmer.wasmer_instantiate;

const plugin_api = @import("block-place-api");
const PluginInfo = plugin_api.PluginInfo;

const MAX_WASM_SIZE = 10 * 1024 * 1024;

pub fn main() anyerror!void {
    const allocator = std.heap.c_allocator;

    std.debug.warn("Loading plugins\n", .{});

    const env_module_name = "env";
    const env_module_name_bytes = wasmer.wasmer_byte_array{ .bytes = env_module_name, .bytes_len = env_module_name.len };

    const wasm_warn_params: []const wasmer.wasmer_value_tag = &[_]wasmer.wasmer_value_tag{ wasmer.WASM_I32, wasmer.WASM_I32 };
    const wasm_warn_returns: []const wasmer.wasmer_value_tag = &[_]wasmer.wasmer_value_tag{};
    const wasm_warn_import_func = wasmer.wasmer_import_func_new(@ptrCast(fn (?*c_void) callconv(.C) void, wasm_warn), wasm_warn_params.ptr, wasm_warn_params.len, wasm_warn_returns.ptr, wasm_warn_returns.len);

    var imports = [_]wasmer_import_t{.{
        .module_name = env_module_name_bytes,
        .import_name = .{ .bytes = WASM_WARN_NAME, .bytes_len = WASM_WARN_NAME.len },
        .tag = wasmer.WASM_FUNCTION,
        .value = .{ .func = wasm_warn_import_func },
    }};

    const wasm_bytes = try std.fs.cwd().readFileAlloc(allocator, "plugins/default-plugin.wasm", MAX_WASM_SIZE);

    var wasm_instance: *wasmer_instance_t = undefined;
    const compile_result = wasmer_instantiate(&wasm_instance, wasm_bytes.ptr, @intCast(u32, wasm_bytes.len), &imports, imports.len);
    defer wasmer.wasmer_instance_destroy(wasm_instance);

    if (compile_result != .WASMER_OK) {
        try print_wasmer_error(allocator);
        return error.PluginCompile;
    }

    // Get plugin info, print it out, and set the context data to the plugin info
    var plugin_info = get_plugin_info(allocator, wasm_instance) catch {
        try print_wasmer_error(allocator);
        return error.PluginInfo;
    };
    defer allocator.free(plugin_info.name);

    wasmer.wasmer_instance_context_data_set(wasm_instance, &plugin_info);

    std.debug.warn("Loading {} {}\n", .{ plugin_info.name, plugin_info.version });

    const response_value = callFunc(wasm_instance, "add_one", .{@as(i32, 24)}, i32);
    std.debug.warn("add_one({}) = {}\n", .{ 24, response_value });

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

fn get_plugin_info(allocator: *std.mem.Allocator, instance: *wasmer.wasmer_instance_t) !PluginInfo {
    // Get plugin info
    const ctx = wasmer.wasmer_instance_context_get(instance);
    const memory = wasmer.wasmer_instance_context_memory(ctx, 0);
    const data_ptr = wasmer.wasmer_memory_data(memory);
    const data_len = wasmer.wasmer_memory_data_length(memory);
    const data = data_ptr[0..data_len];

    const name_ptr = try callFunc(instance, "plugin_info_name_ptr", .{}, u32);
    const name_len = try callFunc(instance, "plugin_info_name_len", .{}, u32);

    return PluginInfo{
        .name = try std.mem.dupe(allocator, u8, data[name_ptr .. name_ptr + name_len]),
        .version = .{
            .major = try callFunc(instance, "plugin_info_version_major", .{}, u32),
            .minor = try callFunc(instance, "plugin_info_version_minor", .{}, u32),
            .patch = try callFunc(instance, "plugin_info_version_patch", .{}, u32),
        },
    };
}

// Call a function with the signature `fn() u32`
fn callFunc(instance: *wasmer.wasmer_instance_t, func_name: [:0]const u8, comptime params: var, comptime return_type: type) !return_type {
    // this array should be empty, but zig doesn't like passing 0 sized arrays to c
    comptime var generated_wasmer_params: [params.len]wasmer.wasmer_value_t = undefined;
    comptime {
        var i = 0;
        while (i < params.len) : (i += 1) {
            generated_wasmer_params[i] = switch (@TypeOf(params[i])) {
                i32 => .{ .tag = wasmer.WASM_I32, .value = .{ .I32 = params[i] } },
                else => @compileError("Unsupported parameter type"),
            };
        }
    }

    var dummy_params = [_]wasmer.wasmer_value_t{std.mem.zeroes(wasmer.wasmer_value_t)};

    const wasmer_params: []wasmer.wasmer_value_t = if (params.len != 0) &generated_wasmer_params else &dummy_params;

    var results = [_]wasmer.wasmer_value_t{std.mem.zeroes(wasmer.wasmer_value_t)};

    const call_result = wasmer.wasmer_instance_call(instance, func_name, wasmer_params.ptr, @intCast(u32, params.len), &results, 1);

    if (call_result != .WASMER_OK) {
        return error.WasmCall;
    }

    return switch (return_type) {
        u32 => @bitCast(u32, results[0].value.I32),
        i32 => results[0].value.I32,
        void => {},
        else => @compileError("Unsupported return type"),
    };
}

const WASM_WARN_NAME = "warn";

fn wasm_warn(ctx: *wasmer.wasmer_instance_context_t, str_ptr: u32, str_len: u32) callconv(.C) void {
    const memory = wasmer.wasmer_instance_context_memory(ctx, 0);
    const data_ptr = wasmer.wasmer_memory_data(memory);
    const data_len = wasmer.wasmer_memory_data_length(memory);
    const data = data_ptr[0..data_len];

    const str = data[str_ptr .. str_ptr + str_len];

    if (wasmer.wasmer_instance_context_data_get(ctx)) |ctx_data_ptr| {
        const plugin_info = @ptrCast(*PluginInfo, @alignCast(@alignOf(*PluginInfo), ctx_data_ptr));
        std.debug.warn("[{}] {}\n", .{ plugin_info.name, str });
    } else {
        std.debug.warn("[UNKNOWN] {}\n", .{str});
    }
}
