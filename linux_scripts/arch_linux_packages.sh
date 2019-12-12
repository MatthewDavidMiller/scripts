#!/bin/bash

# Script to install packages

read -r -p "Install gnome desktiop environment? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S gnome
fi

read -r -p "Install i3 windows manager? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S i3-gaps i3-bar i3-status dmenu
fi

read -r -p "Install blender? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S blender
fi

read -r -p "Install gimp? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S gimp
fi

read -r -p "Install libreoffice? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S libreoffice-fresh
fi

read -r -p "Install vscode? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S code
fi

read -r -p "Install git? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S git
fi

read -r -p "Install putty? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        pacman -S putty
fi