#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for a vpn server. Use with Debian live installer. Run the script when in the live installer.

# Lists partitions
lsblk -f

# Prompts and variables
# Specify disk and partition numbers to use for install
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
read -r -p "Specify partition number for /boot. Example '1': " partition_number1
read -r -p "Specify partition number for lvm. Example '2': " partition_number2
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
# Specify whether to delete all partitions
read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response1
# Specify whether to continue install
read -r -p "Do you want to continue the install? [y/N] " response3
# Specify if cpu is intel
read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify disk encryption password
read -r -p "Set the password for disk encryption: " disk_password
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name

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

# Continue install
if [[ "${response3}" =~ ^([nN][oO]|[nN])+$ ]]
then
    exit 1
fi

# Get cpu type
if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    ucode='intel-microcode'
else
    ucode='amd64-microcode'
fi


# Creates two partitions.  First one is a 512 MB EFI partition while the second is a 10 GB Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
sgdisk -n 0:0:+12GiB -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"

# Setup lvm on partition 2
pvcreate '/dev/mapper/cryptlvm'
vgcreate VPNLvm '/dev/mapper/cryptlvm'
lvcreate -L 2G VPNLvm -n swap
lvcreate -L 5G VPNLvm -n root
lvcreate -l 100%FREE VPNLvm -n home

# Setup and mount filesystems
mkfs.ext4 '/dev/VPNLvm/root'
mkfs.ext4 '/dev/VPNLvm/home'
mkswap '/dev/VPNLvm/swap'
mount '/dev/VPNLvm/root' /mnt
mkdir '/mnt/home'
mount '/dev/VPNLvm/home' '/mnt/home'
swapon '/dev/VPNLvm/swap'
mkfs.fat -F32 "${partition1}"
mkdir '/mnt/boot'
mount "${partition1}" '/mnt/boot'

# Setup debootstrap
apt-get update
apt-get install debootstrap

# Install base packages
debootstrap --arch amd64 --components=main,contrib,non-free stable systemd linux-image-4.19.0-6-amd64 ${ucode} /mnt 'http://ftp.us.debian.org/debian'

# Install recommended packages
debootstrap --arch amd64 wget vi git ufw /mnt 'http://ftp.us.debian.org/debian'

# Setup fstab
genfstab -U /mnt >> '/mnt/etc/fstab'

# Setup part 2 script
touch '/mnt/vpn_server_install_part_2.sh'
chmod +x '/mnt/vpn_server_install_part_2.sh'

# Get the uuids
uuid="$(blkid -o value -s UUID /dev/VPNLvm/root)"

cat <<EOF > /mnt/vpn_server_install_part_2.sh
#!/bin/bash

# Set the timezone
ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'

# Set the clock
hwclock --systohc

# Setup ntp client
systemctl enable ntpd.service

# Setup locale config
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate locale
locale-gen

# Set language to English
rm '/etc/locale.conf'
{
printf '%s\n' '# language config'
printf '%s\n' '# file location is /etc/locale.conf'
printf '%s\n' ''
printf '%s\n' 'LANG=en_US.UTF-8'
printf '%s\n' ''
} >> '/etc/locale.conf'

# Set hostname
rm '/etc/hostname'
{
printf '%s\n' '# hostname file'
printf '%s\n' '# File location is /etc/hostname'
printf '%s\n' "${device_hostname}"
printf '%s\n' ''
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
printf '%s\n' ''
} >> '/etc/hosts'

# Setup mirrors and sources
deb-src 'http://ftp.us.debian.org/debian' stable main
deb 'http://security.debian.org/' stable/updates main
deb-src 'http://security.debian.org/' stable/updates main

# Set password
echo 'Set root password'
passwd root

# Configure kernel for lvm
rm '/etc/mkinitcpio.conf'
{
printf '%s\n' '# config for kernel'
printf '%s\n' '# file location is /etc/mkinitcpio.conf'
printf '%s\n' ''
printf '%s\n' 'MODULES=()'
printf '%s\n' ''
printf '%s\n' 'BINARIES=()'
printf '%s\n' ''
printf '%s\n' 'FILES=()'
printf '%s\n' ''
printf '%s\n' 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block lvm2 filesystems fsck)'
printf '%s\n' ''
} >> '/etc/mkinitcpio.conf'
mkinitcpio -P

# Setup systemd-boot with lvm
mkdir '/boot/loader'
mkdir '/boot/loader/entries'

{
printf '%s\n' '# kernel entry for systemd-boot'
printf '%s\n' '# file location is /boot/loader/entries/vpn_server.conf'
printf '%s\n' ''
printf '%s\n' 'title   VPN Server Kernel'
printf '%s\n' 'linux   /vmlinuz-linux-image-4.19.0-6-amd64'
printf '%s\n' "initrd  /${ucode}.img"
printf '%s\n' 'initrd  /initramfs-linux-image-4.19.0-6-amd64.img'
printf '%s\n' "options root=UUID=${uuid} rw"
printf '%s\n' ''
} >> '/boot/loader/entries/vpn_server.conf'

{
printf '%s\n' '# config for systemd-boot'
printf '%s\n' '# file location is /boot/loader/loader.conf'
printf '%s\n' ''
printf '%s\n' 'default  vpn_server'
printf '%s\n' 'auto-entries 1'
printf '%s\n' ''
} >> '/boot/loader/loader.conf'

# Setup systemd-boot
bootctl --path=/boot install

# Add a user
useradd -m "${user_name}"
echo "Set the password for ${user_name}"
passwd "${user_name}"

# Setup sudo
printf '%s\n' "${user_name} ALL=(ALL) ALL" >> '/etc/sudoers'

# Enable ufw
systemctl enable ufw.service
ufw enable

# Exit chroot
exit

EOF

# Move to installation
chroot /mnt "./vpn_server_install_part_2.sh"
