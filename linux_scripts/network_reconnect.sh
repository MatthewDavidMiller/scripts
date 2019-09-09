#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Script is used to automatically restart interface if the device can't access the gateway.

# Add this cron job to /etc/rc.local
# /bin/bash /usr/local/bin/network_reconnect.sh

# Gateway ip
gateway='10.2.1.1'

# Interface
interface='eth0'

# Log file location
log='/var/log/network_reconnect.sh.log'

# Time to wait before pinging again.
ping_time='300'

# Time to wait after restarting interface.
interface_time='300'

# Define path to commands.

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

while true
do
    if ping "-c2" "${gateway}" > "/dev/null"
        then
            echo "Network is up at the time of $(date)" >> "${log}"
            sleep "${ping_time}"
        else
            # Restart the interface
            echo "Restarting ${interface} at the time of $(date)" >> "${log}"
            ifdown "${interface}"
            sleep "12"
            ifup "${interface}"
            sleep "${interface_time}"
    fi
done