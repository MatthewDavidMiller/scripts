#!/bin/bash

# Script to configure i3 window manager in Arch Linux

# Get username
user_name=$(who | awk '{print $1}')

# Install packages
pacman -S i3 dmenu network-manager-applet

# Setup i3 config
mkdir "/home/$user_name/.i3"
cat <<EOF > "/home/$user_name/.i3/config"
exec --no-startup-id nm-applet
exec --no-startup-id xsetroot -solid "#000000"

EOF