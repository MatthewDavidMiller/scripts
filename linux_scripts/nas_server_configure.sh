#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the Nas server.

# Source functions
source linux_scripts.sh
source nas_server_scripts.sh

# Call functions
get_username
configure_network
fix_apt_packages
install_nas_packages
configure_ssh
configure_nas_ssh_key
configure_ufw_base
configure_nas_ufw_rules
enable_ufw
configure_nas_scripts
configure_auto_updates_old_stable
configure_openmediavault
create_users
configure_samba
