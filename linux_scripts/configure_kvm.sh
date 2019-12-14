#!/bin/bash

# Script to configure kvm in Arch Linux
# Does not need to be executed as root.

# Install packages
sudo pacman -S --noconfirm --needed libvirt gnome-boxes ebtables dnsmasq bridge-utils

# Enable nested virtualization
sudo bash -c "cat <<EOF > '/etc/modprobe.d/kvm_intel.conf'

options kvm_intel nested=1

EOF"
