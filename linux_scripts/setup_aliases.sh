#!/bin/bash

# Script to configure aliases
# Does not need to be executed as root.

# Get username
user_name=$(logname)

function copy_ssh_keys() {
    sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/nas_key' '.ssh/nas_key'
    sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/openwrt_key' '.ssh/openwrt_key'
    sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/proxmox_key' '.ssh/proxmox_key'
    sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/vpn_key' '.ssh/vpn_key'
    sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/pihole_key' '.ssh/pihole_key'
}

function configure_bashrc() {
    cat <<\EOF >>"/home/${user_name}/.bashrc"

# Aliases
alias sudo='sudo '
alias ssh_nas="ssh -i '.ssh/nas_key' matthew@matt-nas.miller.lan"
alias ssh_openwrt="ssh -i '.ssh/openwrt_key' matthew@mattopenwrt.miller.lan"
alias ssh_proxmox="ssh -i '.ssh/proxmox_key' matthew@matt-prox.miller.lan"
alias ssh_vpn="ssh -i '.ssh/vpn_key' matthew@matt-vpn.miller.lan"
alias ssh_pihole="ssh -i '.ssh/pihole_key' matthew@matt-pihole.miller.lan"
alias pacman_autoremove='pacman -Rs $(pacman -Qtdq)'

EOF
}

# Call functions
copy_ssh_keys
configure_bashrc
