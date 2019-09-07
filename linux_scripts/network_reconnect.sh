#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Add this cron job to /etc/rc.local
# /bin/bash /usr/local/bin/network_reconnect.sh

# Gateway ip
gateway='10.2.1.1'

# Interface
interface='eth0'

# Log file location
log='/var/log/network_reconnect.sh.log'

# Ping command location
function ping
{
    command "/bin/ping" "$1" "$2"
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

# Ifdown command location
function ifdown
{
    command "/sbin/ifdown" "$1"
}

# Ifup command location
function ifup
{
    command "/sbin/ifup" "$1"
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
            "ifdown" "${interface}"
            "sleep" 5
            "ifup" "${interface}"
            "sleep" 120
    fi
done