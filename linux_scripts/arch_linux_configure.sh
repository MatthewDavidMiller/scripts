#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Configuration script for Arch Linux.  Run after installing. Do not run as root.

# Enable bluetooth
sudo systemctl enable bluetooth.service

# Enable ufw
sudo systemctl enable ufw.service
sudo ufw enable

# Enable gdm
sudo systemctl enable gdm.service

# Configure Xorg
Xorg :0 -configure

# Setup touchpad
sudo rm -f '/etc/X11/xorg.conf.d/20-touchpad.conf'
sudo bash -c "cat <<\EOF > '/etc/X11/xorg.conf.d/20-touchpad.conf'

Section \"InputClass\"
 Identifier \"libinput touchpad catchall\"
 Driver \"libinput\"
 MatchIsTouchpad \"on\"
 MatchDevicePath \"/dev/input/event*\"
 Option \"Tapping\" \"on\"
 Option \"NaturalScrolling\" \"false\"
EndSection

EOF"

# Prompts
read -r -p "Run arch_linux_packages script? [y/N] " arch_linux_packages
read -r -p "Run configure_i3 script? [y/N] " configure_i3
read -r -p "Run connect_smb script? [y/N] " connect_smb
read -r -p "Set a timer to select OS or kernel? [y/N] " ostimer

# Run arch_linux_packages script
if [[ "${arch_linux_packages}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/arch_linux_packages.sh'
    chmod +x arch_linux_packages.sh
    bash arch_linux_packages.sh
fi

# Run configure_i3 script
if [[ "${configure_i3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/configure_i3.sh'
    chmod +x configure_i3.sh
    bash configure_i3.sh
fi

# Run connect_smb script
if [[ "${connect_smb}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/connect_smb.sh'
    chmod +x connect_smb.sh
    bash connect_smb.sh
fi

# Set a timer to select OS or kernel
if [[ "${ostimer}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    {
        printf '%s\n' 'timeout 60'
        printf '%s\n' ''
    } >> '/boot/loader/loader.conf'
fi
