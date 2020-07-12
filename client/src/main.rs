use std::collections::{VecDeque, HashMap, hash_map::Entry};
use pathfinder_canvas::{Canvas, CanvasFontContext, TextAlign};
use pathfinder_color::ColorF;
use pathfinder_geometry::vector::{Vector2F, vec2f, vec2i};
use pathfinder_geometry::rect::RectF;
use pathfinder_gl::{GLDevice, GLVersion};
use pathfinder_renderer::concurrent::rayon::RayonExecutor;
use pathfinder_renderer::concurrent::scene_proxy::SceneProxy;
use pathfinder_renderer::gpu::options::{DestFramebuffer, RendererMode, RendererOptions};
use pathfinder_renderer::gpu::renderer::Renderer;
use pathfinder_renderer::options::BuildOptions;
use pathfinder_resources::fs::FilesystemResourceLoader;
use sdl2::event::{Event, WindowEvent};
use sdl2::keyboard::{Keycode, Scancode};
use sdl2::video::GLProfile;
use harlequinn::{HqEndpoint, Certificate, EndpointEvent, MessageOrder};
use bytes::Bytes;
use block_place_shared::packets::{ClientPacket, ServerPacket};
use nanoserde::{SerBin, DeBin};

struct PlayerEntity {
    entity_id: u32,
    name: String,
    pos: Vector2F,
}

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

    let mut text_log: VecDeque<String> = VecDeque::new();
    let mut text_typed = String::new();

    let mut server_peer_id = None;

    let mut player_entities: HashMap<u32, PlayerEntity> = HashMap::new();
    let mut player_entity_id = 0;
    let mut last_update_tick = 0;

    let mut next_hearbeat = std::time::Instant::now() + std::time::Duration::from_millis(200);

    // Wait for a keypress.
    let mut hq_events = Vec::new();
    let mut event_pump = sdl_context.event_pump().unwrap();
    loop {
        let mut should_render = false;
        endpoint.poll_events(&mut hq_events);
        for event in hq_events.drain(..) {
            match event {
                EndpointEvent::ConnectionRequested {
                    peer_id,
                    socket_addr,
                    ..
                } => {
                    endpoint.accept(peer_id);
                    server_peer_id = Some(peer_id);
                    println!("Server connected: {}", socket_addr);

                }
                EndpointEvent::ReceivedMessage { bytes, .. } => {
                    println!("Received message");
                    match std::str::from_utf8(&*bytes) {
                        Ok(s) => {
                            text_log.push_back(s.into());
                            should_render = true;
                        },
                        _ => println!("invalid utf-8"),
                    };
                }
                EndpointEvent::ReceivedDatagram { bytes, .. } => {
                    if let Ok(packet) = ServerPacket::deserialize_bin(&bytes) {
                        match packet {
                            ServerPacket::SetClientPlayerEntity(entity_id) => player_entity_id = entity_id,
                            ServerPacket::Update { ticks, players } => {
                                if ticks > last_update_tick {
                                    should_render = true;
                                    last_update_tick = ticks;
                                    for player in players {
                                        match player_entities.entry(player.entity_id) {
                                            Entry::Occupied(mut slot) => {
                                                let entity = slot.get_mut();
                                                entity.pos.set_x(player.pos_x);
                                                entity.pos.set_y(player.pos_y);
                                            }
                                            Entry::Vacant(slot) => {
                                                slot.insert(PlayerEntity {
                                                    name: String::new(),
                                                    entity_id: player.entity_id,
                                                    pos: Vector2F::new(player.pos_x, player.pos_y),
                                                });
                                            }
                                        }
                                    }
                                }
                            },
                        }
                    }
                }
                EndpointEvent::Disconnected {reason, ..} => {
                    println!("Server disconnected: {}", reason.as_ref().map(|x| x.as_str()).unwrap_or("Reason unknown"));
                }
                _ => { }
            }
        }

        for event in event_pump.poll_iter(){
            match event {
                Event::Quit {..} | Event::KeyDown { keycode: Some(Keycode::Escape), .. } => return,
                Event::KeyDown { keycode: Some(Keycode::Backspace), .. } => {
                    let _ = text_typed.pop();
                    should_render = true;
                },
                Event::KeyDown { keycode: Some(Keycode::Return), .. } => {
                    if server_peer_id.is_none() {
                        continue;
                    }
                    endpoint.send_message(
                        server_peer_id.unwrap(),
                        Bytes::from(text_typed.clone()),
                        MessageOrder::Ordered,
                    );
                    text_typed.clear();
                    should_render = true;
                },
                Event::TextInput { text, .. } => {
                    text_typed.push_str(&text);
                    should_render = true;
                },
                Event::Window { win_event: WindowEvent::Exposed, .. } => {
                    should_render = true;
                },
                _ => {}
            }
        }

        let mut movement = Vector2F::new(0.0, 0.0);
        if event_pump.keyboard_state().is_scancode_pressed(Scancode::Left) {
            movement += Vector2F::new(-2.0, 0.0);
        }
        if event_pump.keyboard_state().is_scancode_pressed(Scancode::Right) {
            movement += Vector2F::new(2.0, 0.0);
        }
        if event_pump.keyboard_state().is_scancode_pressed(Scancode::Up) {
            movement += Vector2F::new(0.0, -2.0);
        }
        if event_pump.keyboard_state().is_scancode_pressed(Scancode::Down) {
            movement += Vector2F::new(0.0, 2.0);
        }
        if let Some(peer_id) = server_peer_id {
            if movement != Vector2F::zero() {
                if let Some(player) = player_entities.get(&player_entity_id) {
                    let new_pos = player.pos + movement;
                    let packet = ClientPacket::Moved{pos_x: new_pos.x(), pos_y: new_pos.y()}.serialize_bin();
                    endpoint.send_datagram(peer_id, Bytes::from(packet));
                }
            }
            if std::time::Instant::now() >= next_hearbeat {
                let packet = ClientPacket::Heartbeat.serialize_bin();
                endpoint.send_datagram(peer_id, Bytes::from(packet));
                next_hearbeat = std::time::Instant::now() + std::time::Duration::from_millis(200);
            }
        }


        if should_render {
            // Make a canvas.
            let mut canvas = Canvas::new(window_size.to_f32()).get_context_2d(font_context.clone());

            // Draw players
            for (_entity_id, player) in player_entities.iter() {
                canvas.fill_rect(RectF::new(player.pos, Vector2F::new(32.0, 32.0)));
            }

            // Draw the text.
            let font_size = 32.0;
            let line_height = font_size * 1.5;
            canvas.set_font_size(font_size);
            canvas.set_text_align(TextAlign::Left);

            let mut y = window_size.y() as f32 - 5.0;
            canvas.fill_text(&text_typed, vec2f(5.0, y));
            for text in text_log.iter().rev() {
                y -= line_height;
                if y < 0.0 { break; }
                canvas.fill_text(text, vec2f(5.00, y));
            }

            // Render the canvas to screen.
            let mut scene = SceneProxy::from_scene(canvas.into_canvas().into_scene(),
                                                   renderer.mode().level,
                                                   RayonExecutor);
            scene.build_and_render(&mut renderer, BuildOptions::default());
            window.gl_swap_window();
        }

        std::thread::sleep(std::time::Duration::from_millis(100));
    }
}

