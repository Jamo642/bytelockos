# ByteLock OS - AI-Driven Cybersecurity Operating System

A containerized, distributed **Cybersecurity Operating System (SecOS)** that acts as the unified command center orchestrating all enterprise security tools through intelligent correlation, multi-agent AI debate, and automated response.

## Vision

ByteLock OS transforms fragmented security tools into a cohesive, intelligent defense system by:
- **Centralizing telemetry** from SIEMs, EDR, cloud, firewalls, and IDS into a Kafka event bus
- **Normalizing everything** to OCSF (Open Cybersecurity Schema Framework) 
- **Correlating attacks** across domains using hierarchical AI (Edge + Master AIs)
- **Debating high-risk decisions** via multi-agent LLM consensus
- **Requiring human approval** for costly/dangerous actions
- **Automating response** through integrated SOAR actions

## Architecture at a Glance

```
[Security Tools] → [Kafka Bus] → [OCSF Normalization] → [AI Correlation] 
  → [Multi-Agent Debate] → [HITL Approval] → [Automated Response]
```

## Tech Stack (Holy Trinity)

| Component | Language | Purpose |
|-----------|----------|---------|
| Data Ingestion, API Connectors, Syslog Receivers | **Rust (45%)** | Memory-safe, high-performance |
| AI Orchestration, ML Pipelines, Multi-Agent Debate | **Python (50%)** | Flexibility, LLM ecosystem |
| Kernel-level Hardware Sensors, eBPF | **C/eBPF (5%)** | Zero-day anomaly detection |

## Directory Structure

```
bytelock-os/
├── integrations/                  # Rust-based data connectors
│   ├── connectors/               # API connectors (Splunk, CrowdStrike, AWS, etc.)
│   ├── ocsf-parsers/             # Convert any format → OCSF JSON
│   └── syslog-receiver/          # Listen on UDP/514 for legacy logs
├── ai-engine/                     # Python AI orchestration
│   ├── correlation/              # Master AI + Kill chain detection
│   ├── multi-agent-debate/       # LLM reasoning, cost gating, HITL approval
│   ├── anomaly-detection/        # CNNs for zero-day, GANs for pentesting
│   └── memory-safety/            # Vector DB, poisoning defense
├── ui-dashboard/                 # Web interface + backend API
│   ├── backend/                  # Python Flask/FastAPI backend
│   └── frontend/                 # React/Vue frontend
├── infrastructure/               # Containerization & orchestration
│   ├── docker/                   # Dockerfiles for each component
│   ├── kubernetes/               # K8s manifests (deployments, services)
│   └── terraform/                # IaC for cloud deployment
├── docs/                         # Architecture docs, API specs, runbooks
├── scripts/                      # Setup, deployment, debugging scripts
└── tests/                        # Integration & unit tests
```

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Kubernetes cluster (optional, for production)
- Python 3.10+
- Rust 1.70+
- Git

### 1. Clone & Setup
```bash
git clone https://github.com/your-org/bytelock-os.git
cd bytelock-os
```

### 2. Start with Docker Compose (Development)
```bash
docker-compose -f infrastructure/docker/docker-compose.yml up -d
```

This spins up:
- Apache Kafka (event bus)
- PostgreSQL (state store)
- Python AI engine
- Rust connectors
- Web UI backend
- Frontend dashboard

### 3. Access the UI
Open http://localhost:3000 in your browser.

### 4. Deploy to Kubernetes (Production)
```bash
kubectl apply -f infrastructure/kubernetes/
```

## Core Components

### 1. **Kafka Event Bus** (Central Nervous System)
Hyper-reliable event streaming with topics:
- `secos.telemetry.raw` - Raw, unfiltered logs
- `secos.telemetry.cloud` - AWS/Azure/GCP events
- `secos.telemetry.endpoint` - EDR, Windows/Mac/Linux
- `secos.telemetry.network` - IDS/Firewall logs
- `secos.events.ocsf` - Normalized OCSF JSON
- `secos.ai.analysis` - AI analysis results
- `secos.response.actions` - Commands from AI to security tools

### 2. **Integrations Layer** (Rust)
Bi-directional connectors for:
- **API-based:** Splunk, CrowdStrike, AWS, Azure, Okta, Slack
- **Syslog-based:** pfSense, Cisco, Fortinet (legacy hardware)

Each connector:
- Pulls telemetry into Kafka
- Pushes response actions (block IP, lock device, etc.)
- Validates TLS/mTLS
- Handles rate limiting & backpressure

### 3. **OCSF Normalization** (Rust)
Parse any vendor format into standardized OCSF JSON:
```json
{
  "event_time": "2026-05-06T14:22:33Z",
  "severity": "high",
  "activity": "detect",
  "category": "system_activity",
  "object_type": "process",
  "status": "success",
  "metadata": { "event_code": "4688", ... }
}
```

