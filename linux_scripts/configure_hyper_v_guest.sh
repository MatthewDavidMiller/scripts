#!/bin/bash

# Script to configure hyper_v guest tools.
# Does not need to be executed as root.

# Install hyperv tools
sudo pacman -S --noconfirm --needed hyperv

# Configure hyperv
sudo systemctl enable hv_fcopy_daemon.service
sudo systemctl start hv_fcopy_daemon.service
sudo systemctl enable hv_kvp_daemon.service
sudo systemctl start hv_kvp_daemon.service
sudo systemctl enable hv_vss_daemon.service
sudo systemctl start hv_vss_daemon.service
