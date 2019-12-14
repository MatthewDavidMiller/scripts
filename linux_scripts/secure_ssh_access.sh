#!/bin/bash

# Script to secure ssh access
# Does not need to be executed as root.

read -r -p "Dropbear used? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        sudo uci set dropbear.@dropbear[0].PasswordAuth="off"
        sudo uci set dropbear.@dropbear[0].RootPasswordAuth="off"
        sudo uci commit dropbear
        sudo service dropbear restart
        exit
fi

# Turn off password authentication
sudo sed -i 's,#PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config
sudo sed -i 's,#PasswordAuthentication\s*no,PasswordAuthentication no,' /etc/ssh/sshd_config
sudo sed -i 's,PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config

# Do not allow empty passwords
sudo sed -i 's,#PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sudo sed -i 's,#PermitEmptyPasswords\s*no,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sudo sed -i 's,PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config

# Turn off PAM
sudo sed -i 's,#UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config
sudo sed -i 's,#UsePAM\s*no,UsePAM no,' /etc/ssh/sshd_config
sudo sed -i 's,UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config

# Turn off root ssh access
sudo sed -i 's,#PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sudo sed -i 's,PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sudo sed -i 's,#PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sudo sed -i 's,PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sudo sed -i 's,#PermitRootLogin\s*no,PermitRootLogin no,' /etc/ssh/sshd_config

# Enable public key authentication
sudo sed -i 's,#AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys,' /etc/ssh/sshd_config
sudo sed -i 's,#PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sudo sed -i 's,#PubkeyAuthentication\s*yes,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sudo sed -i 's,PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
