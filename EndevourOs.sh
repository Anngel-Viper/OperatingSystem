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
mkdir -p ~/.config/fish
echo "starship init fish | source " >> ~/.config/fish/config.fish

# Making Adjustment for other users as well
for i in "${my_array[@]}"; do
    user_home=$(eval echo ~$i)  # Get the user's home directory
    mkdir -p "$user_home/.config/fish"
    echo "starship init fish | source" >> "$user_home/.config/fish/config.fish"
    chown -R $i:$i "$user_home/.config/fish"  # Ensure correct ownership
done

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

# Install Virtualbox
pacman -S virtualbox virtualbox-host-dkms linux-lts-headers
modprobe vboxdrv     # Main VirtualBox module
modprobe vboxnetadp   # Host network adapter
modprobe vboxnetflt   # NAT network driver

echo "vboxdrv" | tee -a /etc/modules-load.d/virtualbox.conf
echo "vboxnetadp" | tee -a /etc/modules-load.d/virtualbox.conf
echo "vboxnetflt" | tee -a /etc/modules-load.d/virtualbox.conf

for i in "${my_array[@]}"; do
    usermod -aG vboxusers $i
done
vboxreload
modprobe vboxdrv && systemctl restart systemd-modules-load.service


systemctl enable vboxservice --now

# Ask user if they want to reboot
read -p "Reboot now to apply changes? (y/n): " choice
case "$choice" in 
  y|Y ) echo "Rebooting..."; sudo reboot;;
  n|N ) echo "Reboot skipped. Please restart manually to apply changes.";;
  * ) echo "Invalid choice. Reboot skipped.";;
esac

echo "Installation complete!"