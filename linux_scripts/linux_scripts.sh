#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions that can be called for most Linux distros.

function enable_bluetooth() {
    systemctl enable bluetooth.service
}

function configure_dropbear() {
    uci set dropbear.@dropbear[0].PasswordAuth="off"
    uci set dropbear.@dropbear[0].RootPasswordAuth="off"
    uci commit dropbear
    service dropbear restart
    exit
}

function connect_smb() {
    # Parameters
    local user_name=${1}

    # Make /mnt directory
    mkdir '/mnt'

    # Script to connect and mount a smb share
    read -r -p "Mount a samba share? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        # Prompts
        # Share location
        read -r -p "Specify share location. Example'//matt-nas.miller.lan/matt_files': " share
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_files': " mount_location
        # Username
        read -r -p "Specify Username. Example'matthew': " samba_username
        # Password
        read -r -p "Specify Password. Example'password': " password

        # Make directory to mount the share at
        mkdir "${mount_location}"

        # Automount smb share
        printf '%s\n' "${share} ${mount_location} cifs rw,noauto,x-systemd.automount,_netdev,uid=${user_name},user,username=${samba_username},password=${password} 0 0" >>'/etc/fstab'

        # Mount another disk
        read -r -p "Do you want to mount another samba share? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            printf '%s\n' '' >>'/etc/fstab'
            exit
        fi
    done
}

function configure_hyperv() {
    systemctl enable hv_fcopy_daemon.service
    systemctl start hv_fcopy_daemon.service
    systemctl enable hv_kvp_daemon.service
    systemctl start hv_kvp_daemon.service
    systemctl enable hv_vss_daemon.service
    systemctl start hv_vss_daemon.service
}

function configure_kvm() {
    # Enable nested virtualization
    rm -rf '/etc/modprobe.d/kvm_intel.conf'
    cat <<EOF >'/etc/modprobe.d/kvm_intel.conf'

options kvm_intel nested=1

EOF
}

function configure_termite() {
    # Parameters
    local user_name=${1}

    # Setup termite config
    mkdir "/home/${user_name}/.config"
    mkdir "/home/${user_name}/.config/termite"
    rm -rf "/home/${user_name}/.config/termite/config"
    cat <<EOF >"/home/${user_name}/.config/termite/config"
    
    [options]
    font = Monospace 16
    scrollback_lines = 10000
    
    [colors]
    
    # If unset, will reverse foreground and background
    highlight = #2f2f2f
    
    # Colors from color0 to color254 can be set
    color0 = #000000
    
    [hints]
    
EOF
}

function mount_drives() {
    # Make /mnt directory
    mkdir '/mnt'

    read -r -p "Mount a disk? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do

        #See disks
        lsblk -f

        # Prompts
        # Disk location
        read -r -p "Specify disk location. Example'/dev/sda1': " disk1
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_backup': " mount_location
        #Specify disk type
        read -r -p "Specify disk type. Example'ntfs': " disk_type

        # Get uuid
        uuid="$(blkid -o value -s UUID "${disk1}")"

        # Make directory to mount the disk at
        mkdir "${mount_location}"

        # Automount smb share
        printf '%s\n' "UUID=${uuid} ${mount_location} ${disk_type} rw,noauto,x-systemd.automount 0 0" >>'/etc/fstab'

        # Mount another disk
        read -r -p "Do you want to mount another disk? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            printf '%s\n' '' >>'/etc/fstab'
            exit
        fi
    done
}

function configure_fwupd() {
    # Copy efi file
    cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

    # Setup hook
    mkdir -p '/etc/pacman.d'
    mkdir -p '/etc/pacman.d/hooks'
    touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'
    rm -rf '/etc/pacman.d/hooks/fwupd-to-esp.hook'
    cat <<EOF >'/etc/pacman.d/hooks/fwupd-to-esp.hook'
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF
}

