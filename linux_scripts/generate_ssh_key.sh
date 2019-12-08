#!/bin/bash

# Script to generate a ssh key
# If using sudo to run the script, specify the user with the -u option.

user_name=$(id -u -n)

read -r -p "Generate ecdsa key? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Generate an ecdsa 521 bit key
        ssh-keygen -f "/home/$user_name/ssh_key" -t ecdsa -b 521
fi

read -r -p "Generate rsa key? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
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

read -r -p "Dropbear used? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        cat "/home/$user_name/ssh_key.pub" >> '/etc/dropbear/authorized_keys'
        printf '%s\n' '' >> '/etc/dropbear/authorized_keys'
        chmod 0700 /etc/dropbear
        chmod 0600 /etc/dropbear/authorized_keys
fi