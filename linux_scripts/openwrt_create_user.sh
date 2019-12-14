#!/bin/bash

# Script to add an user in OpenWrt
# Does not need to be executed as root.

# Create user
read -r -p "Set username " user_name
sudo useradd "${user_name}"
mkdir '/home'
mkdir "/home/${user_name}"
sudo passwd "${user_name}"
sudo chown "${user_name}" "/home/${user_name}"

# Setup sudo
sudo bash -c "printf '%s\n' \"${user_name} ALL=(ALL) ALL\" >> '/etc/sudoers'"
