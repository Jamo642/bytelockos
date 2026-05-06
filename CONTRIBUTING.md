# Contributing to ByteLock OS

We welcome contributions to ByteLock OS! Whether it's bug fixes, new features, documentation, or security improvements, we appreciate your help in making enterprise security more intelligent.

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Python 3.10+
- Rust 1.70+ (for connector development)
- Node.js 18+ (for frontend development)
- Git

### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/your-org/bytelock-os.git
cd bytelock-os

# Run setup script
./scripts/setup.sh

# Verify installation
docker-compose logs -f
```

## Development Workflow

### 1. Create a Branch

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/xxx` - New features
- `fix/xxx` - Bug fixes
- `docs/xxx` - Documentation
- `refactor/xxx` - Code refactoring
- `perf/xxx` - Performance improvements

### 2. Make Changes

Follow the coding standards for your language:

#### Python (AI Engine & Dashboard)
```python
# Follow PEP 8
# Use type hints
# Add docstrings

def process_event(event: Dict[str, Any]) -> Optional[Threat]:
    """
    Process OCSF event through correlation engine.
    
    Args:
        event: OCSF-formatted event dictionary
        
    Returns:
        Threat object if suspicious, None otherwise
    """
    # Implementation
```

#### Rust (Integrations & Connectors)
```rust
// Follow Rust naming conventions
// Use idiomatic Rust (iterators, pattern matching)
// Add comprehensive error handling

pub async fn parse_log(raw: &str) -> Result<OcsEvent> {
    // Implementation
}
```

#### TypeScript/React (Dashboard Frontend)
```typescript
// Use functional components + hooks
// Type all props and state
// Follow naming conventions

interface ThreatProps {
  threatId: string;
  severity: "low" | "medium" | "high" | "critical";
}

export const ThreatCard: React.FC<ThreatProps> = ({ threatId, severity }) => {
  // Implementation
};
```

### 3. Test Your Changes

```bash
# Python tests
pytest tests/ -v --cov

# Rust tests
cargo test --workspace

# Frontend tests (if applicable)
cd ui-dashboard/frontend
npm test
```

**Coverage requirement:** Aim for 80%+ line coverage for new code.

### 4. Write/Update Documentation

- Update `README.md` if adding new features
- Update `docs/ARCHITECTURE.md` for architecture changes
- Add docstrings to all public functions
- Update API documentation at `docs/API.md`

### 5. Commit Changes

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: add multi-threat correlation support

- Implement independent Kafka streams per threat
- Add threat actor attribution AI
- Update Master AI correlation logic
- Add tests for parallel threat handling"
```

**Commit message format:**
- `feat: ...` - New feature
- `fix: ...` - Bug fix
- `docs: ...` - Documentation
- `refactor: ...` - Code refactoring
- `perf: ...` - Performance improvement
- `test: ...` - Testing improvements
- `chore: ...` - Dependency updates, etc.

### 6. Push & Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create PR via GitHub UI
```

**PR checklist:**
- [ ] Tests pass locally (`pytest`, `cargo test`)
- [ ] Code coverage maintained (80%+)
- [ ] Docstrings added/updated
- [ ] No breaking changes (or documented)
- [ ] PR description explains what and why

### 7. Code Review

- Address reviewer feedback
- Push additional commits for fixes
- Don't force-push once PR is under review

### 8. Merge

Once approved, maintainers will merge to `main`.

## Code Style Guidelines

### Python
```bash
# Format code
black ai-engine/ ui-dashboard/

# Lint
flake8 ai-engine/ ui-dashboard/

# Type checking
mypy ai-engine/ ui-dashboard/
```

### Rust
```bash
# Format code
cargo fmt --all

# Lint
cargo clippy --all-targets --all-features
```

### Pre-commit Hook (Recommended)

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Security

### Reporting Security Issues

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead:
1. Email security@bytelock.io with:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

2. We'll respond within 24 hours
3. We'll issue a patch and coordinate disclosure

### Security Best Practices

- Never commit secrets (API keys, credentials, etc.)
- Use environment variables for sensitive config
- Follow OWASP guidelines for input validation
- Always validate user input
- Use parameterized queries to prevent SQL injection
- Keep dependencies up to date

## Performance

When making changes that might affect performance:

1. Run benchmarks before/after:
   ```bash
   pytest tests/performance/ --benchmark
   ```

2. Document performance impact in PR description
3. Target metrics:
   - Event processing: <100ms (p99)
   - API response: <200ms (p95)
   - Memory: <1GB per container

## Documentation

### Adding a New Feature

1. **Code comments:** Explain WHY, not what
   ```python
   # Bad: Add 1 to x
   x = x + 1
   
   # Good: Increment counter for successful debated decisions
   debate_decision_count += 1
   ```

2. **Docstrings:** Google or NumPy style
   ```python
   def analyze_threat(event: Dict) -> Threat:
       """Analyze OCSF event for threat indicators.
       
       Args:
           event: OCSF event dictionary
           
       Returns:
           Threat object with score and metadata
           
       Raises:
           ValueError: If event missing required fields
       """
   ```

3. **Architecture docs:** Update if changing system design
   ```
   docs/ARCHITECTURE.md
   docs/API.md
   docs/DEPLOYMENT.md
   ```

## Dependency Management

### Adding Python Package
```bash
# Add to requirements.txt with pinned version
pip install package-name==1.2.3
pip freeze | grep package-name >> requirements.txt

# Rebuild Docker
docker-compose build --no-cache
```

### Adding Rust Dependency
```bash
# Add to Cargo.toml
cargo add dependency-name

# Lock version
cargo update
```

### Version Pinning
- Pin major versions in production: `package==1.2.3`
- Use `~=` for compatible releases: `~=1.2.0` (allows 1.2.x, not 1.3.0)

## Issue Management

### Reporting Bugs

Include:
1. **Environment:**
   - OS, Docker version
   - Python/Rust version
   - Docker Compose vs. Kubernetes?

2. **Steps to reproduce:**
   - Exact commands
   - Sample input/logs

3. **Expected vs. actual behavior**

4. **Logs & error messages:**
   ```bash
   docker-compose logs ai-engine > logs.txt
   ```

### Feature Requests

Include:
1. **Problem statement:** What's the use case?
2. **Proposed solution:** How should it work?
3. **Alternatives:** Other approaches considered?

## Testing Strategy

### Required Test Coverage

- **Unit tests:** Core logic (80%+ coverage)
- **Integration tests:** Kafka pipeline, API endpoints
- **E2E tests:** Full attack scenarios

### Running Tests Locally

```bash
# Full test suite
./scripts/run-tests.sh

# Specific test
pytest tests/integration/test_correlation_engine.py::test_kill_chain_detection -v

# With coverage report
pytest tests/ --cov=ai_engine --cov-report=html
open htmlcov/index.html
```

## Release Process

1. **Version bump:** Update `__version__` in `__init__.py`
2. **Changelog:** Add entry to `CHANGELOG.md`
3. **Tag release:** `git tag v0.2.0`
4. **Build artifacts:** Docker images pushed to registry
5. **Deploy:** Kubernetes manifests updated

## Questions?

- **Documentation:** See `docs/` folder
- **Architecture:** Read `docs/ARCHITECTURE.md`
- **Discussion:** Open GitHub Discussion
- **Chat:** Join our Slack workspace (link in README)

---

Thank you for contributing to ByteLock OS! 🔐
