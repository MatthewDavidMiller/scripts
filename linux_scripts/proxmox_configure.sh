#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the Proxmox server.

# Source functions
source linux_scripts.sh
source proxmox_scripts.sh

# Call functions
get_username
configure_proxmox_network
fix_apt_packages
install_proxmox_packages
configure_ssh
configure_proxmox_ssh_key
configure_ufw_base
configure_proxmox_ufw_rules
enable_ufw
configure_proxmox_scripts
configure_auto_updates_stable
set_proxmox_auto_update_reboot_time
configure_proxmox_hosts
configure_proxmox
configure_proxmox_storage
