#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions for the Omada Controller.

function install_omada_controller_packages() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y wget vim git ufw ntp ssh openssh-server jsvc curl unattended-upgrades
}

function configure_omada_controller_ufw_rules() {
    # Limit max connections to ssh server and allow it only on private networks
    ufw limit proto tcp from 10.0.0.0/8 to any port 22
    ufw limit proto tcp from fe80::/10 to any port 22

    # Allow omada controller
    ufw allow proto tcp from 10.0.0.0/8 to any port 8043
    ufw allow proto tcp from fe80::/10 to any port 8043
    ufw allow proto tcp from 10.0.0.0/8 to any port 8088
    ufw allow proto tcp from fe80::/10 to any port 8088
    ufw allow proto udp from 10.0.0.0/8 to any port 29810
    ufw allow proto udp from fe80::/10 to any port 29810
    ufw allow proto tcp from 10.0.0.0/8 to any port 29811
    ufw allow proto tcp from fe80::/10 to any port 29811
    ufw allow proto tcp from 10.0.0.0/8 to any port 29812
    ufw allow proto tcp from fe80::/10 to any port 29812
    ufw allow proto tcp from 10.0.0.0/8 to any port 29813
    ufw allow proto tcp from fe80::/10 to any port 29813
}

function configure_omada_controller_ssh_key() {
    # Generate an ecdsa 521 bit key
    ssh-keygen -f "/home/${user_name}/eap_controller_key" -t ecdsa -b 521

    # Authorize the key for use with ssh
    mkdir "/home/${user_name}/.ssh"
    chmod 700 "/home/${user_name}/.ssh"
    touch "/home/${user_name}/.ssh/authorized_keys"
    chmod 600 "/home/${user_name}/.ssh/authorized_keys"
    cat "/home/${user_name}/eap_controller_key.pub" >>"/home/${user_name}/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/${user_name}/.ssh/authorized_keys"
    chown -R "${user_name}" "/home/${user_name}"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"
}

function configure_omada_controller() {
    # Download the controller software
    wget 'https://static.tp-link.com/2019/201911/20191108/omada_v3.2.4_linux_x64_20190925173425.deb'

    # Install the software
    dpkg -i 'omada_v3.2.4_linux_x64_20190925173425.deb'
}
