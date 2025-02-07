#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[x] This script must be run as root. Exiting..."
  exit 1
fi

# Upgrading the system
echo "[+] Updating & Upgrading the system"
apt update && apt upgrade -y

# Install fish
echo "[+] Installing fish shell"
apt install fish -y
chsh -s $(which fish) $USER
chsh -s $(which fish)

