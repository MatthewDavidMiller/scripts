#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Part 2 of install script for Arch Linux.

# Log errors
# exec 2>arch_linux_install_part_2.sh_errors.txt

# Default variables
user_name='matthew'
device_hostname='MatthewLaptop'

# Source functions
source linux_scripts.sh
source arch_linux_scripts.sh
source /tmp/temp_variables.sh

# Prompts, uncomment to use

# Specify device hostname
#read -r -p "Set the device hostname: " device_hostname
# Specify user name
#read -r -p "Specify a username for a new user: " user_name

# Call functions
arch_install_extra_packages
get_lvm_uuids
create_basic_lvm_fstab
create_swap_file
set_timezone
set_hardware_clock
enable_ntpd_client
arch_setup_locales
set_language
set_hostname "${device_hostname}"
setup_hosts_file "${device_hostname}"
set_root_password
arch_configure_kernel
arch_setup_systemd_boot_luks_lvm
set_systemd_boot_install_path
create_user "${user_name}"
add_user_to_sudo "${user_name}"
enable_network_manager
