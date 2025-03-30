#!/bin/bash
set -e

# Configuration
HOSTNAME="anngel"
USERNAME="anngel"
PASSWORD="anngel"
DISK="/dev/sda"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"

# Check UEFI/BIOS
if [ -d /sys/firmware/efi/efivars ]; then
    FIRMWARE="UEFI"
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
else
    FIRMWARE="BIOS"
    ROOT_PART="${DISK}1"
fi

# Verify root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

# Partitioning
echo "Partitioning disk ($FIRMWARE)..."
parted -s "$DISK" mklabel $([ "$FIRMWARE" = "UEFI" ] && echo "gpt" || echo "msdos")

if [ "$FIRMWARE" = "UEFI" ]; then
    parted -s "$DISK" mkpart "EFI" fat32 1MiB 513MiB
    parted -s "$DISK" set 1 esp on
    parted -s "$DISK" mkpart "root" ext4 513MiB 100%
else
    parted -s "$DISK" mkpart primary ext4 1MiB 100%
    parted -s "$DISK" set 1 boot on
fi

# Formatting
echo "Formatting partitions..."
if [ "$FIRMWARE" = "UEFI" ]; then
    mkfs.fat -F32 "$BOOT_PART"
fi
mkfs.ext4 -F "$ROOT_PART"

# Mounting
echo "Mounting filesystems..."
mount "$ROOT_PART" /mnt
if [ "$FIRMWARE" = "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
fi

# Base system installation
echo "Installing base system..."
pacman -Sy --noconfirm archlinux-keyring
BASE_PKGS="base linux linux-firmware sudo networkmanager nano virtualbox-guest-utils"
if [ "$FIRMWARE" = "UEFI" ]; then
    BASE_PKGS="$BASE_PKGS grub efibootmgr dosfstools"
else
    BASE_PKGS="$BASE_PKGS grub"
fi

pacstrap /mnt $BASE_PKGS

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
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Bootloader installation
echo "Installing GRUB for $FIRMWARE..."
if [ "$FIRMWARE" = "UEFI" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    grub-install --target=i386-pc "$DISK"
fi
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
