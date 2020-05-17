#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Configuration script for OpenWrt. Run as root. Install bash before running script.

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'linux_install_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_install_scripts.sh'
wget -O 'openwrt_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/openwrt_scripts.sh'
wget -O 'bash_config_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/bash_config_scripts.sh'
wget -O 'ssh_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/ssh_scripts.sh'

# Default variables
user_name='matthew'
update_packages_response='y'
install_packages_response='y'

# Prompts, uncomment to use

#read -r -p "Enter an username: " user_name
#read -r -p "Do you want to upgrade all installed packages? [y/N] " update_packages_response
#read -r -p "Do you want to install the packages? [y/N] " install_packages_response

# Source functions
source linux_scripts.sh
source linux_install_scripts.sh
source openwrt_scripts.sh
source bash_config_scripts.sh
source ssh_scripts.sh

# Call functions
create_user "${user_name}"

if [[ "${install_packages_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    install_openwrt_packages
fi

if [[ "${update_packages_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    update_openwrt_packages
fi

add_user_to_sudo "${user_name}"
set_shell_bash "${user_name}"
restrict_luci_access
generate_ssh_key "${user_name}" "y" "n" "y" "openwrt_key"
openwrt_configure_interfaces
openwrt_configure_dhcp
openwrt_configure_wifi
openwrt_configure_firewall
openwrt_configure_upnp
openwrt_configure_sysupgrade
configure_dropbear_openwrt
configure_ssh
remove_openwrt_packages
