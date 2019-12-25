#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root.
# Install script for a vpn server. Use with Debian live installer. Run the script when in the live installer.

# Install needed packages
apt-get update
apt-get install gdisk lvm2 binutils debootstrap

# Lists partitions
lsblk -f

# Prompts and variables
# Specify disk and partition numbers to use for install
read -r -p "Specify disk to use for install. Example '/dev/sda': " disk
read -r -p "Specify partition number for /boot. Example '1': " partition_number1
read -r -p "Specify partition number for lvm. Example '2': " partition_number2
partition1="${disk}${partition_number1}"
partition2="${disk}${partition_number2}"
# Specify whether to delete all partitions
read -r -p "Do you want to delete all parititions on ${disk}? [y/N] " response1
# Specify whether to continue install
read -r -p "Do you want to continue the install? [y/N] " response3
# Specify if cpu is intel
read -r -p "Is the cpu intel? [y/N] " ucode_response
# Specify device hostname
read -r -p "Set the device hostname: " device_hostname
# Specify user name
read -r -p "Specify a username for a new user: " user_name

# Enter code for dynamic dns
read -r -p "Enter code for dynamic dns: " dynamic_dns

# Delete all parititions on ${disk}
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response2
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    fi
fi

# Continue install
if [[ "${response3}" =~ ^([nN][oO]|[nN])+$ ]]
then
    exit 1
fi

# Get cpu type
if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    ucode='intel-microcode'
else
    ucode='amd64-microcode'
fi


# Creates two partitions.  First one is a 512 MB EFI partition while the second is a 10 GB Linux filesystem partition.
sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
sgdisk -n 0:0:+12GiB -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"

# Setup lvm on partition 2
pvcreate "${partition2}"
vgcreate VPNLvm "${partition2}"
lvcreate -L 2G VPNLvm -n swap
lvcreate -L 5G VPNLvm -n root
lvcreate -l 100%FREE VPNLvm -n home

# Setup and mount filesystems
mkfs.ext4 '/dev/VPNLvm/root'
mkfs.ext4 '/dev/VPNLvm/home'
mkswap '/dev/VPNLvm/swap'
mount '/dev/VPNLvm/root' /mnt
mkdir '/mnt/home'
mount '/dev/VPNLvm/home' '/mnt/home'
swapon '/dev/VPNLvm/swap'
mkfs.fat -F32 "${partition1}"
mkdir '/mnt/boot'
mount "${partition1}" '/mnt/boot'

# Get the uuids
uuid="$(blkid -o value -s UUID /dev/VPNLvm/root)"
uuid2="$(blkid -o value -s UUID /dev/VPNLvm/home)"
uuid3="$(blkid -o value -s UUID /dev/VPNLvm/swap)"

# Setup fstab
mkdir '/mnt/etc'
{
    printf '%s\n' "UUID=${uuid} / ext4 defaults 0 0"
    printf '%s\n' "UUID=${uuid2} /home ext4 defaults 0 0"
    printf '%s\n' "UUID=${uuid3} none swap sw 0 0"
} >> '/mnt/etc/fstab'

# Install base packages
debootstrap --arch amd64 --components=main,contrib,non-free buster /mnt 'http://ftp.us.debian.org/debian'

# Setup part 2 script
touch '/mnt/vpn_server_install_part_2.sh'
chmod +x '/mnt/vpn_server_install_part_2.sh'

cat <<EOF > /mnt/vpn_server_install_part_2.sh
#!/bin/bash

# Set the timezone
ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'

# Set the clock
hwclock --systohc

# Setup locale config
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate locale
locale-gen

# Set language to English
rm '/etc/locale.conf'
{
    printf '%s\n' '# language config'
    printf '%s\n' '# file location is /etc/locale.conf'
    printf '%s\n' ''
    printf '%s\n' 'LANG=en_US.UTF-8'
} >> '/etc/locale.conf'

# Set hostname
rm '/etc/hostname'
{
    printf '%s\n' '# hostname file'
    printf '%s\n' '# File location is /etc/hostname'
    printf '%s\n' "${device_hostname}"
} >> '/etc/hostname'

# Setup hosts file
rm '/etc/hosts'
{
    printf '%s\n' '# host file'
    printf '%s\n' '# file location is /etc/hosts'
    printf '%s\n' ''
    printf '%s\n' '127.0.0.1 localhost'
    printf '%s\n' '::1 localhost'
    printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
} >> '/etc/hosts'

# Setup mirrors and sources
deb-src 'http://ftp.us.debian.org/debian' buster main
deb 'http://security.debian.org/' buster/updates main
deb-src 'http://security.debian.org/' buster/updates main

# Install standard packages
tasksel install standard
apt-get install systemd linux-image-4.19.0-6-amd64 ${ucode}

# Install recommended packages
apt-get install wget vim git ufw ntp ssh

# Clean download cache
aptitude clean

# Setup ntp client
systemctl enable ntpd.service

# Set password
echo 'Set root password'
passwd root

# Configure kernel for lvm
rm '/etc/mkinitcpio.conf'
{
    printf '%s\n' '# config for kernel'
    printf '%s\n' '# file location is /etc/mkinitcpio.conf'
    printf '%s\n' ''
    printf '%s\n' 'MODULES=()'
    printf '%s\n' ''
    printf '%s\n' 'BINARIES=()'
    printf '%s\n' ''
    printf '%s\n' 'FILES=()'
    printf '%s\n' ''
    printf '%s\n' 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block lvm2 filesystems fsck)'
} >> '/etc/mkinitcpio.conf'
mkinitcpio -P

# Setup systemd-boot with lvm
mkdir '/boot/loader'
mkdir '/boot/loader/entries'

{
    printf '%s\n' '# kernel entry for systemd-boot'
    printf '%s\n' '# file location is /boot/loader/entries/vpn_server.conf'
    printf '%s\n' ''
    printf '%s\n' 'title   VPN Server Kernel'
    printf '%s\n' 'linux   /vmlinuz-linux-image-4.19.0-6-amd64'
    printf '%s\n' "initrd  /${ucode}.img"
    printf '%s\n' 'initrd  /initramfs-linux-image-4.19.0-6-amd64.img'
    printf '%s\n' "options root=UUID=${uuid} rw"
} >> '/boot/loader/entries/vpn_server.conf'

{
    printf '%s\n' '# config for systemd-boot'
    printf '%s\n' '# file location is /boot/loader/loader.conf'
    printf '%s\n' ''
    printf '%s\n' 'default  vpn_server'
    printf '%s\n' 'auto-entries 1'
} >> '/boot/loader/loader.conf'

# Setup systemd-boot
bootctl --path=/boot install

# Add a user
useradd -m "${user_name}"
echo "Set the password for ${user_name}"
passwd "${user_name}"

# Setup sudo
printf '%s\n' "${user_name} ALL=(ALL) ALL" >> '/etc/sudoers'

# Configure ufw

# Limit max connections to vpn server
ufw limit udp 64640 0.0.0.0/0 any 0.0.0.0/0 in

# Limit max connections to ssh server and allow it only on private networks
ufw limit tcp 22 0.0.0.0/0 any 10.0.0.0/8 in

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
    printf '%s\n' '@reboot apt-get update && apt-get install openvpn &'
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

# Exit chroot
exit

EOF

# Move to installation
chroot /mnt "./vpn_server_install_part_2.sh"
