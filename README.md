# Scripts
This repository contains small scripts I have created.

Copyright (c) Matthew David Miller. All rights reserved.

[Licensed under the MIT License.](LICENSE)

## Windows Scripts

- [7z Batch Compress](windows_scripts/7z_batch_compress.ps1) - PowerShell script to batch compress files and folders into a 7z archive.
- [Batch Process Hard Links](windows_scripts/batch_process_hard_links.bat) - Batch script to create hard links for all files in the current directory.
- [Get File Hashes](windows_scripts/get_file_hashes.ps1) - PowerShell script to compute file hashes.
- [Printer Restart](windows_scripts/printer_restart.bat) - Batch script to restart the print spooler and clear temporary spooler files.
- [Robocopy Backup](windows_scripts/robocopy_backup.bat) - Batch script to copy a directory to another location.
- [Run PowerShell Scripts](windows_scripts/run_powershell_script.bat) - Batch script to execute a PowerShell script without changing the system's execution policy.
- [Tar Batch Process Files](windows_scripts/tar_batch_process_files.bat) - Batch script to archive all folders in the current directory into tar files.
- [View Hard Links](windows_scripts/view_hard_links.bat) - Batch script to display hard links for files in the current directory.
- [WSL Restart](windows_scripts/wsl_restart.bat) - Batch script to restart Windows Subsystem for Linux.

## Linux Scripts

- [Apt Package Updates](linux_scripts/apt_package_updates.sh) - Bash script to update packages on Debian-based distributions.
- [Backup Configs](linux_scripts/backup_configs.sh) - Bash script to archive the /etc and /home directories for config backups.
- [Delete Logs](linux_scripts/delete_logs.py) - Python script to delete log files exceeding a specified size.
- [Email IP Address](linux_scripts/email_ip_address.py) - Python script to email the device's IP address.
- [Email on VPN Connections](linux_scripts/email_on_vpn_connections.py) - Python script to send emails on VPN events.
- [Email on VPN Connections](linux_scripts/email_on_vpn_connections.sh) - Bash script to monitor OpenVPN logs and send emails on specific keywords.
- [Log Rotate](linux_scripts/log_rotate_setup.sh) - Bash script to configure log rotation.
- [Network Reconnect](linux_scripts/network_reconnect.sh) - Bash script to restart a network interface if the gateway is unreachable.
- [Rsync Backups](linux_scripts/rsync_backups.sh) - Bash script to perform file backups using rsync.
- [Updates](linux_scripts/updates.py) - Python script to update packages via apt-get.

## Omarchy Scripts

- [Backup OpenSnitch](linux_scripts/Omarchy/backup_opensnitch.sh) - Bash script to backup OpenSnitch rules.
- [Controller 8bitdo Setup](linux_scripts/Omarchy/controller_8bitdo_setup.sh) - Bash script to configure an 8Bitdo controller with D-input.
- [Gaming Setup](linux_scripts/Omarchy/gaming_setup.sh) - Bash script to set up an optimal gaming environment for Proton on Omarchy Linux (Arch-based).
- [Local LLM Setup](linux_scripts/Omarchy/local_llm_setup.sh) - Bash script to install and configure Ollama with ROCm for local large language models.
- [Network Tweaks](linux_scripts/Omarchy/network_tweaks.sh) - Bash script for high-bandwidth TCP optimizations for 2.5Gbps+ NICs on Arch Linux.
- [Security Setup](linux_scripts/Omarchy/security_setup.sh) - Bash script for initial setup of OpenSnitch, Bubblewrap, Bubblejail, and UFW.
