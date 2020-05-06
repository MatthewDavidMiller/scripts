#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the VPN server.

# Source functions
source linux_scripts.sh
source vpn_server_scripts.sh

# Call functions
get_username
configure_network
fix_apt_packages
install_vpn_server_packages
configure_ssh
configure_vpn_ssh_key
configure_ufw_base
configure_vpn_ufw_rules
enable_ufw
configure_vpn_scripts
configure_auto_updates_stable
configure_vpn
