#!/bin/bash

# Script to add an user in OpenWrt


# Create user
read -r -p "Set username " user_name
printf '%s\n' "$user_name:x:700:100:$user_name:/home/$user_name:/bin/ash" >> '/etc/passwd'
mkdir /home
mkdir /home/$user_name
passwd $user_name

# Setup sudo
printf '%s\n' "${user_name} ALL=(ALL) NOPASSWD:ALL" >> '/etc/sudoers'
