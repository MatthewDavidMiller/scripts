#!/bin/bash

# Script to configure kvm in Arch Linux

# Install packages
pacman -S --noconfirm --needed libvirt gnome-boxes ebtables dnsmasq bridge-utils

# Enable nested virtualization
cat <<EOF > '/etc/modprobe.d/kvm_intel.conf'

options kvm_intel nested=1

EOF
