#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root.
# Install script for a debian server. Use with Debian standard live installer. Run the script when in the live installer.

# Lists partitions
lsblk -f

# Prompts and variables
# Specify disk and partition numbers to use for install
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
read -r -p "Specify partition number for /boot. Example '1': " partition_number1
read -r -p "Specify partition number for swap. Example '2': " partition_number2
read -r -p "Specify partition number for root /. Example '3': " partition_number3
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
partition3="${disk}${partition_number3}"
# Specify whether to delete all partitions
read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response1
# Specify if cpu is intel
read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name

# Install needed packages
apt-get update
apt-get install -y gdisk binutils debootstrap dosfstools

# Delete all parititions on ${disk}
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response2
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    fi
fi

# Get cpu type
if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    ucode='intel-microcode'
else
    ucode='amd64-microcode'
fi

# Creates three partitions.  First one is a 512 MB EFI partition, second is a 2GB Linux filesystem partition partition, and third is a 10 GB Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
sgdisk -n 0:0:+2GiB -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
sgdisk -n 0:0:+10GiB -c "${partition_number3}":"Linux Filesystem" -t "${partition_number3}":8300 "${disk}"

# Setup and mount filesystems
mkfs.ext4 "${partition3}"
mount "${partition3}" /mnt
mkswap "${partition2}"
mkfs.fat -F32 "${partition1}"

# Install base packages
debootstrap --arch amd64 --components=main,contrib,non-free oldstable /mnt 'http://ftp.us.debian.org/debian'

# Mount proc and sysfs
{
    printf '%s\n' 'proc /mnt/proc proc defaults 0 0'
    printf '%s\n' 'sysfs /mnt/sys sysfs defaults 0 0'
} >> '/etc/fstab'
mount proc /mnt/proc -t proc
mount sysfs /mnt/sys -t sysfs

# Get the uuids
uuid="$(blkid -o value -s UUID "${partition1}")"
uuid2="$(blkid -o value -s UUID "${partition2}")"
uuid3="$(blkid -o value -s UUID "${partition3}")"

# Setup part 2 script
touch '/mnt/vpn_server_install_part_2.sh'
chmod +x '/mnt/vpn_server_install_part_2.sh'

cat <<EOF > /mnt/vpn_server_install_part_2.sh
#!/bin/bash

# Create device files
apt-get install -y makedev
cd /dev
MAKEDEV generic
cd /

# Setup fstab
{
    printf '%s\n' "UUID=${uuid} /boot vfat defaults 0 0"
    printf '%s\n' "UUID=${uuid2} none swap sw 0 0"
    printf '%s\n' "UUID=${uuid3} / ext4 defaults 0 0"
} >> '/etc/fstab'

# Make directories
mkdir '/boot'
mkdir '/boot/EFI'
mkdir '/boot/EFI/debian'

# Mount drives
mount -a

# Set the timezone
ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'

# Setup locales
dpkg-reconfigure locales

# Set language to English
rm '/etc/locale.conf'
{
    printf '%s\n' '# language config'
    printf '%s\n' '# file location is /etc/locale.conf'
    printf '%s\n' ''
    printf '%s\n' 'LANG=en_US.UTF-8'
} >> '/etc/locale.conf'

# Set hostname
rm '/etc/hostname'
{
    printf '%s\n' '# hostname file'
    printf '%s\n' '# File location is /etc/hostname'
    printf '%s\n' "${device_hostname}"
} >> '/etc/hostname'

# Setup hosts file
rm '/etc/hosts'
{
    printf '%s\n' '# host file'
    printf '%s\n' '# file location is /etc/hosts'
    printf '%s\n' ''
    printf '%s\n' '127.0.0.1 localhost'
    printf '%s\n' '::1 localhost'
    printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
} >> '/etc/hosts'

# Setup mirrors and sources
{
    printf '%s\n' 'deb http://mirrors.advancedhosters.com/debian/ oldstable main'
    printf '%s\n' 'deb-src http://mirrors.advancedhosters.com/debian/ oldstable main'
    printf '%s\n' 'deb http://mirrors.advancedhosters.com/debian/ oldstable-updates main'
    printf '%s\n' 'deb-src http://mirrors.advancedhosters.com/debian/ oldstable-updates main'
    printf '%s\n' 'deb-src http://ftp.us.debian.org/debian oldstable main'
    printf '%s\n' 'deb http://security.debian.org/ oldstable/updates main'
    printf '%s\n' 'deb-src http://security.debian.org/ oldstable/updates main'
} >> '/etc/apt/sources.list'

# Install standard packages
tasksel install standard
apt-get install -y systemd linux-image-amd64 ${ucode} efibootmgr grub-efi initramfs-tools

# Update kernel
update-initramfs -u

# Clean download cache
apt-get clean

# Set password
echo 'Set root password'
passwd root

# Setup grub
rm '/etc/default/grub'
{
    printf '%s\n' 'GRUB_DEFAULT=0'
    printf '%s\n' 'GRUB_TIMEOUT=0'
    printf '%s\n' 'GRUB_DISTRIBUTOR=$(lsb_release -i -s 2> /dev/null || echo Debian)'
    printf '%s\n' 'GRUB_CMDLINE_LINUX_DEFAULT="quiet"'
    printf '%s\n' "GRUB_CMDLINE_LINUX=\"\""
} > '/etc/default/grub'
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=debian
update-grub

# Add a user
useradd -m "${user_name}"
echo "Set the password for ${user_name}"
passwd "${user_name}"

# Setup sudo
printf '%s\n' "${user_name} ALL=(ALL) ALL" >> '/etc/sudoers'

# Exit chroot
exit

EOF

# Move to installation
LANG=C.UTF-8 chroot /mnt "./vpn_server_install_part_2.sh"
