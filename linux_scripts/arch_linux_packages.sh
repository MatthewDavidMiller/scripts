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
        pacman -S i3 dmenu
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