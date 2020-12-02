# Scripts
This repository contains small scripts I have created.

Copyright (c) Matthew David Miller. All rights reserved.

[Licensed under the MIT License.](LICENSE)

## Windows Scripts:

[7z Batch Compress](windows_scripts/7z_batch_compress.ps1) - Powershell script to batch compress files and folders to a 7z archive.

[Batch Process Hard Links](windows_scripts/batch_process_hard_links.bat) - Simple script to make hard links of all files from where the script is run from.

[Get File Hashes](windows_scripts/get_file_hashes.ps1) - PowerShell script to get the hash of a file.

[Printer Restart](windows_scripts/printer_restart.bat) - Script to restart print spooler and clear temporary files from the spooler.

[Robocopy Backup](windows_scripts/robocopy_backup.bat) - Script to copy a directory to another location.

[Run PowerShell Scripts](windows_scripts/robocopy_backup.bat) - Script to run a PowerShell script without modifying the execution policy of the device.

[Tar Batch Process Files](windows_scripts/tar_batch_process_files.bat) - Places all folders in a tar archive from where the script is run from.

[View Hard Links](windows_scripts/view_hard_links.bat) - Simple script to see all the hard links of files from where the script is run from.

[WSL Restart](windows_scripts/wsl_restart.bat) - Simple script to restart Windows Subsystem for Linux.

## Linux Scripts:

[Apt Package Updates](linux_scripts/apt_package_updates.sh) - A bash script to update the packages on Debian based distros.

[Backup Configs](linux_scripts/backup_configs.sh) - A bash script to tar the /etc and /home directory.  Used to automate backing up config files.

[Delete Logs](linux_scripts/delete_logs.py) - Simple python script to delete some logs files after going over a certain size.

[Email IP Address](linux_scripts/email_ip_address.py) - A simple python script to send an email with the ip address of the device that ran the script.

[Send Email](linux_scripts/email_on_vpn_connections.py) - Python script to send out an email.

[Email on VPN Connections](linux_scripts/email_on_vpn_connections.sh) - A bash script that checks the openvpn log file for a certain keyword and sends out an email.

[Log Rotate](linux_scripts/log_rotate_setup.sh) - A bash script to configure log rotate.

[Network Reconnect](linux_scripts/network_reconnect.sh) - A bash script that restarts a network interface if it can't ping the gateway.

[Rsync Backups](linux_scripts/rsync_backups.sh) - Bash script to backup files with rsync.

[Updates](linux_scripts/updates.py) - Python script to update packages with the apt-get package manager.
