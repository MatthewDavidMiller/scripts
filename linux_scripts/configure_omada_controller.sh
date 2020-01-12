#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Install script for TP Link Omada Controller
# Use with Debian
# Run as user using sudo
# Run after installing Debian stable with the install script

# Set server ip
read -r -p "Enter server ip address. Example '10.1.10.5': " ip_address
# Set network
read -r -p "Enter network ip address. Example '10.1.10.0': " network_address
# Set subnet mask
read -r -p "Enter netmask. Example '255.255.255.0': " subnet_mask
# Set gateway
read -r -p "Enter gateway ip. Example '10.1.10.1': " gateway_address
# Set dns server
read -r -p "Enter dns server ip. Example '1.1.1.1': " dns_address

# Get the interface name
interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
echo "Interface name is ${interface}"

# Get username
user_name=$(logname)

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

# Restart network interface
ifdown "${interface}" && ifup "${interface}"

# Fix all packages
dpkg --configure -a

# Install recommended packages
apt-get update
apt-get upgrade -y
apt-get install -y wget vim git ufw ntp ssh openssh-server jsvc curl unattended-upgrades

# Configure ufw

# Set default inbound to deny
ufw default deny incoming

# Set default outbound to allow
ufw default allow outgoing

# Limit max connections to ssh server and allow it only on private networks
ufw limit proto tcp from 192.168.0.0/16 to any port 22
ufw limit proto tcp from fe80::/10 to any port 22

# Allow omada controller
ufw allow proto tcp from 192.168.0.0/16 to any port 8043
ufw allow proto tcp from fe80::/10 to any port 8043

# Setup ssh

# Generate an ecdsa 521 bit key
ssh-keygen -f "/home/${user_name}/eap_controller_key" -t ecdsa -b 521

# Authorize the key for use with ssh
mkdir "/home/${user_name}/.ssh"
chmod 700 "/home/${user_name}/.ssh"
touch "/home/${user_name}/.ssh/authorized_keys"
chmod 600 "/home/${user_name}/.ssh/authorized_keys"
cat "/home/${user_name}/eap_controller_key.pub" >> "/home/${user_name}/.ssh/authorized_keys"
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
        "origin=Debian,a=stable";
        "origin=Debian,a=stable-updates";
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

# Download the controller software
wget 'https://static.tp-link.com/2019/201911/20191108/omada_v3.2.4_linux_x64_20190925173425.deb'

# Install the software
dpkg -i 'omada_v3.2.4_linux_x64_20190925173425.deb'
