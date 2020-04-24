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

function configure_i3() {
    # Get username
    user_name=$(logname)

    # Wifi network name
    wifi='Miller Homelab'

    # Prompts
    read -r -p "Have the wifi autoconnect? [y/N] " response1

    # Setup Duel Monitors
    read -r -p "Is there more than one monitor? [y/N] " monitor_response
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        xrandr
        read -r -p "Specify the first display. Example 'HDMI-1': " display1
        read -r -p "Specify the second display. Example 'DVI-D-1': " display2
    fi

    # Setup i3 config
    mkdir "/home/${user_name}/.config"
    mkdir "/home/${user_name}/.config/i3"
    rm -r "/home/${user_name}/.i3"
    rm -rf "/home/${user_name}/.config/i3/config"
    cat <<EOF >"/home/${user_name}/.config/i3/config"
# i3 config file (v4)

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 12

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork &
    
# use these keys for focus, movement, and resize directions when reaching for
# the arrows is not convenient
set \$up l
set \$down k
set \$left j
set \$right semicolon
    
# use Mouse+Mod1 to drag floating windows to their wanted position
floating_modifier Mod1
    
# start a terminal
bindsym Mod1+Return exec i3-sensible-terminal
    
# kill focused window
bindsym Mod1+Shift+q kill
    
# start dmenu (a program launcher)
bindsym Mod1+d exec dmenu_run
    
# change focus
bindsym Mod1+\$left focus left
bindsym Mod1+\$down focus down
bindsym Mod1+\$up focus up
bindsym Mod1+\$right focus right

# alternatively, you can use the cursor keys:
bindsym Mod1+Left focus left
bindsym Mod1+Down focus down
bindsym Mod1+Up focus up
bindsym Mod1+Right focus right
    
# move focused window
bindsym Mod1+Shift+\$left move left
bindsym Mod1+Shift+\$down move down
bindsym Mod1+Shift+\$up move up
bindsym Mod1+Shift+\$right move right

# alternatively, you can use the cursor keys:
bindsym Mod1+Shift+Left move left
bindsym Mod1+Shift+Down move down
bindsym Mod1+Shift+Up move up
bindsym Mod1+Shift+Right move right
    
# split in horizontal orientation
bindsym Mod1+h split h
    
# split in vertical orientation
bindsym Mod1+v split v
    
# enter fullscreen mode for the focused container
bindsym Mod1+f fullscreen toggle
    
# change container layout (stacked, tabbed, toggle split)
bindsym Mod1+s layout stacking
bindsym Mod1+w layout tabbed
bindsym Mod1+e layout toggle split
    
# toggle tiling / floating
bindsym Mod1+Shift+space floating toggle
    
# change focus between tiling / floating windows
bindsym Mod1+space focus mode_toggle
    
# focus the parent container
bindsym Mod1+a focus parent
    
# focus the child container
#bindsym Mod1+d focus child
    
# move the currently focused window to the scratchpad
bindsym Mod1+Shift+minus move scratchpad
    
# Show the next scratchpad window or hide the focused scratchpad window.
# If there are multiple scratchpad windows, this command cycles through them.
bindsym Mod1+minus scratchpad show
    
# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
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
    
# switch to workspace
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

# move focused container to workspace
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

# reload the configuration file
bindsym Mod1+Shift+c reload

# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym Mod1+Shift+r restart
    
# exit i3 (logs you out of your X session)
bindsym Mod1+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# resize window (you can also use the mouse for that)
mode "resize" {
    # These bindings trigger as soon as you enter the resize mode
    
    # Pressing left will shrink the window’s width.
    # Pressing right will grow the window’s width.
    # Pressing up will shrink the window’s height.
    # Pressing down will grow the window’s height.
    bindsym \$left       resize shrink width 10 px or 10 ppt
    bindsym \$down       resize grow height 10 px or 10 ppt
    bindsym \$up         resize shrink height 10 px or 10 ppt
    bindsym \$right      resize grow width 10 px or 10 ppt
    
    # same bindings, but for the arrow keys
    bindsym Left        resize shrink width 10 px or 10 ppt
    bindsym Down        resize grow height 10 px or 10 ppt
    bindsym Up          resize shrink height 10 px or 10 ppt
    bindsym Right       resize grow width 10 px or 10 ppt
    
    # back to normal: Enter or Escape or Mod1+r
    bindsym Return mode "default"
    bindsym Escape mode "default"
    bindsym Mod1+r mode "default"
}

bindsym Mod1+r mode "resize"

# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
    status_command i3status
    mode hide
    hidden_state hide
    modifier Mod1
}

exec --no-startup-id bash '/usr/local/bin/i3_autostart.sh'

