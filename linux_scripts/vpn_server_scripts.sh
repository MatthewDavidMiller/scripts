#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions for the VPN Server.

function install_vpn_server_packages() {
    apt-get update
    apt-get upgrade
    apt-get install -y wget vim git ufw ntp ssh apt-transport-https openssh-server unattended-upgrades
}

function configure_vpn_ufw_rules() {
    # Limit max connections to vpn server
    ufw limit proto udp from any to any port 64640

    # Limit max connections to ssh server and allow it only on private networks
    ufw limit proto tcp from 10.0.0.0/8 to any port 22
    ufw limit proto tcp from fe80::/10 to any port 22
}

function configure_vpn_scripts() {
    # Enter code for dynamic dns
    read -r -p "Enter code for dynamic dns: " dynamic_dns
    # Script to get emails on vpn connections
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/email_on_vpn_connections.sh'
    mv 'email_on_vpn_connections.sh' '/usr/local/bin/email_on_vpn_connections.sh'
    chmod +x '/usr/local/bin/email_on_vpn_connections.sh'
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/email_on_vpn_connections.py'
    mv 'email_on_vpn_connections.py' '/usr/local/bin/email_on_vpn_connections.py'
    chmod +x '/usr/local/bin/email_on_vpn_connections.py'

    # Script to archive config files for backup
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
    mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
    chmod +x '/usr/local/bin/backup_configs.sh'

    # Configure cron jobs
    cat <<EOF >jobs.cron
@reboot apt-get update && apt-get install -y openvpn &
* 0 * * 1 bash /usr/local/bin/backup_configs.sh &
@reboot nohup bash /usr/local/bin/email_on_vpn_connections.sh &
3,8,13,18,23,28,33,38,43,48,53,58 * * * * sleep 29 ; wget --no-check-certificate -O - https://freedns.afraid.org/dynamic/update.php?${dynamic_dns} >> /tmp/freedns_mattm_mooo_com.log 2>&1 &
* 0 * * * '/sbin/reboot'

EOF
    crontab jobs.cron
    rm -f jobs.cron
}

function configure_vpn() {
    # Setup vpn with PiVPN
    wget 'https://raw.githubusercontent.com/pivpn/pivpn/master/auto_install/install.sh'
    mv 'install.sh' '/usr/local/bin/pivn_installer.sh'
    chmod +x '/usr/local/bin/pivn_installer.sh'
    bash '/usr/local/bin/pivn_installer.sh'

    # Add openvpn users
    read -r -p "Add a vpn user? [y/N] " vpn_user_response
    while [[ "${vpn_user_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        pivpn add
        read -r -p "Add another vpn user? [y/N] " vpn_user_response
    done
}

function configure_vpn_ssh_key() {
    # Generate an ecdsa 521 bit key
    ssh-keygen -f "/home/${user_name}/vpn_key" -t ecdsa -b 521

    # Authorize the key for use with ssh
    mkdir "/home/${user_name}/.ssh"
    chmod 700 "/home/${user_name}/.ssh"
    touch "/home/${user_name}/.ssh/authorized_keys"
    chmod 600 "/home/${user_name}/.ssh/authorized_keys"
    cat "/home/${user_name}/vpn_key.pub" >>"/home/${user_name}/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/${user_name}/.ssh/authorized_keys"
    chown -R "${user_name}" "/home/${user_name}"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"
}
