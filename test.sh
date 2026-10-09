#!/usr/bin/env bash

IMAGE_NAME="diagnostic-app"
VOLUME_NAME="log-data"

echo "=== Building Docker Image ==="
docker build -t "$IMAGE_NAME" . >/dev/null 2>&1

echo -e "\n=== Running Integration Tests ==="

# Test 1: System Command (Exit Code 0)
echo -n "Test 1: System subcommand... "
docker run --rm -v "$VOLUME_NAME":/app/logs "$IMAGE_NAME" system >/dev/null 2>&1
if [ $? -eq 0 ]; then echo "PASSED"; else echo "FAILED"; fi

# Test 2: Disk Command Valid (Exit Code 0 or 1)
echo -n "Test 2: Disk threshold check... "
docker run --rm -v "$VOLUME_NAME":/app/logs "$IMAGE_NAME" disk 99 >/dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 1 ]; then echo "PASSED"; else echo "FAILED"; fi

# Test 3: Disk Command Invalid Input (Exit Code 2)
echo -n "Test 3: Invalid threshold handling... "
docker run --rm -v "$VOLUME_NAME":/app/logs "$IMAGE_NAME" disk 150 >/dev/null 2>&1
if [ $? -eq 2 ]; then echo "PASSED"; else echo "FAILED"; fi

# Test 4: Network Command Host Missing (Exit Code 2)
echo -n "Test 4: Missing argument error handling... "
docker run --rm -v "$VOLUME_NAME":/app/logs "$IMAGE_NAME" network >/dev/null 2>&1
if [ $? -eq 2 ]; then echo "PASSED"; else echo "FAILED"; fi

# Test 5: Log File Persistence Verification
echo -n "Test 5: Persistent volume log check... "
LOG_COUNT=$(docker run --rm -v "$VOLUME_NAME":/app/logs alpine wc -l /app/logs/diagnostic.log 2>/dev/null | awk '{print $1}')
if [ -n "$LOG_COUNT" ] && [ "$LOG_COUNT" -gt 0 ]; then
    echo "PASSED ($LOG_COUNT log entries found)"
else
    echo "FAILED"
fi

echo -e "\n=== Testing Complete ==="
