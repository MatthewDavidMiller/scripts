#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root. Make sure you are logged in as a user instead of root.
# Configuration script for the nas server. Run after installing with the oldstable install script.

# Get username
user_name=$(logname)

function configure_network() {
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

    # Get the interface name
    interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
    echo "Interface name is ${interface}"

    # Configure network
    rm -f '/etc/network/interfaces'
    cat <<EOF >'/etc/network/interfaces'
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
}

function configure_packages() {
    # Fix all packages
    dpkg --configure -a

    # Install recommended packages
    apt-get update
    apt-get upgrade
    apt-get install -y wget vim git ufw ntp ssh apt-transport-https openssh-server unattended-upgrades
}

function configure_firewall() {
    # Configure ufw
    # Set default inbound to deny
    ufw default deny incoming

    # Set default outbound to allow
    ufw default allow outgoing

    # Limit max connections to ssh server and allow it only on private networks
    ufw limit proto tcp from 10.0.0.0/8 to any port 22
    ufw limit proto tcp from fe80::/10 to any port 22

    # Allow https on private networks
    ufw allow proto tcp from 10.0.0.0/8 to any port 443
    ufw allow proto tcp from fe80::/10 to any port 443

    # Allow smb on private networks
    ufw allow proto tcp from 10.0.0.0/8 to any port 445
    ufw allow proto tcp from fe80::/10 to any port 445

    # Allow netbios on private networks
    ufw allow proto tcp from 10.0.0.0/8 to any port 137
    ufw allow proto tcp from fe80::/10 to any port 137

    # Allow netbios on private networks
    ufw allow proto tcp from 10.0.0.0/8 to any port 138
    ufw allow proto tcp from fe80::/10 to any port 138

    # Allow netbios on private networks
    ufw allow proto tcp from 10.0.0.0/8 to any port 139
    ufw allow proto tcp from fe80::/10 to any port 139

    # Enable ufw
    systemctl enable ufw.service
    ufw enable
}

function configure_scripts() {
    # Script to archive config files for backup
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
    mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
    chmod +x '/usr/local/bin/backup_configs.sh'

    # Configure cron jobs
    cat <<EOF >jobs.cron
* 0 * * 1 bash /usr/local/bin/backup_configs.sh &

EOF
    crontab jobs.cron
    rm -f jobs.cron
}

function configure_ssh() {
    # Generate an ecdsa 521 bit key
    ssh-keygen -f "/home/${user_name}/nas_key" -t ecdsa -b 521

    # Authorize the key for use with ssh
    mkdir "/home/${user_name}/.ssh"
    chmod 700 "/home/${user_name}/.ssh"
    touch "/home/${user_name}/.ssh/authorized_keys"
    chmod 600 "/home/${user_name}/.ssh/authorized_keys"
    cat "/home/${user_name}/nas_key.pub" >>"/home/${user_name}/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/${user_name}/.ssh/authorized_keys"
    chown -R "${user_name}" "/home/${user_name}"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"

    # Secure ssh access

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

function configure_auto_updates() {
    rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

    cat <<\EOF >'/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,n=stretch,l=Debian";
        "origin=Debian,n=stretch,l=Debian-Security";
        "origin=Debian,n=stretch-updates";
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
}

function configure_openmediavault() {

    cat <<EOF >>'/etc/apt/sources.list.d/openmediavault.list'
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

    cat <<\EOF >>'openmediavault_install.sh'

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
}

# Customize based on use case
function configure_samba() {
    rm -f '/etc/samba/smb.conf'
    cat <<\EOF >>'/etc/samba/smb.conf'
#======================= Global Settings =======================
[global]
workgroup = WORKGROUP
server string = %h server
dns proxy = no
log level = 0
log file = /var/log/samba/log.%m
max log size = 1000
logging = syslog
panic action = /usr/share/samba/panic-action %d
encrypt passwords = true
passdb backend = tdbsam
obey pam restrictions = no
unix password sync = no
passwd program = /usr/bin/passwd %u
passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
pam password change = yes
socket options = TCP_NODELAY IPTOS_LOWDELAY
guest account = nobody
load printers = no
disable spoolss = yes
printing = bsd
printcap name = /dev/null
unix extensions = yes
wide links = no
create mask = 0777
directory mask = 0777
map to guest = Bad User
use sendfile = yes
aio read size = 16384
aio write size = 16384
local master = yes
time server = no
wins support = no

#======================= Share Definitions =======================
[vm_backup]
path = /srv/dev-disk-by-label-Matthew_Backup/matt_files/vm_backup
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "matthew"
invalid users =
read list =
write list = "matthew"

[matt_files]
path = /srv/dev-disk-by-label-Matthew_Backup/matt_files
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "matthew"
invalid users =
read list =
write list = "matthew"

[maryicloudphotos]
path = /srv/dev-disk-by-label-Matthew_Backup/mary_backup/icloud photos
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "mary"
invalid users =
read list =
write list = "mary"

[maryiclouddrive]
path = /srv/dev-disk-by-label-Matthew_Backup/mary_backup/icloud drive
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "mary"
invalid users =
read list =
write list = "mary"

[public]
path = /srv/dev-disk-by-label-Matthew_Backup/public
guest ok = yes
guest only = yes
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes

[matthew_versions]
path = /srv/dev-disk-by-label-Matthew_Backup/matthew_versions
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "matthew"
invalid users =
read list =
write list = "matthew"

[mary_versions]
path = /srv/dev-disk-by-label-Matthew_Backup/mary_versions
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "mary"
invalid users =
read list =
write list = "mary"

[mary_backup]
path = /srv/dev-disk-by-label-Matthew_Backup/mary_backup
guest ok = no
read only = no
browseable = yes
inherit acls = yes
inherit permissions = no
ea support = no
store dos attributes = no
vfs objects =
printable = no
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
hide special files = yes
follow symlinks = yes
hide dot files = yes
valid users = "mary"
invalid users =
read list =
write list = "mary"

EOF
}

function create_users() {
    read -r -p "Add a user? [y/N] " create_users
    while [[ "${create_users}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        read -r -p "Set username. " new_user_name
        # Add a user
        useradd -m "${new_user_name}"
        echo "Set the password for ${new_user_name}"
        passwd "${new_user_name}"
        read -r -p "Do you want to add another user? [y/N] " continue_create_users
        if [[ "${continue_create_users}" =~ ^([nN][oO]|[nN])+$ ]]; then
            break
        fi
    done
}

# Call functions
configure_network
configure_packages
configure_ssh
configure_firewall
configure_scripts
configure_auto_updates
configure_openmediavault
create_users
configure_samba
