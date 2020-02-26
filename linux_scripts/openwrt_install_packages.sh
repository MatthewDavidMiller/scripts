#!/bin/bash

# Script to install some packages I use.
# Does not need to be executed as root.

read -r -p "Do you want to install the packages? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    # Updates package lists
    sudo opkg update
    
    # Installs packages
    sudo opkg install luci-app-upnp ipset luci-ssl iptables-mod-geoip sudo bash coreutils openssh-keygen shadow-useradd shadow-chsh
fi