function configure_git() {
    # Parameters
    local user_name=${1}

    # Variables
    # Git username
    git_name='MatthewDavidMiller'
    # Email address
    email='matthewdavidmiller1@gmail.com'
    # SSH key location
    key_location='/mnt/matt_files/SSHConfigs/github/github_ssh'
    # SSH key filename
    key='github_ssh'

    # Setup username
    git config --global user.name "${git_name}"

    # Setup email
    git config --global user.email "${email}"

    # Setup ssh key
    mkdir -p "/home/${user_name}/.ssh"
    chmod 700 "/home/${user_name}/.ssh"
    cp "${key_location}" "/home/${user_name}/.ssh/${key}"
    git config --global core.sshCommand "ssh -i ""/home/${user_name}/.ssh/${key}"" -F /dev/null"
}

function configure_serial() {
    # Parameters
    local user_name=${1}

    # Add user to uucp group
    gpasswd -a "${user_name}" uucp
}

function configure_ostimer() {
    grep -q ".*timeout" '/boot/loader/loader.conf' && sed -i "s,.*timeout.*,timeout 60," '/boot/loader/loader.conf' || printf '%s\n' 'timeout 60' >>'/boot/loader/loader.conf'
}

function get_username() {
    user_name=$(logname)
}

function get_username_second_method() {
    user_name=$(whoami)
}

function get_interface_name() {
    interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
    echo "Interface name is ${interface}"
}

function configure_network() {
    # Parameters
    local ip_address=${1}
    local network_address=${2}
    local subnet_mask=${3}
    local gateway_address=${4}
    local dns_address=${5}
    local interface=${6}

    # Configure network
    rm -f '/etc/network/interfaces'
    cat <<EOF >'/etc/network/interfaces'
auto lo
iface lo inet loopback

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

function fix_apt_packages() {
    dpkg --configure -a
}

function apt_configure_auto_updates() {
    # Parameters
    local release_name=${1}

    rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

    cat <<EOF >'/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,n=${release_name},l=Debian";
        "origin=Debian,n=${release_name},l=Debian-Security";
        "origin=Debian,n=${release_name}-updates";
};

Unattended-Upgrade::Package-Blacklist {

};

Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

EOF
}

function create_user() {
    # Parameters
    local user_name=${1}

    useradd -m "${user_name}"
    echo "Set the password for ${user_name}"
    passwd "${user_name}"
    mkdir -p "/home/${user_name}"
    chown "${user_name}" "/home/${user_name}"
}

function list_partitions() {
    lsblk -f
}

function check_for_internet_access() {
    if false ping -c2 "google.com"; then
        echo 'No internet'
        exit 1
    fi
}

function start_dhcpcd() {
    systemctl start "dhcpcd.service"
}

function enable_ntp_timedatectl() {
    timedatectl set-ntp true
}

function enable_network_manager() {
    systemctl enable NetworkManager.service
}

function cli_autologin() {
    # Parameters
    local user_name=${1}

    mkdir -p '/etc/systemd/system//getty@tty1.service.d'
    cat <<EOF >'/etc/systemd/system/getty@tty1.service.d/override.conf'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${user_name} --noclear %I \$TERM
EOF
}

function get_ucode_type() {
    # Parameters
    local distro=${1}

    if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        if [[ "${distro}" =~ ^([dD][eE][bB][iI][aA][nN])+$ ]]; then
            ucode='intel-microcode'
        fi
        if [[ "${distro}" =~ ^([aA][rR][cC][hH])+$ ]]; then
            ucode='intel-ucode'
        fi
    else
        if [[ "${distro}" =~ ^([dD][eE][bB][iI][aA][nN])+$ ]]; then
            ucode='amd-microcode'
        fi
        if [[ "${distro}" =~ ^([aA][rR][cC][hH])+$ ]]; then
            ucode='amd-ucode'
        fi
    fi
}

function mount_all_drives() {
    mount -a
}

function apt_clear_cache() {
    apt-get clean
}

function configure_neovim() {
    # Parameters
    local user_name=${1}

}
