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

function generate_ssh_key() {
    # Parameters
    local user_name=${1}
    local ecdsa_response=${2}
    local rsa_response=${3}
    local dropbear_response=${4}
    local key_name=${5}

    # Generate ecdsa key
    if [[ "${ecdsa_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Generate an ecdsa 521 bit key
        ssh-keygen -f "/home/$user_name/${key_name}" -t ecdsa -b 521
    fi

    # Generate rsa key
    if [[ "${rsa_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Generate an rsa 4096 bit key
        ssh-keygen -f "/home/$user_name/${key_name}" -t rsa -b 4096
    fi

    # Authorize the key for use with ssh
    mkdir "/home/$user_name/.ssh"
    chmod 700 "/home/$user_name/.ssh"
    touch "/home/$user_name/.ssh/authorized_keys"
    chmod 600 "/home/$user_name/.ssh/authorized_keys"
    cat "/home/$user_name/${key_name}.pub" >>"/home/$user_name/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/$user_name/.ssh/authorized_keys"
    chown -R "$user_name" "/home/$user_name"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"

    # Dropbear setup
    if [[ "${dropbear_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cat "/home/$user_name/${key_name}.pub" >>'/etc/dropbear/authorized_keys'
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
    mkdir "/home/${user_name}/.config"
    mkdir "/home/${user_name}/.config/${window_manager}"
    rm -r "/home/${user_name}/.${window_manager}"
    rm -rf "/home/${user_name}/.config/${window_manager}/config"

    # Setup autostart applications
    rm -rf "/usr/local/bin/${window_manager}_autostart.sh"
    cat <<EOF >"/usr/local/bin/${window_manager}_autostart.sh"
#!/bin/bash

# Define path to commands.
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

termite &
nm-applet &
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

function configure_sway_config_file() {
    # Parameters
    local user_name=${1}
    local touchpad=${2}

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
    cat <<EOF >>"/home/${user_name}/.config/sway/config"
    input "${touchpad}" {
        tap enabled
        natural_scroll disabled
    }
    
EOF
}

function configure_termite() {
    # Parameters
    local user_name=${1}

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
    # Parameters
    local user_name=${1}

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
    # Parameters
    local user_name=${1}

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
    # Parameters
    local user_name=${1}

    # Add user to uucp group
    gpasswd -a "${user_name}" uucp
}

function configure_ostimer() {
    grep -q ".*timeout" '/boot/loader/loader.conf' && sed -i "s,.*timeout.*,timeout 60," '/boot/loader/loader.conf' || printf '%s\n' 'timeout 60' >>'/boot/loader/loader.conf'
}

function get_username() {
    user_name=$(logname)
}

function get_interface_name() {
    interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
    echo "Interface name is ${interface}"
}

function configure_network() {
    # Parameters
    local ip_address=${1}
    local network_address=${2}
    local subnet_mask=${3}
    local gateway_address=${4}
    local dns_address=${5}
    local interface=${6}

    # Configure network
    rm -f '/etc/network/interfaces'
    cat <<EOF >'/etc/network/interfaces'
auto lo
iface lo inet loopback
auto ${interface}
iface ${interface} inet static
    address ${ip_address}
    network ${network_address}
    netmask ${subnet_mask}
    gateway ${gateway_address}
    dns-nameservers ${dns_address}

EOF

    # Restart network interface
    ifdown "${interface}" && ifup "${interface}"
}

function fix_apt_packages() {
    dpkg --configure -a
}

function configure_ufw_base() {
    # Set default inbound to deny
    ufw default deny incoming

    # Set default outbound to allow
    ufw default allow outgoing
}

function enable_ufw() {
    systemctl enable ufw.service
    ufw enable
}

function apt_configure_auto_updates() {
    # Parameters
    local release_name=${1}

    rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

    cat <<EOF >'/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,n=${release_name},l=Debian";
        "origin=Debian,n=${release_name},l=Debian-Security";
        "origin=Debian,n=${release_name}-updates";
};

Unattended-Upgrade::Package-Blacklist {

};

Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

EOF
}

function create_user() {
    # Parameters
    local user_name=${1}

    useradd -m "${user_name}"
    echo "Set the password for ${user_name}"
    passwd "${user_name}"
    mkdir -p "/home/${user_name}"
    chown "${user_name}" "/home/${user_name}"
}

function list_partitions() {
    lsblk -f
}

function check_for_internet_access() {
    if false ping -c2 "google.com"; then
        echo 'No internet'
        exit 1
    fi
}

function start_dhcpcd() {
    systemctl start "dhcpcd.service"
}

function enable_ntp_timedatectl() {
    timedatectl set-ntp true
}

function delete_all_partitions_on_a_disk() {
    # Parameters
    local disk=${1}

    local response
    read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response
    if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    fi
}

function create_luks_partition() {
    # Parameters
    local disk_password=${1}
    local partition=${2}

    printf '%s\n' "${disk_password}" >'/tmp/disk_password'
    cryptsetup -q luksFormat "${partition}" <'/tmp/disk_password'
}

function create_basic_lvm() {
    # Parameters
    local partition=${1}
    local disk_password=${2}
    local lvm_name=${3}
    local root_partition_size=${4}
    local home_partition_size=${5}

    cryptsetup open "${partition}" cryptlvm <"${disk_password}"
    pvcreate '/dev/mapper/cryptlvm'
    vgcreate "${lvm_name}" '/dev/mapper/cryptlvm'
    lvcreate -L "${root_partition_size}" "${lvm_name}" -n root
    lvcreate -l "${home_partition_size}" "${lvm_name}" -n home
    rm -f "${disk_password}"
}

function create_basic_filesystems_lvm() {
    # Parameters
    local lvm_name=${1}
    local duel_boot=${2}
    local partition=${3}

    mkfs.ext4 "/dev/${lvm_name}/root"
    mkfs.ext4 "/dev/${lvm_name}/home"
    if [[ ! "${duel_boot}" =~ ^([d][b])+$ ]]; then
        mkfs.fat -F32 "${partition}"
    fi
}

function mount_basic_filesystems_lvm() {
    # Parameters
    local lvm_name=${1}
    local partition=${2}

    mount "/dev/${lvm_name}/root" /mnt
    mkdir '/mnt/home'
    mount "/dev/${lvm_name}/home" '/mnt/home'
    mkdir '/mnt/boot'
    mount "${partition}" '/mnt/boot'
}

function get_lvm_uuids() {
    boot_uuid=uuid="$(blkid -o value -s UUID "${partition1}")"
    luks_partition_uuid="$(blkid -o value -s UUID "${partition2}")"
    root_uuid="$(blkid -o value -s UUID /dev/Archlvm/root)"
    home_uuid="$(blkid -o value -s UUID /dev/Archlvm/home)"
}

function create_basic_lvm_fstab() {
    rm -f '/etc/fstab'
    {
        printf '%s\n' "UUID=${boot_uuid} /boot/EFI vfat defaults 0 0"
        printf '%s\n' '/swapfile none swap defaults 0 0'
        printf '%s\n' "UUID=${root_uuid} / ext4 defaults 0 0"
        printf '%s\n' "UUID=${home_uuid} / ext4 defaults 0 0"
    } >>'/etc/fstab'
}

function create_swap_file() {
    # Parameters
    local swap_file_size=${1}

    # Create swapfile
    dd if=/dev/zero of=/swapfile bs=1M count="${swap_file_size}" status=progress
    # Set file permissions
    chmod 600 /swapfile
    # Format file to swap
    mkswap /swapfile
    # Activate the swap file
    swapon /swapfile
}

function set_timezone() {
    ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'
}

function set_hardware_clock() {
    hwclock --systohc
}

function enable_ntpd_client() {
    systemctl enable ntpd.service
}

function arch_setup_locales() {
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    # Generate locale
    locale-gen
}

function set_language() {
    rm -f '/etc/locale.conf'
    {
        printf '%s\n' '# language config'
        printf '%s\n' '# file location is /etc/locale.conf'
        printf '%s\n' ''
        printf '%s\n' 'LANG=en_US.UTF-8'
        printf '%s\n' ''
    } >>'/etc/locale.conf'
}

function set_hostname() {
    # Parameters
    local device_hostname=${1}

    rm -f '/etc/hostname'
    {
        printf '%s\n' '# hostname file'
        printf '%s\n' '# File location is /etc/hostname'
        printf '%s\n' "${device_hostname}"
        printf '%s\n' ''
    } >>'/etc/hostname'
}

function setup_hosts_file() {
    # Parameters
    local device_hostname=${1}

    rm -f '/etc/hosts'
    {
        printf '%s\n' '# host file'
        printf '%s\n' '# file location is /etc/hosts'
        printf '%s\n' ''
        printf '%s\n' '127.0.0.1 localhost'
        printf '%s\n' '::1 localhost'
        printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
        printf '%s\n' ''
    } >>'/etc/hosts'
}

function set_root_password() {
    echo 'Set root password'
    passwd root
}

function set_systemd_boot_install_path() {
    bootctl --path=/boot install
}

function add_user_to_sudo() {
    # Parameters
    local user_name=${1}

    printf '%s\n' "${user_name} ALL=(ALL) ALL" >>'/etc/sudoers'
}

function enable_network_manager() {
    systemctl enable NetworkManager.service
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

function configure_i3_blueman_applet_autostart() {
    grep -q ".*blueman-applet" '/usr/local/bin/i3_autostart.sh' && sed -i "s,.*blueman-applet.*,blueman-applet &," '/usr/local/bin/i3_autostart.sh' || printf '%s\n' 'blueman-applet &' >>'/usr/local/bin/i3_autostart.sh'
}

function configure_i3_pasystray_autostart() {
    grep -q ".*pasystray" '/usr/local/bin/i3_autostart.sh' && sed -i "s,.*pasystray.*,pasystray &," '/usr/local/bin/i3_autostart.sh' || printf '%s\n' 'pasystray &' >>'/usr/local/bin/i3_autostart.sh'
}

function configure_i3_config_file() {
    # Parameters
    local user_name=${1}

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

exec --no-startup-id bash "/usr/local/bin/i3_autostart.sh"

EOF
}

function cli_autologin() {
    # Parameters
    local user_name=${1}

    mkdir -p '/etc/systemd/system//getty@tty1.service.d'
    cat <<EOF >'/etc/systemd/system/getty@tty1.service.d/override.conf'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${user_name} --noclear %I \$TERM
EOF
}

function set_shell_bash() {
    # Parameters
    local user_name=${1}

    chsh -s /bin/bash
    chsh -s /bin/bash "${user_name}"
}

function ufw_configure_rules() {
    # Parameters
    local network_prefix=${1}
    local limit_ssh=${2}
    local allow_dns=${3}
    local allow_unbound=${4}
    local allow_http=${5}
    local allow_https=${6}
    local allow_port_4711_tcp=${7}
    local allow_smb=${9}
    local allow_netbios=${9}
    local limit_port_64640=${10}
    local allow_port_8006=${11}
    local allow_omada_controller=${12}

    if [[ "${limit_ssh}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw limit proto tcp from "${network_prefix}" to any port 22
        ufw limit proto tcp from fe80::/10 to any port 22
    fi

    if [[ "${allow_dns}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 53
        ufw allow proto tcp from fe80::/10 to any port 53
        ufw allow proto udp from "${network_prefix}" to any port 53
        ufw allow proto udp from fe80::/10 to any port 53
    fi

    if [[ "${allow_unbound}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto udp from 127.0.0.1 to any port 5353
        ufw allow proto udp from ::1 to any port 5353
        ufw allow proto tcp from 127.0.0.1 to any port 5353
        ufw allow proto tcp from ::1 to any port 5353
    fi

    if [[ "${allow_http}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 80
        ufw allow proto tcp from fe80::/10 to any port 80
    fi

    if [[ "${allow_https}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 443
        ufw allow proto tcp from fe80::/10 to any port 443
    fi

    if [[ "${allow_port_4711_tcp}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 4711
        ufw allow proto tcp from fe80::/10 to any port 4711
    fi

    if [[ "${allow_smb}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 445
        ufw allow proto tcp from fe80::/10 to any port 445
    fi

    if [[ "${allow_netbios}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 137
        ufw allow proto tcp from fe80::/10 to any port 137
        ufw allow proto tcp from "${network_prefix}" to any port 138
        ufw allow proto tcp from fe80::/10 to any port 138
        ufw allow proto tcp from "${network_prefix}" to any port 139
        ufw allow proto tcp from fe80::/10 to any port 139
    fi

    if [[ "${limit_port_64640}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw limit proto udp from any to any port 64640
    fi

    if [[ "${allow_port_8006}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 8006
        ufw allow proto tcp from fe80::/10 to any port 8006
    fi

    if [[ "${allow_omada_controller}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ufw allow proto tcp from "${network_prefix}" to any port 8043
        ufw allow proto tcp from fe80::/10 to any port 8043
        ufw allow proto tcp from "${network_prefix}" to any port 8088
        ufw allow proto tcp from fe80::/10 to any port 8088
        ufw allow proto udp from "${network_prefix}" to any port 29810
        ufw allow proto udp from fe80::/10 to any port 29810
        ufw allow proto tcp from "${network_prefix}" to any port 29811
        ufw allow proto tcp from fe80::/10 to any port 29811
        ufw allow proto tcp from "${network_prefix}" to any port 29812
        ufw allow proto tcp from fe80::/10 to any port 29812
        ufw allow proto tcp from "${network_prefix}" to any port 29813
        ufw allow proto tcp from fe80::/10 to any port 29813
    fi

}

function get_ucode_type() {
    # Parameters
    local distro=${1}

    if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        if [[ "${distro}" =~ ^([dD][eE][bB][iI][aA][nN])+$ ]]; then
            ucode='intel-microcode'
        fi
        if [[ "${distro}" =~ ^([aA][rR][cC][hH])+$ ]]; then
            ucode='intel-ucode'
        fi
    else
        if [[ "${distro}" =~ ^([dD][eE][bB][iI][aA][nN])+$ ]]; then
            ucode='amd-microcode'
        fi
        if [[ "${distro}" =~ ^([aA][rR][cC][hH])+$ ]]; then
            ucode='amd-ucode'
        fi
    fi
}

function create_basic_partitions() {
    if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Creates one partition.  Partition uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    else
        # Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    fi
}

function create_basic_filesystems() {
    # Parameters
    local partition1=${1}
    local partition2=${2}
    local duel_boot=${3}

    mkfs.ext4 "${partition2}"
    if [[ ! "${duel_boot}" =~ ^([d][b])+$ ]]; then
        mkfs.fat -F32 "${partition1}"
    fi
}

function mount_basic_filesystems() {
    # Parameters
    local boot_partition=${1}
    local root_partition=${2}

    mount "${root_partition}" /mnt
    mkdir '/mnt/boot'
    mount "${boot_partition}" '/mnt/boot'
}

function mount_proc_and_sysfs() {
    {
        printf '%s\n' 'proc /mnt/proc proc defaults 0 0'
        printf '%s\n' 'sysfs /mnt/sys sysfs defaults 0 0'
    } >>'/etc/fstab'
    mount proc /mnt/proc -t proc
    mount sysfs /mnt/sys -t sysfs
}

function get_base_partition_uuids() {
    # Parameters
    local partition1=${1}
    local partition2=${2}

    uuid="$(blkid -o value -s UUID "${partition1}")"
    uuid2="$(blkid -o value -s UUID "${partition2}")"
}

function create_basic_partition_fstab() {
    {
        printf '%s\n' "UUID=${uuid} /boot/EFI vfat defaults 0 0"
        printf '%s\n' '/swapfile none swap defaults 0 0'
        printf '%s\n' "UUID=${uuid2} / ext4 defaults 0 0"
    } >>'/etc/fstab'
}

function mount_all_drives() {
    mount -a
}

function enable_base_network_connectivity() {
    # Parameters
    local interface=${1}

    {
        printf '%s\n' 'auto lo'
        printf '%s\n' 'iface lo inet loopback'
        printf '%s\n' "auto ${interface}"
        printf '%s\n' "iface ${interface} inet dhcp"
    } >>'/etc/network/interfaces'
}

function apt_clear_cache() {
    apt-get clean
}
