#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the pihole server.

# Source functions
source linux_scripts.sh
source pihole_server_scripts.sh

# Call functions
get_username
configure_network
fix_apt_packages
install_pihole_packages
configure_ssh
configure_pihole_ssh_key
configure_ufw_base
configure_pihole_ufw_rules
enable_ufw
configure_auto_updates_stable
configure_pihole_scripts
configure_unbound
configure_pihole
