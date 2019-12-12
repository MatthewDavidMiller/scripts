#!/bin/bash

# Script to to update packages from Arch Linux aur.
# Verify the source for malicious content before using.

# Get username
user_name=$(logname)

# Install packages
pacman -S --needed base-devel

# Update freefilesync
read -r -p "Update freefilesync? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        cd "/home/${user_name}/aur/freefilesync" || exit
        git pull
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to update? [y/N] " response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
            then
                sudo -u ${user_name} makepkg -si
        fi
fi
