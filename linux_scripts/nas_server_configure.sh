#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root. Make sure you are logged in as a user instead of root.
# Configuration script for the nas server. Run after installing with the oldstable install script.

# Set server ip
read -r -p "Enter server ip address. Example '10.1.10.4': " ip_address
# Set network
read -r -p "Enter network ip address. Example '10.1.10.0': " network_address
# Set subnet mask
read -r -p "Enter netmask. Example '255.255.255.0': " subnet_mask
# Set gateway
read -r -p "Enter gateway ip. Example '10.1.10.1': " gateway_address
# Set dns server
read -r -p "Enter dns server ip. Example '10.1.10.5': " dns_address

# Get username
user_name=$(logname)

# Get the interface name
interface="(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"

# Configure network
rm -f '/etc/network/interfaces'
cat <<EOF > '/etc/network/interfaces'
auto lo
iface lo inet loopback
auto ${interface}
iface ${interface} inet static
    address ${ip_address}
    network ${network_address}
    netmask ${subnet_mask}
    gateway ${gateway_address}
    dns-nameservers ${dns_address}

EOF

# Install recommended packages
apt-get update
apt-get install -y wget vim git ufw ntp ssh apt-transport-https openssh-server

# Setup ntp client
systemctl enable ntpd.service

# Configure ufw

# Limit max connections to ssh server and allow it only on private networks
ufw limit proto tcp from 10.0.0.0/8 to any port 22

# Allow https on private networks
ufw allow proto tcp from 10.0.0.0/8 to any port 443

# Allow smb on private networks
ufw allow proto tcp from 10.0.0.0/8 to any port 445

# Allow netbios on private networks
ufw allow proto tcp from 10.0.0.0/8 to any port 137

# Allow netbios on private networks
ufw allow proto tcp from 10.0.0.0/8 to any port 138

# Allow netbios on private networks
ufw allow proto tcp from 10.0.0.0/8 to any port 139

# Enable ufw
systemctl enable ufw.service
ufw enable

# Get scripts

# Script to archive config files for backup
wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
chmod +x '/usr/local/bin/backup_configs.sh'

# Configure cron jobs
{
    printf '%s\n' '* 0 * * 1 bash /usr/local/bin/backup_configs.sh &'
} >> jobs.cron
crontab jobs.cron
rm -f jobs.cron

# Setup ssh

# Generate an ecdsa 521 bit key
ssh-keygen -f "/home/${user_name}/nas_key" -t ecdsa -b 521

# Authorize the key for use with ssh
mkdir "/home/${user_name}/.ssh"
chmod 700 "/home/${user_name}/.ssh"
touch "/home/${user_name}/.ssh/authorized_keys"
chmod 600 "/home/${user_name}/.ssh/authorized_keys"
cat "/home/${user_name}/nas_key.pub" >> "/home/${user_name}/.ssh/authorized_keys"
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

# Configure automatic updates

rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

cat <<\EOF > '/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,a=oldstable";
        "origin=Debian,a=oldstable-updates";
};

Unattended-Upgrade::Package-Blacklist {

};

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
Unattended-Upgrade::Automatic-Reboot "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

EOF

# Setup openmediavault

cat <<EOF >> '/etc/apt/sources.list.d/openmediavault.list'
deb https://packages.openmediavault.org/public arrakis main
# deb https://downloads.sourceforge.net/project/openmediavault/packages arrakis main
## Uncomment the following line to add software from the proposed repository.
# deb https://packages.openmediavault.org/public arrakis-proposed main
# deb https://downloads.sourceforge.net/project/openmediavault/packages arrakis-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb https://packages.openmediavault.org/public arrakis partner
# deb https://downloads.sourceforge.net/project/openmediavault/packages arrakis partner

EOF

cat <<\EOF >> 'openmediavault_install.sh'

export LANG=C
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get update
apt-get --allow-unauthenticated install openmediavault-keyring
apt-get update
apt-get --yes --auto-remove --show-upgraded \
    --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    --option Dpkg::Options::="--force-confdef" \
    --option DPkg::Options::="--force-confold" \
    install postfix openmediavault
# Initialize the system and database.
omv-initsystem

EOF
bash 'openmediavault_install.sh'
