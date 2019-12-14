#!/bin/bash

# Script to configure gdm
# Does not need to be executed as root.

# Specify session for gdm to use
read -r -p "Specify session to use. Example: i3 " session

# Get username
user_name=$(logname)

# Enable gdm
sudo systemctl enable gdm.service

# Enable autologin
sudo bash -c "cat <<EOF > '/etc/gdm/custom.conf'
# Enable automatic login for user
[daemon]
AutomaticLogin=${user_name}
AutomaticLoginEnable=True

EOF"

# Setup default session
sudo bash -c "cat <<EOF > \"/var/lib/AccountsService/users/$user_name\"
[User]
Language=
Session=${session}
XSession=${session}

EOF"
