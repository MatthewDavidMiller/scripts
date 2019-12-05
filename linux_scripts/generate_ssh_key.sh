#!/bin/bash

# Script to generate a ssh key

user_name=$(who am i | awk '{print $1}')

# Generate an ecdsa 521 bit key
ssh-keygen -f "/home/$user_name/ssh_key" -t ecdsa -b 521

# Authorize the key for use with ssh
mkdir "/home/$user_name/.ssh"
chmod 700 "/home/$user_name/.ssh"
touch "/home/$user_name/.ssh/authorized_keys"
chmod 600 "/home/$user_name/.ssh/authorized_keys"
cat "/home/$user_name/ssh_key.pub" >> "/home/$user_name/.ssh/authorized_keys"
chown -R "$user_name" "/home/$user_name"
