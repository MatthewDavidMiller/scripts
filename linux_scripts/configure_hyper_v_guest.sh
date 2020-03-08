#!/bin/bash

# Script to configure hyper_v guest tools.
# Does not need to be executed as root.

function configure_hyperv() {
    # Install hyperv tools
    sudo pacman -S --noconfirm --needed hyperv

    sudo systemctl enable hv_fcopy_daemon.service
    sudo systemctl start hv_fcopy_daemon.service
    sudo systemctl enable hv_kvp_daemon.service
    sudo systemctl start hv_kvp_daemon.service
    sudo systemctl enable hv_vss_daemon.service
    sudo systemctl start hv_vss_daemon.service
}

# Call functions
configure_hyperv
