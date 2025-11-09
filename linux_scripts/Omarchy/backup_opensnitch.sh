#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the backup directory (use first argument or default path)
BACKUP_DIR="${1:-/path/to/your/backup/directory}"

# Validate that BACKUP_DIR is provided and is a valid path
if [[ -z "$BACKUP_DIR" ]]; then
    echo "Error: BACKUP_DIR not specified. Usage: $0 <backup_directory>"
    exit 1
fi

# Create a timestamped subdirectory for this backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/opensnitch_backup_$TIMESTAMP"

# Create the backup directory if it doesn't exist, with error check
if ! mkdir -p "$BACKUP_PATH"; then
    echo "Error: Failed to create backup directory $BACKUP_PATH"
    exit 1
fi

# Copy OpenSnitch rules from the correct location, with error check
if ! sudo cp -r /etc/opensnitchd/rules/* "$BACKUP_PATH"; then
    echo "Error: Failed to copy OpenSnitch rules to $BACKUP_PATH"
    exit 1
fi

# Fix permissions and ownership to match the parent directory
sudo chmod --reference="$BACKUP_DIR" "$BACKUP_PATH"
sudo chown --reference="$BACKUP_DIR" "$BACKUP_PATH"

echo "OpenSnitch rules backed up to $BACKUP_PATH"
