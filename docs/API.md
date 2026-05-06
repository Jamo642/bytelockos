# ByteLock OS - API Documentation

## REST API Endpoints

### Health & Status

#### Get Health Status
```http
GET /health
```

Response:
```json
{
  "status": "healthy",
  "service": "ai-engine",
  "version": "0.1.0"
}
```

### Threat Intelligence

#### Get Active Threats
```http
GET /threats?status=active&severity=high
```

Query Parameters:
- `status` (optional): `active`, `resolved`, or `all`
- `severity` (optional): `low`, `medium`, `high`, `critical`
- `limit` (optional): Max results (default: 100)

Response:
```json
{
  "count": 3,
  "threats": [
    {
      "threat_id": "threat-12345",
      "severity": "critical",
      "threat_score": 0.98,
      "threat_actor": "APT-28",
      "kill_chain_phases": ["initial_access", "persistence"],
      "affected_assets": ["server-1", "workstation-42"],
      "created_at": "2026-05-06T14:22:33Z",
      "last_updated": "2026-05-06T14:35:22Z",
      "proposed_action": "Block IP 203.0.113.5 and isolate affected servers"
    }
  ]
}
```

### Event Analysis

#### Submit Event for Analysis
```http
POST /analyze
Content-Type: application/json

{
  "event_id": "splunk-event-xyz",
  "event_time": "2026-05-06T14:22:33Z",
  "severity": "high",
  "activity": "detect",
  "category": "system_activity",
  "object": {
    "type": "process",
    "name": "mimikatz.exe",
    "pid": 1234
  },
  "metadata": {
    "source": "crowdstrike",
    "endpoint": "WS-12345"
  }
}
```

Response:
```json
{
  "event_id": "splunk-event-xyz",
  "threat_score": 0.92,
  "threat_id": "threat-12345",
  "related_events": [
    "event-abc-001",
    "event-abc-002"
  ],
  "threat_actor": "APT-28",
  "kill_chain_phase": "persistence",
  "recommended_action": "Isolate endpoint and revoke credentials",
  "requires_debate": true
}
```

### Multi-Agent Debate

#### Trigger Debate on High-Risk Action
```http
POST /debate
Content-Type: application/json

{
  "threat_id": "threat-12345",
  "proposed_action": "Block IP 203.0.113.5 and isolate endpoint WS-12345",
  "threat_score": 0.98,
  "confidence": 0.95,
  "cost_estimate": 75.50,
  "risk_of_false_positive": 0.15
}
```

Response:
```json
{
  "debate_id": "debate-xyz-789",
  "proposed_action": "Block IP 203.0.113.5 and isolate endpoint",
  "threat_score": 0.98,
  "master_ai_argument": {
    "role": "master",
    "recommendation": "APPROVE_ACTION",
    "confidence": 0.98,
    "reasoning": "Strong indicators of ransomware kill chain: failed logins + mimikatz execution + C2 beacon",
    "risks": "Very low - isolated endpoint, C2 domain already known malicious"
  },
  "devils_advocate_argument": {
    "role": "devil",
    "counter_argument": "The gateway IP is shared with legitimate traffic. Risk of blocking critical services.",
    "risk_of_false_positive": 0.20,
    "alternative_hypotheses": [
      "Misconfigured security tool",
      "User testing attack detection"
    ],
    "recommendation": "CONDITIONAL_APPROVAL"
  },
  "consensus": {
    "recommendation": "APPROVE_ACTION",
    "final_confidence": 0.78,
    "explanation": "Multi-agent consensus reached. Master AI confidence outweighs devil's FP risk."
  },
  "debate_turns": 2,
  "requires_human_approval": true,
  "human_approval_required_until": "2026-05-06T14:35:22Z"
}
```

### Response Actions

#### Submit Response Action
```http
POST /actions
Content-Type: application/json

{
  "action_id": "action-12345",
  "action_type": "block_ip",
  "target": "203.0.113.5",
  "threat_id": "threat-12345",
  "debate_id": "debate-xyz-789",
  "human_approval": {
    "approved_by": "analyst@company.com",
    "approval_timestamp": "2026-05-06T14:35:22Z",
    "approval_signature": "jwt-token-here"
  }
}
```

Response:
```json
{
  "action_id": "action-12345",
  "status": "executing",
  "action_type": "block_ip",
  "target": "203.0.113.5",
  "execution_steps": [
    {
      "step": 1,
      "connector": "pfsense",
      "action": "Add firewall rule",
      "status": "in_progress"
    },
    {
      "step": 2,
      "connector": "crowdstrike",
      "action": "Isolate endpoint WS-12345",
      "status": "pending"
    }
  ],
  "estimated_completion": "2026-05-06T14:36:00Z"
}
```

