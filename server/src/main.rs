use std::path::Path;

use wasmtime::{Store, Module, Extern, Func, Trap, Caller, Linker, Engine, Config};

use harlequinn::{Certificate, EndpointEvent, HqEndpoint, PrivateKey};

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

    linker.func("env", "register_player_join_listener", |plugin: i32, callback: i32| {
        println!("register_player_join_listener({}, {})", plugin as u32, callback as u32);
        Ok(())
    }).unwrap();

    linker.func("env", "player_name", |player: i32, plugin: i32, ptr_out: i32, len_out: i32| {
        println!("player_name({}, {}, {}, {})", player as u32, plugin as u32, ptr_out as u32, len_out as u32);
        Ok(())
    }).unwrap();

    let instance = linker.instantiate(&module).unwrap();

    let on_enable = instance.get_func("on_enable").ok_or(anyhow::format_err!("failed to find `on_enable` function export")).unwrap().get1::<i32, ()>().unwrap();

    on_enable(1234).unwrap();

    // Initialize networking...
    let (cert, pkey) = get_certificate();

    let socket_addr = "0.0.0.0:41800".parse().unwrap();
    let mut endpoint = HqEndpoint::new_server("block-place", socket_addr, cert, pkey);

    let mut events = Vec::new();

    loop {
        endpoint.poll_events(&mut events);

        for event in events.drain(..) {
            match event {
                EndpointEvent::ConnectionRequested {
                    peer_id,
                    socket_addr,
                    ..
                } => {
                    endpoint.accept(peer_id);
                    println!("Client connected: {}", socket_addr);
                }
                EndpointEvent::Disconnected { .. } => {
                    println!("Client disconnected");
                }
                EndpointEvent::ReceivedMessage { bytes, .. } => {
                    println!("Receied: {:?}", &*bytes);
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
