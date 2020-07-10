use pathfinder_canvas::{Canvas, CanvasFontContext, TextAlign};
use pathfinder_color::ColorF;
use pathfinder_geometry::vector::{vec2f, vec2i};
use pathfinder_gl::{GLDevice, GLVersion};
use pathfinder_renderer::concurrent::rayon::RayonExecutor;
use pathfinder_renderer::concurrent::scene_proxy::SceneProxy;
use pathfinder_renderer::gpu::options::{DestFramebuffer, RendererMode, RendererOptions};
use pathfinder_renderer::gpu::renderer::Renderer;
use pathfinder_renderer::options::BuildOptions;
use pathfinder_resources::fs::FilesystemResourceLoader;
use sdl2::event::Event;
use sdl2::keyboard::Keycode;
use sdl2::video::GLProfile;
use harlequinn::{HqEndpoint, Certificate, EndpointEvent, MessageOrder};
use bytes::Bytes;

fn main() {
    let mut endpoint = HqEndpoint::new_client("block-place");

    let certificate_der = std::fs::read("./cert.der").unwrap();
    let certificate = Certificate::from_der(&certificate_der).unwrap();
    let socket_addr = "127.0.0.1:41800".parse().unwrap();
    endpoint.connect(socket_addr, "localhost", certificate);

    // Set up SDL2.
    let sdl_context = sdl2::init().unwrap();
    let video = sdl_context.video().unwrap();

    // Make sure we have at least a GL 3.0 context. Pathfinder requires this.
    let gl_attributes = video.gl_attr();
    gl_attributes.set_context_profile(GLProfile::Core);
    gl_attributes.set_context_version(3, 3);

    // Open a window.
    let window_size = vec2i(640, 480);
    let window = video.window("Text example", window_size.x() as u32, window_size.y() as u32)
                      .opengl()
                      .build()
                      .unwrap();

    // Create the GL context, and make it current.
    let gl_context = window.gl_create_context().unwrap();
    gl::load_with(|name| video.gl_get_proc_address(name) as *const _);
    window.gl_make_current(&gl_context).unwrap();

    // Create a Pathfinder renderer.
    let resource_loader = FilesystemResourceLoader::locate();
    let device = GLDevice::new(GLVersion::GL3, 0);
    let mode = RendererMode::default_for_device(&device);
    let options = RendererOptions {
        background_color: Some(ColorF::white()),
        dest: DestFramebuffer::full_window(window_size),
        ..RendererOptions::default()
    };
    let mut renderer = Renderer::new(device, &resource_loader, mode, options);

    // Load a font.
    let font_context = CanvasFontContext::from_system_source();

    // Make a canvas.
    let mut canvas = Canvas::new(window_size.to_f32()).get_context_2d(font_context);

    // Draw the text.
    canvas.set_font_size(32.0);
    canvas.fill_text("Hello Pathfinder!", vec2f(32.0, 48.0));
    canvas.set_text_align(TextAlign::Right);
    canvas.stroke_text("Goodbye Pathfinder!", vec2f(608.0, 464.0));

    // Render the canvas to screen.
    let mut scene = SceneProxy::from_scene(canvas.into_canvas().into_scene(),
                                           renderer.mode().level,
                                           RayonExecutor);
    scene.build_and_render(&mut renderer, BuildOptions::default());
    window.gl_swap_window();

    // Wait for a keypress.
    let mut hq_events = Vec::new();
    let mut event_pump = sdl_context.event_pump().unwrap();
    loop {
        endpoint.poll_events(&mut hq_events);
        for event in hq_events.drain(..) {
            match event {
                EndpointEvent::ConnectionRequested {
                    peer_id,
                    socket_addr,
                    ..
                } => {
                    endpoint.accept(peer_id);
                    println!("Server connected: {}", socket_addr);

                    endpoint.send_message(
                        peer_id,
                        Bytes::from(&[1,2,3,4][..]),
                        MessageOrder::Unordered,
                    );
                }
                _ => {
                    println!("Unknown event");
                }
            }
        }

        for event in event_pump.poll_iter(){
            match event {
                Event::Quit {..} | Event::KeyDown { keycode: Some(Keycode::Escape), .. } => return,
                _ => {}
            }
        }

        std::thread::sleep(std::time::Duration::from_millis(100));
    }
}

