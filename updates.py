# This script is used to automatically update the Raspberry Pi when used in cron.

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

# MIT License

# Copyright (c) 2019 Matthew David Miller

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
