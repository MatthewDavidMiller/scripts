#!/bin/bash

read -r -p "Do you want to upgrade all installed packages? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        # Updates package lists
        opkg update

        # Upgrades all installed packages
        opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
fi