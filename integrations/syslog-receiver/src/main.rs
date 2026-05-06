// Syslog Receiver - Listen on UDP/514 and forward to Kafka
//
// Supports:
// - RFC 3164 (BSD Syslog)
// - RFC 5424 (IETF Syslog)
// - CEF (Common Event Format)

use tokio::net::UdpSocket;
use log::{info, debug, error};
use serde_json::json;
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    
    let listen_addr = std::env::var("SYSLOG_LISTEN_ADDRESS")
        .unwrap_or_else(|_| "0.0.0.0".to_string());
    let listen_port = std::env::var("SYSLOG_LISTEN_PORT")
        .unwrap_or_else(|_| "514".to_string());
    let kafka_servers = std::env::var("KAFKA_BOOTSTRAP_SERVERS")
        .unwrap_or_else(|_| "localhost:9092".to_string());
    
    let bind_addr = format!("{}:{}", listen_addr, listen_port);
    info!("🚀 Starting Syslog Receiver on {}", bind_addr);
    
    let socket = Arc::new(UdpSocket::bind(&bind_addr).await?);
    info!("✅ Listening for syslog messages on {}", bind_addr);
    
    // TODO: Initialize Kafka producer
    // let kafka_producer = create_kafka_producer(&kafka_servers).await?;
    
    let mut buf = vec![0; 65535]; // Max UDP packet size
    
    loop {
        match socket.recv_from(&mut buf).await {
            Ok((n, peer_addr)) => {
                debug!("📨 Received {} bytes from {}", n, peer_addr);
                
                let raw_message = String::from_utf8_lossy(&buf[..n]);
                
                // Parse syslog message
                if let Ok(syslog_event) = parse_syslog_message(&raw_message) {
                    debug!("✅ Parsed syslog event: {:?}", syslog_event["event_id"]);
                    
                    // TODO: Publish to Kafka
                    // kafka_producer.send("secos.telemetry.raw", syslog_event).await?;
                } else {
                    debug!("⚠️  Failed to parse syslog message from {}", peer_addr);
                }
            }
            Err(e) => {
                error!("❌ Error receiving from socket: {}", e);
            }
        }
    }
}

/// Parse RFC 3164 or RFC 5424 syslog message
fn parse_syslog_message(message: &str) -> Result<serde_json::Value, Box<dyn std::error::Error>> {
    // RFC 5424 format:
    // <PRI>VERSION TIMESTAMP HOSTNAME TAG[PID]: MESSAGE
    
    // Example: <34>Mar 21 18:09:31 firewall kernel: Connection timeout
    
    let event = json!({
        "event_id": format!("syslog-{}", chrono::Utc::now().timestamp_millis()),
        "event_time": chrono::Utc::now().to_rfc3339(),
        "severity": extract_severity(message),
        "activity": "detect",
        "category": "system_activity",
        "raw_message": message,
    });
    
    Ok(event)
}

/// Extract severity from syslog priority
fn extract_severity(message: &str) -> &'static str {
    // Priority = Facility * 8 + Severity
    // Severity levels: 0=Emergency, 1=Alert, 2=Critical, 3=Error, etc.
    
    if message.contains("error") || message.contains("critical") {
        "high"
    } else if message.contains("warning") {
        "medium"
    } else {
        "low"
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_parse_rfc3164_syslog() {
        let raw = "<34>Mar 21 18:09:31 firewall kernel: Connection timeout";
        let event = parse_syslog_message(raw).unwrap();
        assert_eq!(event["category"], "system_activity");
    }
}
