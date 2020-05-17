#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root.
# Install script for a debian server. Use with Debian standard live installer. Run the script when in the live installer.

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'linux_install_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_install_scripts.sh'
wget -O 'debian_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/debian_scripts.sh'
wget -O 'bash_config_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/bash_config_scripts.sh'

# Source functions
source linux_scripts.sh
source linux_install_scripts.sh
source debian_scripts.sh
source bash_config_scripts.sh

# Default Variables
disk='/dev/sda'
partition_number1='1'
partition_number2='2'
delete_partitions_response='n'
ucode_response='y'
distro='debian'
device_hostname='DebianServer'
user_name='matthew'
specify_version='2'

# Prompts, uncomment to use
# Specify disk and partition numbers to use for install
#read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
#read -r -p "Specify partition number for /boot/EFI. Example '1': " partition_number1
#read -r -p "Specify partition number for root /. Example '2': " partition_number2
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
# Specify whether to delete all partitions
#read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " delete_partitions_response
# Specify if cpu is intel
#read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
#read -r -p "Specify a username for a new user: " user_name
# Specify version
read -r -p "Use stretch [1] or buster [2]? [1/2]: " specify_version

# Call functions
list_partitions
specify_debian_version "${specify_version}"
debian_installer_needed_packages

if [[ "${delete_partitions_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    delete_all_partitions_on_a_disk "${disk}"
fi

get_ucode_type "${distro}"
create_basic_partitions
create_basic_filesystems "${partition1}" "${partition2}"
mount_basic_filesystems "${partition1}" "${partition2}"
debootstrap_install_base_packages "${version}"
mount_proc_and_sysfs
get_base_partition_uuids "${partition1}" "${partition2}"
get_interface_name
debian_install_move_to_script_part_2
