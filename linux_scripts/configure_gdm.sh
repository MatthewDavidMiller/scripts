#!/bin/bash

# Script to configure gdm

# Specify session for gdm to use
read -r -p "Specify session to use. Example: i3 " session

# Get username
user_name=$(logname)

# Enable gdm
systemctl enable gdm.service

# Enable autologin
cat <<EOF > '/etc/gdm/custom.conf'
# Enable automatic login for user
[daemon]
AutomaticLogin=${user_name}
AutomaticLoginEnable=True

EOF

# Setup default session
cat <<EOF > "/var/lib/AccountsService/users/$user_name"
[User]
Language=
Session=${session}
XSession=${session}

EOF
