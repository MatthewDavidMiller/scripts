#!/bin/bash

# Script to connect and mount a smb share

# Variables to edit
# Share location
share='//matt-nas.lan/matt_files'
# Mount point location
mount_location='/mnt/matt-nas'
# Username
username='matthew'
# Password
password='password'

# Install samba
pacman -S samba

# Make directory to mount the share at
mkdir "${mount_location}"

# Automount smb share
printf '%s\n' "${share} /mnt/matt-nas cifs rw,noauto,x-systemd.automount,_netdev,user,username=${username},password=${password} 0 0" >> '/etc/fstab'
