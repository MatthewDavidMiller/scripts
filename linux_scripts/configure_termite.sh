#!/bin/bash

# Script to configure i3 window manager in Arch Linux

# Get username
user_name=$(logname)

# Install packages
pacman -S --noconfirm --needed termite

# Setup termite config
mkdir "/home/${user_name}/.config"
mkdir "/home/${user_name}/.config/termite"
cat <<EOF > "/home/${user_name}/.config/termite/config"

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
