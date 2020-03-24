#!/bin/bash

# Script to mount a disk
# Does not need to be executed as root.

function mount_drives() {
    # Instal linux-utils
    sudo pacman -S --noconfirm --needed util-linux

    # Make /mnt directory
    sudo mkdir '/mnt'

    read -r -p "Mount a disk? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do

        #See disks
        lsblk -f

        # Prompts
        # Disk location
        read -r -p "Specify disk location. Example'/dev/sda1': " disk1
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_backup': " mount_location
        #Specify disk type
        read -r -p "Specify disk type. Example'ntfs': " disk_type

        # Get uuid
        uuid="$(sudo blkid -o value -s UUID "${disk1}")"

        # Make directory to mount the disk at
        sudo mkdir "${mount_location}"

        # Automount smb share
        sudo bash -c "printf '%s\n' \"UUID=${uuid} ${mount_location} ${disk_type} rw,noauto,x-systemd.automount 0 0\" >> '/etc/fstab'"

        # Mount another disk
        read -r -p "Do you want to mount another disk? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            sudo bash -c "printf '%s\n' '' >> '/etc/fstab'"
            exit
        fi
    done
}

# Call functions
mount_drives
