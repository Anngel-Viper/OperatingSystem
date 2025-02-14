#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[x] This script must be run as root. Exiting..."
  exit 1
fi

echo "[+] This script is running as root"

# Getting all the usernames
read -p "Enter usernames separated by spaces: " -a my_array
echo "You entered: ${my_array[@]}"

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

# Changing Shell for each user
for i in "${my_array[@]}"; do
    echo "Changing shell for $i"
    chsh -s $(which fish) $i
done

pacman -S starship --noconfirm
echo "starship init fish | source " >> ~/.config/fish/config.fish


# Installing VSCode
curl https://code.visualstudio.com/sha/download?build=stable&os=linux-x64 --output vscode.tar.gz
tar -xvf vscode.tar.gz
mv VSCode-linux-x64 /opt/
ln -s /opt/VSCode-linux-x64/code /usr/bin/code
ln -s /opt/VSCode-linux-x64/code /usr/bin/vscode
rm vscode.tar.gz
echo "[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
Exec=/opt/VSCode-linux-x64/bin/code --no-sandbox %F
Icon=/opt/VSCode-linux-x64/resources/app/resources/linux/code.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
MimeType=text/plain;
" >> /usr/share/applications/vscode.desktop

chmod +x /usr/share/applications/vscode.desktop
update-desktop-database ~/.local/share/applications/


# Install Black Arch
curl -o ~/Downloads/strap.sh https://blackarch.org/strap.sh
chmod +x ~/Downloads/strap.sh
sh strap.sh


