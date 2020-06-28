const std = @import("std");
const ArrayListSentineled = std.ArrayListSentineled;
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

    render(window, renderer, text_typed.span());

    while (true) {
        var renderText = false;
        var event: SDL_Event = undefined;
        if (SDL_WaitEvent(&event) == 0) return error.SDL_Event;
        switch (event.type) {
            SDL_QUIT => break,
            SDL_KEYDOWN => {
                if (event.key.keysym.sym == SDLK_ESCAPE) {
                    break;
                } else if (event.key.keysym.sym == SDLK_BACKSPACE and text_typed.len() > 0) {
                    pop_utf8_codepoint(&text_typed);
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
        if (renderText) {
            render(window, renderer, text_typed.span());
        }
    }
}

fn render(window: *SDL_Window, renderer: PFGLRendererRef, text: [:0]const u8) void {
    const canvas = PFCanvasCreate(PFCanvasFontContextCreateWithSystemSource(), &PFVector2F{ .x = 640, .y = 480 });

    // Draw a house
    PFCanvasSetLineWidth(canvas, 10);
    PFCanvasStrokeRect(canvas, &PFRectF{
        .origin = .{ .x = 75, .y = 140 },
        .lower_right = .{ .x = 225, .y = 250 },
    });
    PFCanvasFillRect(canvas, &PFRectF{
        .origin = .{ .x = 130, .y = 190 },
        .lower_right = .{ .x = 170, .y = 250 },
    });
    PFCanvasFillRect(canvas, &PFRectF{
        .origin = .{ .x = 130, .y = 190 },
        .lower_right = .{ .x = 170, .y = 250 },
    });

    const path = PFPathCreate();
    PFPathMoveTo(path, &PFVector2F{ .x = 50, .y = 140 });
    PFPathLineTo(path, &PFVector2F{ .x = 150, .y = 60 });
    PFPathLineTo(path, &PFVector2F{ .x = 250, .y = 140 });
    PFPathClosePath(path);
    PFCanvasStrokePath(canvas, path);

    PFCanvasFillText(canvas, text, text.len, &PFVector2F{ .x = 32, .y = 48 });

    // Render canvas to screen
    const scene = PFCanvasCreateScene(canvas);
    const scene_proxy = PFSceneProxyCreateFromSceneAndRayonExecutor(scene, PF_RENDERER_LEVEL_D3D9);
    PFSceneProxyBuildAndRenderGL(scene_proxy, renderer, PFBuildOptionsCreate());
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
