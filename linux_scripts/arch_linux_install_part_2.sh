#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Part 2 of install script for Arch Linux.

# Source functions
source linux_scripts.sh
source arch_linux_scripts.sh

# Prompts and variables
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name

# Call functions
get_lvm_uuids 2>>arch_linux_install_part_2.sh_errors.txt
create_basic_lvm_fstab 2>>arch_linux_install_part_2.sh_errors.txt
create_swap_file 2>>arch_linux_install_part_2.sh_errors.txt
set_timezone 2>>arch_linux_install_part_2.sh_errors.txt
set_hardware_clock 2>>arch_linux_install_part_2.sh_errors.txt
enable_ntpd_client 2>>arch_linux_install_part_2.sh_errors.txt
arch_setup_locales 2>>arch_linux_install_part_2.sh_errors.txt
set_language 2>>arch_linux_install_part_2.sh_errors.txt
set_hostname "${device_hostname}" 2>>arch_linux_install_part_2.sh_errors.txt
setup_hosts_file "${device_hostname}" 2>>arch_linux_install_part_2.sh_errors.txt
set_root_password 2>>arch_linux_install_part_2.sh_errors.txt
arch_configure_kernel 2>>arch_linux_install_part_2.sh_errors.txt
arch_setup_systemd_boot_luks_lvm 2>>arch_linux_install_part_2.sh_errors.txt
set_systemd_boot_install_path 2>>arch_linux_install_part_2.sh_errors.txt
create_users 2>>arch_linux_install_part_2.sh_errors.txt
add_user_to_sudo "${user_name}" 2>>arch_linux_install_part_2.sh_errors.txt
enable_network_manager 2>>arch_linux_install_part_2.sh_errors.txt

# Exit chroot
exit