### Metrics & Monitoring

#### Get Engine Metrics
```http
GET /metrics
```

Response:
```json
{
  "events_processed": 45280,
  "threats_detected": 127,
  "alerts_filtered": 12450,
  "average_processing_latency_ms": 87,
  "p99_latency_ms": 245,
  "debates_triggered": 23,
  "human_approvals": 21,
  "actions_executed": 19,
  "uptime_seconds": 604800,
  "kafka_lag": 0,
  "memory_usage_mb": 512,
  "cpu_usage_percent": 45
}
```

### Audit & Compliance

#### Get Action Audit Trail
```http
GET /audit?threat_id=threat-12345&limit=50
```

Response:
```json
{
  "audit_entries": [
    {
      "timestamp": "2026-05-06T14:35:22Z",
      "event_type": "threat_detected",
      "threat_id": "threat-12345",
      "details": {
        "threat_score": 0.98,
        "threat_actor": "APT-28"
      }
    },
    {
      "timestamp": "2026-05-06T14:35:45Z",
      "event_type": "debate_started",
      "debate_id": "debate-xyz-789"
    },
    {
      "timestamp": "2026-05-06T14:36:00Z",
      "event_type": "human_approval",
      "approved_by": "analyst@company.com",
      "approval_signature": "jwt-token"
    },
    {
      "timestamp": "2026-05-06T14:36:05Z",
      "event_type": "action_executed",
      "action_id": "action-12345",
      "status": "success"
    }
  ]
}
```

## Dashboard Backend API

### Authentication

All Dashboard API endpoints require Bearer token:

```http
Authorization: Bearer <jwt-token>
```

### Dashboard Summary

```http
GET /api/v1/dashboard
```

Response:
```json
{
  "threats": {
    "critical": 2,
    "high": 5,
    "medium": 12,
    "low": 34
  },
  "threat_actors": 3,
  "mttr_minutes": 8.5,
  "response_rate_percent": 94,
  "system_uptime_percent": 99.99,
  "total_events_today": 1250000
}
```

### List Threats (Dashboard)

```http
GET /api/v1/threats?page=1&page_size=20&sort=threat_score
```

### Create Incident

```http
POST /api/v1/incidents
Content-Type: application/json

{
  "threat_id": "threat-12345",
  "title": "Ransomware Campaign - APT-28",
  "description": "Multi-stage attack detected targeting finance department",
  "severity": "critical",
  "assigned_to": "security-team@company.com"
}
```

### Close Incident

```http
PATCH /api/v1/incidents/{incident_id}
Content-Type: application/json

{
  "status": "resolved",
  "resolution": "Threat actor IP ranges blocked, endpoints isolated and cleaned"
}
```

## Error Handling

All endpoints follow standard HTTP status codes:

| Code | Meaning |
|------|---------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource created |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing/invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |
| 503 | Service Unavailable - Maintenance/overloaded |

Error Response:
```json
{
  "error": "invalid_input",
  "message": "Missing required field: threat_id",
  "details": {
    "field": "threat_id",
    "reason": "required"
  },
  "request_id": "req-xyz-789"
}
```

## Rate Limiting

- **Rate limit:** 1000 requests/minute per API key
- **Headers:**
  ```
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 987
  X-RateLimit-Reset: 1651837200
  ```

## Webhooks

Subscribe to events:

```http
POST /webhooks/subscribe
Content-Type: application/json

{
  "event_type": "threat_detected",
  "url": "https://your-app.com/webhooks/threats",
  "headers": {
    "Authorization": "Bearer your-secret"
  }
}
```

Webhook payload:
```json
{
  "event_id": "evt-xyz-123",
  "event_type": "threat_detected",
  "timestamp": "2026-05-06T14:22:33Z",
  "data": {
    "threat_id": "threat-12345",
    "threat_score": 0.98,
    "threat_actor": "APT-28"
  }
}
```

---

## OpenAPI/Swagger

Interactive API documentation available at:
- AI Engine: `http://localhost:8001/docs`
- Dashboard: `http://localhost:8000/docs`

Download OpenAPI spec:
- `http://localhost:8001/openapi.json`
- `http://localhost:8000/openapi.json`

---

**Last Updated:** 2026-05-06
**API Version:** 1.0.0
