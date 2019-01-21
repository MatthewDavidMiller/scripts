#!/bin/bash

# The script is a work in progress and some parts of the script may not work.

# This script is used to email the admin when a VPN connection is established on the VPN server.

# Run the script as root

# Variables to edit based on configuration.
	# Variable for words to search for in the log file.
	search_for_these_words="Connection"
	# File to search through.
	file_to_search_for_words="/var/log/openvpn.log"
	# Subject Header of email to send.
	message_subject="Connection Established on VPN"
	# Email address to send the email to.
	email_to_send_to="matthewdavidmiller1@gmail.com"
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
		"${printf_command}" "${new_connection_established}" | "${mail_command}" -s "${message_subject}" "${emailtosendto}"
	fi
	done
	)

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
