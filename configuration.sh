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
/usr/bin/apt-get install ufw fail2ban apt-listchanges ssmtp mailutils git curl -y

# Create SSH Key and configure SSH
ssh_default_public_key_location="/home/matthew/.ssh/id_rsa.pub"
ssh_authorized_keys_location="/home/matthew/.ssh/authorized_keys"
script_temp_location="/tmp/scripttemp"
temp_ssh_config="/tmp/scripttemp/ssh_config"
sshd_config_location="/etc/ssh/sshd_config"

service ssh start
read -sp "Specify SSH Password: " sshpassword
ssh-keygen -t rsa -b 2048 -N "${sshpassword}"
cat "${ssh_default_public_key_location}" >> "${ssh_authorized_keys_location}"
chmod 644 "${ssh_authorized_keys_location}"
mkdir -p "${script_temp_location}"
git clone https://gist.github.com/a297b08ed75e362e7c0ad71e4b8ee4a1.git "${temp_ssh_config}"
cp "${temp_ssh_config}/sshd_config" "${sshd_config_location}"
service ssh reload

# Configure Fail2ban
fail2ban_default_location="/etc/fail2ban/jail.conf"
fail2ban_new_location="/etc/fail2ban/jail.local"

cp "${fail2ban_default_location}" "${fail2ban_new_location}"

# Configure OpenVPN Server
curl -L https://install.pivpn.io | bash
pivpn add "${user}"

# Configure firewall rules
ufw_temp_location="/tmp/scripttemp/ufw_config"
ufw_default_config_location="/etc/default/ufw"
ufw_sysctl_location="/etc/ufw/sysctl.conf"
ufw_before_rules_location="/etc/ufw/before.rules"
ip_tables_rules_location="/etc/iptables.rules"

ufw reset
ufw limit ssh/tcp
ufw limit 40040/udp
ufw allow from 10.3.0.0/24
git clone https://gist.github.com/f72bda03009cf18d114faece6896e0bc.git "${ufw_temp_location}"
cp "${ufw_temp_location}/ufw" "${ufw_default_config_location}"
cp "${ufw_temp_location}/ufw_sysctl_config" "${ufw_sysctl_location}"
cp "${ufw_temp_location}/ufw_before_rules" "${ufw_before_rules_location}"
ufw enable
bash -c "iptables-save > ${ip_tables_rules_location}"

# Disable Bluetooth
boot_config_temp_location="/tmp/scripttemp/boot_config"
boot_config_location="/boot/config.txt"

git clone https://gist.github.com/09ff037b0693aa246a0ec2897630cf6f.git "${boot_config_temp_location}"
cp "${boot_config_temp_location}/raspberry_pi_boot_config" "${boot_config_location}"
systemctl disable hciuart.service
systemctl disable bluetooth.service
systemctl disable bluealsa.service

# Delete the scripttemp folder
rm -rf "${script_temp_location}"

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
