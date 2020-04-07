#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for Arch Linux.

# Lists partitions
lsblk -f

# Prompts and variables
# Setup wifi
read -r -p "Connect to a wireless network? [y/N] " wifi_response
if [[ "${wifi_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    systemctl start "iwd.service"
    iw dev
    read -r -p "Specify wireless interface name: " wifi_interface
    iwctl station "${wifi_interface}" scan
    read -r -p "Specify SSID name: " ssid
fi
# Specify if windows is installed
read -r -p "Is windows installed? [y/N] " windows_response
# Specify disk and partition numbers to use for install
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
read -r -p "Specify partition number for /boot. If using windows select the partiton where the EFI folder is located. Example '1': " partition_number1
read -r -p "Specify partition number for lvm. Example '2': " partition_number2
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
# Specify whether to delete all partitions
read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response1
# Specify if cpu is intel
read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify disk encryption password
read -r -p "Set the password for disk encryption: " disk_password
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name

# Setup wifi
if [[ "${wifi_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    iwctl station "${wifi_interface}" connect "${ssid}"
fi

# Start dhcpcd
systemctl start "dhcpcd.service"

if false ping -c2 "google.com"; then
    echo 'No internet'
    exit 1
fi

# Setup ntp client
timedatectl set-ntp true

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
    ucode='intel-ucode'
else
    ucode='amd-ucode'
fi

# Configure Windows duel boot
if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Creates one partition.  Partition uses the rest of the free space avalailable to create a Linux filesystem partition.
    sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
else
    # Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
    sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
    sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
fi

# Use luks encryption on partition 2
printf '%s\n' "${disk_password}" >'/tmp/disk_password'
cryptsetup -q luksFormat "${partition2}" <'/tmp/disk_password'

# Setup lvm on partition 2
cryptsetup open "${partition2}" cryptlvm <'/tmp/disk_password'
pvcreate '/dev/mapper/cryptlvm'
vgcreate Archlvm '/dev/mapper/cryptlvm'
lvcreate -L 2G Archlvm -n swap
lvcreate -L 32G Archlvm -n root
lvcreate -l 100%FREE Archlvm -n home
rm -f '/tmp/disk_password'

# Configure Windows duel boot
if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Setup and mount filesystems
    mkfs.ext4 '/dev/Archlvm/root'
    mkfs.ext4 '/dev/Archlvm/home'
    mkswap '/dev/Archlvm/swap'
    mount '/dev/Archlvm/root' /mnt
    mkdir '/mnt/home'
    mount '/dev/Archlvm/home' '/mnt/home'
    swapon '/dev/Archlvm/swap'
    mkdir '/mnt/boot'
    mount "${partition1}" '/mnt/boot'
else
    # Setup and mount filesystems
    mkfs.ext4 '/dev/Archlvm/root'
    mkfs.ext4 '/dev/Archlvm/home'
    mkswap '/dev/Archlvm/swap'
    mount '/dev/Archlvm/root' /mnt
    mkdir '/mnt/home'
    mount '/dev/Archlvm/home' '/mnt/home'
    swapon '/dev/Archlvm/swap'
    mkfs.fat -F32 "${partition1}"
    mkdir '/mnt/boot'
    mount "${partition1}" '/mnt/boot'
fi

# Configure mirrors
rm -f '/etc/pacman.d/mirrorlist'
cat <<\EOF >'/etc/pacman.d/mirrorlist'
Server = https://archlinux.surlyjake.com/archlinux/$repo/os/$arch
Server = https://mirror.arizona.edu/archlinux/$repo/os/$arch
Server = https://arch.mirror.constant.com/$repo/os/$arch
Server = https://mirror.dc02.hackingand.coffee/arch/$repo/os/$arch
Server = https://repo.ialab.dsu.edu/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirror.dal10.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.mia11.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.sfo12.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.wdc1.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.lty.me/archlinux/$repo/os/$arch
Server = https://reflector.luehm.com/arch/$repo/os/$arch
Server = https://mirrors.lug.mtu.edu/archlinux/$repo/os/$arch
Server = https://mirror.kaminski.io/archlinux/$repo/os/$arch
Server = https://iad.mirrors.misaka.one/archlinux/$repo/os/$arch
Server = https://mirrors.ocf.berkeley.edu/archlinux/$repo/os/$arch
Server = https://dfw.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://iad.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://ord.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
Server = https://mirrors.rutgers.edu/archlinux/$repo/os/$arch
Server = https://mirrors.sonic.net/archlinux/$repo/os/$arch
Server = https://arch.mirror.square-r00t.net/$repo/os/$arch
Server = https://mirror.stephen304.com/archlinux/$repo/os/$arch
Server = https://mirror.pit.teraswitch.com/archlinux/$repo/os/$arch
Server = https://mirrors.xtom.com/archlinux/$repo/os/$arch

EOF

# Install base packages
pacstrap /mnt --noconfirm base base-devel linux linux-lts linux-firmware systemd e2fsprogs ntfs-3g exfat-utils vi man-db man-pages texinfo lvm2 xf86-video-intel xf86-video-amdgpu xf86-video-nouveau bash bash-completion ntp util-linux

# Install recommended packages
pacstrap /mnt --noconfirm ${ucode} efibootmgr pacman-contrib sudo networkmanager nm-connection-editor networkmanager-openvpn ufw wget gdm xorg xorg-xinit xorg-drivers xorg-server xorg-apps bluez bluez-utils blueman pulseaudio pulseaudio-bluetooth pavucontrol libinput xf86-input-libinput i3-wm i3-bar i3-status dmenu firefox gnome-keyring seahorse termite htop dolphin cron kdenetwork-filesharing

# Setup fstab
genfstab -U /mnt >>'/mnt/etc/fstab'

# Setup part 2 script
touch '/mnt/arch_linux_install_part_2.sh'
chmod +x '/mnt/arch_linux_install_part_2.sh'

# Get the uuids
uuid="$(blkid -o value -s UUID "${partition2}")"
uuid2="$(blkid -o value -s UUID /dev/Archlvm/root)"

cat <<EOF >/mnt/arch_linux_install_part_2.sh
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
rm -f '/etc/locale.conf'
{
printf '%s\n' '# language config'
printf '%s\n' '# file location is /etc/locale.conf'
printf '%s\n' ''
printf '%s\n' 'LANG=en_US.UTF-8'
printf '%s\n' ''
} >> '/etc/locale.conf'

# Set hostname
rm -f '/etc/hostname'
{
printf '%s\n' '# hostname file'
printf '%s\n' '# File location is /etc/hostname'
printf '%s\n' "${device_hostname}"
printf '%s\n' ''
} >> '/etc/hostname'

# Setup hosts file
rm -f '/etc/hosts'
{
printf '%s\n' '# host file'
printf '%s\n' '# file location is /etc/hosts'
printf '%s\n' ''
printf '%s\n' '127.0.0.1 localhost'
printf '%s\n' '::1 localhost'
printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
printf '%s\n' ''
} >> '/etc/hosts'

# Set password
echo 'Set root password'
passwd root

# Configure kernel for encryption and lvm
rm -f '/etc/mkinitcpio.conf'
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
printf '%s\n' 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)'
printf '%s\n' ''
} >> '/etc/mkinitcpio.conf'
mkinitcpio -P

# Setup systemd-boot with luks and lvm
mkdir '/boot/loader'
mkdir '/boot/loader/entries'

{
printf '%s\n' '# kernel entry for systemd-boot'
printf '%s\n' '# file location is /boot/loader/entries/arch_linux_lts.conf'
printf '%s\n' ''
printf '%s\n' 'title   Arch Linux LTS Kernel'
printf '%s\n' 'linux   /vmlinuz-linux-lts'
printf '%s\n' "initrd  /${ucode}.img"
printf '%s\n' 'initrd  /initramfs-linux-lts.img'
printf '%s\n' "options cryptdevice=UUID=${uuid}:cryptlvm root=UUID=${uuid2} rw"
printf '%s\n' ''
} >> '/boot/loader/entries/arch_linux_lts.conf'

{
printf '%s\n' '# kernel entry for systemd-boot'
printf '%s\n' '# file location is /boot/loader/entries/arch_linux.conf'
printf '%s\n' ''
printf '%s\n' 'title   Arch Linux Default Kernel'
printf '%s\n' 'linux   /vmlinuz-linux'
printf '%s\n' "initrd  /${ucode}.img"
printf '%s\n' 'initrd  /initramfs-linux.img'
printf '%s\n' "options cryptdevice=UUID=${uuid}:cryptlvm root=UUID=${uuid2} rw"
printf '%s\n' ''
} >> '/boot/loader/entries/arch_linux.conf'

{
printf '%s\n' '# config for systemd-boot'
printf '%s\n' '# file location is /boot/loader/loader.conf'
printf '%s\n' ''
printf '%s\n' 'default  arch_linux_lts'
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

# Setup network manager
systemctl enable NetworkManager.service

# Exit chroot
exit

EOF

# Move to installation
arch-chroot /mnt "./arch_linux_install_part_2.sh"
