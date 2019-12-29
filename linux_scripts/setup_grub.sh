#!/bin/bash

# Script to setup grub

read -r -p "What package manager are you using? yum [1], apt [2], pacman [3] Select a number: " response1

# Install packages

if [[ "${response1}" =~ ^([1])+$ ]]
then
    sudo yum install epel-release ntfs-3g
fi

if [[ "${response1}" =~ ^([2])+$ ]]
then
    sudo apt-get install ntfs-3g
fi

if [[ "${response1}" =~ ^([3])+$ ]]
then
    sudo pacman -S --noconfirm --needed ntfs-3g
fi

# Mount partition
wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/mount_drives.sh'
bash 'mount_drives.sh'

# Detect OS
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo cp /boot/grub/grub.cfg /etc/grub.d/40_custom
