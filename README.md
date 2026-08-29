# bash-scripts

A collection of practical Bash scripts for Linux server automation.  
Tested on Ubuntu 22.04 / Debian 12.

---

## Scripts included

| File | Description |
|---|---|
| `backup.sh` | Backup directories with date-stamped archives and rotation |
| `health-check.sh` | Check CPU, RAM, disk usage — log and alert if thresholds exceeded |
| `log-cleanup.sh` | Clean old logs older than N days |
| `user-setup.sh` | Create a new sudo user with SSH key in one command |
| `update-system.sh` | Full system update + cleanup in one run |

> 📸 Screenshots in `/screenshots/`

---

## Requirements

- Ubuntu 22.04 / Debian 12
- Bash 5+
- `mail` or `mailutils` (optional, for email alerts in health-check)

---

## Usage

```bash
# Clone the repo
git clone https://github.com/Dan-jiw/bash-scripts.git
cd bash-scripts

# Make a script executable
chmod +x backup.sh

# Run
./backup.sh
```

---

## Script 1 — backup.sh

Creates compressed archives of specified directories.  
Keeps the last N backups and deletes older ones automatically.

```bash
./backup.sh
```

Configure at the top of the file:
- `BACKUP_DIRS` — what to back up
- `BACKUP_DEST` — where to store archives
- `KEEP_DAYS` — how many days to keep

---

## Script 2 — health-check.sh

Checks CPU load, RAM usage, and disk space.  
Logs results to a file. Prints a warning if any threshold is exceeded.

```bash
./health-check.sh
```

Set thresholds at the top:
- `CPU_THRESHOLD` — default 80%
- `RAM_THRESHOLD` — default 80%
- `DISK_THRESHOLD` — default 85%

Add to cron for automatic monitoring:

```bash
crontab -e
# Run every hour
0 * * * * /opt/scripts/health-check.sh >> /var/log/health-check.log 2>&1
```

---

## Script 3 — log-cleanup.sh

Removes log files older than N days from specified directories.  
Safe: prints what will be deleted before doing it.

```bash
./log-cleanup.sh
```

---

## Script 4 — user-setup.sh

Creates a new Linux user with sudo rights and installs an SSH public key.  
Useful when provisioning a new server.

```bash
./user-setup.sh USERNAME "ssh-ed25519 AAAA... user@host"
```

---

## Script 5 — update-system.sh

Runs a full system update, removes unused packages, and clears the apt cache.

```bash
./update-system.sh
```

---

## Cron setup example

```bash
crontab -e
```

```
# Daily backup at 02:00
0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1

# Health check every hour
0 * * * * /opt/scripts/health-check.sh >> /var/log/health-check.log 2>&1

# Log cleanup every Sunday at 03:00
0 3 * * 0 /opt/scripts/log-cleanup.sh >> /var/log/cleanup.log 2>&1

# System update every Monday at 04:00
0 4 * * 1 /opt/scripts/update-system.sh >> /var/log/update.log 2>&1
```

---

## Checklist

- [ ] Scripts are executable (`chmod +x`)
- [ ] Paths configured inside each script
- [ ] Tested manually before adding to cron
- [ ] Logs are being written correctly
- [ ] Old backups are rotating as expected

---

## Author

**Dan-jiw** · [GitHub](https://github.com/Dan-jiw)
