#!/bin/bash

# Script to install packages
# Does not need to be executed as root.

function install_arch_packages() {
    # Prompts
    read -r -p "Install gnome desktop environment? [y/N] " gnome_response
    read -r -p "Install i3 windows manager? [y/N] " i3_response
    read -r -p "Install blender? [y/N] " blender_response
    read -r -p "Install gimp? [y/N] " gimp_response
    read -r -p "Install libreoffice? [y/N] " libreoffice_response
    read -r -p "Install vscode? [y/N] " vscode_response
    read -r -p "Install git? [y/N] " git_response
    read -r -p "Install putty? [y/N] " putty_response
    read -r -p "Install Nvidia LTS driver? [y/N] " nvidia_response
    read -r -p "Install dolphin file manager? [y/N] " dolphin_fm_response
    read -r -p "Install audacity? [y/N] " audacity_response
    read -r -p "Install nmap? [y/N] " nmap_response
    read -r -p "Install wireshark? [y/N] " wireshark_response
    read -r -p "Install ntop? [y/N] " ntop_response
    read -r -p "Install jnettop? [y/N] " jnettop_response
    read -r -p "Install nethogs? [y/N] " nethogs_response
    read -r -p "Install clamav? [y/N] " clamav_response
    read -r -p "Install vim? [y/N] " vim_response
    read -r -p "Install shellcheck? [y/N] " shellcheck_response
    read -r -p "Install tftpd? [y/N] " tftpd_response
    read -r -p "Install cmake? [y/N] " cmake_response
    read -r -p "Install pylint? [y/N] " pylint_response
    read -r -p "Install light? [y/N] " light_response

    # Install gnome desktop environment
    if [[ "${gnome_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed gnome
    fi

    # Install i3 windows manager
    if [[ "${i3_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed i3-wm i3blocks i3lock i3status dmenu
    fi

    # Install blender
    if [[ "${blender_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed blender
    fi

    # Install gimp
    if [[ "${gimp_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed gimp
    fi

    # Install libreoffice
    if [[ "${libreoffice_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed libreoffice-fresh
    fi

    # Install vscode
    if [[ "${vscode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed code
    fi

    # Install git
    if [[ "${git_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed git
    fi

    # Install putty
    if [[ "${putty_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed putty
    fi

    # Install Nvidia LTS driver
    if [[ "${nvidia_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed nvidia-lts
    fi

    # Install dolphin file manager
    if [[ "${dolphin_fm_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed dolphin
    fi

    # Install audacity
    if [[ "${audacity_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed audacity
    fi

    # Install nmap
    if [[ "${nmap_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed nmap
    fi

    # Install wireshark
    if [[ "${wireshark_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed wireshark-cli wireshark-qt
    fi

    # Install ntop
    if [[ "${ntop_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed ntop
    fi

    # Install jnettop
    if [[ "${jnettop_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed jnettop
    fi

    # Install nethogs
    if [[ "${nethogs_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed nethogs
    fi

    # Install clamav
    if [[ "${clamav_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed clamav clamtk
    fi

    # Install vim
    if [[ "${vim_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed vim
    fi

    # Install shellcheck
    if [[ "${shellcheck_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed shellcheck
    fi

    # Install tftpd
    if [[ "${tftpd_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed tftp-hpa
    fi

    # Install cmake
    if [[ "${cmake_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed cmake
    fi

    # Install pylint
    if [[ "${pylint_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed python-pylint
    fi

    # Install light
    if [[ "${light_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo pacman -S --noconfirm --needed light
    fi
}

# Call functions
install_arch_packages
