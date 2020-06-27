const std = @import("std");
usingnamespace @import("./c.zig");

pub fn main() anyerror!void {
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

    // Render canvas to screen
    const scene = PFCanvasCreateScene(canvas);
    const scene_proxy = PFSceneProxyCreateFromSceneAndRayonExecutor(scene, PF_RENDERER_LEVEL_D3D9);
    PFSceneProxyBuildAndRenderGL(scene_proxy, renderer, PFBuildOptionsCreate());
    SDL_GL_SwapWindow(window);

    std.debug.warn("All your codebase are belong to us.\n", .{});

    while (true) {
        var event: SDL_Event = undefined;
        if (SDL_WaitEvent(&event) == 0) return error.SDL_Event;
        if (event.type == SDL_QUIT or (event.type == SDL_KEYDOWN and event.key.keysym.sym == SDLK_ESCAPE)) {
            break;
        }
    }
}

fn LoadGLFunction(name: ?[*]const u8, userdata: ?*c_void) callconv(.C) ?*c_void {
    return SDL_GL_GetProcAddress(name);
}
