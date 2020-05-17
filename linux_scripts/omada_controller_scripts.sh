#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions for the Omada Controller.

function install_omada_controller_packages() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y wget vim git ufw ntp ssh openssh-server jsvc curl unattended-upgrades
}

function configure_omada_controller() {
    # Download the controller software
    wget 'https://static.tp-link.com/2019/201911/20191108/omada_v3.2.4_linux_x64_20190925173425.deb'

    # Install the software
    dpkg -i 'omada_v3.2.4_linux_x64_20190925173425.deb'
}
