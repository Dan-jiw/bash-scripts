#!/bin/bash
# log-cleanup.sh — remove log files older than N days
# Usage: ./log-cleanup.sh

# ── Configuration ──────────────────────────────────────────
LOG_DIRS=("/var/log/nginx" "/var/log/mysql" "/tmp")
KEEP_DAYS=14
DRY_RUN=false   # set to true to preview without deleting
# ───────────────────────────────────────────────────────────

DATE=$(date +"%Y-%m-%d %H:%M")
echo "[$DATE] Log cleanup started (keep last ${KEEP_DAYS} days)"

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] No files will be deleted."
fi

for DIR in "${LOG_DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then
        echo "[SKIP] Not found: $DIR"
        continue
    fi

    echo "Scanning: $DIR"

    if [ "$DRY_RUN" = true ]; then
        find "$DIR" -type f -name "*.log" -mtime +"$KEEP_DAYS" -print
    else
        find "$DIR" -type f -name "*.log" -mtime +"$KEEP_DAYS" -print -delete
    fi
done

echo "[$DATE] Cleanup finished."
