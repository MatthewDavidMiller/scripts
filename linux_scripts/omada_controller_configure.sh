#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run with sudo. Do not run while logged into root.
# Configuration script for the TP Link Omada Controller.

# Source functions
source linux_scripts.sh
source omada_controller_scripts.sh

# Default variables
release_name='buster'
key_name='omada_controller_key'
ip_address='10.1.10.7'
network_address='10.1.10.0'
subnet_mask='255.255.255.0'
gateway_address='10.1.10.1'
dns_address='1.1.1.1'
network_prefix='10.0.0.0/8'
limit_ssh='y'
allow_dns='n'
allow_unbound='n'
allow_http='n'
allow_https='n'
allow_port_4711_tcp='n'
allow_smb='n'
allow_netbios='n'
limit_port_64640='n'
allow_port_8006='n'
allow_omada_controller='y'

# Call functions
get_username
get_interface_name
configure_network "${ip_address}" "${network_address}" "${subnet_mask}" "${gateway_address}" "${dns_address}" "${interface}"
fix_apt_packages
install_omada_controller_packages
configure_ssh
generate_ssh_key "${user_name}" "y" "n" "n" "${key_name}"
configure_ufw_base
ufw_configure_rules "${network_prefix}" "${limit_ssh}" "${allow_dns}" "${allow_unbound}" "${allow_http}" "${allow_https}" "${allow_port_4711_tcp}" "${allow_smb}" "${allow_netbios}" "${limit_port_64640}" "${allow_port_8006}" "${allow_omada_controller}"
enable_ufw
apt_configure_auto_updates "${release_name}"
configure_omada_controller
