# This script is used to automatically update the Raspberry Pi when used in cron.

# Run the script as root

# Libraries to import.

import subprocess

# Variables to edit based on configuration.

script_temp_folder = '/tmp/scripttemp'
script_temp_file = '/tmp/scripttemp/temp.txt'
words_to_look_for = '0 upgraded'
mkdir_command = '/bin/mkdir'
touch_command = '/usr/bin/touch'
apt_get_command = '/usr/bin/apt-get'
tee_command = '/usr/bin/tee'
grep_command = '/bin/grep'
rm_command = '/bin/rm'
reboot_command = '/sbin/reboot'

# Create a temporary Directory

subprocess.check_output([mkdir_command, "-p", script_temp_folder])
subprocess.check_output([touch_command, script_temp_file])

# Update the applications

subprocess.check_output([apt_get_command, "update"])
subprocess.check_output([apt_get_command, "upgrade", "-y"]) | subprocess.check_output([tee_command, "-a", script_temp_file])
grep_output = subprocess.check_output([grep_command, "-qi", words_to_look_for, script_temp_file])
if grep_output == False:
    subprocess.check_output([apt_get_command, "autoremove", "--purge"])
    subprocess.check_output([apt_get_command, "autoclean"])
    subprocess.check_output([rm_command, "-rf", script_temp_folder])
    subprocess.check_output([reboot_command])

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
