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
    //var imports = [_]wasmer_import_t{};

    const wasm_bytes = try std.fs.cwd().readFileAlloc(allocator, "plugins/default-plugin.wasm", MAX_WASM_SIZE);

    var wasm_instance: *wasmer_instance_t = undefined;
    const compile_result = wasmer_instantiate(&wasm_instance, wasm_bytes.ptr, @intCast(u32, wasm_bytes.len), null, 0);
    defer wasmer.wasmer_instance_destroy(wasm_instance);

    if (compile_result != .WASMER_OK) {
        try print_wasmer_error(allocator);
        return error.PluginCompile;
    }

    const plugin_info = try get_plugin_info(allocator, wasm_instance);
    defer allocator.free(plugin_info.name);

    std.debug.warn("Loading {} {}\n", .{ plugin_info.name, plugin_info.version });

    var params = [_]wasmer.wasmer_value_t{
        .{ .tag = wasmer.WASM_I32, .value = .{ .I32 = 24 } },
    };
    var results = [_]wasmer.wasmer_value_t{
        std.mem.zeroes(wasmer.wasmer_value_t),
    };

    const call_result = wasmer.wasmer_instance_call(wasm_instance, "add_one", &params, 1, &results, 1);
    const response_value = results[0].value.I32;
    std.debug.warn("add_one({}) = {}\n", .{ params[0].value.I32, response_value });

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

    const name_ptr = try call_func_void_to_u32(instance, "plugin_info_name_ptr");
    const name_len = try call_func_void_to_u32(instance, "plugin_info_name_len");

    return PluginInfo{
        .name = try std.mem.dupe(allocator, u8, data[name_ptr .. name_ptr + name_len]),
        .version = .{
            .major = try call_func_void_to_u32(instance, "plugin_info_version_major"),
            .minor = try call_func_void_to_u32(instance, "plugin_info_version_minor"),
            .patch = try call_func_void_to_u32(instance, "plugin_info_version_patch"),
        },
    };
}

// Call a function with the signature `fn() u32`
fn call_func_void_to_u32(instance: *wasmer.wasmer_instance_t, func_name: [:0]const u8) !u32 {
    // this array should be empty, but zig doesn't like passing 0 sized arrays to c
    const dummy_params = [_]wasmer.wasmer_value_t{std.mem.zeroes(wasmer.wasmer_value_t)};
    var results = [_]wasmer.wasmer_value_t{std.mem.zeroes(wasmer.wasmer_value_t)};

    const call_result = wasmer.wasmer_instance_call(instance, func_name, &dummy_params, 0, &results, 1);

    if (call_result != .WASMER_OK) {
        return error.WasmCall;
    }

    return @bitCast(u32, results[0].value.I32);
}
