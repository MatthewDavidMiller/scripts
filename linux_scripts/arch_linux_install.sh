#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for Arch Linux. Needs linux_scripts.sh and arch_linux_scripts.sh files.

# Log errors
exec 2>arch_linux_install.sh_errors.txt

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'arch_linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/arch_linux_scripts.sh'

# Source functions
source linux_scripts.sh
source arch_linux_scripts.sh

# Prompts and variables
read -r -p "Connect to a wireless network? [y/N] " wifi_response
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

# Call functions
list_partitions
start_dhcpcd

if [[ "${wifi_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    read -r -p "Specify wireless interface name: " wifi_interface
    read -r -p "Specify SSID name: " ssid
    arch_connect_to_wifi "${wifi_interface}" "${ssid}"
fi

check_for_internet_access
enable_ntp_timedatectl

if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    delete_all_partitions_on_a_disk "${disk}"
fi

arch_get_ucode_type
arch_install_configure_partitions
create_luks_partition "${disk_password}" "${partition2}"
create_basic_lvm "${partition2}" '/tmp/disk_password' 'Archlvm' '8G' '100%FREE'

if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    create_basic_filesystems "Archlvm" "db" "${partition1}"
    mount_basic_filesystems "Archlvm" "${partition1}"
else
    create_basic_filesystems "Archlvm" "" "${partition1}"
    mount_basic_filesystems "Archlvm" "${partition1}"
fi

arch_configure_mirrors
arch_install_base_packages_pacstrap
arch_install_move_to_script_part_2
