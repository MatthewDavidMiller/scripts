#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Configuration script for OpenWrt. Run as root. Install bash before running script.

# Prompts
read -r -p "Set username " user_name
read -r -p "Do you want to upgrade all installed packages? [y/N] " update_packages_response
read -r -p "Do you want to install the packages? [y/N] " install_packages_response

function create_user() {
    useradd "${user_name}"
    mkdir '/home'
    mkdir "/home/${user_name}"
    passwd "${user_name}"
    chown "${user_name}" "/home/${user_name}"
}

function configure_sudo() {
    bash -c "printf '%s\n' \"${user_name} ALL=(ALL) ALL\" >> '/etc/sudoers'"
}

function configure_shell() {
    chsh -s /bin/bash
    chsh -s /bin/bash "${user_name}"
}

function install_packages() {
    # Updates package lists
    opkg update
    # Installs packages
    opkg install luci-app-upnp ipset luci-ssl iptables-mod-geoip sudo bash coreutils openssh-keygen shadow-useradd shadow-chsh python3
}

function restrict_luci_access() {
    # Set http port and ip to listen to.
    uci set uhttpd.main.listen_http='10.1.10.1:80'
    # Set https port and ip to listen to.
    uci set uhttpd.main.listen_https='10.1.10.1:443'
    # Redirect http to https.
    uci set uhttpd.main.redirect_https='1'
    # Apply changes
    uci commit
}

function update_openwrt_packages() {
    # Updates package lists
    opkg update
    # Upgrades all installed packages
    opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
}

function generate_ssh_key() {
    # Generate an ecdsa 521 bit key
    ssh-keygen -f "/home/$user_name/openwrt_key" -t ecdsa -b 521

    # Authorize the key for use with ssh
    sudo mkdir "/home/$user_name/.ssh"
    sudo chmod 700 "/home/$user_name/.ssh"
    sudo touch "/home/$user_name/.ssh/authorized_keys"
    sudo chmod 600 "/home/$user_name/.ssh/authorized_keys"
    sudo bash -c "cat \"/home/$user_name/openwrt_key.pub\" >> \"/home/$user_name/.ssh/authorized_keys\""
    sudo bash -c "printf '%s\n' '' >> \"/home/$user_name/.ssh/authorized_keys\""
    sudo chown -R "$user_name" "/home/$user_name"
    python3 -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"

    # Dropbear setup
    bash -c "cat \"/home/$user_name/openwrt_key.pub\" >> '/etc/dropbear/authorized_keys'"
    bash -c "printf '%s\n' '' >> '/etc/dropbear/authorized_keys'"
    chmod 0700 /etc/dropbear
    chmod 0600 /etc/dropbear/authorized_keys
}

function configure_dropbear() {
    rm -f '/etc/config/dropbear'
    cat <<EOF >'/etc/config/dropbear'
config dropbear
        option Port '22'
        option Interface 'Vlan_10'
        option PasswordAuth 'off'
        option RootPasswordAuth 'off'

EOF
    uci set dropbear.@dropbear[0].PasswordAuth="off"
    uci set dropbear.@dropbear[0].RootPasswordAuth="off"
    uci commit dropbear
}

function configure_ssh() {
    # Turn off password authentication
    grep -q ".*PasswordAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PasswordAuthentication.*,PasswordAuthentication no," '/etc/ssh/sshd_config' || printf '%s\n' 'PasswordAuthentication no' >>'/etc/ssh/sshd_config'

    # Do not allow empty passwords
    grep -q ".*PermitEmptyPasswords" '/etc/ssh/sshd_config' && sed -i "s,.*PermitEmptyPasswords.*,PermitEmptyPasswords no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitEmptyPasswords no' >>'/etc/ssh/sshd_config'

    # Turn off PAM
    grep -q ".*UsePAM" '/etc/ssh/sshd_config' && sed -i "s,.*UsePAM.*,UsePAM no," '/etc/ssh/sshd_config' || printf '%s\n' 'UsePAM no' >>'/etc/ssh/sshd_config'

    # Turn off root ssh access
    grep -q ".*PermitRootLogin" '/etc/ssh/sshd_config' && sed -i "s,.*PermitRootLogin.*,PermitRootLogin no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitRootLogin no' >>'/etc/ssh/sshd_config'

    # Enable public key authentication
    grep -q ".*AuthorizedKeysFile" '/etc/ssh/sshd_config' && sed -i "s,.*AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys," '/etc/ssh/sshd_config' || printf '%s\n' 'AuthorizedKeysFile .ssh/authorized_keys' >>'/etc/ssh/sshd_config'
    grep -q ".*PubkeyAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PubkeyAuthentication.*,PubkeyAuthentication yes," '/etc/ssh/sshd_config' || printf '%s\n' 'PubkeyAuthentication yes' >>'/etc/ssh/sshd_config'
}

