#!/bin/bash

# Script to add an user in OpenWrt
# Does not need to be executed as root.

read -r -p "Set username " user_name

function create_user() {
    sudo useradd "${user_name}"
    mkdir '/home'
    mkdir "/home/${user_name}"
    sudo passwd "${user_name}"
    sudo chown "${user_name}" "/home/${user_name}"
}

function configure_sudo() {
    sudo bash -c "printf '%s\n' \"${user_name} ALL=(ALL) ALL\" >> '/etc/sudoers'"
}

function configure_shell() {
    chsh -s /bin/bash
    chsh -s /bin/bash "${user_name}"
}

# Call functions
create_user
configure_sudo
configure_shell
