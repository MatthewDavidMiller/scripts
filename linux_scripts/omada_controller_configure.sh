#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the TP Link Omada Controller.

# Source functions
source linux_scripts.sh
source omada_controller_scripts.sh

# Call functions
get_username
configure_network
fix_apt_packages
install_omada_controller_packages
configure_ssh
configure_omada_controller_ssh_key
configure_ufw_base
configure_omada_controller_ufw_rules
enable_ufw
configure_auto_updates_stable
configure_omada_controller
