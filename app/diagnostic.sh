#!/usr/bin/env sh

LOG_DIR="/app/logs"
LOG_FILE="${LOG_DIR}/diagnostic.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR" 2>/dev/null

log_message() {
    LEVEL="$1"
    MSG="$2"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$TIMESTAMP] [$LEVEL] $MSG" | tee -a "$LOG_FILE"
}

show_help() {
    echo "Usage: diagnostic.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  system           Display system metrics (CPU, Memory, Hostname)"
    echo "  disk <threshold> Check disk usage against percentage threshold (1-100)"
    echo "  network <host>   Check host connectivity and ping"
    echo "  help             Display this help message"
}

COMMAND="$1"

case "$COMMAND" in
    system)
        log_message "INFO" "Running system diagnostic"
        echo "=== System Status ==="
        echo "Hostname: $(hostname)"
        echo "Uptime:   $(uptime)"
        if [ -f /proc/meminfo ]; then
            echo "Memory:   $(free -h 2>/dev/null || grep MemTotal /proc/meminfo)"
        fi
        exit 0
        ;;
    disk)
        THRESHOLD="$2"
        if [ -z "$THRESHOLD" ] || ! [ "$THRESHOLD" -eq "$THRESHOLD" ] 2>/dev/null; then
            log_message "ERROR" "Disk check failed: Invalid threshold input '$THRESHOLD'"
            echo "Error: Disk threshold must be an integer (1-100)" >&2
            exit 2
        fi
        if [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
            log_message "ERROR" "Disk check failed: Threshold '$THRESHOLD' out of bounds"
            echo "Error: Threshold must be between 1 and 100" >&2
            exit 2
        fi
        
        USAGE=$(df -P / | tail -n 1 | awk '{print $5}' | tr -d '%')
        echo "Current disk usage: ${USAGE}% (Threshold: ${THRESHOLD}%)"
        
        if [ "$USAGE" -ge "$THRESHOLD" ]; then
            log_message "WARN" "Disk usage (${USAGE}%) exceeded threshold (${THRESHOLD}%)"
            echo "WARNING: Disk usage exceeds threshold!"
            exit 1
        fi
        log_message "INFO" "Disk check passed: ${USAGE}% used (threshold: ${THRESHOLD}%)"
        exit 0
        ;;
    network)
        HOST="$2"
        if [ -z "$HOST" ]; then
            log_message "ERROR" "Network check failed: Target host missing"
            echo "Error: Target host is required" >&2
            exit 2
        fi
        log_message "INFO" "Pinging target host: $HOST"
        if ping -c 2 -W 2 "$HOST" >/dev/null 2>&1; then
            log_message "INFO" "Network check success: $HOST reachable"
            echo "SUCCESS: Host $HOST is reachable"
            exit 0
        else
            log_message "ERROR" "Network check failed: Host $HOST unreachable"
            echo "ERROR: Could not reach $HOST" >&2
            exit 1
        fi
        ;;
    help|""|--help|-h)
        show_help
        exit 0
        ;;
    *)
        log_message "ERROR" "Unknown command received: '$COMMAND'"
        echo "Error: Unknown command '$COMMAND'" >&2
        show_help
        exit 2
        ;;
esac