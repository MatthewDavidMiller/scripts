#!/bin/bash

# Script to generate a ssh key

# Prompts
read -r -p "Generate ecdsa key? [y/N] " response1
read -r -p "Generate rsa key? [y/N] " response2
read -r -p "Dropbear used? [y/N] " response3

user_name=$(logname)

# Generate ecdsa key
if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Generate an ecdsa 521 bit key
        ssh-keygen -f "/home/$user_name/ssh_key" -t ecdsa -b 521
fi

# Generate rsa key
if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Generate an rsa 4096 bit key
        ssh-keygen -f "/home/$user_name/ssh_key" -t rsa -b 4096
fi

# Authorize the key for use with ssh
mkdir "/home/$user_name/.ssh"
chmod 700 "/home/$user_name/.ssh"
touch "/home/$user_name/.ssh/authorized_keys"
chmod 600 "/home/$user_name/.ssh/authorized_keys"
cat "/home/$user_name/ssh_key.pub" >> "/home/$user_name/.ssh/authorized_keys"
printf '%s\n' '' >> "/home/$user_name/.ssh/authorized_keys"
chown -R "$user_name" "/home/$user_name"

# Dropbear setup
if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        cat "/home/$user_name/ssh_key.pub" >> '/etc/dropbear/authorized_keys'
        printf '%s\n' '' >> '/etc/dropbear/authorized_keys'
        chmod 0700 /etc/dropbear
        chmod 0600 /etc/dropbear/authorized_keys
fi