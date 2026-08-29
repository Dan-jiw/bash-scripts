#!/bin/bash
# user-setup.sh — create a sudo user with SSH key
# Usage: ./user-setup.sh USERNAME "ssh-ed25519 AAAA... user@host"

set -e

USERNAME="$1"
SSH_KEY="$2"

if [ -z "$USERNAME" ] || [ -z "$SSH_KEY" ]; then
    echo "Usage: $0 USERNAME \"ssh-public-key\""
    echo "Example: $0 danylo \"ssh-ed25519 AAAA... user@host\""
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "[INFO] User '$USERNAME' already exists."
else
    adduser --disabled-password --gecos "" "$USERNAME"
    echo "[OK] User '$USERNAME' created."
fi

# Add to sudo group
usermod -aG sudo "$USERNAME"
echo "[OK] Added '$USERNAME' to sudo group."

# Setup SSH key
SSH_DIR="/home/$USERNAME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
echo "$SSH_KEY" >> "$AUTH_KEYS"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTH_KEYS"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo "[OK] SSH key installed for '$USERNAME'."
echo ""
echo "Test login:"
echo "  ssh $USERNAME@YOUR_SERVER_IP"
