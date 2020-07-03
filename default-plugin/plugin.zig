const api = @import("block-place-api");

export const PLUGIN_INFO_NAME = "xyz.geemili.default";
export const PLUGIN_INFO_VERSION_MAJOR: u32 = 0;
export const PLUGIN_INFO_VERSION_MINOR: u32 = 1;
export const PLUGIN_INFO_VERSION_PATCH: u32 = 0;

export fn add_one(a: i32) i32 {
    const msg = "Hello from wasm!\n";
    api.warn(msg, msg.len);
    return a + 1;
}
