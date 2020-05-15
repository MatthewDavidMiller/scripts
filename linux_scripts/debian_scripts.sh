#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions that can be called for Debian.

function specify_debian_version() {
    # Parameters
    local specify_version=${1}

    # Specify version
    if [[ "${specify_version}" =~ ^([1])+$ ]]; then
        version='stretch'
    fi

    # Specify version
    if [[ "${specify_version}" =~ ^([2])+$ ]]; then
        version='buster'
    fi
}

function debian_installer_needed_packages() {
    apt-get update
    apt-get install -y gdisk binutils debootstrap dosfstools
}

function debootstrap_install_base_packages() {
    # Parameters
    local version=${1}

    debootstrap --arch amd64 --components=main,contrib,non-free ${version} /mnt 'http://ftp.us.debian.org/debian'
}

function debian_install_move_to_script_part_2() {
    cp linux_scripts.sh '/mnt/linux_scripts.sh'
    cp debian_scripts.sh '/mnt/debian_scripts.sh'
    wget -O '/mnt/debian_server_install_part_2.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/debian_server_install_part_2.sh'
    chmod +x '/mnt/debian_server_install_part_2.sh'
    LANG=C.UTF-8 chroot /mnt "./debian_server_install_part_2.sh"
}

function debian_create_device_files() {
    apt-get install -y makedev
    cd /dev || exit
    MAKEDEV generic
    cd / || exit
}

function debian_create_boot_directories() {
    mkdir -p '/boot/EFI/debian'
}

function debian_setup_locale_package() {
    # Install locale package
    apt-get install -y locales

    # Setup locales
    dpkg-reconfigure locales
}

function debian_setup_mirrors() {
    # Parameters
    local version=${1}

    {
        printf '%s\n' "deb https://mirrors.wikimedia.org/debian/ ${version} main contrib non-free"
        printf '%s\n' "deb-src https://mirrors.wikimedia.org/debian/ ${version} main contrib non-free"
        printf '%s\n' "deb https://mirrors.wikimedia.org/debian/ ${version}-updates main contrib non-free"
        printf '%s\n' "deb-src https://mirrors.wikimedia.org/debian/ ${version}-updates main contrib non-free"
        printf '%s\n' "deb http://security.debian.org/debian-security/ ${version}/updates main contrib non-free"
        printf '%s\n' "deb-src http://security.debian.org/debian-security/ ${version}/updates main contrib non-free"
    } >>'/etc/apt/sources.list'
}

function debian_install_standard_packages() {
    # Parameters
    local ucode=${1}

    tasksel install standard
    apt-get install -y systemd linux-image-amd64 ${ucode} efibootmgr grub-efi initramfs-tools sudo apt-transport-https
}

function debian_update_kernel() {
    update-initramfs -u
}

function debian_setup_grub() {
    rm -f '/etc/default/grub'
    {
        printf '%s\n' 'GRUB_DEFAULT=0'
        printf '%s\n' 'GRUB_TIMEOUT=0'
        printf '%s\n' 'GRUB_DISTRIBUTOR=$(lsb_release -i -s 2>/dev/null || echo Debian)'
        printf '%s\n' 'GRUB_CMDLINE_LINUX_DEFAULT="quiet"'
        printf '%s\n' "GRUB_CMDLINE_LINUX=\"\""
    } >'/etc/default/grub'
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=debian
    update-grub
}
