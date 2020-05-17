#!/bin/bash
# Script to configure Windows Subsystem for Linux

# Get needed scripts
wget -O 'linux_scripts.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/linux_scripts.sh'

# Source functions
source wsl_scripts.sh
source linux_scripts.sh

# Call functions
get_username_second_method
wsl_setup_gui
wsl_configure_bashrc
wsl_mount_network_drives
copy_ssh_keys
wsl_install_packages
configure_git "${user_name}"
