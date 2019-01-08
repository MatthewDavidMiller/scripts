#!/bin/bash

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

# Run the script as root

# Basic Configuration

# Configure locale
cp /etc/locale.gen /etc/locale.gen.dist
sed -i -e "/^[^#]/s/^/#/" -e "/en_US.UTF-8/s/^#//" /etc/locale.gen
cp /var/cache/debconf/config.dat /var/cache/debconf/config.dat.dist
sed -i -e "/^Value: en_GB.UTF-8/s/en_GB/en_US/" \
	-e "/^ locales = en_GB.UTF-8/s/en_GB/en_US/" /var/cache/debconf/config.dat
locale-gen
update-locale LANG=en_US.UTF-8

# Configure timezone
cp /etc/timezone /etc/timezone.dist
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Configure Keyboard
cp /etc/default/keyboard /etc/default/keyboard.dist
sed -i -e "/XKBLAYOUT=/s/gb/us/" /etc/default/keyboard
service keyboard-setup restart

# Adduser and delete the default user
adduser matthew
echo 'matthew    ALL= (ALL) ALL' | sudo EDITOR='tee -a' visudo
deluser -remove-home pi

# Create Directories
mkdir /home/matthew/scripts
mkdir /home/matthew/logs

# Install and update applications
/usr/bin/apt-get update && /usr/bin/apt-get upgrade -y 
/usr/bin/apt-get install ufw fail2ban apt-listchanges ssmtp mailutils git -y

# Create SSH Key and configure SSH
service ssh start
read -sp 'Specify SSH Password: ' sshpassword
ssh-keygen -t rsa -b 2048 -N $sshpassword
cat /home/matthew/.ssh/id_rsa.pub >> /home/matthew/.ssh/authorized_keys
chmod 644 /home/matthew/.ssh/authorized_keys
mkdir /scripttemp
git clone https://gist.github.com/a297b08ed75e362e7c0ad71e4b8ee4a1.git /scripttemp/ssh_config
cp /scripttemp/ssh_config/sshd_config /etc/ssh/sshd_config
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
git clone https://gist.github.com/f72bda03009cf18d114faece6896e0bc.git /scripttemp/ufw_config
cp /scripttemp/ufw_config/ufw /etc/default/ufw
cp /scripttemp/ufw_config/ufw_sysctl_config /etc/ufw/sysctl.conf
cp /scripttemp/ufw_config/ufw_before_rules /etc/ufw/before.rules
ufw enable
bash -c "iptables-save > /etc/iptables.rules"

# Disable Bluetooth
git clone https://gist.github.com/09ff037b0693aa246a0ec2897630cf6f.git /scripttemp/boot_config
cp /scripttemp/boot_config/raspberry_pi_boot_config /boot/config.txt
systemctl disable hciuart.service
systemctl disable bluetooth.service
systemctl disable bluealsa.service

# Delete the scripttemp folder
rm -rf /scripttemp
