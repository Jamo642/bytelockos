# ByteLock OS - Testing Guide

## Test Structure

```
tests/
├── integration/
│   ├── test_kafka_pipeline.py
│   ├── test_ocsf_normalization.py
│   ├── test_correlation_engine.py
│   └── test_multi_agent_debate.py
├── unit/
│   ├── test_parsers.rs
│   ├── test_syslog_receiver.rs
│   └── test_ai_logic.py
└── fixtures/
    ├── sample_logs/
    └── mock_responses/
```

## Running Tests

### Python Tests
```bash
# Activate virtual environment
source venv/bin/activate

# Run all tests
pytest tests/

# Run with coverage
pytest tests/ --cov=ai_engine --cov=ui_dashboard

# Run specific test
pytest tests/integration/test_correlation_engine.py -v

# Run with logging
pytest tests/ -v --log-cli-level=DEBUG
```

### Rust Tests
```bash
# Run all Rust tests
cargo test --workspace

# Run tests with output
cargo test -- --nocapture

# Run specific package tests
cargo test -p ocsf-parsers
cargo test -p syslog-receiver

# Run with logging
RUST_LOG=debug cargo test -- --nocapture
```

### Integration Tests
```bash
# Start Docker Compose services
docker-compose -f infrastructure/docker/docker-compose.yml up -d

# Run integration tests
pytest tests/integration/ -v

# Tear down
docker-compose down
```

## Test Coverage Goals

- **Unit Tests:** 80%+ coverage
- **Integration Tests:** Critical paths (Kafka → Correlation → Response)
- **E2E Tests:** Full attack scenario simulations

## Example Tests

### Test Correlation Engine
```python
@pytest.mark.asyncio
async def test_kill_chain_detection():
    """Verify Master AI detects multi-stage attack."""
    engine = CorrelationEngine(kafka_bus)
    
    # Simulate attack sequence
    failed_login = create_ocsf_event("failed_login")
    process_exec = create_ocsf_event("process_execution", process="mimikatz.exe")
    c2_beacon = create_ocsf_event("network_traffic", destination="203.0.113.5")
    
    # Process events
    await engine.process_event(failed_login)
    await engine.process_event(process_exec)
    await engine.process_event(c2_beacon)
    
    # Verify kill chain detected
    threats = await engine.get_active_threats()
    assert len(threats) > 0
    assert threats[0]["threat_score"] > 0.9
```

### Test Multi-Agent Debate
```python
@pytest.mark.asyncio
async def test_debate_turns():
    """Verify debate completes in 2 turns."""
    debate = MultiAgentDebate("local")
    
    analysis = {
        "threat_score": 0.95,
        "proposed_action": "Block IP and isolate endpoint",
    }
    
    result = await debate.debate(analysis)
    
    assert result["debate_turns"] == 2
    assert "master_ai_argument" in result
    assert "devils_advocate_argument" in result
    assert result["requires_human_approval"] is True
```

## Performance Benchmarks

Target metrics:
- **Event processing:** <100ms latency (p99)
- **Correlation:** <500ms for 1000 events
- **LLM inference:** <2s per debate
- **API response:** <200ms (p95)

Run benchmarks:
```bash
pytest tests/performance/ --benchmark
```

## CI/CD Integration

See `.github/workflows/test.yml` for automated testing on pull requests.

Tests run on:
- Python 3.10, 3.11, 3.12
- Rust 1.70+
- Ubuntu, macOS, Windows

---

Happy testing! 🧪