function configure_interfaces() {
    rm -f '/etc/config/network'
    cat <<EOF >'/etc/config/network'
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fdf2:48c8:433c::/48'

config interface 'lan'
        option type 'bridge'
        option ifname 'eth0.1'
        option proto 'static'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option ipaddr '10.1.1.1'
        list dns '1.1.1.1'
        list dns '8.8.8.8'
        list dns '8.8.4.4'

config device 'lan_dev'
        option name 'eth0.1'

config interface 'wan'
        option ifname 'eth0.2'
        option proto 'static'
        option ipaddr '192.168.1.2'
        option netmask '255.255.255.252'
        option gateway '192.168.1.1'
        list dns '1.1.1.1'
        list dns '8.8.8.8'
        list dns '8.8.4.4'

config device 'wan_dev'
        option name 'eth0.2'

config interface 'wan6'
        option ifname 'eth0.2'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'

config switch
        option name 'switch0'
        option reset '1'
        option enable_vlan '1'

config switch_vlan
        option device 'switch0'
        option vlan '1'
        option vid '1'
        option ports '4 3 2 1 0t'

config switch_vlan
        option device 'switch0'
        option vlan '10'
        option vid '10'
        option ports '3t 2t 0t'

config switch_vlan
        option device 'switch0'
        option vlan '2'
        option vid '2'
        option ports '5 0t'

config interface 'vlan_1'
        option proto 'static'
        option netmask '255.255.255.0'
        option type 'bridge'
        option ipaddr '10.1.50.1'
        option ifname 'eth0.50'
        list dns '1.1.1.1'
        list dns '8.8.8.8'
        list dns '8.8.4.4'

config interface 'Vlan_10'
        option proto 'static'
        option ipaddr '10.1.10.1'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option ifname 'eth0.10'
        option type 'bridge'
        list dns '1.1.1.1'
        list dns '8.8.8.8'
        list dns '8.8.4.4'

config interface 'Vlan_20'
        option proto 'static'
        option ifname 'eth0.20'
        option ipaddr '10.1.20.1'
        option netmask '255.255.255.0'
        option type 'bridge'
        list dns '1.1.1.1'
        list dns '8.8.8.8'
        list dns '8.8.4.4'

config switch_vlan
        option device 'switch0'
        option vlan '11'
        option vid '20'
        option ports '3t 2t 0t'

config switch_vlan
        option device 'switch0'
        option vlan '12'
        option ports '3t 0t'
        option vid '50'

EOF
}

function configure_dhcp() {
    rm -f '/etc/config/dhcp'
    cat <<EOF >'/etc/config/dhcp'
config dnsmasq
        option domainneeded '1'
        option localise_queries '1'
        option rebind_protection '1'
        option rebind_localhost '1'
        option local '/lan/'
        option expandhosts '1'
        option authoritative '1'
        option readethers '1'
        option leasefile '/tmp/dhcp.leases'
        option nonwildcard '1'
        option localservice '1'
        option domain 'miller.lan'

config dhcp 'lan'
        option interface 'lan'
        option leasetime '12h'
        option dhcpv6 'server'
        option ra 'server'
        option start '200'
        option limit '54'
        option ra_management '1'
        list dhcp_option '6,10.1.10.5,10.1.1.1'

config dhcp 'wan'
        option interface 'wan'
        option ignore '1'

config odhcpd 'odhcpd'
        option maindhcp '0'
        option leasefile '/tmp/hosts/odhcpd'
        option leasetrigger '/usr/sbin/odhcpd-update'
        option loglevel '4'

config dhcp 'vlan_1'
        option interface 'vlan_1'
        option start '200'
        option leasetime '6h'
        option limit '50'
        list dhcp_option '6,10.1.10.5,10.1.50.1'

config domain
        option name 'matt-prox'
        option ip '10.1.10.3'

config domain
        option name 'matt-nas'
        option ip '10.1.10.4'

config host
        option name 'MaryPrinter'
        option dns '1'
        option mac '64:51:06:71:BC:07'
        option ip '10.1.20.213'

config domain
        option name 'matt-pihole'
        option ip '10.1.10.5'

config domain
        option name 'matt-vpn'
        option ip '10.1.10.6'

config domain
        option name 'matt-switch'
        option ip '10.1.10.206'

config domain
        option name 'tim-switch'
        option ip '10.1.1.201'

config host
        option name 'MattSwitch'
        option dns '1'
        option mac 'B0:4E:26:97:E9:66'
        option ip '10.1.10.206'

config host
        option name 'TimSwitch'
        option dns '1'
        option mac '68:FF:7B:0B:22:C9'
        option ip '10.1.1.201'

config dhcp 'Vlan_10'
        option leasetime '12h'
        option interface 'Vlan_10'
        option start '200'
        option limit '50'
        list dhcp_option '6,10.1.10.5,10.1.10.1'

config domain
        option name 'mary-printer'
        option ip '10.1.20.213'

config host
        option name 'DavidRoku'
        option dns '1'
        option mac 'C8:3A:6B:1C:7E:86'
        option ip '10.1.1.216'

config host
        option name 'Matt-PC'
        option dns '1'
        option mac '34:97:F6:83:31:E6'
        option ip '10.1.10.247'

config host
        option name 'Tim-PC'
        option dns '1'
        option mac '4C:CC:6A:4F:F7:3B'
        option ip '10.1.1.244'

config domain
        option name 'david-roku'

EOF
}

