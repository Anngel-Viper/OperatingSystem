#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[x] This script must be run as root. Exiting..."
  exit 1
fi

echo "[+] This script is running as root"

# Update the system
echo "[+] Updating & Upgrading the system"
pacman -Syu --noconfirm

# Install yay
echo "[+] Installing yay"
pacman -S yay --noconfirm

# Installing paru
echo "[+] Installing paru"
pacman -S paru --noconfirm

# Installing fish shell
echo "[+] Installing fish shell"
pacman -S fish --noconfirm
chsh -s $(which fish)
chsh -s $(which fish) $USER
pacman -S starship --noconfirm
echo "starship init fish | source " >> ~/.config/fish/config.fish

# # Installing Virtualbox 
# echo "[+] Installing Virtualbox"
# pacman -S virtualbox virtualbox-host-modules-lts linux-lts-headers
# modprobe vboxdrv
# usermod -aG vboxusers $USER

