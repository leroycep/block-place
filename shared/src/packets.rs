use nanoserde::{SerBin, DeBin};

/// Packets sent from the Server to the Client
#[derive(Debug, SerBin, DeBin)]
pub enum ServerPacket {
    SetClientPlayerEntity(u32),
    Update{
        ticks: u64,
        players: Vec<PlayerUpdate>,
    },
}

#[derive(Debug, SerBin, DeBin)]
pub struct PlayerUpdate {
    pub entity_id: u32,
    pub pos_x: f32,
    pub pos_y: f32,
}

/// Packets sent from the Client to the Server
#[derive(Debug, SerBin, DeBin)]
pub enum ClientPacket {
    Heartbeat,
    Moved {
        pos_x: f32,
        pos_y: f32,
    },
}
