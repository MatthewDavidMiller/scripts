#!/bin/bash
# Rsync script for backups

user_name=$(logname)
source_directory='/mnt/matt_files'
destination_directory="/home/${user_name}/laptop_backup"

function laptop_backup() {
    rsync -av --exclude 'games/windows' --exclude 'gog_library' --exclude 'indiegala_library' --exclude 'itch_library' --exclude 'steam_library' --exclude 'mods' "${source_directory}" "${destination_directory}"
}

# Call functions
laptop_backup
