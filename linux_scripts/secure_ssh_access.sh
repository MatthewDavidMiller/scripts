#!/bin/bash

# Script to secure ssh access

read -r -p "Dropbear used? [y/N] " response
if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        uci set dropbear.@dropbear[0].PasswordAuth="off"
        uci set dropbear.@dropbear[0].RootPasswordAuth="off"
        uci commit dropbear
        service dropbear restart
fi

# Turn off password authentication
sed -i 's,#PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,#PasswordAuthentication\s*no,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config

# Do not allow empty passwords
sed -i 's,#PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,#PermitEmptyPasswords\s*no,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config

# Turn off PAM
sed -i 's,#UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,#UsePAM\s*no,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config

# Turn off root ssh access
sed -i 's,#PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*no,PermitRootLogin no,' /etc/ssh/sshd_config

# Enable public key authentication
sed -i 's,#AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*yes,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
