const api = @import("block-place-api");

usingnamespace api.generate_plugin_info(.{
    .name = "xyz.geemili.default",
    .version = .{
        .major = 0,
        .minor = 1,
        .patch = 0,
    },
});

export fn add_one(a: i32) i32 {
    const msg = "Hello from wasm!";
    api.warn(msg, msg.len);
    return a + 1;
}
