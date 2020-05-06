#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Configuration script for OpenWrt. Run as root. Install bash before running script.

# Prompts
read -r -p "Do you want to upgrade all installed packages? [y/N] " update_packages_response
read -r -p "Do you want to install the packages? [y/N] " install_packages_response

# Source functions
source openwrt_scripts.sh

# Call functions
create_user

if [[ "${install_packages_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    install_packages
fi

if [[ "${update_packages_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    update_openwrt_packages
fi

configure_sudo
configure_shell
restrict_luci_access
generate_ssh_key
configure_interfaces
configure_dhcp
configure_wifi
configure_firewall
configure_upnp
configure_sysupgrade
configure_dropbear
configure_ssh
remove_packages