EOF

    # Setup autostart applications
    rm -rf '/usr/local/bin/i3_autostart.sh'
    cat <<EOF >'/usr/local/bin/i3_autostart.sh'
#!/bin/bash

# Define path to commands.
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

termite &
nm-applet &
blueman-applet &
pasystray &
picom &
xsetroot -solid "#000000"

EOF

    # Have the wifi autoconnect
    if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp '/usr/local/bin/i3_autostart.sh' '/tmp/i3_autostart.sh'
        bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"nmcli connect up '\"'${wifi}'\"'\"; next }1' '/tmp/i3_autostart.sh' > '/usr/local/bin/i3_autostart.sh'"
    fi

    # Setup duel monitors
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp '/usr/local/bin/i3_autostart.sh' '/tmp/i3_autostart.sh'
        bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"xrandr --output ${display2} --auto --right-of ${display1}\"; next }1' '/tmp/i3_autostart.sh' > '/usr/local/bin/i3_autostart.sh'"

    fi

    # Allow script to be executable.
    chmod +x '/usr/local/bin/i3_autostart.sh'
}

function connect_smb() {
    # Make /mnt directory
    mkdir '/mnt'

    # Script to connect and mount a smb share
    read -r -p "Mount a samba share? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do
        # Prompts
        # Share location
        read -r -p "Specify share location. Example'//matt-nas.miller.lan/matt_files': " share
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_files': " mount_location
        # Username
        read -r -p "Specify Username. Example'matthew': " username
        # Password
        read -r -p "Specify Password. Example'password': " password

        # Make directory to mount the share at
        mkdir "${mount_location}"

        # Automount smb share
        printf '%s\n' "${share} ${mount_location} cifs rw,noauto,x-systemd.automount,_netdev,user,username=${username},password=${password} 0 0" >>'/etc/fstab'

        # Mount another disk
        read -r -p "Do you want to mount another samba share? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            printf '%s\n' '' >>'/etc/fstab'
            exit
        fi
    done
}

function configure_hyperv() {
    systemctl enable hv_fcopy_daemon.service
    systemctl start hv_fcopy_daemon.service
    systemctl enable hv_kvp_daemon.service
    systemctl start hv_kvp_daemon.service
    systemctl enable hv_vss_daemon.service
    systemctl start hv_vss_daemon.service
}

function configure_kvm() {
    # Enable nested virtualization
    rm -rf '/etc/modprobe.d/kvm_intel.conf'
    cat <<EOF >'/etc/modprobe.d/kvm_intel.conf'

options kvm_intel nested=1

EOF
}

