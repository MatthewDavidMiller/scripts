#!/bin/bash

# Script to backup the /etc directory into a tar archive.
# Add * 0 * * 1 bash /usr/local/bin/backup_configs.sh & to cron

function check_script() {
    # Script name
    script_name='backup_configs.sh'
    # Log file location
    log='/var/log/backup_configs.sh.log'
    # Check if script is already running.
    if pidof -x "${script_name}" -o $$ >/dev/null; then
        echo "Process already running" >>"${log}"
        exit 1
    fi
}

function backup_configs() {
    # Define path to commands.
    PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

    # Get username
    user_name=$(logname)

    # Output date into a variable
    time=$(date +"%m_%d_%Y")

    # Create tar archive compressed with gzip
    tar --exclude 'config_backup_*' --exclude 'home_backup*' -czf "/home/$user_name/config_backup_$time.tar.gz" '/etc'
    tar --exclude 'config_backup_*' --exclude 'home_backup*' -czf "/home/$user_name/home_backup_$time.tar.gz" '/home'

    # Delete backups older than 30 days
    find "/home/$user_name" -name 'config_backup_*.tar.gz' -mtime +30 -delete
    find "/home/$user_name" -name 'home_backup_*.tar.gz' -mtime +30 -delete
}

# Call functions
check_script
backup_configs
