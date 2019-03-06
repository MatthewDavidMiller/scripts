# Simple script to clear log files I have setup.

# Libraries to import.

import subprocess

# Variables to edit based on configuration.

log_1 = '/home/matthew/logs/update.log'
log_2 = '/home/matthew/logs/send_ip_address.log'
log_3 = '/home/matthew/logs/freedns_matthewmiller_us_to.log'
log_4 = '/home/matthew/logs/get_email_from_vpn_connections.log'
find_command = '/usr/bin/find'

# Prints date

date = subprocess.check_output(['date', '+"%m/%d/%Y %H:%M:%S"'])

print(date)

# Script to delete logs

subprocess.check_output([find_command, log_1, '-size', '40M', '-delete'])
subprocess.check_output([find_command, log_2, '-size', '40M', '-delete'])
subprocess.check_output([find_command, log_3, '-size', '40M', '-delete'])
subprocess.check_output([find_command, log_4, '-size', '40M', '-delete'])

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
