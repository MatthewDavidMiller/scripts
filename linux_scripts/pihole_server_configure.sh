#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the pihole server.

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'pihole_server_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/pihole_server_scripts.sh'

# Source functions
source linux_scripts.sh
source pihole_server_scripts.sh

# Default variables
release_name='buster'
key_name='pihole_key'
ip_address='10.1.10.4'
network_address='10.1.10.0'
subnet_mask='255.255.255.0'
gateway_address='10.1.10.1'
dns_address='1.1.1.1'
network_prefix='10.0.0.0/8'
limit_ssh='y'
allow_dns='y'
allow_unbound='y'
allow_http='y'
allow_https='y'
allow_port_4711_tcp='y'
allow_smb='n'
allow_netbios='n'
limit_port_64640='n'
allow_port_8006='n'
allow_omada_controller='n'

# Call functions
lock_root
get_username
get_interface_name
configure_network "${ip_address}" "${network_address}" "${subnet_mask}" "${gateway_address}" "${dns_address}" "${interface}"
fix_apt_packages
install_pihole_packages
configure_ssh
generate_ssh_key "${user_name}" "y" "n" "n" "${key_name}"
configure_ufw_base
ufw_configure_rules "${network_prefix}" "${limit_ssh}" "${allow_dns}" "${allow_unbound}" "${allow_http}" "${allow_https}" "${allow_port_4711_tcp}" "${allow_smb}" "${allow_netbios}" "${limit_port_64640}" "${allow_port_8006}" "${allow_omada_controller}"
enable_ufw
apt_configure_auto_updates "${release_name}"
configure_pihole_scripts
configure_unbound
configure_pihole
