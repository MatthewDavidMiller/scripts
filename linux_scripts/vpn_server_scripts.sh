#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions for the VPN Server.

function install_vpn_server_packages() {
    apt-get update
    apt-get upgrade
    apt-get install -y wget vim git ufw ntp ssh apt-transport-https openssh-server unattended-upgrades
}

function configure_vpn_scripts() {
    # Enter code for dynamic dns
    read -r -p "Enter code for dynamic dns: " dynamic_dns
    # Script to get emails on openvpn connections
    #wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/email_on_vpn_connections.sh'
    #mv 'email_on_vpn_connections.sh' '/usr/local/bin/email_on_vpn_connections.sh'
    #chmod +x '/usr/local/bin/email_on_vpn_connections.sh'
    #wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/email_on_vpn_connections.py'
    #mv 'email_on_vpn_connections.py' '/usr/local/bin/email_on_vpn_connections.py'
    #chmod +x '/usr/local/bin/email_on_vpn_connections.py'

    # Script to archive config files for backup
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
    mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
    chmod +x '/usr/local/bin/backup_configs.sh'

    # Configure cron jobs
    cat <<EOF >jobs.cron
#@reboot apt-get update && apt-get install -y openvpn &
* 0 * * 1 bash /usr/local/bin/backup_configs.sh &
#@reboot nohup bash /usr/local/bin/email_on_vpn_connections.sh &
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

    # Add vpn users
    read -r -p "Add a vpn user? [y/N] " vpn_user_response
    while [[ "${vpn_user_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        pivpn add
        read -r -p "Add another vpn user? [y/N] " vpn_user_response
    done
}
