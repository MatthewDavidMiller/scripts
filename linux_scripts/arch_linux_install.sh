#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Install script for Arch Linux. Needs linux_scripts.sh and arch_linux_scripts.sh files.

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh' 2>>arch_linux_install.sh_errors.txt
wget -O 'arch_linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/arch_linux_scripts.sh' 2>>arch_linux_install.sh_errors.txt

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
list_partitions 2>>arch_linux_install.sh_errors.txt
start_dhcpcd 2>>arch_linux_install.sh_errors.txt

if [[ "${wifi_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    read -r -p "Specify wireless interface name: " wifi_interface
    read -r -p "Specify SSID name: " ssid
    arch_connect_to_wifi "${wifi_interface}" "${ssid}" 2>>arch_linux_install.sh_errors.txt
fi

check_for_internet_access 2>>arch_linux_install.sh_errors.txt
enable_ntp_timedatectl 2>>arch_linux_install.sh_errors.txt

if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    delete_all_partitions_on_a_disk "${disk}" 2>>arch_linux_install.sh_errors.txt
fi

arch_get_ucode_type 2>>arch_linux_install.sh_errors.txt
arch_install_configure_partitions 2>>arch_linux_install.sh_errors.txt
create_luks_partition "${disk_password}" "${partition2}" 2>>arch_linux_install.sh_errors.txt
create_basic_lvm "${partition2}" '/tmp/disk_password' 'Archlvm' '8G' '100%FREE' 2>>arch_linux_install.sh_errors.txt

if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    create_basic_filesystems "Archlvm" "db" "${partition1}" 2>>arch_linux_install.sh_errors.txt
    mount_basic_filesystems "Archlvm" "${partition1}" 2>>arch_linux_install.sh_errors.txt
else
    create_basic_filesystems "Archlvm" "" "${partition1}" 2>>arch_linux_install.sh_errors.txt
    mount_basic_filesystems "Archlvm" "${partition1}" 2>>arch_linux_install.sh_errors.txt
fi

arch_configure_mirrors 2>>arch_linux_install.sh_errors.txt
arch_install_base_packages_pacstrap 2>>arch_linux_install.sh_errors.txt
arch_install_extra_packages_pacstrap 2>>arch_linux_install.sh_errors.txt
arch_install_move_to_script_part_2 2>>arch_linux_install.sh_errors.txt
