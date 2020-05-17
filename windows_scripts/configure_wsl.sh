#!/bin/bash
# Script to configure Windows Subsystem for Linux

# Get needed scripts
apt-get update
apt-get install wget
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'
wget -O 'wsl_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/windows_scripts/wsl_scripts.sh'

# Source functions
source wsl_scripts.sh
source linux_scripts.sh

# Call functions
wsl_install_packages
get_username_second_method
wsl_setup_gui
wsl_configure_bashrc
wsl_mount_network_drives
wsl_copy_ssh_keys "${user_name}"
configure_git "${user_name}"
