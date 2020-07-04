pub extern fn warn(str_ptr: [*]const u8, str_len: usize) void;

pub const Plugin = @Type(.Opaque);
pub extern fn register_player_join_listener(plugin: *Plugin, fn (plugin: *Plugin, server: *Server, event: *Event, player: *Player) callconv(.C) void) void;

pub const Server = @Type(.Opaque);
pub extern fn server_broadcast_message(server: *Server, message_ptr: [*]u8, message_len: usize) callconv(.C) void;

pub const Event = @Type(.Opaque);

pub const Player = @Type(.Opaque);
pub extern fn player_name(player: *Player) callconv(.C) Bytes;
