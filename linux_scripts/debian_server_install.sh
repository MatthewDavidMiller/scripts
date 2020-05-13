#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root.
# Install script for a debian server. Use with Debian standard live installer. Run the script when in the live installer.

# Lists partitions
lsblk -f

# Prompts and variables
# Specify disk and partition numbers to use for install
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
read -r -p "Specify partition number for /boot/EFI. Example '1': " partition_number1
read -r -p "Specify partition number for root /. Example '2': " partition_number2
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
# Specify whether to delete all partitions
read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response1
# Specify if cpu is intel
read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name
# Specify version
read -r -p "Use stretch [1] or buster [2]? [1/2]: " specify_version

# Specify version
if [[ "${specify_version}" =~ ^([1])+$ ]]; then
    version='stretch'
fi

# Specify version
if [[ "${specify_version}" =~ ^([2])+$ ]]; then
    version='buster'
fi

# Install needed packages
apt-get update
apt-get install -y gdisk binutils debootstrap dosfstools

# Delete all parititions on ${disk}
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response2
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    fi
fi

# Get cpu type
if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    ucode='intel-microcode'
else
    ucode='amd64-microcode'
fi

# Creates two partitions.  First one is a 512 MB EFI partition, and second is a 14 GB Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
sgdisk -n 0:0:+14GiB -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"

# Setup and mount filesystems
mkfs.ext4 "${partition2}"
mount "${partition2}" /mnt
mkfs.fat -F32 "${partition1}"

# Install base packages
debootstrap --arch amd64 --components=main,contrib,non-free ${version} /mnt 'http://ftp.us.debian.org/debian'

# Mount proc and sysfs
{
    printf '%s\n' 'proc /mnt/proc proc defaults 0 0'
    printf '%s\n' 'sysfs /mnt/sys sysfs defaults 0 0'
} >>'/etc/fstab'
mount proc /mnt/proc -t proc
mount sysfs /mnt/sys -t sysfs

# Get the uuids
uuid="$(blkid -o value -s UUID "${partition1}")"
uuid2="$(blkid -o value -s UUID "${partition2}")"

# Get the interface name
interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
echo "Interface name is ${interface}"

# Setup part 2 script
touch '/mnt/debian_server_install.sh'
chmod +x '/mnt/debian_server_install.sh'

cat <<EOF >/mnt/debian_server_install.sh
#!/bin/bash

# Create device files
apt-get install -y makedev
cd /dev
MAKEDEV generic
cd /

# Setup fstab
{
    printf '%s\n' "UUID=${uuid} /boot/EFI vfat defaults 0 0"
    printf '%s\n' '/swapfile none swap defaults 0 0'
    printf '%s\n' "UUID=${uuid2} / ext4 defaults 0 0"
} >> '/etc/fstab'

# Configure swap
# Create swapfile
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
# Set file permissions
chmod 600 /swapfile
# Format file to swap
mkswap /swapfile
# Activate the swap file
swapon /swapfile

# Make directories
mkdir '/boot'
mkdir '/boot/EFI'
mkdir '/boot/EFI/debian'

# Mount drives
mount -a

# Set the timezone
ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'

# Install locale package
apt-get install -y locales

# Setup locales
dpkg-reconfigure locales

# Set language to English
rm -f '/etc/locale.conf'
{
    printf '%s\n' 'LANG=en_US.UTF-8'
} >> '/etc/locale.conf'

# Set hostname
rm -f '/etc/hostname'
{
    printf '%s\n' "${device_hostname}"
} >> '/etc/hostname'

# Setup hosts file
rm -f '/etc/hosts'
{
    printf '%s\n' '127.0.0.1 localhost'
    printf '%s\n' '::1 localhost'
    printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
} >> '/etc/hosts'

# Setup mirrors and sources
{
    printf '%s\n' 'deb https://mirrors.wikimedia.org/debian/ ${version} main contrib non-free'
    printf '%s\n' 'deb-src https://mirrors.wikimedia.org/debian/ ${version} main contrib non-free'
    printf '%s\n' 'deb https://mirrors.wikimedia.org/debian/ ${version}-updates main contrib non-free'
    printf '%s\n' 'deb-src https://mirrors.wikimedia.org/debian/ ${version}-updates main contrib non-free'
    printf '%s\n' 'deb http://security.debian.org/debian-security/ ${version}/updates main contrib non-free'
    printf '%s\n' 'deb-src http://security.debian.org/debian-security/ ${version}/updates main contrib non-free'
} >> '/etc/apt/sources.list'

# Install standard packages
tasksel install standard
apt-get install -y systemd linux-image-amd64 ${ucode} efibootmgr grub-efi initramfs-tools sudo apt-transport-https

# Update kernel
update-initramfs -u

# Clean download cache
apt-get clean

# Set password
echo 'Set root password'
passwd root

# Enable network connectivity
{
    printf '%s\n' 'auto lo'
    printf '%s\n' 'iface lo inet loopback'
    printf '%s\n' "auto ${interface}"
    printf '%s\n' "iface ${interface} inet dhcp"
} >> '/etc/network/interfaces'

# Setup grub
rm -f '/etc/default/grub'
{
    printf '%s\n' 'GRUB_DEFAULT=0'
    printf '%s\n' 'GRUB_TIMEOUT=0'
    printf '%s\n' 'GRUB_DISTRIBUTOR=$(lsb_release -i -s 2>/dev/null || echo Debian)'
    printf '%s\n' 'GRUB_CMDLINE_LINUX_DEFAULT="quiet"'
    printf '%s\n' "GRUB_CMDLINE_LINUX=\"\""
} > '/etc/default/grub'
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=debian
update-grub

# Add a user
useradd -m "${user_name}"
echo "Set the password for ${user_name}"
passwd "${user_name}"

# Setup sudo
printf '%s\n' "${user_name} ALL=(ALL) ALL" >> '/etc/sudoers'

# Set shell
chsh -s /bin/bash
chsh -s /bin/bash "${user_name}"

# Exit chroot
exit

EOF

# Move to installation
LANG=C.UTF-8 chroot /mnt "./debian_server_install.sh"
