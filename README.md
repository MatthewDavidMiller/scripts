# Scripts
This repository contains scripts I have created.

Copyright (c) 2019 Matthew David Miller. All rights reserved.

[Licensed under the MIT License.](https://github.com/MatthewDavidMiller/scripts/blob/stable/LICENSE)

# Windows Scripts:

[batch_process_hard_links.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/batch_process_hard_links.bat) - Simple script to make hard links of all files from where the script is run from.

[configure_windows_10.ps1](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/configure_windows_10.ps1) - Powershell script to configure Windows 10 settings I use such as disabling telemetry, disabling cortana, and configuring the firewall.

[get_file_hash.ps1](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/get_file_hash.ps1) - Powershell script to get the file hashes of all files from where the script is run from.

[printer_restart.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/printer_restart.bat) - Script to restart print spooler and clear temporary files from the spooler.

[robocopy_backup.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/robocopy_backup.bat) - Script to copy a directory to another location.

[tar_batch_process_files.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/tar_batch_process_files.bat) - Places all folders in a tar archive from where the script is run from.

[uninstall_default_applications.ps1](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/uninstall_default_applications.ps1) - Simple powershell script to remove some of the default apps installed in Windows 10.

[view_hard_links.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/view_hard_links.bat) - Simple script to see all the hard links of files from where the script is run from.

[wsl_restart.bat](https://github.com/MatthewDavidMiller/scripts/blob/stable/windows_scripts/wsl_restart.bat) - Simple script to restart Windows Subsystem for Linux.

# Linux Scripts:

# Large Scripts:

[arch_linux_install.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/arch_linux_install.sh) - Bash script to automate my install of Arch Linux.

[debian_server_install.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/debian_server_install.sh) - Bash script to automate the install of debian servers.

[vpn_server_configure.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/vpn_server_configure.sh) - Bash script to automate the configuration of my vpn server.

# Small Scripts:

[apt_package_updates.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/apt_package_updates.sh) - A bash script to update the packages on Debian based distros.

[arch_linux_packages.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/arch_linux_packages.sh) - Simple script to install some packages I use.

[backup_configs.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/backup_configs.sh) - A bash script I wrote to tar the /etc and /home directory.  Used to automate backing up config files.

[configure_gdm.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/configure_gdm.sh) - A bash script to configure gdm.

[configure_hyper_v_guest.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/configure_hyper_v_guest.sh) - Bash script to configure the hyper-v guest.

[configure_i3.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/configure_i3.sh) - A bash script to configure the i3 window manager.

[configure_kvm.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/configure_kvm.sh) - A bash script to configure kvm.

[configure_termite.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/configure_termite.sh) - A bash script to configure the termite terminal emulator.

[connect_smb.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/connect_smb.sh) - A bash script to connect a samba share and automount it.

[delete_logs.py](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/delete_logs.py) - Simple python script to delete some logs files after going over a certain size.

[email_ip_address.py](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/email_ip_address.py) - A simple python script to send an email with the ip address of the device that ran the script.

[email_on_vpn_connections.py](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/email_on_vpn_connections.py) - A python script that it paired with my bash script to send an email when there is a connection on my openvpn server.

[email_on_vpn_connections.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/email_on_vpn_connections.sh) - A bash script that checks the openvpn log file for a certain keyword so I know if a vpn connection was established on my server.

[generate_ssh_keys.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/generate_ssh_key.sh) - A bash script that generates keys as well as authorizes the key for ssh use.

[install_aur_packages.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/install_aur_packages.sh) - Bash script to install aur packages from Arch Linux.

[mount_drives.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/mount_drives.sh) - Bash script to mount drives.  Adds an entry to the fstab.

[network_reconnect_buster.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/network_reconnect_buster.sh) - A bash script that restarts a network interface if it can't ping the gateway.  Utilizes iplink command.

[network_reconnect.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/network_reconnect.sh) - A bash script that restarts a network interface if it can't ping the gateway.  Utilizes ifdown and ifup commands.

[openwrt_create_user.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/openwrt_create_user.sh) - Simple script to create an user in OpenWrt.

[openwrt_install_packages.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/openwrt_install_packages.sh) - Simple script to install some packages in OpenWrt.

[openwrt_restrict_luci_access.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/openwrt_restrict_luci_access.sh) - Simple script to limit access to luci gui as well as redirect http to https.

[secure_ssh_access.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/secure_ssh_access.sh) - A bash script that changes the configuration for ssh to not allow password authentication and enables key based authentication. Also disables root login over ssh.

[setup_wsl_gui.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/setup_wsl_gui.sh) - Simple bash script to setup the xserver in Windows Subsystem for Linux.

[setup_git.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/setup_git.sh) - Bash script to configure git.

[setup_aliases.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/setup_aliases.sh) - Bash script to configure aliases.

[setup_fwupd.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/setup_fwupd.sh) - Bash script to setup fwupd in Arch Linux.

[update_aur_packages.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/update_aur_packages.sh) - Bash script to update aur packages from Arch Linux.

[update_openwrt.sh](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/update_openwrt.sh) - A simple script to update packages in OpenWrt.

[updates.py](https://github.com/MatthewDavidMiller/scripts/blob/stable/linux_scripts/updates.py) - Python script to update packages with the apt-get package manager.