function configure_wifi() {
    # Prompts
    # SSID 1 setup for LAN
    read -r -p "Set SSID 1 name " ssid1_name
    read -r -p "Set SSID 1 Password " ssid1_password
    # SSID 2 Setup for a guest network
    read -r -p "Set SSID 2 name " ssid2_name
    read -r -p "Set SSID 2 Password " ssid2_password
    # SSID 3 Setup for an admin/management network
    read -r -p "Set SSID 3 name " ssid3_name
    read -r -p "Set SSID 3 Password " ssid3_password
    # SSID 4 setup for an IOT network
    read -r -p "Set SSID 4 name " ssid4_name
    read -r -p "Set SSID 4 Password " ssid4_password

    rm -f '/etc/config/wireless'
    cat <<EOF >'/etc/config/wireless'
    config wifi-device 'radio0'
        option type 'mac80211'
        option hwmode '11g'
        option path 'soc/1b500000.pci/pci0000:00/0000:00:00.0/0000:01:00.0'
        option country 'US'
        option htmode 'HT40'
        option channel 'auto'
        option disabled '1'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option encryption 'psk2+ccmp'
        option key "${ssid1_password}"
        option wpa_disable_eapol_key_retries '1'
        option ssid "${ssid1_name}"
        option disabled '1'

config wifi-device 'radio1'
        option type 'mac80211'
        option hwmode '11a'
        option path 'soc/1b700000.pci/pci0001:00/0001:00:00.0/0001:01:00.0'
        option htmode 'VHT80'
        option country 'US'
        option channel 'auto'
        option disabled '1'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option encryption 'psk2+ccmp'
        option key "${ssid1_password}"
        option wpa_disable_eapol_key_retries '1'
        option ssid "${ssid1_name}"
        option disabled '1'

config wifi-iface 'wifinet0'
        option device 'radio1'
        option mode 'ap'
        option ssid "${ssid2_name}"
        option isolate '1'
        option encryption 'psk2+ccmp'
        option key "${ssid2_password}"
        option wpa_disable_eapol_key_retries '1'
        option network 'vlan_1'
        option disabled '1'

config wifi-iface 'wifinet1'
        option device 'radio0'
        option mode 'ap'
        option ssid "${ssid2_name}"
        option encryption 'psk2+ccmp'
        option key "${ssid2_password}"
        option wpa_disable_eapol_key_retries '1'
        option isolate '1'
        option disabled '1'
        option network 'vlan_1'

config wifi-iface 'wifinet2'
        option device 'radio1'
        option mode 'ap'
        option network 'Vlan_10'
        option encryption 'psk2+ccmp'
        option key "${ssid3_password}"
        option wpa_disable_eapol_key_retries '1'
        option ssid "${ssid3_name}"
        option hidden '1'
        option disabled '1'

config wifi-iface 'wifinet3'
        option device 'radio0'
        option mode 'ap'
        option network 'Vlan_10'
        option encryption 'psk2+ccmp'
        option key "${ssid3_password}"
        option wpa_disable_eapol_key_retries '1'
        option ssid "${ssid3_name}"
        option hidden '1'
        option disabled '1'

config wifi-iface 'wifinet4'
        option device 'radio1'
        option mode 'ap'
        option ssid "${ssid4_name}"
        option network 'Vlan_20'
        option encryption 'psk2+ccmp'
        option key "${ssid4_password}"
        option wpa_disable_eapol_key_retries '1'
        option hidden '1'
        option disabled '1'

config wifi-iface 'wifinet5'
        option device 'radio0'
        option mode 'ap'
        option ssid "${ssid4_name}"
        option network 'Vlan_20'
        option encryption 'psk2+ccmp'
        option key "${ssid4_password}"
        option wpa_disable_eapol_key_retries '1'
        option hidden '1'
        option disabled '1'
EOF
}

