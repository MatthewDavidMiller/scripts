#!/bin/bash
# Does not need to be executed as root.

function connect_smb() {
    # Install samba
    sudo pacman -S --noconfirm --needed samba

    # Make /mnt directory
    sudo mkdir '/mnt'

    # Script to connect and mount a smb share
    read -r -p "Mount a samba share? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        # Prompts
        # Share location
        read -r -p "Specify share location. Example'//matt_files.miller.lan/matt_files': " share
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_files': " mount_location
        # Username
        read -r -p "Specify Username. Example'matthew': " username
        # Password
        read -r -p "Specify Password. Example'password': " password

        # Make directory to mount the share at
        sudo mkdir "${mount_location}"

        # Automount smb share
        sudo bash -c "printf '%s\n' \"${share} ${mount_location} cifs rw,noauto,x-systemd.automount,_netdev,user,username=${username},password=${password} 0 0\" >> '/etc/fstab'"

        # Mount another disk
        read -r -p "Do you want to mount another samba share? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            sudo bash -c "printf '%s\n' '' >> '/etc/fstab'"
            exit
        fi
    done
}

# Call functions
connect_smb
