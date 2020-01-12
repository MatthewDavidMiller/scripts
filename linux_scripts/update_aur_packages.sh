#!/bin/bash

# Script to to update packages from Arch Linux aur.
# Verify the source for malicious content before using.
# Does not need to be executed as root.

# Prompts
read -r -p "Update freefilesync? [y/N] " response1
read -r -p "Update spotify? [y/N] " response3
read -r -p "Update vscode? [y/N] " response5

# Get username
user_name=$(logname)

# Install packages
sudo pacman -S --noconfirm --needed base-devel

# Update freefilesync
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    cd "/home/${user_name}/aur/freefilesync" || exit
    git clean -df
    git checkout -- .
    sudo git fetch
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    sudo git diff master...origin/master
    read -r -p "Ready to update? [y/N] " response2
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        sudo git pull
        makepkg -sirc
    fi
fi

# Update spotify
if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    read -r -p "Choose the latest key. Press enter to continue: "
    gpg --keyserver 'hkp://keyserver.ubuntu.com' --search-key 'Spotify Public Repository Signing Key'
    cd "/home/${user_name}/aur/spotify" || exit
    git clean -df
    git checkout -- .
    sudo git fetch
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    sudo git diff master...origin/master
    read -r -p "Ready to update? [y/N] " response4
    if [[ "${response4}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        sudo git pull
        makepkg -sirc
    fi
fi

# Update vscode
if [[ "${response5}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    cd "/home/${user_name}/aur/vscode" || exit
    git clean -df
    git checkout -- .
    sudo git fetch
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    sudo git diff master...origin/master
    read -r -p "Ready to update? [y/N] " response6
    if [[ "${response6}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        sudo git pull
        makepkg -sirc
    fi
fi
