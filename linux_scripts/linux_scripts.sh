#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions that can be called for most Linux distros.

function enable_bluetooth() {
    systemctl enable bluetooth.service
}

function enable_ufw() {
    systemctl enable ufw.service
    ufw enable
}

function configure_xorg() {
    # Get username
    user_name=$(logname)

    sudo -u "${user_name}" Xorg :0 -configure
}

function setup_touchpad() {
    rm -f '/etc/X11/xorg.conf.d/20-touchpad.conf'
    cat <<\EOF >'/etc/X11/xorg.conf.d/20-touchpad.conf'

Section "InputClass"
 Identifier "libinput touchpad catchall"
 Driver "libinput"
 MatchIsTouchpad "on"
 MatchDevicePath "/dev/input/event*"
 Option "Tapping" "on"
 Option "NaturalScrolling" "false"
EndSection

EOF
}

function configure_gdm() {
    # Get username
    user_name=$(logname)
    # Specify session for gdm to use
    read -r -p "Specify session to use. Example: i3 " session

    # Enable gdm
    systemctl enable gdm.service

    # Enable autologin
    rm -rf '/etc/gdm/custom.conf'
    cat <<EOF >'/etc/gdm/custom.conf'
# Enable automatic login for user
[daemon]
AutomaticLogin=${user_name}
AutomaticLoginEnable=True

EOF

    # Setup default session
    rm -rf "/var/lib/AccountsService/users/$user_name"
    cat <<EOF >"/var/lib/AccountsService/users/$user_name"
    [User]
    Language=
    Session=${session}
    XSession=${session}
    
EOF
}

function generate_ssh_key() {
    # Prompts
    read -r -p "Generate ecdsa key? [y/N] " response1
    read -r -p "Generate rsa key? [y/N] " response2
    read -r -p "Dropbear used? [y/N] " response3

    user_name=$(logname)

    # Generate ecdsa key
    if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Generate an ecdsa 521 bit key
        ssh-keygen -f "/home/$user_name/ssh_key" -t ecdsa -b 521
    fi

    # Generate rsa key
    if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Generate an rsa 4096 bit key
        ssh-keygen -f "/home/$user_name/ssh_key" -t rsa -b 4096
    fi

    # Authorize the key for use with ssh
    mkdir "/home/$user_name/.ssh"
    chmod 700 "/home/$user_name/.ssh"
    touch "/home/$user_name/.ssh/authorized_keys"
    chmod 600 "/home/$user_name/.ssh/authorized_keys"
    cat "/home/$user_name/ssh_key.pub" >>"/home/$user_name/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/$user_name/.ssh/authorized_keys"
    chown -R "$user_name" "/home/$user_name"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"

    # Dropbear setup
    if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cat "/home/$user_name/ssh_key.pub" >>'/etc/dropbear/authorized_keys'
        printf '%s\n' '' >>'/etc/dropbear/authorized_keys'
        chmod 0700 /etc/dropbear
        chmod 0600 /etc/dropbear/authorized_keys
    fi
}

function configure_dropbear() {
    uci set dropbear.@dropbear[0].PasswordAuth="off"
    uci set dropbear.@dropbear[0].RootPasswordAuth="off"
    uci commit dropbear
    service dropbear restart
    exit
}

function configure_ssh() {
    # Turn off password authentication
    grep -q ".*PasswordAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PasswordAuthentication.*,PasswordAuthentication no," '/etc/ssh/sshd_config' || printf '%s\n' 'PasswordAuthentication no' >>'/etc/ssh/sshd_config'

    # Do not allow empty passwords
    grep -q ".*PermitEmptyPasswords" '/etc/ssh/sshd_config' && sed -i "s,.*PermitEmptyPasswords.*,PermitEmptyPasswords no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitEmptyPasswords no' >>'/etc/ssh/sshd_config'

    # Turn off PAM
    grep -q ".*UsePAM" '/etc/ssh/sshd_config' && sed -i "s,.*UsePAM.*,UsePAM no," '/etc/ssh/sshd_config' || printf '%s\n' 'UsePAM no' >>'/etc/ssh/sshd_config'

    # Turn off root ssh access
    grep -q ".*PermitRootLogin" '/etc/ssh/sshd_config' && sed -i "s,.*PermitRootLogin.*,PermitRootLogin no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitRootLogin no' >>'/etc/ssh/sshd_config'

    # Enable public key authentication
    grep -q ".*AuthorizedKeysFile" '/etc/ssh/sshd_config' && sed -i "s,.*AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys," '/etc/ssh/sshd_config' || printf '%s\n' 'AuthorizedKeysFile .ssh/authorized_keys' >>'/etc/ssh/sshd_config'
    grep -q ".*PubkeyAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PubkeyAuthentication.*,PubkeyAuthentication yes," '/etc/ssh/sshd_config' || printf '%s\n' 'PubkeyAuthentication yes' >>'/etc/ssh/sshd_config'
}
