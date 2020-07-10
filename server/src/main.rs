use std::path::Path;

use wasmtime::{Store, Module, Extern, Trap, Caller, Linker, Engine, Config, Val};

use dashmap::DashMap;

use harlequinn::{Certificate, EndpointEvent, HqEndpoint, PrivateKey, PeerId, MessageOrder};

mod plugin;

use plugin::Plugin;

struct Player {
    name: String,
    peer_id: PeerId,
}

fn main() {
    // Initialize WASM runtime
    let engine = Engine::new(Config::new().wasm_bulk_memory(true));
    let store = Store::new(&engine);
    let module = Module::from_file(store.engine(), "plugins/default-plugin.wasm").unwrap();
    let mut linker = Linker::new(&store);

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

    let player_join_listener: std::rc::Rc<std::cell::RefCell<Option<u32>>> = std::rc::Rc::new(std::cell::RefCell::new(None));
    let plugins_rc: std::rc::Rc<DashMap<u32, Plugin>> = std::rc::Rc::new(DashMap::new());
    let players_rc: std::rc::Rc<DashMap<u32, Player>> = std::rc::Rc::new(DashMap::new());

    let player_join_listener_clone = std::rc::Rc::clone(&player_join_listener);
    linker.func("env", "register_player_join_listener", move |plugin: i32, callback: i32| {
        println!("register_player_join_listener({}, {})", plugin as u32, callback as u32);
        player_join_listener_clone.replace(Some(callback as u32));
        Ok(())
    }).unwrap();

    let plugins_rc_clone = std::rc::Rc::clone(&plugins_rc);
    let players_rc_clone = std::rc::Rc::clone(&players_rc);
    linker.func("env", "player_name", move |caller: Caller<'_>, player: i32, plugin: i32, ptr_out: i32, len_out: i32| {
        println!("player_name({}, {}, {}, {})", player as u32, plugin as u32, ptr_out as u32, len_out as u32);
        let mem = match caller.get_export("memory") {
            Some(Extern::Memory(mem)) => mem,
            _ => return Err(Trap::new("failed to find host memory")),
        };
        let plugin =  match plugins_rc_clone.get(&(plugin as u32)) {
            Some(p) => p,
            None => return Err(Trap::new("invalid plugin id")),
        };
        let player =  match players_rc_clone.get(&(player as u32)) {
            Some(p) => p,
            None => return Err(Trap::new("invalid player id")),
        };
        let plugin_alloc = match plugin.realloc(1, 0, player.name.len()) {
            Ok(0) => return Err(Trap::new("allocation failed")),
            Ok(a) => a,
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

    // Initialize networking...
    let (cert, pkey) = get_certificate();

    let socket_addr = "0.0.0.0:41800".parse().unwrap();
    let mut endpoint = HqEndpoint::new_server("block-place", socket_addr, cert, pkey);

    let mut events = Vec::new();

    let mut next_player_id: u32 = 1;

    loop {
        endpoint.poll_events(&mut events);

        for event in events.drain(..) {
            match event {
                EndpointEvent::ConnectionRequested {
                    peer_id,
                    ..
                } => {
                    endpoint.accept(peer_id);
                    players_rc.insert(next_player_id, Player {
                        name: format!("{}", next_player_id),
                        peer_id,
                    });

                    let listener_opt = player_join_listener.borrow()
                        .map(|callback| plugin_callback_table.get(callback))
                        .flatten()
                        .map(|val| match val {Val::FuncRef(func) => Some(func), _ => None})
                        .flatten();
                    if let Some(listener_func) = listener_opt {
                        let listener = listener_func.get4::<i32,i32,i32,i32,()>().unwrap();
                        listener(1234, 1, 1, next_player_id as i32).unwrap();
                    }

                    next_player_id += 1;
                }
                EndpointEvent::Disconnected { .. } => {
                    println!("Client disconnected");
                }
                EndpointEvent::ReceivedMessage { bytes, .. } => {
                    println!("Receied: {:?}", &*bytes);
                    for player in players_rc.iter() {
                        endpoint.send_message(player.peer_id, bytes.clone(), MessageOrder::Ordered);
                    }
                }
                _ => {}
            }
        }

        std::thread::sleep(std::time::Duration::from_millis(100))
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
