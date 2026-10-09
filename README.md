# Assignment 3 - Multi-Container Diagnostic System with Persistent Logging

Enhanced Dockerized Diagnostic CLI supporting persistent volume logging, container healthchecks, and structured environment injection.

## Architecture Highlights
- **Base Image**: `alpine:3.19` running non-root `appuser`.
- **Volume Mount**: Named volume `log-data` mounted to `/app/logs` for file persistence across container lifecycles.
- **Healthcheck Endpoint**: `app/health-check.sh` integrated into compose file.

## Execution Guide

### Direct Container Execution
```bash
# Run system diagnostic with volume log persistence
docker run --rm -v log-data:/app/logs diagnostic-app system

# Run disk check against 80% threshold
docker run --rm -v log-data:/app/logs diagnostic-app disk 80

# Perform network diagnostic
docker run --rm -v log-data:/app/logs diagnostic-app network google.

Inspecting Persistent Logs
Bash

docker run --rm -v log-data:/app/logs alpine cat /app/logs/diagnostic.log

Running Automated Test Suite
Bash

./test.sh

