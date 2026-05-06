---
name: Bug Report
about: Create a bug report to help us improve
title: "[BUG] "
labels: bug
assignees: ''

---

## Description
A clear and concise description of what the bug is.

## Reproduction Steps
Steps to reproduce the behavior:
1. Go to '...'
2. Run command '...'
3. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened instead.

## Environment
- **OS:** (e.g., Ubuntu 22.04, macOS 13, Windows 11)
- **Docker version:** (output of `docker --version`)
- **Python version:** (output of `python3 --version`)
- **Rust version:** (if applicable, output of `cargo --version`)
- **Deployment:** (Docker Compose, Kubernetes, other)

## Logs
Please share relevant logs. You can get them with:
```bash
docker-compose logs ai-engine > logs.txt  # For Docker
kubectl logs -n bytelock-os -l app=ai-engine  # For Kubernetes
```

<details>
<summary>Log output (click to expand)</summary>

```
[Paste logs here]
```

</details>

## Screenshots
If applicable, add screenshots showing the issue.

## Minimal Example
If possible, provide minimal code/config to reproduce:

```python
# Minimal reproducible example
```

## Additional Context
Add any other context about the problem here.
