#!/bin/bash

# Define the backup directory (change this to your desired path)
BACKUP_DIR="/path/to/your/backup/directory"

# Create a timestamped subdirectory for this backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/opensnitch_backup_$TIMESTAMP"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_PATH"

# Copy OpenSnitch rules (assuming default location)
cp -r ~/.config/opensnitch/rules/* "$BACKUP_PATH"

echo "OpenSnitch rules backed up to $BACKUP_PATH"
