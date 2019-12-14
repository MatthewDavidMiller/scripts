#!/bin/bash

# Script to configure termite terminal in Arch Linux
# Does not need to be executed as root.

# Get username
user_name=$(logname)

# Install packages
sudo pacman -S --noconfirm --needed termite

# Setup termite config
sudo mkdir "/home/${user_name}/.config"
sudo mkdir "/home/${user_name}/.config/termite"
sudo bash -c "cat <<EOF > \"/home/${user_name}/.config/termite/config\"

[options]
font = Monospace 16
scrollback_lines = 10000

[colors]

# If unset, will reverse foreground and background
highlight = #2f2f2f

# Colors from color0 to color254 can be set
color0 = #000000 

[hints]

EOF"
