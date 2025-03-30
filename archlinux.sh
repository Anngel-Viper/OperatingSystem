#!/bin/bash
set -e

# Configuration
HOSTNAME="anngel"
USERNAME="anngel"
PASSWORD="anngel"
DISK="/dev/sda"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"

# Verify root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

# Partitioning
echo "Partitioning disk..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart "EFI" fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart "root" ext4 513MiB 100%

# Formatting
echo "Formatting partitions..."
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"

# Mounting
echo "Mounting filesystems..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

# Base system installation
echo "Installing base system..."
pacman -Sy --noconfirm archlinux-keyring
pacstrap /mnt base linux linux-firmware \
    grub efibootmgr sudo networkmanager \
    virtualbox-guest-utils nano

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot setup
arch-chroot /mnt /bin/bash <<EOF
set -e

# Time configuration
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Localization
echo "LANG=$LOCALE" > /etc/locale.conf
sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen

# Network configuration
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

# User setup
echo "Setting up user..."
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

# Sudo configuration
echo "Configuring sudo..."
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Bootloader
echo "Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Hyprland installation
echo "Installing Hyprland..."
pacman -S --noconfirm hyprland seatd xorg-xwayland waybar grim slurp wofi

# Services
systemctl enable NetworkManager
systemctl enable vboxservice

# Cleanup
pacman -Scc --noconfirm
EOF

# Finalization
echo "Unmounting..."
umount -R /mnt
echo "Installation complete! Rebooting..."
reboot
