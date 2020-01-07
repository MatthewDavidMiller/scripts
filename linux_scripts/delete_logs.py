# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

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