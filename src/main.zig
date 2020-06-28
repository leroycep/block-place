const std = @import("std");
const ArrayListSentineled = std.ArrayListSentineled;
const TailQueue = std.TailQueue;
usingnamespace @import("./c.zig");

pub fn main() anyerror!void {
    const allocator = std.heap.c_allocator;
    if (SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO) != 0) {
        return error.SDL_Init;
    }
    defer SDL_Quit();

    if (SDL_GL_SetAttribute(.SDL_GL_CONTEXT_MAJOR_VERSION, 3) != 0) {
        return error.SDL_GL_MajorVersion;
    }
    if (SDL_GL_SetAttribute(.SDL_GL_CONTEXT_MINOR_VERSION, 2) != 0) {
        return error.SDL_GL_MinorVersion;
    }
    if (SDL_GL_SetAttribute(.SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE) != 0) {
        return error.SDL_GL_Profile;
    }
    if (SDL_GL_SetAttribute(.SDL_GL_DOUBLEBUFFER, 1) != 0) {
        return error.SDL_GL_DoubleBuffer;
    }

    const window = SDL_CreateWindow("Block Place", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_OPENGL) orelse return error.SDL_Window;

    const gl_context = SDL_GL_CreateContext(window) orelse return error.SDL_GL_CreateContext;

    SDL_ShowWindow(window);

    // Initialize enet library
    if (enet_initialize() != 0) {
        return error.EnetInitialize;
    }
    defer enet_deinitialize();

    var client = enet_host_create(null, 1, 2, 0, 0) orelse return error.CreatingENetClientHost;
    defer enet_host_destroy(client);

    var address: ENetAddress = undefined;
    if (enet_address_set_host(&address, "localhost") != 0) {
        return error.ENetSetAddress;
    }
    address.port = 41800;

    const peer = enet_host_connect(client, &address, 2, 0) orelse return error.ENetNoPeersAvailable;

    PFGLLoadWith(LoadGLFunction, null);
    const dest_framebuffer = PFGLDestFramebufferCreateFullWindow(&PFVector2I{ .x = 640, .y = 480 });
    const renderer = PFGLRendererCreate(
        PFGLDeviceCreate(PF_GL_VERSION_GL3, 0),
        PFFilesystemResourceLoaderLocate(),
        &PFRendererMode{
            .level = PF_RENDERER_LEVEL_D3D9,
        },
        &PFRendererOptions{
            .dest = dest_framebuffer,
            .background_color = PFColorF{ .r = 1, .g = 1, .b = 1, .a = 1 },
            .flags = PF_RENDERER_OPTIONS_FLAGS_HAS_BACKGROUND_COLOR,
        },
    );

    SDL_StartTextInput();

    var text_typed = try ArrayListSentineled(u8, 0).init(allocator, "Hello, world!");
    defer text_typed.deinit();
    var message_log = TailQueue([]const u8).init();
    defer {
        var it = message_log.first;
        while (it) |node| {
            allocator.free(node.data);
            it = node.next;
            message_log.destroyNode(node, allocator);
        }
    }

    {
        const new_message = try std.mem.dupe(allocator, u8, "Connecting to server...");
        const new_message_node = try message_log.createNode(new_message, allocator);
        message_log.prepend(new_message_node);
    }
    render(window, renderer, text_typed.span(), message_log);

    var running = true;
    while (running) {
        var renderText = false;
        var enet_event: ENetEvent = undefined;
        while (enet_host_service(client, &enet_event, 0) > 0) {
            switch (enet_event.type) {
                .ENET_EVENT_TYPE_CONNECT => {
                    const new_message = try std.fmt.allocPrint(allocator, "Connected to server at {}:{}", .{ enet_event.peer.*.address.host, enet_event.peer.*.address.port });
                    const new_message_node = try message_log.createNode(new_message, allocator);
                    message_log.prepend(new_message_node);
                    renderText = true;
                },
                .ENET_EVENT_TYPE_RECEIVE => {
                    defer enet_packet_destroy(enet_event.packet);
                    const new_message = try std.mem.dupe(allocator, u8, enet_event.packet.*.data[0..enet_event.packet.*.dataLength]);
                    const new_message_node = try message_log.createNode(new_message, allocator);
                    message_log.prepend(new_message_node);
                    renderText = true;
                },
                .ENET_EVENT_TYPE_NONE => break,
                else => {},
            }
        }

        var event: SDL_Event = undefined;
        while (SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                SDL_QUIT => running = false,
                SDL_KEYDOWN => {
                    if (event.key.keysym.sym == SDLK_ESCAPE) {
                        running = false;
                    } else if (event.key.keysym.sym == SDLK_BACKSPACE and text_typed.len() > 0) {
                        pop_utf8_codepoint(&text_typed);
                        renderText = true;
                    } else if (event.key.keysym.sym == SDLK_RETURN and text_typed.len() > 0) {
                        const new_message = try std.mem.dupe(allocator, u8, text_typed.span());
                        const new_message_node = try message_log.createNode(new_message, allocator);
                        message_log.prepend(new_message_node);
                        try text_typed.resize(0);
                        renderText = true;
                    } else if (event.key.keysym.sym == SDLK_c and @enumToInt(SDL_GetModState()) & KMOD_CTRL > 0) {
                        _ = SDL_SetClipboardText(text_typed.span());
                    } else if (event.key.keysym.sym == SDLK_v and @enumToInt(SDL_GetModState()) & KMOD_CTRL > 0) {
                        const pasted_text = SDL_GetClipboardText();
                        var i: usize = 0;
                        while ((pasted_text + i).* != 0) : (i += 1) {}
                        try text_typed.appendSlice(pasted_text[0..i]);
                        renderText = true;
                    }
                },
                SDL_TEXTINPUT => {
                    if (!(@enumToInt(SDL_GetModState()) & KMOD_CTRL > 0 and (event.text.text[0] == 'c' or event.text.text[0] == 'C' or event.text.text[0] == 'v' or event.text.text[0] == 'V'))) {
                        var i: usize = 0;
                        while (event.text.text[i] != 0) : (i += 1) {}
                        try text_typed.appendSlice(event.text.text[0..i]);
                        renderText = true;
                    }
                },
                SDL_WINDOWEVENT => if (event.window.event == SDL_WINDOWEVENT_EXPOSED) {
                    renderText = true;
                },
                else => {},
            }
        }
        if (renderText) {
            render(window, renderer, text_typed.span(), message_log);
        }
    }

    enet_peer_disconnect(peer, 0);

    // Wait 3 seconds for disconnect to succeed
    var enet_event: ENetEvent = undefined;
    while (enet_host_service(client, &enet_event, 3000) > 0) {
        switch (enet_event.type) {
            .ENET_EVENT_TYPE_RECEIVE => {
                enet_packet_destroy(enet_event.packet);
            },
            .ENET_EVENT_TYPE_DISCONNECT => {
                std.debug.warn("Disconnected from server.\n", .{});
                break;
            },
            else => {},
        }
    }

    enet_peer_reset(peer);
}