### 4. **Correlation Engine** (Python)
- **Master AI:** Reads 5+ Kafka topics, spots kill chains and smokescreens
- **Edge AIs:** Live inside connector apps, filter domain-specific noise
- **CNNs:** Transform time-series telemetry into spatial matrices for zero-day detection
- **GANs:** Powers MITRE ATLAS fuzzing & automated threat testing

### 5. **Multi-Agent Debate** (Python)
- Master AI vs. Devil's Advocate LLM reasoning
- Cost-based gating: Low-cost actions auto-approved, high-cost trigger debate
- 2-turn limit (or unlimited for private LLMs)
- Hallucination detection & output sanitization
- **Human-in-the-Loop:** Critical decisions require human JWT approval

### 6. **Automated Response** (SOAR)
Actions triggered after debate + approval:
- Block/unblock IP via firewall API
- Isolate endpoint (network quarantine)
- Lock device remotely (Jamf, Intune)
- Revoke credentials (Okta, AD)
- Create incident in SIEM
- Send alerts to Slack/Teams/PagerDuty

## AI Architecture

### Hierarchical Intelligence
```
Master AI (central correlation)
├── Edge AI (Cloud domain) - AWS/Azure/GCP threat detection
├── Edge AI (Endpoint domain) - EDR threat detection
├── Edge AI (Network domain) - IDS/Firewall threat detection
└── Edge AI (Identity domain) - Okta/AD anomalies
```

### Advanced Defenses Built-In
- **Alert Spam Defense:** CNN-based classification (1000+ incoherent alerts = flagged, hidden from SOC)
- **DDoS Detection:** CNN-based pattern matching (identical requests + synchronized timing)
- **Threat Actor Attribution:** Learn attacker patterns, deprioritize repeat attacks
- **Multi-Attacker Scenarios:** Independent Kafka streams per threat, parallel multi-agent debates
- **Memory Poisoning Defense:** Immutable Vector DB, daily cryptographic snapshots, GAN fuzzing

### Cost Optimization
- Use BYOM (Bring Your Own Model): Single LLM provider, multi-agent debate via system prompts
- Tiered Hardware:
  - **Strong:** Run Llama 70B locally (100% privacy, zero API costs)
  - **Weak:** Run Llama 7B locally (free), route only 1% of suspicious alerts to cheap cloud APIs (Haiku, GPT-4o-mini)

## API Gateway

REST API for integrations:

```
POST /api/v1/alerts       - Ingest raw alerts
POST /api/v1/actions      - Dispatch response actions
GET  /api/v1/threats      - Query active threats
GET  /api/v1/dashboard    - Real-time dashboard metrics
```

## Configuration

All components use environment variables. See `.env.example` for defaults.

Key configs:
- `KAFKA_BOOTSTRAP_SERVERS` - Kafka cluster address
- `LLM_PROVIDER` - `openai`, `anthropic`, or `local` (llama)
- `COST_THRESHOLD` - $ value triggering HITL approval
- `DEBUG_MODE` - Enable verbose logging

## Security & Compliance

- **mTLS** on all inter-service communication
- **RBAC** on UI & API (Role-based access control)
- **Immutable audit logs** in PostgreSQL
- **GDPR/HIPAA-compliant** data retention policies
- **Air-gapped option** - Can run fully offline with private LLMs

## Development

### Contributing
1. Fork the repo
2. Create a feature branch (`git checkout -b feature/xyz`)
3. Make changes & test locally
4. Submit PR with description of changes

### Running Tests
```bash
pytest tests/                    # Python tests
cargo test                       # Rust tests
npm test                         # Frontend tests (if applicable)
```

### Building Docker Images
```bash
./scripts/build-docker.sh
```

## Production Deployment

### Recommended Setup
- **Kafka cluster:** 3+ brokers for HA
- **Kubernetes cluster:** 3+ nodes, GPU node for ML training
- **PostgreSQL:** Primary + replicas
- **Redis:** For caching & session store
- **TLS certificates:** Issued by internal CA or LetsEncrypt

See [infrastructure/kubernetes/README.md](infrastructure/kubernetes/README.md) for detailed setup.

## Roadmap

- [ ] Phase 1: MVP - Kafka + OCSF normalization + basic correlation
- [ ] Phase 2: Multi-agent debate + HITL approval gates
- [ ] Phase 3: GAN-based pentesting (MITRE ATLAS)
- [ ] Phase 4: Edge AI deployment (domain-specific filtering)
- [ ] Phase 5: Autopsy DFIR integration

## License

[Your License Here]

## Contact

- **Questions?** Open an Issue
- **Security concerns?** Email security@bytelock.io
- **Commercial support?** Contact sales@bytelock.io

---

**ByteLock OS**: Transforming chaos into clarity. 🔐
