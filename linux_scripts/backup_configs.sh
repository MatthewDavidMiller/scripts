#!/bin/bash

# Script to backup the /etc directory into a tar archive.
# Add * 0 * * 1 bash /usr/local/bin/backup_configs.sh & to cron

# Output date into a variable
time=$(date +"%m_%d_%Y")

# Create tar archive compressed with gzip
tar -czf "$HOME/config_backup_$time.tar.gz" '/etc'
