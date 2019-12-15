#!/bin/bash

# Script to to install packages from Arch Linux aur.
# Verify the source for malicious content before using.
# Does not need to be executed as root. makepkg does not work if running as root.

# Prompts
read -r -p "Install freefilesync? [y/N] " response1
read -r -p "Install spotify? [y/N] " response3
read -r -p "Install vscode? [y/N] " response5

# Get username
user_name=$(logname)

# Install packages
sudo pacman -S --noconfirm --needed base-devel

# Create a directory to use for compiling aur packages
sudo mkdir "/home/${user_name}/aur"
sudo chown "${user_name}" "/home/${user_name}/aur"
sudo chmod 744 "/home/${user_name}/aur"

# Install freefilesync
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    sudo mkdir "/home/${user_name}/aur/freefilesync"
    sudo git clone 'https://aur.archlinux.org/freefilesync.git' "/home/${user_name}/aur/freefilesync"
    sudo chown -R "${user_name}" "/home/${user_name}/aur/freefilesync"
    sudo chmod -R 744 "/home/${user_name}/aur/freefilesync"
    cd "/home/${user_name}/aur/freefilesync" || exit
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    less PKGBUILD
    read -r -p "Ready to install? [y/N] " response2
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        makepkg -sirc
    fi
fi

# Install spotify
if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    sudo mkdir "/home/${user_name}/aur/spotify"
    sudo git clone 'https://aur.archlinux.org/spotify.git' "/home/${user_name}/aur/spotify"
    sudo chown -R "${user_name}" "/home/${user_name}/aur/spotify"
    sudo chmod -R 744 "/home/${user_name}/aur/spotify"
    read -r -p "Choose the latest key. Press enter to continue: "
    gpg --keyserver 'hkp://keyserver.ubuntu.com' --search-key 'Spotify Public Repository Signing Key'
    cd "/home/${user_name}/aur/spotify" || exit
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    less PKGBUILD
    read -r -p "Ready to install? [y/N] " response4
    if [[ "${response4}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        makepkg -sirc
    fi
fi

# Install vscode
if [[ "${response5}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    sudo mkdir "/home/${user_name}/aur/vscode"
    sudo git clone 'https://aur.archlinux.org/visual-studio-code-bin.git' "/home/${user_name}/aur/vscode"
    sudo chown -R "${user_name}" "/home/${user_name}/aur/vscode"
    sudo chmod -R 744 "/home/${user_name}/aur/vscode"
    cd "/home/${user_name}/aur/vscode" || exit
    read -r -p "Check the contents of the files before installing. Press enter to continue: "
    less PKGBUILD
    read -r -p "Ready to install? [y/N] " response6
    if [[ "${response6}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        makepkg -sirc
    fi
fi
