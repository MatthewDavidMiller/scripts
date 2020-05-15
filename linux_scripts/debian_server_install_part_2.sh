#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Part 2 of install script for Debian.

# Default variables
swap_file_size='512'

# Source functions
source linux_scripts.sh
source debian_scripts.sh
source /tmp/temp_variables.sh

# Call functions
debian_create_boot_directories
debian_create_device_files
create_basic_partition_fstab
create_swap_file "${swap_file_size}"
mount_all_drives
set_timezone
debian_setup_locale_package
set_language
set_hostname "${device_hostname}"
setup_hosts_file "${device_hostname}"
debian_setup_mirrors "${version}"
debian_install_standard_packages "${ucode}"
debian_update_kernel
apt_clear_cache
set_root_password
enable_base_network_connectivity "${interface}"
debian_setup_grub
create_user "${user_name}"
add_user_to_sudo "${user_name}"
set_shell_bash "${user_name}"
