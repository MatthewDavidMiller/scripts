#!/bin/bash

# Script is currently a work in progress.  Some portions of the script may not work.

# Run the script as root

# Basic Configuration

# Configure locale
locale="LANG=en_US.UTF-8"
locale_gen_location="/etc/locale.gen"
locale_gen_backup_location="/etc/locale.gen.backup"

cp "${locale_gen_location}" "${locale_gen_backup_location}"
sed -i -e "/^[^#]/s/^/#/" -e "/en_US.UTF-8/s/^#//" "${locale_gen_location}"
locale-gen
update-locale "${locale}"

# Configure timezone
timezone_location="/etc/timezone"
timezone_backup_location="/etc/timezone.backup"

cp "${timezone_location}" "${timezone_backup_location}"
echo "America/New_York" > "${timezone_location}"
dpkg-reconfigure -f noninteractive tzdata

# Configure Keyboard
keyboard_location="/etc/default/keyboard"
keyboard_backup_location="/etc/default/keyboard.backup"

cp "${keyboard_location}" "${keyboard_backup_location}"
sed -i -e "/XKBLAYOUT=us" "${keyboard_location}"
service keyboard-setup restart

# Adduser and delete the default user
user="matthew"

adduser "${user}"
echo "${user}    ALL= (ALL) ALL" | sudo EDITOR="tee -a" visudo
deluser -remove-home pi

# Create Directories
scripts_directory="/home/matthew/scripts"
logs_directory="/home/matthew/logs"

mkdir -p "${scripts_directory}"
mkdir -p "${logs_directory}"

# Install and update applications
/usr/bin/apt-get update && /usr/bin/apt-get upgrade -y 
/usr/bin/apt-get install ufw fail2ban apt-listchanges ssmtp mailutils git -y

# Create SSH Key and configure SSH
service ssh start
read -sp "Specify SSH Password: " sshpassword
ssh-keygen -t rsa -b 2048 -N $sshpassword
cat /home/matthew/.ssh/id_rsa.pub >> /home/matthew/.ssh/authorized_keys
chmod 644 /home/matthew/.ssh/authorized_keys
mkdir -p /tmp/scripttemp
git clone https://gist.github.com/a297b08ed75e362e7c0ad71e4b8ee4a1.git /tmp/scripttemp/ssh_config
cp /tmp/scripttemp/ssh_config/sshd_config /etc/ssh/sshd_config
service ssh reload

# Configure Fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure OpenVPN Server
curl -L https://install.pivpn.io
pivpn add matthew

# Configure firewall rules
ufw reset
ufw limit ssh/tcp
ufw limit 40040/udp
ufw allow from 10.3.0.0/24
git clone https://gist.github.com/f72bda03009cf18d114faece6896e0bc.git /tmp/scripttemp/ufw_config
cp /tmp/scripttemp/ufw_config/ufw /etc/default/ufw
cp /tmp/scripttemp/ufw_config/ufw_sysctl_config /etc/ufw/sysctl.conf
cp /tmp/scripttemp/ufw_config/ufw_before_rules /etc/ufw/before.rules
ufw enable
bash -c "iptables-save > /etc/iptables.rules"

# Disable Bluetooth
git clone https://gist.github.com/09ff037b0693aa246a0ec2897630cf6f.git /tmp/scripttemp/boot_config
cp /tmp/scripttemp/boot_config/raspberry_pi_boot_config /boot/config.txt
systemctl disable hciuart.service
systemctl disable bluetooth.service
systemctl disable bluealsa.service

# Delete the scripttemp folder
rm -rf /tmp/scripttemp

# MIT License

# Copyright (c) 2019 Matthew David Miller

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
