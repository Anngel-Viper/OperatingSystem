#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[x] This script must be run as root. Exiting..."
  exit 1
fi


read -p "Enter usernames separated by spaces: " -a my_array
echo "You entered: ${my_array[@]}"


# Upgrading the system
echo "[+] Updating & Upgrading the system"
apt update && apt upgrade -y

# Install fish
echo "[+] Installing fish shell"
apt install fish -y

# Changing Shell for each user
for i in "${my_array[@]}"; do
    echo "Changing shell for $i"
    chsh -s $(which fish) $i
done
chsh -s $(which fish)

sudo apt install powershell -y

# Installing VSCode for ParrotOS
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" --output vscode.deb
dpkg -i vscode.deb
rm vscode.deb


