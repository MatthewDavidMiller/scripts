# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

# This script is used to automatically update a Debian based distro when used in cron.

# Run the script as root

# Libraries to import.

import subprocess

# Variables to edit based on configuration.

words_to_look_for = '0 upgraded'
apt_get_command = '/usr/bin/apt-get'
reboot_command = '/sbin/reboot'

# Prints date

date = subprocess.check_output(["date", "+'%m/%d/%Y %H:%M:%S'"])

print(date)

# Update the applications

subprocess.check_output([apt_get_command, "update"])
upgrade_packages = subprocess.Popen([apt_get_command, "upgrade", "-y"], stdout=subprocess.PIPE)
update_output = upgrade_packages.stdout.read()
if bytes(words_to_look_for, encoding='utf-8') not in update_output:
    subprocess.check_output([apt_get_command, "autoremove", "--purge"])
    subprocess.check_output([apt_get_command, "autoclean"])
    subprocess.check_output([reboot_command])
else:
    print('No updates available.')