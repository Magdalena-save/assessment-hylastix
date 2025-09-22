#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp || true    # opciono
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable

echo "[*] UFW enabled: 22/80/443 allowed, ostalo deny."
