# Copyright (c) 2019 Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

#!/bin/bash

# This script is used to email the admin when a VPN connection is established on the VPN server.

# Run the script as root

# Variables to edit based on configuration.

# Variable for words to search for in the log file.
search_for_these_words="Connection Initiated"

# File to search through.
file_to_search_for_words="/var/log/openvpn.log"

# Subject Header of email to send.
message_subject="Connection Established on VPN"

# Tail command location.
tail_command="/usr/bin/tail"

# Printf command location.
printf_command="/usr/bin/printf"

# Grep command location.
grep_command="/bin/grep"

# Mail command location.
mail_command="/usr/bin/mail"

# Script

"${tail_command}" -f -c 0 "${file_to_search_for_words}" | (while true ; do
	read -r new_connection_established
	"${printf_command}" "${new_connection_established}" | "${grep_command}" -q "${search_for_these_words}"
if [ "$?" = "0" ] ; then
	"${printf_command}" "${new_connection_established}" | "${mail_command}" -s "${message_subject}" matthewdavidmiller1@gmail.com
fi
done
)