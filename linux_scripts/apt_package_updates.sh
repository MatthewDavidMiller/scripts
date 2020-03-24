#!/bin/bash

# Used to automatically update a Debian based distro.
# Run in cron or rc.local

# Define path to commands.
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

function apt_update_packages() {
    # Variables
    temp='/tmp/apt_package_updates_temp'
    words_to_look_for='0 upgraded'
    log='/var/log/apt_package_updates.log'

    # Create temp file
    touch "${temp}"

    apt-get update
    apt-get upgrade -y |& tee -a "${temp}"
    if grep -qi "${words_to_look_for}" "${temp}"; then
        printf '%s\n' 'No updates.' >>"${log}"
        rm -rf "${temp}"
    else
        printf '%s\n' 'Updated' >>"${log}"
        apt-get autoremove --purge
        apt-get autoclean
        rm -rf "${temp}"
        reboot
    fi
}

# Call functions
apt_update_packages
