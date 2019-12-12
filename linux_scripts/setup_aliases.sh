#!/bin/bash

# Script to configure aliases

# Get username
user_name=$(logname)

# Setup bashrc config
cat <<\EOF >> "/home/${user_name}/.bashrc"

# Aliases
alias ssh_nas="ssh -i '/mnt/matt-nas/SSHConfigs/matt_homelab/nas.openssh' matthew@matt-nas.lan"
alias ssh_openwrt="ssh -i '/mnt/matt-nas/SSHConfigs/matt_homelab/openwrt.openssh' matthew@mattopenwrt.lan"
alias ssh_proxmox="ssh -i '/mnt/matt-nas/SSHConfigs/matt_homelab/proxmox.openssh' matthew@matt-prox.lan"
alias ssh_vpn="ssh -i '/mnt/matt-nas/SSHConfigs/matt_homelab/vpn.openssh' matthew@matt-vpn.lan"
alias ssh_pihole="ssh -i '/mnt/matt-nas/SSHConfigs/matt_homelab/pihole.openssh' pihole@matt-pihole.lan"

EOF
