#!/bin/bash

set -e

# Variables
disk="/dev/sda"
hostname="anngel"
username="anngel"
password="anngel"  # Change this after installation

# Partitioning
parted -s "$disk" mklabel gpt
parted -s "$disk" mkpart ESP fat32 1MiB 512MiB
parted -s "$disk" set 1 esp on
parted -s "$disk" mkpart primary ext4 512MiB 100%

# Formatting and mounting
mkfs.fat -F32 "${disk}1"
mkfs.ext4 "${disk}2"
mount "${disk}2" /mnt
mkdir -p /mnt/boot/efi
mount "${disk}1" /mnt/boot/efi

# Install base system
pacstrap /mnt base linux linux-firmware neovim git

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure
arch-chroot /mnt /bin/bash <<EOF

# Timezone and localization
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$hostname" > /etc/hostname

# Hosts file
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
EOT

# Install essential packages
pacman -Sy --noconfirm grub efibootmgr networkmanager sudo

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager

# Create user
useradd -m -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

EOF

# Ensure all file system changes are written
sync

# Unmount all partitions
umount -l /mnt/boot/efi
umount -l /mnt

# Reboot
echo "Installation complete. Rebooting..."
sleep 2
reboot
