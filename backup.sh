#!/bin/bash
# backup.sh — backup directories with rotation
# Usage: ./backup.sh

# ── Configuration ──────────────────────────────────────────
BACKUP_DIRS=("/etc" "/var/www" "/home")   # directories to back up
BACKUP_DEST="/var/backups/manual"          # where to store archives
KEEP_DAYS=7                                # delete backups older than N days
DATE=$(date +"%Y-%m-%d_%H-%M")
LOG="/var/log/backup.log"
# ───────────────────────────────────────────────────────────

mkdir -p "$BACKUP_DEST"

echo "[$DATE] Starting backup..." | tee -a "$LOG"

for DIR in "${BACKUP_DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then
        echo "[WARN] Directory not found, skipping: $DIR" | tee -a "$LOG"
        continue
    fi

    NAME=$(echo "$DIR" | tr '/' '_' | sed 's/^_//')
    ARCHIVE="$BACKUP_DEST/${NAME}_${DATE}.tar.gz"

    tar -czf "$ARCHIVE" "$DIR" 2>>"$LOG"

    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$ARCHIVE" | cut -f1)
        echo "[OK] $DIR → $ARCHIVE ($SIZE)" | tee -a "$LOG"
    else
        echo "[ERROR] Failed to backup $DIR" | tee -a "$LOG"
    fi
done

# Rotate: delete archives older than KEEP_DAYS
echo "Removing backups older than $KEEP_DAYS days..." | tee -a "$LOG"
find "$BACKUP_DEST" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete

echo "[$DATE] Backup finished." | tee -a "$LOG"
echo "─────────────────────────────" >> "$LOG"