fn render(window: *SDL_Window, renderer: PFGLRendererRef, text: [:0]const u8, message_log: TailQueue([]const u8)) void {
    const canvas = PFCanvasCreate(PFCanvasFontContextCreateWithSystemSource(), &PFVector2F{ .x = 640, .y = 480 });

    var ypos: f32 = 480;
    const text_size = 20;
    PFCanvasSetFontSize(canvas, text_size);
    const line_height = text_size * 1.5;

    ypos -= line_height;
    PFCanvasFillText(canvas, text, text.len, &PFVector2F{ .x = 32, .y = ypos });

    {
        var it = message_log.first;
        while (it) |node| : (it = node.next) {
            ypos -= line_height;
            PFCanvasFillText(canvas, node.data.ptr, node.data.len, &PFVector2F{ .x = 32, .y = ypos });
        }
    }

    // Render canvas to screen
    const scene = PFCanvasCreateScene(canvas);
    const scene_proxy = PFSceneProxyCreateFromSceneAndRayonExecutor(scene, PF_RENDERER_LEVEL_D3D9);
    const build_options = PFBuildOptionsCreate();
    defer PFBuildOptionsDestroy(build_options);
    PFSceneProxyBuildAndRenderGL(scene_proxy, renderer, build_options);
    SDL_GL_SwapWindow(window);
}

fn LoadGLFunction(name: ?[*]const u8, userdata: ?*c_void) callconv(.C) ?*c_void {
    return SDL_GL_GetProcAddress(name);
}

fn is_leading_utf8_byte(c: u8) bool {
    const first_bit_set = (c & 0x80) != 0;
    const second_bit_set = (c & 0x40) != 0;
    return !first_bit_set or second_bit_set;
}

fn pop_utf8_codepoint(string: *ArrayListSentineled(u8, 0)) void {
    if (string.len() == 0) return;
    var new_len = string.len() - 1;
    while (new_len > 0 and !is_leading_utf8_byte(string.span()[new_len])) : (new_len -= 1) {}
    string.shrink(new_len);
}
