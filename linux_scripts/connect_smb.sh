#!/bin/bash

# Script to connect and mount a smb share

# Variables to edit
# Share location
read -r -p "Specify share location. Example'//matt-nas.lan/matt_files': " share
# Mount point location
read -r -p "Specify mount location. Example'/mnt/matt-nas': " mount_location
# Username
read -r -p "Specify Username. Example'matthew': " username
# Password
read -r -p "Specify Password. Example'password': " password

# Install samba
pacman -S --needed samba

# Make directory to mount the share at
mkdir '/mnt'
mkdir "${mount_location}"

# Automount smb share
printf '%s\n' "${share} /mnt/matt-nas cifs rw,noauto,x-systemd.automount,_netdev,user,username=${username},password=${password} 0 0" >> '/etc/fstab'
