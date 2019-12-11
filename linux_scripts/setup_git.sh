#!/bin/bash

# Script to setup git
# If using sudo to run the script, specify the user with the -u option.

# Variables to edit
# Git username
git_name='MatthewDavidMiller'
# Email address
email='matthewdavidmiller1@gmail.com'
# SSH key location
key_location='/mnt/a/SSHConfigs/github/github_ssh'
# SSH key filename
key='github_ssh'

# Get username
user_name=$(id -u -n)

# Install git
pacman -S git

# Setup username
git config --global user.name "${git_name}"

# Setup email
git config --global user.email "${email}"

# Setup ssh key
mkdir "/home/${user_name}/ssh_keys"
cp "${key_location}" "/home/${user_name}/ssh_keys/${key}"
git config core.sshCommand "ssh -i ""/home/${user_name}/ssh_keys/${key}"" -F /dev/null"
chmod 400 -R "/home/${user_name}/ssh keys"
