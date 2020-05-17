#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of xorg related functions that can be called for most Linux distros.

function configure_xorg() {
    # Parameters
    local user_name=${1}

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

function configure_xinit() {
    # Parameters
    local user_name=${1}

    # Copy default config
    cp '/etc/X11/xinit/xinitrc' "/home/${user_name}/.xinitrc"

}

function configure_xinit_i3() {
    # Parameters
    local user_name=${1}

    sed -i '/.*exec xterm.*/d' "/home/${user_name}/.xinitrc"
    grep -q ".*i3" "/home/${user_name}/.xinitrc" && sed -i "s,.*i3.*,exec i3," "/home/${user_name}/.xinitrc" || printf '%s\n' 'exec i3' >>"/home/${user_name}/.xinitrc"
}
