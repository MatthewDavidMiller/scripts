#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of window manager, desktop environment, and, display manager functions that can be called for most Linux distros.

function configure_gdm() {
    # Parameters
    local user_name=${1}

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

function configure_i3_sway_base() {
    # Parameters
    local user_name=${1}
    local wifi_name=${2}
    local window_manager=${3}

    # Local variables
    local wifi_response
    local monitor_response
    local display1
    local display2

    # Prompts
    read -r -p "Have the wifi autoconnect? [y/N] " wifi_response

    # Setup Duel Monitors
    read -r -p "Is there more than one monitor? [y/N] " monitor_response
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        xrandr
        read -r -p "Specify the first display. Example 'HDMI-1': " display1
        read -r -p "Specify the second display. Example 'DVI-D-1': " display2
    fi

    # Setup wm config
    mkdir -p "/home/${user_name}/.config/${window_manager}"
    rm -r "/home/${user_name}/.${window_manager}"
    rm -rf "/home/${user_name}/.config/${window_manager}/config"

    # Setup autostart applications
    rm -rf "/usr/local/bin/${window_manager}_autostart.sh"
    cat <<EOF >"/usr/local/bin/${window_manager}_autostart.sh"
#!/bin/bash

# Define path to commands.
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

termite &
picom &
xsetroot -solid "#000000"

EOF

    # Have the wifi autoconnect
    if [[ "${wifi_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp "/usr/local/bin/${window_manager}_autostart.sh" "/tmp/${window_manager}_autostart.sh"
        bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"nmcli connect up '\"'${wifi_name}'\"'\"; next }1' \"/tmp/${window_manager}_autostart.sh\" > \"/usr/local/bin/${window_manager}_autostart.sh\""
    fi

    # Setup duel monitors
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp "/usr/local/bin/${window_manager}_autostart.sh" "/tmp/${window_manager}_autostart.sh"
        bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"xrandr --output ${display2} --auto --right-of ${display1}\"; next }1' \"/tmp/${window_manager}_autostart.sh\" > \"/usr/local/bin/${window_manager}_autostart.sh\""

    fi

    # Allow script to be executable.
    chmod +x "/usr/local/bin/${window_manager}_autostart.sh"

    cat <<EOF >"/home/${user_name}/.config/${window_manager}/config"
    # i3 config file (v4)
    
    font pango:monospace 12
    
    exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork &
    
    set \$up l
    set \$down k
    set \$left j
    set \$right semicolon
    
    floating_modifier Mod1
    
    bindsym Mod1+Return exec i3-sensible-terminal
    
    bindsym Mod1+Shift+q kill
    
    bindsym Mod1+d exec dmenu_run
    
    bindsym Mod1+\$left focus left
    bindsym Mod1+\$down focus down
    bindsym Mod1+\$up focus up
    bindsym Mod1+\$right focus right
    
    bindsym Mod1+Left focus left
    bindsym Mod1+Down focus down
    bindsym Mod1+Up focus up
    bindsym Mod1+Right focus right
    
    bindsym Mod1+Shift+\$left move left
    bindsym Mod1+Shift+\$down move down
    bindsym Mod1+Shift+\$up move up
    bindsym Mod1+Shift+\$right move right
    
    bindsym Mod1+Shift+Left move left
    bindsym Mod1+Shift+Down move down
    bindsym Mod1+Shift+Up move up
    bindsym Mod1+Shift+Right move right
    
    bindsym Mod1+h split h
    
    bindsym Mod1+v split v
    
    bindsym Mod1+f fullscreen toggle
    
    bindsym Mod1+s layout stacking
    bindsym Mod1+w layout tabbed
    bindsym Mod1+e layout toggle split
    
    bindsym Mod1+Shift+space floating toggle
    
    bindsym Mod1+space focus mode_toggle
    
    bindsym Mod1+a focus parent
    
    bindsym Mod1+Shift+minus move scratchpad

    bindsym Mod1+minus scratchpad show
    
    set \$ws1 "1"
    set \$ws2 "2"
    set \$ws3 "3"
    set \$ws4 "4"
    set \$ws5 "5"
    set \$ws6 "6"
    set \$ws7 "7"
    set \$ws8 "8"
    set \$ws9 "9"
    set \$ws10 "10"
    
    bindsym Mod1+1 workspace number \$ws1
    bindsym Mod1+2 workspace number \$ws2
    bindsym Mod1+3 workspace number \$ws3
    bindsym Mod1+4 workspace number \$ws4
    bindsym Mod1+5 workspace number \$ws5
    bindsym Mod1+6 workspace number \$ws6
    bindsym Mod1+7 workspace number \$ws7
    bindsym Mod1+8 workspace number \$ws8
    bindsym Mod1+9 workspace number \$ws9
    bindsym Mod1+0 workspace number \$ws10
    
    bindsym Mod1+Shift+1 move container to workspace number \$ws1
    bindsym Mod1+Shift+2 move container to workspace number \$ws2
    bindsym Mod1+Shift+3 move container to workspace number \$ws3
    bindsym Mod1+Shift+4 move container to workspace number \$ws4
    bindsym Mod1+Shift+5 move container to workspace number \$ws5
    bindsym Mod1+Shift+6 move container to workspace number \$ws6
    bindsym Mod1+Shift+7 move container to workspace number \$ws7
    bindsym Mod1+Shift+8 move container to workspace number \$ws8
    bindsym Mod1+Shift+9 move container to workspace number \$ws9
    bindsym Mod1+Shift+0 move container to workspace number \$ws10
    
    bindsym Mod1+Shift+c reload
    
    bindsym Mod1+Shift+r restart
    
    bindsym Mod1+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"
    
    mode "resize" {
        
        bindsym \$left       resize shrink width 10 px or 10 ppt
        bindsym \$down       resize grow height 10 px or 10 ppt
        bindsym \$up         resize shrink height 10 px or 10 ppt
        bindsym \$right      resize grow width 10 px or 10 ppt
        
        bindsym Left        resize shrink width 10 px or 10 ppt
        bindsym Down        resize grow height 10 px or 10 ppt
        bindsym Up          resize shrink height 10 px or 10 ppt
        bindsym Right       resize grow width 10 px or 10 ppt
        
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym Mod1+r mode "default"
    }
    
    bindsym Mod1+r mode "resize"
    
    bar {
        status_command i3status
        mode hide
        hidden_state hide
        modifier Mod1
    }
    
    exec --no-startup-id bash '/usr/local/bin/${window_manager}_autostart.sh'
    
EOF

}

function configure_sway_config_file() {
    #swaymsg -t get_inputs

    # Parameters
    local user_name=${1}
    local touchpad=${2}

    cat <<EOF >>"/home/${user_name}/.config/sway/config"
    input "${touchpad}" {
        tap enabled
        natural_scroll disabled
    }
    
EOF
}

function configure_i3_applet_autostarts() {
    # Parameters
    local blueman_applet=$1
    local pasystray_applet=$1
    local nm_applet=$1

    if [[ "${blueman_applet}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        grep -q ".*blueman-applet" '/usr/local/bin/i3_autostart.sh' && sed -i "s,.*blueman-applet.*,blueman-applet &," '/usr/local/bin/i3_autostart.sh' || printf '%s\n' 'blueman-applet &' >>'/usr/local/bin/i3_autostart.sh'
    fi

    if [[ "${pasystray_applet}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        grep -q ".*pasystray" '/usr/local/bin/i3_autostart.sh' && sed -i "s,.*pasystray.*,pasystray &," '/usr/local/bin/i3_autostart.sh' || printf '%s\n' 'pasystray &' >>'/usr/local/bin/i3_autostart.sh'
    fi

    if [[ "${nm_applet}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        grep -q ".*nm-applet" '/usr/local/bin/i3_autostart.sh' && sed -i "s,.*nm-applet.*,nm-applet &," '/usr/local/bin/i3_autostart.sh' || printf '%s\n' 'nm-applet &' >>'/usr/local/bin/i3_autostart.sh'
    fi
}

function sway_autostart_at_login() {
    # Parameters
    local user_name=$1

    cat <<EOF >>"/home/${user_name}/.bash_profile"
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi
EOF
}