function configure_sway() {
    # Get username
    user_name=$(logname)

    # Wifi network name
    wifi='Miller Homelab'

    # Prompts
    read -r -p "Have the wifi autoconnect? [y/N] " response1

    # Get the touchpad name
    swaymsg -t get_inputs
    read -r -p "Enter name of touchpad: " touchpad_response

    # Setup Duel Monitors
    read -r -p "Is there more than one monitor? [y/N] " monitor_response
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        xrandr
        read -r -p "Specify the first display. Example 'HDMI-1': " display1
        read -r -p "Specify the second display. Example 'DVI-D-1': " display2
    fi

    # Setup i3 config
    mkdir "/home/${user_name}/.config"
    mkdir "/home/${user_name}/.config/sway"
    rm -rf "/home/${user_name}/.config/sway/config"
    cat <<EOF >"/home/${user_name}/.config/sway/config"
    # i3 config file (v4)
    
    # Font for window titles. Will also be used by the bar unless a different font
    # is used in the bar {} block below.
    font pango:monospace 12
    
    # xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
    # screen before suspend. Use loginctl lock-session to lock your screen.
    exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork &
    
    # use these keys for focus, movement, and resize directions when reaching for
    # the arrows is not convenient
    set \$up l
    set \$down k
    set \$left j
    set \$right semicolon
    
    # use Mouse+Mod1 to drag floating windows to their wanted position
    floating_modifier Mod1
    
    # start a terminal
    bindsym Mod1+Return exec i3-sensible-terminal
    
    # kill focused window
    bindsym Mod1+Shift+q kill
    
    # start dmenu (a program launcher)
    bindsym Mod1+d exec dmenu_run
    
    # change focus
    bindsym Mod1+\$left focus left
    bindsym Mod1+\$down focus down
    bindsym Mod1+\$up focus up
    bindsym Mod1+\$right focus right
    
    # alternatively, you can use the cursor keys:
    bindsym Mod1+Left focus left
    bindsym Mod1+Down focus down
    bindsym Mod1+Up focus up
    bindsym Mod1+Right focus right
    
    # move focused window
    bindsym Mod1+Shift+\$left move left
    bindsym Mod1+Shift+\$down move down
    bindsym Mod1+Shift+\$up move up
    bindsym Mod1+Shift+\$right move right
    
    # alternatively, you can use the cursor keys:
    bindsym Mod1+Shift+Left move left
    bindsym Mod1+Shift+Down move down
    bindsym Mod1+Shift+Up move up
    bindsym Mod1+Shift+Right move right
    
    # split in horizontal orientation
    bindsym Mod1+h split h
    
    # split in vertical orientation
    bindsym Mod1+v split v
    
    # enter fullscreen mode for the focused container
    bindsym Mod1+f fullscreen toggle
    
    # change container layout (stacked, tabbed, toggle split)
    bindsym Mod1+s layout stacking
    bindsym Mod1+w layout tabbed
    bindsym Mod1+e layout toggle split
    
    # toggle tiling / floating
    bindsym Mod1+Shift+space floating toggle
    
    # change focus between tiling / floating windows
    bindsym Mod1+space focus mode_toggle
    
    # focus the parent container
    bindsym Mod1+a focus parent
    
    # focus the child container
    #bindsym Mod1+d focus child
    
    # move the currently focused window to the scratchpad
    bindsym Mod1+Shift+minus move scratchpad
    
    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym Mod1+minus scratchpad show
    
    # Define names for default workspaces for which we configure key bindings later on.
    # We use variables to avoid repeating the names in multiple places.
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
    
    # switch to workspace
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
    
    # move focused container to workspace
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
    
    # reload the configuration file
    bindsym Mod1+Shift+c reload
    
    # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
    bindsym Mod1+Shift+r restart
    
    # exit i3 (logs you out of your X session)
    bindsym Mod1+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"
    
    # resize window (you can also use the mouse for that)
    mode "resize" {
        # These bindings trigger as soon as you enter the resize mode
        
        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym \$left       resize shrink width 10 px or 10 ppt
        bindsym \$down       resize grow height 10 px or 10 ppt
        bindsym \$up         resize shrink height 10 px or 10 ppt
        bindsym \$right      resize grow width 10 px or 10 ppt
        
        # same bindings, but for the arrow keys
        bindsym Left        resize shrink width 10 px or 10 ppt
        bindsym Down        resize grow height 10 px or 10 ppt
        bindsym Up          resize shrink height 10 px or 10 ppt
        bindsym Right       resize grow width 10 px or 10 ppt
        
        # back to normal: Enter or Escape or Mod1+r
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym Mod1+r mode "default"
    }
    
    bindsym Mod1+r mode "resize"
    
    # Start i3bar to display a workspace bar (plus the system information i3status
    # finds out, if available)
    bar {
        status_command i3status
        mode hide
        hidden_state hide
        modifier Mod1
    }
    
    exec --no-startup-id bash '/usr/local/bin/sway_autostart.sh'
    
EOF

    rm -rf "/home/${user_name}/.config/sway/config"
    cat <<EOF >>"/home/${user_name}/.config/sway/config"
    input "${touchpad_response}" {
        tap enabled
        natural_scroll disabled
    }
    
EOF

    # Setup autostart applications
    rm -rf '/usr/local/bin/sway_autostart.sh'
    cat <<EOF >'/usr/local/bin/sway_autostart.sh'
#!/bin/bash

# Define path to commands.
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

termite &
nm-applet &
blueman-applet &
pasystray &
picom &
xsetroot -solid "#000000"

EOF

    # Have the wifi autoconnect
    if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp '/usr/local/bin/i3_autostart.sh' '/tmp/sway_autostart.sh'
        sudo bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"nmcli connect up '\"'${wifi}'\"'\"; next }1' '/tmp/sway_autostart.sh' > '/usr/local/bin/sway_autostart.sh'"
    fi

    # Setup duel monitors
    if [[ "${monitor_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cp '/usr/local/bin/i3_autostart.sh' '/tmp/sway_autostart.sh'
        sudo bash -c "awk '/xsetroot -solid \"#000000\"/ { print; print \"xrandr --output ${display2} --auto --right-of ${display1}\"; next }1' '/tmp/sway_autostart.sh' > '/usr/local/bin/sway_autostart.sh'"

    fi

    # Allow script to be executable.
    chmod +x '/usr/local/bin/sway_autostart.sh'
}

function configure_termite() {
    # Get username
    user_name=$(logname)

    # Setup termite config
    mkdir "/home/${user_name}/.config"
    mkdir "/home/${user_name}/.config/termite"
    rm -rf "/home/${user_name}/.config/termite/config"
    cat <<EOF >"/home/${user_name}/.config/termite/config"
    
    [options]
    font = Monospace 16
    scrollback_lines = 10000
    
    [colors]
    
    # If unset, will reverse foreground and background
    highlight = #2f2f2f
    
    # Colors from color0 to color254 can be set
    color0 = #000000
    
    [hints]
    
EOF
}

function mount_drives() {
    # Make /mnt directory
    mkdir '/mnt'

    read -r -p "Mount a disk? [y/N] " response
    while [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; do

        #See disks
        lsblk -f

        # Prompts
        # Disk location
        read -r -p "Specify disk location. Example'/dev/sda1': " disk1
        # Mount point location
        read -r -p "Specify mount location. Example'/mnt/matt_backup': " mount_location
        #Specify disk type
        read -r -p "Specify disk type. Example'ntfs': " disk_type

        # Get uuid
        uuid="$(blkid -o value -s UUID "${disk1}")"

        # Make directory to mount the disk at
        mkdir "${mount_location}"

        # Automount smb share
        printf '%s\n' "UUID=${uuid} ${mount_location} ${disk_type} rw,noauto,x-systemd.automount 0 0" >>'/etc/fstab'

        # Mount another disk
        read -r -p "Do you want to mount another disk? [y/N] " response
        if [[ "${response}" =~ ^([nN][oO]|[nN])+$ ]]; then
            printf '%s\n' '' >>'/etc/fstab'
            exit
        fi
    done
}

function setup_aliases() {
    # Get username
    user_name=$(logname)

    function copy_ssh_keys() {
        cp '/mnt/matt_files/SSHConfigs/matt_homelab/nas_key' '.ssh/nas_key'
        cp '/mnt/matt_files/SSHConfigs/matt_homelab/openwrt_key' '.ssh/openwrt_key'
        cp '/mnt/matt_files/SSHConfigs/matt_homelab/proxmox_key' '.ssh/proxmox_key'
        cp '/mnt/matt_files/SSHConfigs/matt_homelab/vpn_key' '.ssh/vpn_key'
        cp '/mnt/matt_files/SSHConfigs/matt_homelab/pihole_key' '.ssh/pihole_key'
    }

    function configure_bashrc() {
        rm -rf "/home/${user_name}/.bashrc"
        cat <<\EOF >>"/home/${user_name}/.bashrc"

# Aliases
alias sudo='sudo '
alias ssh_nas="ssh -i '.ssh/nas_key' matthew@matt-nas.miller.lan"
alias ssh_openwrt="ssh -i '.ssh/openwrt_key' matthew@mattopenwrt.miller.lan"
alias ssh_proxmox="ssh -i '.ssh/proxmox_key' matthew@matt-prox.miller.lan"
alias ssh_vpn="ssh -i '.ssh/vpn_key' matthew@matt-vpn.miller.lan"
alias ssh_pihole="ssh -i '.ssh/pihole_key' matthew@matt-pihole.miller.lan"
alias pacman_autoremove='pacman -Rs $(pacman -Qtdq)'

EOF
    }
    # Call functions
    copy_ssh_keys
    configure_bashrc
}

function configure_fwupd() {
    # Copy efi file
    cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

    # Setup hook
    mkdir -p '/etc/pacman.d'
    mkdir -p '/etc/pacman.d/hooks'
    touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'
    rm -rf '/etc/pacman.d/hooks/fwupd-to-esp.hook'
    cat <<EOF >'/etc/pacman.d/hooks/fwupd-to-esp.hook'
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF
}

function configure_git() {
    # Get username
    user_name=$(logname)

    # Variables
    # Git username
    git_name='MatthewDavidMiller'
    # Email address
    email='matthewdavidmiller1@gmail.com'
    # SSH key location
    key_location='/mnt/matt_files/SSHConfigs/github/github_ssh'
    # SSH key filename
    key='github_ssh'

    # Setup username
    git config --global user.name "${git_name}"

    # Setup email
    git config --global user.email "${email}"

    # Setup ssh key
    mkdir "/home/${user_name}/ssh_keys"
    cp "${key_location}" "/home/${user_name}/ssh_keys/${key}"
    git config --global core.sshCommand "ssh -i ""/home/${user_name}/ssh_keys/${key}"" -F /dev/null"
    chmod 400 -R "/home/${user_name}/ssh_keys"
}

function configure_serial() {
    # Get username
    user_name=$(logname)

    # Add user to uucp group
    gpasswd -a "${user_name}" uucp
}

function configure_ostimer() {
    grep -q ".*timeout" '/boot/loader/loader.conf' && sed -i "s,.*timeout.*,timeout 60," '/boot/loader/loader.conf' || printf '%s\n' 'timeout 60' >>'/boot/loader/loader.conf'
}
