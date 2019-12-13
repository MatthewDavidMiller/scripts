#!/bin/bash

# Install samba
pacman -S --noconfirm --needed samba

# Make /mnt directory
mkdir '/mnt'

# Script to connect and mount a smb share
read -r -p "Mount a samba share? [y/N] " response
while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    do
    # Prompts
    # Share location
    read -r -p "Specify share location. Example'//matt-nas.lan/matt_files': " share
    # Mount point location
    read -r -p "Specify mount location. Example'/mnt/matt-nas': " mount_location
    # Username
    read -r -p "Specify Username. Example'matthew': " username
    # Password
    read -r -p "Specify Password. Example'password': " password

    # Make directory to mount the share at
    mkdir "${mount_location}"

    # Automount smb share
    printf '%s\n' "${share} ${mount_location} cifs rw,noauto,x-systemd.automount,_netdev,user,username=${username},password=${password} 0 0" >> '/etc/fstab'
    printf '%s\n' ''

    # Mount another disk
    read -r -p "Do you want to mount another samba share? [y/N] " response
    if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]
        then
            printf '%s\n' '' >> '/etc/fstab'
            exit
    fi
done
