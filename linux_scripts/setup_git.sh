#!/bin/bash

# Script to setup git
# Does not need to be executed as root.

function configure_git() {
    # Variables
    # Git username
    git_name='MatthewDavidMiller'
    # Email address
    email='matthewdavidmiller1@gmail.com'
    # SSH key location
    key_location='/mnt/matt-nas/SSHConfigs/github/github_ssh'
    # SSH key filename
    key='github_ssh'

    # Get username
    user_name=$(logname)

    # Install git
    sudo pacman -S --noconfirm --needed git

    # Setup username
    sudo git config --global user.name "${git_name}"

    # Setup email
    sudo git config --global user.email "${email}"

    # Setup ssh key
    mkdir "/home/${user_name}/ssh_keys"
    sudo cp "${key_location}" "/home/${user_name}/ssh_keys/${key}"
    sudo git config --global core.sshCommand "ssh -i ""/home/${user_name}/ssh_keys/${key}"" -F /dev/null"
    sudo chmod 400 -R "/home/${user_name}/ssh_keys"
}

# Call functions
configure_git