function configure_firewall() {
    rm -f '/etc/config/firewall'
    cat <<EOF >'/etc/config/firewall'
config rule
        option src 'vlan_1'
        option name 'allow guests access to dns'
        option dest 'vlan_10'
        option dest_ip '10.1.10.5'
        option target 'ACCEPT'
        option proto 'all'

config rule
        option src 'vlan_20'
        option name 'allow iot access to dns'
        option dest 'vlan_10'
        option dest_ip '10.1.10.5'
        option target 'ACCEPT'
        option proto 'all'

config rule
        option target 'ACCEPT'
        option src 'lan'
        option name 'allow lan access to dns server'
        option proto 'all'
        option dest 'vlan_10'
        option dest_ip '10.1.10.5'

config rule
        option target 'ACCEPT'
        option src 'lan'
        option name 'allow lan access to nas'
        option proto 'all'
        option dest 'vlan_10'
        option dest_ip '10.1.10.4'

config defaults
        option syn_flood '1'
        option drop_invalid '1'
        option input 'DROP'
        option forward 'DROP'
        option output 'DROP'
        option flow_offloading '1'

config zone
        option name 'lan'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'
        option network 'lan'

config zone
        option name 'wan'
        option output 'ACCEPT'
        option masq '1'
        option input 'DROP'
        option forward 'DROP'
        option network 'wan wan6'
        option mtu_fix '1'

config include
        option path '/etc/firewall.user'

config zone
        option output 'ACCEPT'
        option name 'vlan_1'
        option input 'ACCEPT'
        option forward 'ACCEPT'
        option network 'vlan_1'

config forwarding
        option dest 'wan'
        option src 'vlan_1'

config redirect
        option target 'DNAT'
        option src 'wan'
        option dest 'lan'
        option proto 'udp'
        option src_dport '64640'
        option dest_port '64640'
        option name 'vpn'
        option dest_ip '10.1.10.6'

config redirect
        option dest_port '32486'
        option src 'wan'
        option name 'Tim_Minecraft_Server'
        option src_dport '32486'
        option target 'DNAT'
        option dest_ip '10.1.1.244'
        option dest 'lan'

config zone
        option output 'ACCEPT'
        option name 'vlan_10'
        option network 'Vlan_10'
        option input 'ACCEPT'
        option forward 'ACCEPT'

config zone
        option name 'vlan_20'
        option output 'ACCEPT'
        option network 'Vlan_20'
        option forward 'ACCEPT'
        option input 'ACCEPT'

config forwarding
        option dest 'wan'
        option src 'vlan_20'

config rule
        option src 'wan'
        option name 'block rfc 1918'
        option proto 'all'
        option target 'DROP'
        option src_ip '10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 fc00::/7 127.0.0.0/8 ::1 169.254.0.0/16 fe80::/10 100.64.0.0/10'

config forwarding
        option dest 'vlan_1'
        option src 'vlan_10'

config forwarding
        option dest 'vlan_20'
        option src 'vlan_10'

config forwarding
        option dest 'wan'
        option src 'vlan_10'

config forwarding
        option dest 'vlan_20'
        option src 'lan'

config forwarding
        option dest 'wan'
        option src 'lan'

config forwarding
        option dest 'lan'
        option src 'vlan_10'

config include 'miniupnpd'
        option type 'script'
        option path '/usr/share/miniupnpd/firewall.include'
        option family 'any'
        option reload '1'

EOF
}

function configure_upnp() {
    # Prompts
    read -r -p "Enter Device UUID " device_uuid

    rm -f '/etc/config/upnpd'
    cat <<EOF >'/etc/config/upnpd'
config perm_rule
        option comment 'Allow port 53'
        option ext_ports '53'
        option int_addr '0.0.0.0/0'
        option int_ports '53'
        option action 'allow'

config perm_rule
        option comment 'Allow port 80'
        option action 'allow'
        option ext_ports '80'
        option int_addr '0.0.0.0/0'
        option int_ports '80'

config perm_rule
        option comment 'Allow port 500'
        option ext_ports '500'
        option int_addr '0.0.0.0/0'
        option int_ports '500'
        option action 'allow'

config perm_rule
        option comment 'Allow port 88'
        option ext_ports '88'
        option int_addr '0.0.0.0/0'
        option int_ports '88'
        option action 'allow'

config perm_rule
        option action 'allow'
        option ext_ports '1024-65535'
        option int_addr '0.0.0.0/0'
        option int_ports '1024-65535'
        option comment 'Allow high ports'

config perm_rule
        option action 'deny'
        option ext_ports '0-65535'
        option int_addr '0.0.0.0/0'
        option int_ports '0-65535'
        option comment 'Default deny'

config upnpd 'config'
        option download '1024'
        option upload '512'
        option internal_iface 'lan'
        option port '5000'
        option upnp_lease_file '/var/run/miniupnpd.leases'
        option enabled '1'
        option uuid "${device_uuid}"

EOF
}

# Configure directories to be backed up
function configure_sysupgrade() {
    rm -f '/etc/sysupgrade.conf'
    cat <<EOF >'/etc/sysupgrade.conf'
/home

EOF
}

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
