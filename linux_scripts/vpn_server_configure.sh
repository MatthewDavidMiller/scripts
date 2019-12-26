#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root. Make sure you are logged in as a user instead of root.
# Configuration script for the vpn server. Run after installing with the install script.

# Enter code for dynamic dns
read -r -p "Enter code for dynamic dns: " dynamic_dns

# Get username
user_name=$(logname)

# Install recommended packages
apt-get install -y wget vim git ufw ntp ssh

# Setup ntp client
systemctl enable ntpd.service

# Configure ufw

# Limit max connections to vpn server
ufw limit proto udp from any to any port 64640

# Limit max connections to ssh server and allow it only on private networks
ufw limit proto tcp from 10.0.0.0/8 to any port 22

# Enable ufw
systemctl enable ufw.service
ufw enable

# Get scripts

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
{
    printf '%s\n' '@reboot apt-get update && apt-get install -y openvpn &'
    printf '%s\n' '@reboot nohup bash /usr/local/bin/email_on_vpn_connections.sh &'
    printf '%s\n' "3,8,13,18,23,28,33,38,43,48,53,58 * * * * sleep 29 ; wget --no-check-certificate -O - https://freedns.afraid.org/dynamic/update.php?${dynamic_dns} >> /tmp/freedns_mattm_mooo_com.log 2>&1 &"
    printf '%s\n' '* 0 * * 1 bash /usr/local/bin/backup_configs.sh &'
    printf '%s\n' '* 0 * * 0 reboot'
} >> jobs.cron
crontab jobs.cron
rm jobs.cron

# Setup vpn with PiVPN
wget 'https://raw.githubusercontent.com/pivpn/pivpn/master/auto_install/install.sh'
mv 'install.sh' '/usr/local/bin/pivn_installer.sh'
chmod +x '/usr/local/bin/pivn_installer.sh'
bash '/usr/local/bin/pivn_installer.sh'

# Add three openvpn users
pivpn add
pivpn add
pivpn add

# Setup ssh

# Generate an ecdsa 521 bit key
ssh-keygen -f "/home/${user_name}/ssh_key" -t ecdsa -b 521

# Authorize the key for use with ssh
mkdir "/home/${user_name}/.ssh"
chmod 700 "/home/${user_name}/.ssh"
touch "/home/${user_name}/.ssh/authorized_keys"
chmod 600 "/home/${user_name}/.ssh/authorized_keys"
cat "/home/${user_name}/ssh_key.pub" >> "/home/${user_name}/.ssh/authorized_keys"
printf '%s\n' '' >> "/home/${user_name}/.ssh/authorized_keys"
chown -R "${user_name}" "/home/${user_name}"
read -r -p "Remember to copy the ssh private key to the client before restarting the device after install: " >> '/dev/null'

# Secure ssh access

# Turn off password authentication
sed -i 's,#PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,#PasswordAuthentication\s*no,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config

# Do not allow empty passwords
sed -i 's,#PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,#PermitEmptyPasswords\s*no,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config

# Turn off PAM
sed -i 's,#UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,#UsePAM\s*no,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config

# Turn off root ssh access
sed -i 's,#PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*no,PermitRootLogin no,' /etc/ssh/sshd_config

# Enable public key authentication
sed -i 's,#AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*yes,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
