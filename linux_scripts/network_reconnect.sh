# Copyright (c) 2019 Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

#!/bin/bash
# Add this cron job to /etc/crontab
# */2 *   * * *   root    /bin/bash /usr/local/bin/network_reconnect.sh

# Gateway ip
gateway='10.2.1.1'

# Interface
interface='eth0'

# Log file location
log='/var/log/network_reconnect.sh.log'

# Ping command location
ping="/bin/ping"

# Ifdown command location
ifdown="/sbin/ifdown"

# Ifup command location
ifup="/sbin/ifup"

# Sleep command location
sleep="/bin/sleep"

# Echo command location
echo="/bin/echo"

# Date command location
date="/bin/date"

# Date command output
time="$(date)"

# Ping twice and send output to null
${ping} -c2 ${gateway} > /dev/null

if [ $? != 0 ]
then
    # Restart the interface
    ${echo} "Restarting ${interface} at the time of ${time}" >> ${log}
    ${ifdown} ${interface}
    ${sleep} 5
    ${ifup} ${interface}
    ${sleep} 60
else
    ${echo} "Network is up at the time of ${time}" >> ${log}
fi