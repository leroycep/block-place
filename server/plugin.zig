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
        var memory_idx_opt: ?usize = null;
        var table_idx_opt: ?usize = null;
        var plugin_info_name_idx_opt: ?usize = null;
        var plugin_info_version_major_idx_opt: ?usize = null;
        var plugin_info_version_minor_idx_opt: ?usize = null;
        var plugin_info_version_patch_idx_opt: ?usize = null;
        var on_enable_func_idx_opt: ?usize = null;
        var realloc_fn_idx_opt: ?usize = null;

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

                if (std.mem.eql(u8, export_name, "on_enable")) {
                    if (kind != .WASM_EXTERN_FUNC) {
                        return error.InvalidFormat; // on_enable must be a function
                    }
                    on_enable_func_idx_opt = idx;
                } else if (std.mem.eql(u8, export_name, "memory")) {
                    if (kind != .WASM_EXTERN_MEMORY) {
                        return error.InvalidFormat; // "memory" must be memory
                    }
                    memory_idx_opt = idx;
                } else if (std.mem.eql(u8, export_name, "__indirect_function_table")) {
                    if (kind != .WASM_EXTERN_TABLE) {
                        return error.InvalidFormat; // "table" must be memory
                    }
                    table_idx_opt = idx;
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
                } else if (std.mem.eql(u8, export_name, "realloc")) {
                    if (kind != .WASM_EXTERN_FUNC) {
                        return error.InvalidFormat; // realloc must be a function
                    }
                    realloc_fn_idx_opt = idx;
                } else {
                    std.debug.warn("Unknown export: {}\n", .{export_name});
                }
            }
        }

        const memory_idx = memory_idx_opt orelse return error.InvalidFormat;
        const table_idx = table_idx_opt orelse return error.InvalidFormat;
        const plugin_info_name_idx = plugin_info_name_idx_opt orelse return error.InvalidFormat;
        const plugin_info_version_major_idx = plugin_info_version_major_idx_opt orelse return error.InvalidFormat;
        const plugin_info_version_minor_idx = plugin_info_version_minor_idx_opt orelse return error.InvalidFormat;
        const plugin_info_version_patch_idx = plugin_info_version_patch_idx_opt orelse return error.InvalidFormat;
        const on_enable_func_idx = on_enable_func_idx_opt orelse return error.InvalidFormat;
        const realloc_fn_idx = realloc_fn_idx_opt orelse return error.InvalidFormat;

        var externs_vec: wasm_extern_vec_t = undefined;
        wasm_instance_exports(instance, &externs_vec);
        defer wasm_extern_vec_delete(&externs_vec);

        const externs = externs_vec.data[0..externs_vec.size];

        const memory_struct = wasm_extern_as_memory(externs[memory_idx]) orelse return error.WasmMemoryCastError;
        const memory_ptr = wasm_memory_data(memory_struct);
        const memory_len = wasm_memory_data_size(memory_struct);
        const memory = memory_ptr[0..memory_len];

        return Plugin{
            .id = undefined,
            .name = try std.mem.dupe(allocator, u8, try wasm.read_global([]const u8, memory, externs[plugin_info_name_idx].?)),
            .version = .{
                .major = try wasm.read_global(u32, memory, externs[plugin_info_version_major_idx].?),
                .minor = try wasm.read_global(u32, memory, externs[plugin_info_version_minor_idx].?),
                .patch = try wasm.read_global(u32, memory, externs[plugin_info_version_patch_idx].?),
            },
            .memory = memory_struct,
            .callback_table = wasm_extern_as_table(externs[table_idx]) orelse return error.CallbackTableCastError,
            .on_enable_fn = wasm_extern_as_func(externs[on_enable_func_idx]).?,
            .realloc_fn = wasm_extern_as_func(externs[realloc_fn_idx]).?,
        };
    }

    pub fn deinit(self: @This(), allocator: *std.mem.Allocator) void {
        allocator.free(self.name);
    }

    pub fn wasm_alloc(self: @This(), n_bytes: u32) !MemoryView {
        const realloc_params = [_]wasm_val_t{
            .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
            .{ .kind = WASM_I32, .of = .{ .i32 = 0 } },
            .{ .kind = WASM_I32, .of = .{ .i32 = @intCast(i32, n_bytes) } },
        };
        var realloc_results = [_]wasm_val_t{
            std.mem.zeroes(wasm_val_t),
        };
        var trap: ?*wasm_trap_t = undefined;
        if (wasmtime_func_call(self.realloc_fn, &realloc_params, realloc_params.len, &realloc_results, realloc_results.len, &trap)) |err| {
            var message: wasm_name_t = undefined;
            wasmtime_error_message(err, &message);
            const message_slice = message.data[0..message.size];
            std.debug.warn("Wasm error: {}\n", .{message_slice});
            return error.WasmCall;
        }
        std.debug.assert(realloc_results[0].kind == WASM_I32);
        const result = @bitCast(u32, realloc_results[0].of.i32);
        if (result == 0) {
            return error.OutOfMemory;
        }
        return MemoryView{ .memory = self.memory, .ptr = result, .len = n_bytes };
    }

    pub fn get_callback(self: @This(), func_idx: u32) ?*wasm_func_t {
        var func_ref: ?*wasm_func_t = undefined;
        if (wasmtime_funcref_table_get(self.callback_table, func_idx, &func_ref))
            return func_ref
        else
            return null;
    }
};
