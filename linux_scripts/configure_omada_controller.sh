#!/bin/bash

# Install script for TP Link Omada Controller
# Use with Debian
# Does not need to be run as root

# Install needed packages
sudo apt-get install -y jsvc curl wget

# Download the controller software
wget 'https://static.tp-link.com/2019/201911/20191108/omada_v3.2.4_linux_x64_20190925173425.deb'

# Install the software
sudo dpkg -i 'omada_v3.2.4_linux_x64_20190925173425.deb'
