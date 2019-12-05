#!/bin/bash

# Script to backup the /etc directory into a tar archive.
# Add * 0 * * 1 bash /usr/local/bin/backup_configs.sh & to cron

user_name=$(who am i | awk '{print $1}')

# Output date into a variable
time=$(date +"%m_%d_%Y")

# Create tar archive compressed with gzip
tar -czf "/home/$user_name/config_backup_$time.tar.gz" '/etc'
