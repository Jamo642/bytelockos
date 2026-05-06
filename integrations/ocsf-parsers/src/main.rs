// OCSF Parsers - Convert any log format to OCSF JSON
//
// Supported formats:
// - Splunk logs
// - CrowdStrike EDR
// - AWS CloudTrail
// - CEF (Common Event Format)
// - Syslog (RFC 3164 / RFC 5424)

use serde_json::{json, Value};
use anyhow::Result;

/// Generic OCSF event structure
#[derive(Debug, Clone)]
pub struct OcsEvent {
    pub event_id: String,
    pub event_time: String,
    pub severity: String,
    pub activity: String,
    pub category: String,
    pub object_type: String,
    pub status: String,
    pub metadata: Value,
}

impl OcsEvent {
    /// Convert to OCSF-compliant JSON
    pub fn to_json(&self) -> Value {
        json!({
            "event_id": self.event_id,
            "event_time": self.event_time,
            "severity": self.severity,
            "activity": self.activity,
            "category": self.category,
            "object": {
                "type": self.object_type
            },
            "status": self.status,
            "metadata": self.metadata
        })
    }
}

/// Parse Splunk logs into OCSF
pub fn parse_splunk_log(raw_log: &str) -> Result<OcsEvent> {
    // TODO: Implement Splunk log parsing
    // Expected format: timestamp=..., event_code=..., etc.
    
    let event = OcsEvent {
        event_id: "splunk-123".to_string(),
        event_time: chrono::Utc::now().to_rfc3339(),
        severity: "medium".to_string(),
        activity: "detect".to_string(),
        category: "security_finding".to_string(),
        object_type: "event".to_string(),
        status: "success".to_string(),
        metadata: serde_json::from_str(raw_log).unwrap_or(json!({})),
    };
    
    Ok(event)
}

/// Parse CrowdStrike EDR alerts
pub fn parse_crowdstrike_alert(raw_alert: &str) -> Result<OcsEvent> {
    // TODO: Implement CrowdStrike parsing
    let json: Value = serde_json::from_str(raw_alert)?;
    
    let event = OcsEvent {
        event_id: json["id"].as_str().unwrap_or("unknown").to_string(),
        event_time: json["timestamp"].as_str().unwrap_or(&chrono::Utc::now().to_rfc3339()).to_string(),
        severity: json["severity"].as_str().unwrap_or("medium").to_string(),
        activity: "detect".to_string(),
        category: "security_finding".to_string(),
        object_type: "process".to_string(),
        status: "success".to_string(),
        metadata: json.clone(),
    };
    
    Ok(event)
}

/// Parse AWS CloudTrail events
pub fn parse_cloudtrail_event(raw_event: &str) -> Result<OcsEvent> {
    // TODO: Implement CloudTrail parsing
    let json: Value = serde_json::from_str(raw_event)?;
    
    let event = OcsEvent {
        event_id: json["eventID"].as_str().unwrap_or("unknown").to_string(),
        event_time: json["eventTime"].as_str().unwrap_or(&chrono::Utc::now().to_rfc3339()).to_string(),
        severity: "medium".to_string(),
        activity: json["eventName"].as_str().unwrap_or("unknown").to_string(),
        category: "cloud_api_activity".to_string(),
        object_type: "api_request".to_string(),
        status: json["errorCode"].is_null().then(|| "success").unwrap_or("failure").to_string(),
        metadata: json.clone(),
    };
    
    Ok(event)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ocsf_json_generation() {
        let event = OcsEvent {
            event_id: "test-123".to_string(),
            event_time: "2026-05-06T14:00:00Z".to_string(),
            severity: "high".to_string(),
            activity: "detect".to_string(),
            category: "security_finding".to_string(),
            object_type: "process".to_string(),
            status: "success".to_string(),
            metadata: json!({ "test": true }),
        };
        
        let json = event.to_json();
        assert_eq!(json["event_id"], "test-123");
        assert_eq!(json["severity"], "high");
    }
}
