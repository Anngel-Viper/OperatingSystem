#!/bin/bash

# Updating the system
echo "[+] Updating & Upgrading the system"
sudo pacman -Syu --noconfirm

# Installing an AUR helper (choose one)
sudo pacman -S --needed --noconfirm yay  # Or use paru instead

# Installing fish shell
sudo pacman -S fish --noconfirm

# Changing shell for the user
chsh -s $(which fish)
sudo chsh -s $(which fish)

# Customizing the Shell Look
sudo pacman -S starship --noconfirm
mkdir -p ~/.config/fish
echo "starship init fish | source " >> ~/.config/fish/config.fish


# Installing the VScode for the user
# curl -Lo vscode-linux.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
# tar -xvzf vscode-linux.tar.gz
# rm vscode-linux.tar.gz
# sudo mv VSCode-linux-x64 /opt/
# sudo ln -s /opt/VSCode-linux-x64/code /usr/bin/code
# sudo ln -s /opt/VSCode-linux-x64/code /usr/bin/vscode
# sudo echo "[Desktop Entry]
# Name=Visual Studio Code
# Comment=Code Editing. Redefined.
# Exec=/opt/VSCode-linux-x64/bin/code --no-sandbox %F
# Icon=/opt/VSCode-linux-x64/resources/app/resources/linux/code.png
# Terminal=false
# Type=Application
# Categories=Development;IDE;
# StartupNotify=true
# MimeType=text/plain;
# " >> /usr/share/applications/vscode.desktop

# Installing VS Code
yay -S --noconfirm visual-studio-code-bin  # From AUR (more reliable)

sudo chmod +x /usr/share/applications/vscode.desktop
sudo update-desktop-database ~/.local/share/applications/


# Install Virtualbox
sudo pacman -S virtualbox virtualbox-host-dkms linux-lts-headers
sudo modprobe vboxdrv     # Main VirtualBox module
sudo modprobe vboxnetadp   # Host network adapter
sudo modprobe vboxnetflt   # NAT network driver

echo -e "vboxdrv\nvboxnetadp\nvboxnetflt" | sudo tee /etc/modules-load.d/virtualbox.conf > /dev/null

sudo vboxreload
sudo modprobe vboxdrv && systemctl restart systemd-modules-load.service


sudo systemctl enable vboxservice --now