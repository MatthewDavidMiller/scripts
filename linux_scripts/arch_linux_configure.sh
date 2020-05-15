#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Configuration script for Arch Linux.  Run after installing. Run as root.

# Get script location
# script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Prompts
read -r -p "Run arch_linux_packages script? [y/N] " install_arch_packages_var
read -r -p "Run configure_i3 script? [y/N] " configure_i3_var
read -r -p "Run connect_smb script? [y/N] " connect_smb_var
read -r -p "Set a timer to select OS or kernel? [y/N] " ostimer
read -r -p "Run configure_gdm script? [y/N] " configure_gdm_var
read -r -p "Run configure_hyper_v_guest script? [y/N] " configure_hyperv_var
read -r -p "Run configure_kvm script? [y/N] " configure_kvm_var
read -r -p "Run configure_sway script? [y/N] " configure_sway_var
read -r -p "Run configure_termite script? [y/N] " configure_termite_var
read -r -p "Run install_aur_packages script? [y/N] " install_aur_packages_var
read -r -p "Run mount_drives script? [y/N] " mount_drives_var
read -r -p "Run setup_aliases script? [y/N] " setup_aliases_var
read -r -p "Run setup_fwupd script? [y/N] " configure_fwupd_var
read -r -p "Run setup_git script? [y/N] " configure_git_var
read -r -p "Run setup_serial script? [y/N] " setup_serial_var
read -r -p "Configure blueman? [y/N] " configure_blueman_var
read -r -p "Configure pasystray? [y/N] " configure_pasystray_var

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'arch_linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/arch_linux_scripts.sh'

# Source functions
source linux_scripts.sh
source arch_linux_scripts.sh

# Call functions
get_username
enable_bluetooth
enable_ufw
configure_xorg "${user_name}"
setup_touchpad
rank_mirrors
pacman_auto_clear_cache
lock_root

if [[ "${install_arch_packages_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    install_arch_packages
fi

if [[ "${configure_i3_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install packages
    pacman -S --noconfirm --needed i3-wm i3blocks i3lock i3status perl perl-anyevent-i3 perl-json-xs dmenu network-manager-applet paprefs picom xorg-xrandr || echo 'Error installing packages.'
    configure_i3_sway_base "${user_name}"
    configure_i3_config_file "${user_name}"
    configure_xinit
    configure_xinit_i3
fi

if [[ "${connect_smb_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install samba
    pacman -S --noconfirm --needed samba || echo 'Error installing packages.'
    connect_smb
fi

if [[ "${configure_gdm_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    configure_gdm "${user_name}"
fi

if [[ "${configure_hyperv_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install hyperv tools
    pacman -S --noconfirm --needed hyperv || echo 'Error installing packages.'
    configure_hyperv
fi

if [[ "${configure_kvm_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install packages
    pacman -S --noconfirm --needed libvirt gnome-boxes ebtables dnsmasq bridge-utils || echo 'Error installing packages.'
    configure_kvm
fi

if [[ "${configure_sway_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install packages
    pacman -S --noconfirm --needed sway swayidle swaylock i3status dmenu network-manager-applet paprefs xorg-server-xwayland polkit-gnome xorg-xrandr || echo 'Error installing packages.'
    configure_i3_sway_base "${user_name}"
    configure_sway_config_file "${user_name}"
fi

if [[ "${configure_termite_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install packages
    pacman -S --noconfirm --needed termite || echo 'Error installing packages.'
    configure_termite "${user_name}"
fi

if [[ "${install_aur_packages_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    install_aur_packages
fi

if [[ "${mount_drives_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install linux-utils
    pacman -S --noconfirm --needed util-linux || echo 'Error installing packages.'
    mount_drives
fi

if [[ "${setup_aliases_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    setup_aliases "${user_name}"
fi

if [[ "${configure_fwupd_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install fwupd
    pacman -S --noconfirm --needed fwupd || echo 'Error installing packages.'
    configure_fwupd
fi

if [[ "${configure_git_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install git
    pacman -S --noconfirm --needed git || echo 'Error installing packages.'
    configure_git "${user_name}"
fi

if [[ "${setup_serial_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Install putty
    pacman -S --noconfirm --needed putty || echo 'Error installing packages.'
    configure_serial "${user_name}"
fi

if [[ "${ostimer}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    configure_ostimer
fi

if [[ "${configure_blueman_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    configure_i3_blueman_applet_autostart
fi

if [[ "${configure_pasystray_var}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    configure_i3_pasystray_autostart
fi
