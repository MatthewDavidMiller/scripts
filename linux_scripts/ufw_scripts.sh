#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of ufw related functions that can be called for most Linux distros.

function configure_ufw_base() {
    # Set default inbound to deny
    ufw default deny incoming

    # Set default outbound to allow
    ufw default allow outgoing
}

function enable_ufw() {
    systemctl enable ufw.service
    ufw enable
}

function ufw_configure_rules() {
    # Parameters
    local network_prefix=${1}
    local limit_ssh=${2}
    local allow_dns=${3}
    local allow_unbound=${4}
    local allow_http=${5}
    local allow_https=${6}
    local allow_port_4711_tcp=${7}
    local allow_smb=${9}
    local allow_netbios=${9}
    local limit_port_64640=${10}
    local allow_port_8006=${11}
    local allow_omada_controller=${12}

    if [[ "${limit_ssh}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw limit proto tcp from "${network_prefix}" to any port 22
        ufw limit proto tcp from fe80::/10 to any port 22
    fi

    if [[ "${allow_dns}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 53
        ufw allow proto tcp from fe80::/10 to any port 53
        ufw allow proto udp from "${network_prefix}" to any port 53
        ufw allow proto udp from fe80::/10 to any port 53
    fi

    if [[ "${allow_unbound}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto udp from 127.0.0.1 to any port 5353
        ufw allow proto udp from ::1 to any port 5353
        ufw allow proto tcp from 127.0.0.1 to any port 5353
        ufw allow proto tcp from ::1 to any port 5353
    fi

    if [[ "${allow_http}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 80
        ufw allow proto tcp from fe80::/10 to any port 80
    fi

    if [[ "${allow_https}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 443
        ufw allow proto tcp from fe80::/10 to any port 443
    fi

    if [[ "${allow_port_4711_tcp}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 4711
        ufw allow proto tcp from fe80::/10 to any port 4711
    fi

    if [[ "${allow_smb}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 445
        ufw allow proto tcp from fe80::/10 to any port 445
    fi

    if [[ "${allow_netbios}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 137
        ufw allow proto tcp from fe80::/10 to any port 137
        ufw allow proto tcp from "${network_prefix}" to any port 138
        ufw allow proto tcp from fe80::/10 to any port 138
        ufw allow proto tcp from "${network_prefix}" to any port 139
        ufw allow proto tcp from fe80::/10 to any port 139
    fi

    if [[ "${limit_port_64640}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw limit proto udp from any to any port 64640
    fi

    if [[ "${allow_port_8006}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 8006
        ufw allow proto tcp from fe80::/10 to any port 8006
    fi

    if [[ "${allow_omada_controller}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 8043
        ufw allow proto tcp from fe80::/10 to any port 8043
        ufw allow proto tcp from "${network_prefix}" to any port 8088
        ufw allow proto tcp from fe80::/10 to any port 8088
        ufw allow proto udp from "${network_prefix}" to any port 29810
        ufw allow proto udp from fe80::/10 to any port 29810
        ufw allow proto tcp from "${network_prefix}" to any port 29811
        ufw allow proto tcp from fe80::/10 to any port 29811
        ufw allow proto tcp from "${network_prefix}" to any port 29812
        ufw allow proto tcp from fe80::/10 to any port 29812
        ufw allow proto tcp from "${network_prefix}" to any port 29813
        ufw allow proto tcp from fe80::/10 to any port 29813
    fi

}

function ufw_allow_default_forward() {
    grep -q ".*DEFAULT_FORWARD_POLICY=" '/etc/default/ufw' && sed -i "s,.*DEFAULT_FORWARD_POLICY=.*,DEFAULT_FORWARD_POLICY=\"ACCEPT\"," '/etc/default/ufw' || printf '%s\n' 'DEFAULT_FORWARD_POLICY="ACCEPT"' >>'/etc/default/ufw'
}

function ufw_allow_ip_forwarding() {
    grep -q ".*net/ipv4/ip_forward=" '/etc/ufw/sysctl.conf' && sed -i "s,.*net/ipv4/ip_forward=.*,net/ipv4/ip_forward=1," '/etc/ufw/sysctl.conf' || printf '%s\n' 'net/ipv4/ip_forward=1' >>'/etc/ufw/sysctl.conf'
    grep -q ".*net/ipv6/conf/default/forwarding=" '/etc/ufw/sysctl.conf' && sed -i "s,.*net/ipv6/conf/default/forwarding=.*,net/ipv6/conf/default/forwarding=1," '/etc/ufw/sysctl.conf' || printf '%s\n' 'net/ipv6/conf/default/forwarding=1' >>'/etc/ufw/sysctl.conf'
    grep -q ".*net/ipv6/conf/all/forwarding=" '/etc/ufw/sysctl.conf' && sed -i "s,.*net/ipv6/conf/all/forwarding=.*,net/ipv6/conf/all/forwarding=1," '/etc/ufw/sysctl.conf' || printf '%s\n' 'net/ipv6/conf/all/forwarding=1' >>'/etc/ufw/sysctl.conf'
}
