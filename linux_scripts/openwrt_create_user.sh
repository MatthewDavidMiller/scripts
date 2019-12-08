#!/bin/bash

# Script to add an user in OpenWrt

# Create user
read -r -p "Set username " user_name
useradd $user_name
mkdir /home
mkdir /home/$user_name
passwd $user_name
chown "$user_name" "/home/$user_name"

# Setup sudo
printf '%s\n' "$user_name ALL=(ALL) NOPASSWD:ALL" >> '/etc/sudoers'
