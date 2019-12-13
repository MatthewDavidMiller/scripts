#!/bin/bash

# Script to to install packages from Arch Linux aur.
# Verify the source for malicious content before using.

# Prompts
read -r -p "Install freefilesync? [y/N] " response1

# Get username
user_name=$(logname)

# Install packages
pacman -S --noconfirm --needed base-devel

# Create a directory to use for compiling aur packages
mkdir "/home/${user_name}/aur"
chown "${user_name}" "/home/${user_name}/aur"
chmod 744 "/home/${user_name}/aur"

# Install freefilesync
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        mkdir "/home/${user_name}/aur/freefilesync"
        git clone 'https://aur.archlinux.org/freefilesync.git' "/home/${user_name}/aur/freefilesync"
        chown -R "${user_name}" "/home/${user_name}/aur/freefilesync"
        chmod -R 744 "/home/${user_name}/aur/freefilesync"
        cd "/home/${user_name}/aur/freefilesync" || exit
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to install? [y/N] " response2
        if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
            then
                sudo -u ${user_name} makepkg -si
        fi
fi
