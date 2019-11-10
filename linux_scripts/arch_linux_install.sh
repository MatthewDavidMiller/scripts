#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for Arch Linux.

# Disks to partition. Script will erase this disk and repartition it.
disk='/dev/sda'
partition1="${disk}1"
partition2="${disk}2"

# Start dhcpcd
systemctl start "dhcpcd.service"

if false ping -c2 "google.com"
    then
        echo 'No internet'
        exit 1
fi

# Setup ntp client
timedatectl set-ntp true

read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    else
        exit 1
fi

# Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c 1:"EFI System Partition" -t 1:ef00 "${disk}"
sgdisk -n 0:0:0 -c 2:"Linux Filesystem" -t 0:8300 "${disk}"


# Use luks encryption on partition 2
read -r -p "Set the password for disk encryption: " response2
printf '%s\n' "${response2}" > '/tmp/disk_password'
cryptsetup -q luksFormat "${partition2}" < '/tmp/disk_password'

# Setup lvm on partition 2
cryptsetup open "${partition2}" cryptlvm < '/tmp/disk_password'
pvcreate '/dev/mapper/cryptlvm'
vgcreate lvm1 '/dev/mapper/cryptlvm'
lvcreate -L 8G lvm1 -n swap
lvcreate -L 32G lvm1 -n root
lvcreate -l 100%FREE lvm1 -n home

# Setup and mount filesystems
mkfs.ext4 '/dev/lvm1/root'
mkfs.ext4 '/dev/lvm1/home'
mkswap '/dev/lvm1/swap'
mount '/dev/lvm1/root' /mnt
mkdir '/mnt/home'
mount '/dev/lvm1/home' '/mnt/home'
swapon '/dev/lvm1/swap'
mkfs.fat -F32 "${partition1}"
mkdir '/mnt/boot'
mount "${partition1}" '/mnt/boot'

# Change mirrors to US based ones
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
awk '/^## US$/{f=1}f==0{next}/^$/{exit}{print substr($0, 2)}' /etc/pacman.d/mirrorlist

# Install base packages
pacstrap /mnt base base-devel linux linux-firmware systemd e2fsprogs ntfs-3g exfat-utils nano man-db man-pages texinfo

# Install recommended packages
pacstrap /mnt intel-ucode efibootmgr pacman-contrib sudo networkmanager ufw wget gnome

# Setup fstab
genfstab -U /mnt >> '/mnt/etc/fstab'

# Setup part 2 script
touch '/mnt/arch_linux_install_part_2.sh'
chmod +x '/mnt/arch_linux_install_part_2.sh'

# Get the uuids
uuid="$(blkid -o value -s UUID "${partition2}")"
uuid2="$(blkid -o value -s UUID /dev/lvm1/root)"

cat <<EOF > /mnt/arch_linux_install_part_2.sh
#!/bin/bash

# Set the timezone
ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'

# Set the clock
hwclock --systohc

# Setup locale config
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate locale
locale-gen

# Set language
wget -O '/tmp/locale.conf' 'https://gist.githubusercontent.com/MatthewDavidMiller/2fe5b5cef6cd98a24e852db7e6d850fc/raw/38b7099d12da17abecc9b4dda7e9e1878b636f39/locale.conf'
cp '/tmp/locale.conf' '/etc/locale.conf'

# Set hostname
wget -O '/tmp/hostname' 'https://gist.githubusercontent.com/MatthewDavidMiller/2fe5b5cef6cd98a24e852db7e6d850fc/raw/38b7099d12da17abecc9b4dda7e9e1878b636f39/hostname'
cp '/tmp/hostname' '/etc/hostname'

# Setup hosts file
wget -O '/tmp/hosts' 'https://gist.githubusercontent.com/MatthewDavidMiller/2fe5b5cef6cd98a24e852db7e6d850fc/raw/38b7099d12da17abecc9b4dda7e9e1878b636f39/hosts'
cp '/tmp/hosts' '/etc/hosts'

# Set password
echo 'Set root password'
passwd root

# Configure kernel for encryption and lvm
wget -O '/tmp/mkinitcpio.conf' 'https://gist.githubusercontent.com/MatthewDavidMiller/2fe5b5cef6cd98a24e852db7e6d850fc/raw/38b7099d12da17abecc9b4dda7e9e1878b636f39/mkinitcpio.conf'
cp '/tmp/mkinitcpio.conf' '/etc/mkinitcpio.conf'
mkinitcpio -P

# Setup systemd-boot with luks and lvm
wget -O '/tmp/arch_linux.conf' 'https://gist.githubusercontent.com/MatthewDavidMiller/2fe5b5cef6cd98a24e852db7e6d850fc/raw/38b7099d12da17abecc9b4dda7e9e1878b636f39/arch_linux.conf'
mkdir '/boot/loader'
mkdir '/boot/loader/entries'
cp '/tmp/arch_linux.conf' '/boot/loader/entries/arch_linux.conf'
sed -i "s#system_device-UUID#""$uuid""#" '/boot/loader/entries/arch_linux.conf'
sed -i "s#/dev/lvm1/root_uuid#""${uuid2}""#" '/boot/loader/entries/arch_linux.conf'

# Setup systemd-boot
bootctl --path=/boot install

# Add a user
useradd -m matthew
echo 'Set the password for a new user'
passwd matthew

# Setup sudo
echo 'matthew ALL=(ALL) NOPASSWD:ALL' >> '/etc/sudoers'

# Setup network manager
systemctl enable NetworkManager.service

# Enable bluetooth
systemctl enable bluetooth.service

# Enable ufw
systemctl enable ufw.service

# Enable gdm
systemctl enable gdm.service

# Exit chroot
exit
EOF

# Move to installation
arch-chroot /mnt "./arch_linux_install_part_2.sh"