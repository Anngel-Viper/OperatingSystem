# This is my Personal Kali Linux script
# There is no need for changing the shell for the Kali Linux
# Lets work on what are the things that I need in the Kali Linux

#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[x] This script must be run as root. Exiting..."
  exit 1
fi

apt update

# Installing KDE Plasma
apt install kali-desktop-kde -y

apt upgrade

# Installing Powershell
sudo apt install powershell -y

# Installing VSCode for ParrotOS
curl https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 --output vscode.deb
dpkg -i vscode.deb
rm vscode.deb
