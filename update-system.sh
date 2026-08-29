#!/bin/bash
# update-system.sh — full system update and cleanup
# Usage: ./update-system.sh

DATE=$(date +"%Y-%m-%d %H:%M")
LOG="/var/log/system-update.log"

echo "[$DATE] System update started" | tee -a "$LOG"

# Update package lists
apt update 2>&1 | tee -a "$LOG"

# Upgrade packages
apt upgrade -y 2>&1 | tee -a "$LOG"

# Remove unused packages
apt autoremove -y 2>&1 | tee -a "$LOG"

# Clear apt cache
apt clean 2>&1 | tee -a "$LOG"

echo "[$DATE] Update finished." | tee -a "$LOG"

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "[INFO] Reboot required. Run: sudo reboot" | tee -a "$LOG"
else
    echo "[OK] No reboot required." | tee -a "$LOG"
fi

echo "─────────────────────────────" >> "$LOG"
