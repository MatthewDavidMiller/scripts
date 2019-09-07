#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# This script is used to email the admin when a VPN connection is established on the VPN server.
# Run the script as root
# Add to /etc/rc.local
# /bin/bash /usr/local/bin/email_on_vpn_connections.sh

# Variables to edit based on configuration.

# Variable for words to search for in the log file.
search_for_these_words="Connection Initiated"

# File to search through.
file_to_search_for_words="/var/log/openvpn.log"

# Subject Header of email to send.
message_subject="Connection Established on VPN"

# Tail command location.
function tail
{
	command "/usr/bin/tail" "$1" "$2" "$3" "$4"
}

# Printf command location.
function printf
{
	command "/usr/bin/printf" "$1"
}

# Grep command location.
function grep
{
	command "/bin/grep" "$1" "$2"
}

# Mail command location.
function mail
{
	command "/usr/bin/mail" "$1" "$2" "$3"
}

# Sleep command location
function sleep
{
	command "/bin/sleep" "$1"
}

# Time to wait after sending an email in seconds
time='720'

# Script

"tail" -f -c 0 "${file_to_search_for_words}" | (while true
do
	read -r new_connection_established
		if "printf" "${new_connection_established}" | "grep" -q "${search_for_these_words}"
		then
			"printf" "${new_connection_established}" | "mail" -s "${message_subject}" matthewdavidmiller1@gmail.com
			"sleep" "${time}"
		fi
done
)