const std = @import("std");
const wasm = @import("./wasm.zig");
const MemoryView = wasm.MemoryView;
usingnamespace @import("./c.zig");

pub const Plugin = struct {
    id: u32,
    name: []const u8,
    version: struct {
        major: u32,
        minor: u32,
        patch: u32,

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: var) @TypeOf(writer).Error!void {
            return std.fmt.format(writer, "{}.{}.{}", .{ self.major, self.minor, self.patch });
        }
    },
    memory: *wasm_memory_t,
    callback_table: *wasm_table_t,
    on_enable_fn: *wasm_func_t,
    realloc_fn: *wasm_func_t,

    pub fn from_module_and_instance(allocator: *std.mem.Allocator, module: *wasm_module_t, instance: *wasm_instance_t) !Plugin {
        const exports = try wasm.extract_exports(struct {
            memory: *wasm_memory_t,
            __indirect_function_table: *wasm_table_t,
            realloc: *wasm_func_t,
            on_enable: *wasm_func_t,
            PLUGIN_INFO_NAME: []const u8,
            PLUGIN_INFO_VERSION_MAJOR: u32,
            PLUGIN_INFO_VERSION_MINOR: u32,
            PLUGIN_INFO_VERSION_PATCH: u32,
        }, module, instance);

        return Plugin{
            .id = undefined,
            .name = try std.mem.dupe(allocator, u8, exports.PLUGIN_INFO_NAME),
            .version = .{
                .major = exports.PLUGIN_INFO_VERSION_MAJOR,
                .minor = exports.PLUGIN_INFO_VERSION_MINOR,
                .patch = exports.PLUGIN_INFO_VERSION_PATCH,
            },
            .memory = exports.memory,
            .callback_table = exports.__indirect_function_table,
            .on_enable_fn = exports.on_enable,
            .realloc_fn = exports.realloc,
        };
    }

    pub fn deinit(self: @This(), allocator: *std.mem.Allocator) void {
        allocator.free(self.name);
    }

    pub fn wasm_alloc(self: @This(), n_bytes: u32) !MemoryView {
        std.debug.warn("wasm_alloc (realloc {})\n", .{self.realloc_fn});
        defer std.debug.warn("end wasm_alloc\n", .{});
        const realloc_params = [_]wasm_val_t{
            .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
            .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
            .{ .kind = WASM_I32, .of = .{ .i32 = @intCast(i32, n_bytes) } },
        };
        var realloc_results = [_]wasm_val_t{
            std.mem.zeroes(wasm_val_t),
        };
        var trap: ?*wasm_trap_t = null;
        if (wasmtime_func_call(self.realloc_fn, &realloc_params, realloc_params.len, &realloc_results, realloc_results.len, &trap)) |err| {
            var message: wasm_name_t = undefined;
            wasmtime_error_message(err, &message);
            defer wasm_byte_vec_delete(&message);
            wasmtime_error_delete(err);

            const message_slice = message.data[0..message.size];
            std.debug.warn("Wasm error: {}\n", .{message_slice});
            return error.WasmCall;
        }
        if (trap != null) {
            std.debug.warn("Trap!\n", .{});
            var message: wasm_name_t = undefined;
            wasm_trap_message(trap, &message);
            defer wasm_byte_vec_delete(&message);
            wasm_trap_delete(trap);

            const message_slice = message.data[0..message.size];
            std.debug.warn("Wasm trap: {}\n", .{message_slice});
            return error.TrapNotNull;
        }
        std.debug.assert(realloc_results[0].kind == WASM_I32);
        const result = @bitCast(u32, realloc_results[0].of.i32);
        if (result == 0) {
            return error.OutOfMemory;
        }
        return MemoryView{ .memory = self.memory, .ptr = result, .len = n_bytes };
    }

    pub fn wasm_ptr(self: @This(), comptime T: type, ptr: u32) *T {
        const data_ptr = wasm_memory_data(self.memory);
        const data_len = wasm_memory_data_size(self.memory);
        if (ptr + @sizeOf(T) >= data_len) {
            unreachable; // Type goes out of bounds
        }
        return @ptrCast(*T, @alignCast(4, &data_ptr[ptr]));
    }

    pub fn get_callback(self: @This(), func_idx: u32) ?*wasm_func_t {
        var func_ref: ?*wasm_func_t = undefined;
        if (wasmtime_funcref_table_get(self.callback_table, func_idx, &func_ref))
            return func_ref
        else
            return null;
    }
};
