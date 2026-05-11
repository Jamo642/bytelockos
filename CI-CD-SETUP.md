# CI/CD Pipeline Setup

This project includes automated CI/CD checks to ensure code quality and prevent crashes.

## GitHub Actions Workflow

The `.github/workflows/ci.yml` file runs automatically on every commit and pull request to:

✓ **Lint Python code** (Black, Flake8, Pylint)  
✓ **Test Python modules** (pytest with coverage)  
✓ **Build and lint frontend** (ESLint, React build)  
✓ **Build Rust integrations** (cargo build & test)  
✓ **Build Docker images** (validation only, no push)  
✓ **Security scanning** (Bandit, Trufflehog)  

### Pipeline Stages

1. **Lint & Test** - Python code quality and unit tests (tests/ directory)
2. **Frontend Build** - React app compilation and linting
3. **Rust Build** - OCSF parser and syslog receiver compilation
4. **Docker Build** - Validates all Dockerfiles can build successfully
5. **Security Check** - Scans for vulnerabilities and leaked secrets
6. **Summary** - Reports overall pipeline status

**Note:** A commit will fail the pipeline if critical checks fail (lint-and-test, frontend-build, rust-build, docker-build). Security warnings are informational but don't block merges.

## Local Pre-Commit Hooks

To catch issues before pushing, set up pre-commit hooks locally:

```bash
# Install pre-commit
pip install pre-commit

# Install git hooks
pre-commit install

# Run hooks on all files (optional)
pre-commit run --all-files
```

After setup, hooks run automatically on `git commit` to check:
- Trailing whitespace, large files, merge conflicts
- Python formatting (Black, isort)
- Python linting (Flake8, Pylint)
- JavaScript/JSON/Markdown formatting (Prettier)

To bypass (not recommended):
```bash
git commit --no-verify
```

## Adding Tests

Add test files to the `tests/` directory following the `test_*.py` naming pattern:

```python
import pytest

def test_my_feature():
    """Test description"""
    assert True
```

Run locally:
```bash
pytest
pytest --cov  # with coverage report
```

## Troubleshooting

**CI fails but local tests pass?**
- Different Python versions might behave differently (CI tests 3.10 and 3.11)
- Check the GitHub Actions workflow logs for details

**Docker build fails in CI?**
- Ensure Dockerfiles use absolute paths
- Check that all COPY/ADD paths exist
- Review infrastructure/docker/docker-compose.yml for context settings

**Frontend build fails?**
- Run locally: `cd ui-dashboard/frontend && npm install --legacy-peer-deps && npm run build`
- Check for missing dependencies in package.json

**Rust build fails?**
- Run locally: `cd integrations/[project] && cargo build`
- Ensure Rust 1.70+ is installed
