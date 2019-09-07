#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Add this cron job to /etc/rc.local
# /bin/bash /usr/local/bin/network_reconnect_buster.sh

# Gateway ip
gateway='10.2.1.1'

# Interface
interface='wlan0'

# Log file location
log='/var/log/network_reconnect_buster.sh.log'

# Ping command location
ping="/bin/ping"

# Ip command location
ip="/sbin/ip"

# Sleep command location
sleep="/bin/sleep"

# Echo command location
echo="/bin/echo"

# Date command location
date="/bin/date"

# Date command output
time=$("${date}")

# Ping twice and send output to null saved in a variable
network_status=$("${ping}" -c2 "${gateway}" > /dev/null)

while true; do
    if [ "${network_status}" == 0 ]; then
        "${echo}" "Network is up at the time of ${time}" >> "${log}"
        "${sleep}" 300
    else
        # Restart the interface
        "${echo}" "Restarting ${interface} at the time of ${time}" >> "${log}"
        "${ip}" link set "${interface}" down
        "${sleep}" 5
        "${ip}" link set "${interface}" up
        "${sleep}" 120
    fi
    "${sleep}" 120
done