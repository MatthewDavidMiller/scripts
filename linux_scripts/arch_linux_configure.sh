#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Configuration script for Arch Linux.  Run after installing. Do not run as root. Clone entire repository.

# Get script location
script_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

# Rank mirrors
cp '/etc/pacman.d/mirrorlist' '/etc/pacman.d/mirrorlist.backup'
rm -f '/etc/pacman.d/mirrorlist'
rankmirrors -n 40 '/etc/pacman.d/mirrorlist.backup' >> '/etc/pacman.d/mirrorlist'

# Prompts
read -r -p "Run arch_linux_packages script? [y/N] " arch_linux_packages
read -r -p "Run configure_i3 script? [y/N] " configure_i3
read -r -p "Run connect_smb script? [y/N] " connect_smb
read -r -p "Set a timer to select OS or kernel? [y/N] " ostimer
read -r -p "Run configure_gdm script? [y/N] " configure_gdm
read -r -p "Run configure_hyper_v_guest script? [y/N] " configure_hyper_v_guest
read -r -p "Run configure_kvm script? [y/N] " configure_kvm
read -r -p "Run configure_sway script? [y/N] " configure_sway
read -r -p "Run configure_termite script? [y/N] " configure_termite
read -r -p "Run install_aur_packages script? [y/N] " install_aur_packages
read -r -p "Run mount_drives script? [y/N] " mount_drives
read -r -p "Run setup_aliases script? [y/N] " setup_aliases
read -r -p "Run setup_fwupd script? [y/N] " setup_fwupd
read -r -p "Run setup_git script? [y/N] " setup_git
read -r -p "Run setup_serial script? [y/N] " setup_serial

# Run arch_linux_packages script
if [[ "${arch_linux_packages}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/arch_linux_packages.sh"
fi

# Run configure_i3 script
if [[ "${configure_i3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_i3.sh"
fi

# Run connect_smb script
if [[ "${connect_smb}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/connect_smb.sh"
fi

# Run configure_gdm script
if [[ "${configure_gdm}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_gdm.sh"
fi

# Run configure_hyper_v_guest script
if [[ "${configure_hyper_v_guest}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_hyper_v_guest.sh"
fi

# Run configure_kvm script
if [[ "${configure_kvm}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_kvm.sh"
fi

# Run configure_sway script
if [[ "${configure_sway}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_sway.sh"
fi

# Run configure_termite script
if [[ "${configure_termite}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/configure_termite.sh"
fi

# Run install_aur_packages script
if [[ "${install_aur_packages}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/install_aur_packages.sh"
fi

# Run mount_drives script
if [[ "${mount_drives}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/mount_drives.sh"
fi

# Run setup_aliases script
if [[ "${setup_aliases}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/setup_aliases.sh"
fi

# Run setup_fwupd script
if [[ "${setup_fwupd}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/setup_fwupd.sh"
fi

# Run setup_git script
if [[ "${setup_git}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/setup_git.sh"
fi

# Run setup_serial script
if [[ "${setup_serial}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    bash "${script_location}/setup_serial.sh"
fi

# Set a timer to select OS or kernel
if [[ "${ostimer}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    {
        printf '%s\n' 'timeout 60'
        printf '%s\n' ''
    } >> '/boot/loader/loader.conf'
fi
