#!/bin/bash

# Script to setup serial client in linux
# Does not need to be executed as root.

function configure_serial() {
    # Get username
    user_name=$(logname)

    # Install putty
    sudo pacman -S --noconfirm --needed putty

    # Add user to uucp group
    sudo gpasswd -a "${user_name}" uucp
}

# Call functions
configure_serial
