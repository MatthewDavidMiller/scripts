#!/bin/bash

# Script to configure i3 window manager in Arch Linux
# If using sudo to run the script, specify the user with the -u option.

# Get username
user_name=$(id -u -n)

# Install packages
pacman -S i3 dmenu network-manager-applet

# Setup i3 config
mkdir "/home/$user_name/.i3"
cat <<EOF > "/home/$user_name/.i3/config"
exec --no-startup-id nm-applet
exec --no-startup-id xsetroot -solid "#000000"

EOF