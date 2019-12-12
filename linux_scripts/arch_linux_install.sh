#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for Arch Linux.

# Start dhcpcd
systemctl start "dhcpcd.service"

if false ping -c2 "google.com"
    then
        echo 'No internet'
        exit 1
fi

# Setup ntp client
timedatectl set-ntp true

# Lists partitions
sfdisk -l
df | grep '^/dev'

# Specify disk and partitions
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk

read -r -p "Specify partition number for /boot. Example '1': " response1

read -r -p "Specify partition number for lvm. Example '2': " response2

partition1="${disk}${response1}"
partition2="${disk}${response2}"

read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response3
if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response3
        if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
            then
                # Deletes all partitions on disk
                sgdisk -Z "${disk}"
                sgdisk -og "${disk}"
        fi
fi

read -r -p "Do you want to continue the install? [y/N] " response4
if [[ "${response4}" =~ ^([nN][oO]|[nN])+$ ]]
    then
        exit 1
fi

read -r -p "Is the cpu intel? [y/N] " ucode_response
if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        ucode='intel-ucode'
    else
        ucode='amd-ucode'
fi

# Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c "${response1}":"EFI System Partition" -t "${response1}":ef00 "${disk}"
sgdisk -n 0:0:0 -c "${response2}":"Linux Filesystem" -t "${response2}":8300 "${disk}"

# Use luks encryption on partition 2
read -r -p "Set the password for disk encryption: " response5
printf '%s\n' "${response5}" > '/tmp/disk_password'
cryptsetup -q luksFormat "${partition2}" < '/tmp/disk_password'

# Setup lvm on partition 2
cryptsetup open "${partition2}" cryptlvm < '/tmp/disk_password'
pvcreate '/dev/mapper/cryptlvm'
vgcreate Archlvm '/dev/mapper/cryptlvm'
lvcreate -L 2G Archlvm -n swap
lvcreate -L 32G Archlvm -n root
lvcreate -l 100%FREE Archlvm -n home
rm '/tmp/disk_password'

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

# Change mirrors to US based ones
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
awk '/^## US$/{f=1}f==0{next}/^$/{exit}{print substr($0, 2)}' /etc/pacman.d/mirrorlist

# Install base packages
pacstrap /mnt base base-devel linux linux-lts linux-firmware systemd e2fsprogs ntfs-3g exfat-utils vi man-db man-pages texinfo lvm2 xf86-video-intel xf86-video-amdgpu xf86-video-nouveau

# Install recommended packages
pacstrap /mnt ${ucode} efibootmgr pacman-contrib sudo networkmanager nm-connection-editor networkmanager-openvpn ufw wget gdm xorg xorg-xinit xorg-drivers xorg-server xorg-apps bluez bluez-utils blueman pulseaudio pulseaudio-bluetooth pavucontrol libinput xf86-input-libinput i3-wm i3-bar i3-status dmenu firefox gnome-keyring seahorse termite htop dolphin cron kdenetwork-filesharing

# Setup fstab
genfstab -U /mnt >> '/mnt/etc/fstab'

# Setup part 2 script
touch '/mnt/arch_linux_install_part_2.sh'
chmod +x '/mnt/arch_linux_install_part_2.sh'

# Get the uuids
uuid="$(blkid -o value -s UUID "${partition2}")"
uuid2="$(blkid -o value -s UUID /dev/Archlvm/root)"

# Set hostname
read -r -p "Set the device hostname: " response6

# Add user
read -r -p "Specify a username for a new user: " response7

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
printf '%s\n' "${response6}"
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
printf '%s\n' "127.0.1.1 ${response6}.localdomain ${response6}"
printf '%s\n' ''
} >> '/etc/hosts'

# Set password
echo 'Set root password'
passwd root

# Configure kernel for encryption and lvm
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
printf '%s\n' ''
} >> '/boot/loader/loader.conf'

# Setup systemd-boot
bootctl --path=/boot install

# Setup touchpad
rm '/etc/X11/xorg.conf.d/20-touchpad.conf'
{
printf '%s\n' 'Section "InputClass"'
printf '%s\n' ' Identifier "libinput touchpad catchall"'
printf '%s\n' ' Driver "libinput"'
printf '%s\n' ' MatchIsTouchpad "on"'
printf '%s\n' ' MatchDevicePath "/dev/input/event*"'
printf '%s\n' ' Option "Tapping" "on"'
printf '%s\n' ' Option "NaturalScrolling" "false"'
printf '%s\n' 'EndSection'
printf '%s\n' ''
} >> '/etc/X11/xorg.conf.d/20-touchpad.conf'

# Add a user
useradd -m "${response7}"
echo "Set the password for ${response7}"
passwd "${response7}"

# Setup sudo
printf '%s\n' "${response7} ALL=(ALL) NOPASSWD:ALL" >> '/etc/sudoers'

# Setup network manager
systemctl enable NetworkManager.service

# Enable bluetooth
systemctl enable bluetooth.service

# Enable ufw
systemctl enable ufw.service

# Enable gdm
systemctl enable gdm.service

# Configure Xorg
Xorg :0 -configure

# Exit chroot
exit
EOF

# Move to installation
arch-chroot /mnt "./arch_linux_install_part_2.sh"
