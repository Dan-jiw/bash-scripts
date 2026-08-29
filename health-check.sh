#!/bin/bash
# health-check.sh — monitor CPU, RAM, disk usage
# Usage: ./health-check.sh
# Recommended: run via cron every hour

# ── Configuration ──────────────────────────────────────────
CPU_THRESHOLD=80    # % — warn if exceeded
RAM_THRESHOLD=80    # %
DISK_THRESHOLD=85   # %
LOG="/var/log/health-check.log"
# ───────────────────────────────────────────────────────────

DATE=$(date +"%Y-%m-%d %H:%M")
WARN=0

echo "[$DATE] Health check started" >> "$LOG"

# ── CPU ────────────────────────────────────────────────────
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%')
CPU_USED=$(echo "100 - $CPU_IDLE" | bc 2>/dev/null || echo "N/A")

if [ "$CPU_USED" != "N/A" ] && [ "$(echo "$CPU_USED > $CPU_THRESHOLD" | bc)" -eq 1 ]; then
    echo "[WARN] CPU usage: ${CPU_USED}% (threshold: ${CPU_THRESHOLD}%)" | tee -a "$LOG"
    WARN=1
else
    echo "[OK]   CPU usage: ${CPU_USED}%" >> "$LOG"
fi

# ── RAM ────────────────────────────────────────────────────
RAM_TOTAL=$(free | awk '/^Mem:/ {print $2}')
RAM_USED=$(free | awk '/^Mem:/ {print $3}')
RAM_PCT=$(awk "BEGIN {printf \"%.0f\", ($RAM_USED/$RAM_TOTAL)*100}")

if [ "$RAM_PCT" -gt "$RAM_THRESHOLD" ]; then
    echo "[WARN] RAM usage: ${RAM_PCT}% (threshold: ${RAM_THRESHOLD}%)" | tee -a "$LOG"
    WARN=1
else
    echo "[OK]   RAM usage: ${RAM_PCT}%" >> "$LOG"
fi

# ── Disk ───────────────────────────────────────────────────
while IFS= read -r line; do
    USAGE=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')

    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo "[WARN] Disk $MOUNT usage: ${USAGE}% (threshold: ${DISK_THRESHOLD}%)" | tee -a "$LOG"
        WARN=1
    else
        echo "[OK]   Disk $MOUNT usage: ${USAGE}%" >> "$LOG"
    fi
done < <(df -h | grep '^/dev/')

# ── Summary ────────────────────────────────────────────────
if [ "$WARN" -eq 0 ]; then
    echo "[OK]   All checks passed." >> "$LOG"
else
    echo "[WARN] Some thresholds exceeded — review log: $LOG" | tee -a "$LOG"
fi

echo "─────────────────────────────" >> "$LOG"
