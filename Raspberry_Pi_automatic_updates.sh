#!/bin/bash

# This script is used to automatically update the Raspberry Pi when used in cron.

# Run the script as root

/usr/bin/apt-get update && /usr/bin/apt-get upgrade -y
/usr/bin/rpi-update
/usr/bin/apt-get autoremove --purge
/usr/bin/apt-get autoclean
/sbin/reboot