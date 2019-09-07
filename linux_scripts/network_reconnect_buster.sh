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
function ping
{
    command "/bin/ping" "$1" "$2"
}

# Ip command location
function ip
{
    command "/sbin/ip" "$1" "$2" "$3" "$4"
}

# Sleep command location
function sleep
{
    command "/bin/sleep" "$1"
}

# Echo command location
function echo
{
    command "/bin/echo" "$1"
}

# Date command location
function date
{
    command "/bin/date"
}

while true
do
    if "ping" -c2 "${gateway}" > /dev/null
        then
            "echo" "Network is up at the time of $(date)" >> "${log}"
            "sleep" 300
        else
            # Restart the interface
            "echo" "Restarting ${interface} at the time of $(date)" >> "${log}"
            "ip" link set "${interface}" down
            "sleep" 5
            "ip" link set "${interface}" up
            "sleep" 300
    fi
done