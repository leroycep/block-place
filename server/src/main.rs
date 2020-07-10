use std::path::Path;

use harlequinn::{Certificate, EndpointEvent, HqEndpoint, PrivateKey};

fn main() {
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
