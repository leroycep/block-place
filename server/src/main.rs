use std::path::Path;
use wasmtime::{Store, Module, Extern, Trap, Caller, Linker, Engine, Config, Val};
use dashmap::DashMap;
use harlequinn::{Certificate, EndpointEvent, HqEndpoint, PrivateKey, PeerId, MessageOrder};
use bytes::Bytes;
use block_place_shared::packets::{ServerPacket, PlayerUpdate, ClientPacket};
use nanoserde::{SerBin, DeBin};

mod plugin;

use plugin::Plugin;

struct Player {
    name: String,
    peer_id: PeerId,
    entity_id: u32,
    pos: (f32, f32),
}

fn main() {
    // Initialize WASM runtime
    let engine = Engine::new(Config::new().wasm_bulk_memory(true));
    let store = Store::new(&engine);
    let module = Module::from_file(store.engine(), "plugins/default-plugin.wasm").unwrap();
    let mut linker = Linker::new(&store);

    // Variables
    let player_join_listener: std::rc::Rc<std::cell::RefCell<Option<u32>>> = std::rc::Rc::new(std::cell::RefCell::new(None));
    let plugins_rc: std::rc::Rc<DashMap<u32, Plugin>> = std::rc::Rc::new(DashMap::new());
    let players_rc: std::rc::Rc<DashMap<PeerId, Player>> = std::rc::Rc::new(DashMap::new());
    let player_id_to_peer_id: std::rc::Rc<DashMap<u32, PeerId>> = std::rc::Rc::new(DashMap::new());

    // Initialize networking...
    let (cert, pkey) = get_certificate();
    let socket_addr = "0.0.0.0:41800".parse().unwrap();
    let endpoint = std::rc::Rc::new(std::cell::RefCell::new(HqEndpoint::new_server("block-place", socket_addr, cert, pkey)));

    linker.func("env", "warn", |caller: Caller<'_>, ptr: i32, len: i32| {
        let mem = match caller.get_export("memory") {
            Some(Extern::Memory(mem)) => mem,
            _ => return Err(Trap::new("failed to find host memory")),
        };

        unsafe {
            let data = mem.data_unchecked()
                .get(ptr as u32 as usize..)
                .and_then(|arr| arr.get(..len as u32 as usize));
            let string = match data {
                Some(data) => match std::str::from_utf8(data) {
                    Ok(s) => s,
                    Err(_) => return Err(Trap::new("invalid utf-8")),
                },
                None => return Err(Trap::new("pointer/length out of bounds")),
            };
            println!("{}", string);
        }
        Ok(())
    }).unwrap();

    let players_rc_clone = std::rc::Rc::clone(&players_rc);
    let endpoint_clone = std::rc::Rc::clone(&endpoint);
    linker.func("env", "server_broadcast_message", move |caller: Caller<'_>, server: i32, ptr: i32, len: i32| {
        // TODO: Check that server is correct number

        let mem = match caller.get_export("memory") {
            Some(Extern::Memory(mem)) => mem,
            _ => return Err(Trap::new("failed to find host memory")),
        };

        unsafe {
            let data = mem.data_unchecked()
                .get(ptr as u32 as usize..)
                .and_then(|arr| arr.get(..len as u32 as usize));
            let string = match data {
                Some(data) => match std::str::from_utf8(data) {
                    Ok(s) => s,
                    Err(_) => return Err(Trap::new("invalid utf-8")),
                },
                None => return Err(Trap::new("pointer/length out of bounds")),
            };
            let mut endpoint = endpoint_clone.borrow_mut();
            for player in players_rc_clone.iter() {
                endpoint.send_message(player.peer_id, Bytes::from(string.to_string()), MessageOrder::Ordered);
            }
        }
        Ok(())
    }).unwrap();

    let player_join_listener_clone = std::rc::Rc::clone(&player_join_listener);
    linker.func("env", "register_player_join_listener", move |plugin: i32, callback: i32| {
        player_join_listener_clone.replace(Some(callback as u32));
        Ok(())
    }).unwrap();

    let plugins_rc_clone = std::rc::Rc::clone(&plugins_rc);
    let player_id_to_peer_id_clone = std::rc::Rc::clone(&player_id_to_peer_id);
    let players_rc_clone = std::rc::Rc::clone(&players_rc);
    linker.func("env", "player_name", move |caller: Caller<'_>, player: i32, plugin: i32, ptr_out: i32, len_out: i32| {
        let mem = match caller.get_export("memory") {
            Some(Extern::Memory(mem)) => mem,
            _ => return Err(Trap::new("failed to find host memory")),
        };
        let plugin =  match plugins_rc_clone.get(&(plugin as u32)) {
            Some(p) => p,
            None => return Err(Trap::new("invalid plugin id")),
        };
        let peer_id = match player_id_to_peer_id_clone.get(&(player as u32)) {
            Some(peer_id) => peer_id,
            None => return Err(Trap::new("invalid player id")),
        };
        let player =  match players_rc_clone.get(&peer_id) {
            Some(p) => p,
            None => return Err(Trap::new("invalid player peer id")),
        };
        let plugin_alloc = match plugin.realloc(None, player.name.len()) {
            Ok(None) => return Err(Trap::new("allocation failed")),
            Ok(Some(a)) => a,
            Err(trap) => return Err(trap),
        };
        unsafe {
            let data = mem.data_unchecked_mut();
            let string_data = match data.get_mut(plugin_alloc..).and_then(|arr| arr.get_mut(..player.name.len())) {
                Some(d) => d,
                None => return Err(Trap::new("string pointer out of bounds")),
            };

            // Copy string to wasm
            for (dest, src) in string_data.iter_mut().zip(player.name.bytes()) {
                *dest = src;
            }

            let ptr_out_data = match data.get(ptr_out as u32 as usize..).map(|arr| arr.as_ptr() as *mut u32) {
                Some(d) => d,
                None => return Err(Trap::new("pointer out pointer out of bounds")),
            };

            // Write string pointer to ptr_out
            *ptr_out_data = plugin_alloc as u32;

            let len_out_data = match data.get(len_out as u32 as usize..).map(|arr| arr.as_ptr() as *mut u32) {
                Some(d) => d,
                None => return Err(Trap::new("length out pointer out of bounds")),
            };

            // Write len pointer to ptr_out
            *len_out_data = player.name.len() as u32;
        }
        Ok(())
    }).unwrap();

    let instance = linker.instantiate(&module).unwrap();

    let on_enable = instance.get_func("on_enable").ok_or(anyhow::format_err!("failed to find `on_enable` function export")).unwrap().get1::<i32, ()>().unwrap();
    let plugin_callback_table = instance.get_table("__indirect_function_table").ok_or(anyhow::format_err!("failed to find `__indirect_function_table` export")).unwrap();

    let default_plugin = plugin::extract_plugin(&module, &instance).unwrap();
    plugins_rc.insert(1234, default_plugin);

    on_enable(1234).unwrap();

    let mut events = Vec::new();

    let mut next_player_id: u32 = 1;
    let mut ticks: u64 = 0;
    loop {
        {
            endpoint.borrow_mut().poll_events(&mut events);
        }

        for event in events.drain(..) {
            match event {
                EndpointEvent::ConnectionRequested {
                    peer_id,
                    ..
                } => {
                    endpoint.borrow_mut().accept(peer_id);
                    players_rc.insert(peer_id, Player {
                        name: format!("{}", next_player_id),
                        peer_id,
                        entity_id: next_player_id,
                        pos: (320.0, 240.0),
                    });
                    player_id_to_peer_id.insert(next_player_id, peer_id);

                    let listener_opt = player_join_listener.borrow()
                        .map(|callback| plugin_callback_table.get(callback))
                        .flatten()
                        .map(|val| match val {Val::FuncRef(func) => Some(func), _ => None})
                        .flatten();
                    if let Some(listener_func) = listener_opt {
                        let listener = listener_func.get4::<i32,i32,i32,i32,()>().unwrap();
                        listener(1234, 1, 1, next_player_id as i32).unwrap();
                    }

                    let packet = ServerPacket::SetClientPlayerEntity(next_player_id).serialize_bin();
                    endpoint.borrow_mut().send_datagram(peer_id, Bytes::from(packet));

                    next_player_id += 1;
                }
                EndpointEvent::Disconnected { .. } => {
                    println!("Client disconnected");
                }
                EndpointEvent::ReceivedMessage { bytes, .. } => {
                    let mut endpoint = endpoint.borrow_mut();
                    for player in players_rc.iter() {
                        endpoint.send_message(player.peer_id, bytes.clone(), MessageOrder::Ordered);
                    }
                }
                EndpointEvent::ReceivedDatagram { peer_id, bytes } => {
                    if let Ok(packet) = ClientPacket::deserialize_bin(&bytes) {
                        match packet {
                            ClientPacket::Heartbeat => {},
                            ClientPacket::Moved { pos_x, pos_y } => {
                                if let Some(mut player) = players_rc.get_mut(&peer_id) {
                                    player.pos.0 = pos_x;
                                    player.pos.1 = pos_y;
                                }
                            },
                        }
                    }
                }
                _ => {}
            }
        }

        {
            let update = ServerPacket::Update {
                ticks,
                players: players_rc.iter().map(|p| PlayerUpdate { entity_id: p.entity_id, pos_x: p.pos.0, pos_y: p.pos.1 }).collect(),
            };
            let update_bytes = update.serialize_bin();
            let mut endpoint = endpoint.borrow_mut();
            for player in players_rc.iter() {
                endpoint.send_datagram(player.peer_id, Bytes::from(update_bytes.clone()));
            }
        }

        std::thread::sleep(std::time::Duration::from_millis(100));
        ticks += 1;
    }
}

fn get_certificate() -> (Certificate, PrivateKey) {
    let certificate_path = Path::new("./cert.der");
    let private_key_path = Path::new("./key.der");

    if !certificate_path.exists() && !private_key_path.exists() {
        println!("No certificate or private key found, generating");

        let rcgen_cert = rcgen::generate_simple_self_signed(vec!["localhost".into()]).unwrap();

        let certificate_der = rcgen_cert.serialize_der().unwrap();
        let private_key_der = rcgen_cert.serialize_private_key_der();

        std::fs::write(certificate_path, &certificate_der).unwrap();
        std::fs::write(private_key_path, &private_key_der).unwrap();
    }

    let certificate_der = std::fs::read(certificate_path).unwrap();
    let certificate = Certificate::from_der(&certificate_der).unwrap();
    let private_key_der = std::fs::read(private_key_path).unwrap();
    let private_key = PrivateKey::from_der(&private_key_der).unwrap();

    (certificate, private_key)
}
