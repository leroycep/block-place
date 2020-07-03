const std = @import("std");

pub const PluginInfo = struct {
    name: []const u8,
    version: Version,
};

pub const Version = struct {
    major: u32,
    minor: u32,
    patch: u32,

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: var) @TypeOf(writer).Error!void {
        return std.fmt.format(writer, "{}.{}.{}", .{ self.major, self.minor, self.patch });
    }
};

pub fn generate_plugin_info(comptime info: PluginInfo) type {
    return struct {
        pub const PLUGIN_INFO = info;

        export const PLUGIN_INFO_VERSION_MAJOR = info.version.major;

        export fn plugin_info_name_ptr() [*]const u8 {
            return info.name.ptr;
        }

        export fn plugin_info_name_len() u32 {
            return info.name.len;
        }

        export fn plugin_info_version_major() u32 {
            return info.version.major;
        }

        export fn plugin_info_version_minor() u32 {
            return info.version.minor;
        }

        export fn plugin_info_version_patch() u32 {
            return info.version.patch;
        }
    };
}

pub extern fn warn(str_ptr: [*]const u8, str_len: u32) void;
