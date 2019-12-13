#!/bin/bash

# Script to to update packages from Arch Linux aur.
# Verify the source for malicious content before using.

# Prompts
read -r -p "Update freefilesync? [y/N] " response1
read -r -p "Update spotify? [y/N] " response3

# Get username
user_name=$(logname)

# Install packages
pacman -S --noconfirm --needed base-devel

# Update freefilesync
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        cd "/home/${user_name}/aur/freefilesync" || exit
        git pull
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to update? [y/N] " response2
        if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
            then
                sudo -u ${user_name} makepkg -si
        fi
fi

# Update spotify
if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        cd "/home/${user_name}/aur/spotify" || exit
        git pull
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to update? [y/N] " response4
        if [[ "${response4}" =~ ^([yY][eE][sS]|[yY])+$ ]]
            then
                sudo -u ${user_name} makepkg -si
        fi
fi
