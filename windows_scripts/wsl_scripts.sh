#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions for Windows Subsystem for Linux.

function wsl_setup_gui() {
    bash -c "echo export DISPLAY=localhost:0.0" >>~/.bashrc
}

function wsl_configure_bashrc() {
    cat <<\EOF >>"/home/${user_name}/.bashrc"

# Mount network drives
sudo mount -t drvfs N: /mnt/matt_files

# Aliases
alias sudo='sudo '
alias ssh_nas="ssh -i '.ssh/nas_key' matthew@matt-nas.miller.lan"
alias ssh_openwrt="ssh -i '.ssh/openwrt_key' matthew@mattopenwrt.miller.lan"
alias ssh_proxmox="ssh -i '.ssh/proxmox_key' matthew@matt-prox.miller.lan"
alias ssh_vpn="ssh -i '.ssh/vpn_key' matthew@matt-vpn.miller.lan"
alias ssh_pihole="ssh -i '.ssh/pihole_key' matthew@matt-pihole.miller.lan"
alias cd_git='cd /mnt/matt_files/Matthew_Cloud/git'

EOF
}

function wsl_mount_network_drives() {
    mkdir /mnt/matt_files
    mount -t drvfs N: /mnt/matt_files
}

function wsl_copy_ssh_keys() {
    mkdir -p '.ssh'
    cp '/mnt/matt_files/SSHConfigs/matt_homelab/nas_key' '.ssh/nas_key'
    cp '/mnt/matt_files/SSHConfigs/matt_homelab/openwrt_key' '.ssh/openwrt_key'
    cp '/mnt/matt_files/SSHConfigs/matt_homelab/proxmox_key' '.ssh/proxmox_key'
    cp '/mnt/matt_files/SSHConfigs/matt_homelab/vpn_key' '.ssh/vpn_key'
    cp '/mnt/matt_files/SSHConfigs/matt_homelab/pihole_key' '.ssh/pihole_key'
}

function wsl_install_packages() {
    apt-get update
    apt-get upgrade
    apt-get install git ssh python3 python-pip wireshark nmap
}
