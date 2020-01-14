#!/bin/bash

# Script to configure aliases
# Does not need to be executed as root.

# Get username
user_name=$(logname)

# Copy ssh keys
sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/nas.openssh' '.ssh/nas'
sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/openwrt.openssh' '.ssh/openwrt'
sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/proxmox.openssh' '.ssh/proxmox'
sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/vpn.openssh' '.ssh/vpn'
sudo cp '/mnt/matt-nas/SSHConfigs/matt_homelab/pihole.openssh' '.ssh/pihole'

# Setup bashrc config
cat <<\EOF >> "/home/${user_name}/.bashrc"

# Aliases
alias sudo='sudo '
alias ssh_nas="ssh -i '.ssh/nas' matthew@matt-nas.miller.lan"
alias ssh_openwrt="ssh -i '.ssh/openwrt' matthew@mattopenwrt.miller.lan"
alias ssh_proxmox="ssh -i '.ssh/proxmox' matthew@matt-prox.miller.lan"
alias ssh_vpn="ssh -i '.ssh/vpn' matt-vpn@matt-vpn.miller.lan"
alias ssh_pihole="ssh -i '.ssh/pihole' pihole@matt-pihole.miller.lan"
alias pacman_autoremove='pacman -Rs $(pacman -Qtdq)'

EOF
