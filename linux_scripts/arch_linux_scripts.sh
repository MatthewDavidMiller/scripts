#!/bin/bash

# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions that can be called for Arch Linux.

function rank_mirrors() {
    cp '/etc/pacman.d/mirrorlist' '/etc/pacman.d/mirrorlist.backup'
    rm -f '/etc/pacman.d/mirrorlist'
    rankmirrors -n 40 '/etc/pacman.d/mirrorlist.backup' >>'/etc/pacman.d/mirrorlist'
}

function install_arch_packages() {
    # Prompts
    read -r -p "Install gnome desktop environment? [y/N] " gnome_response
    read -r -p "Install i3 windows manager? [y/N] " i3_response
    read -r -p "Install blender? [y/N] " blender_response
    read -r -p "Install gimp? [y/N] " gimp_response
    read -r -p "Install libreoffice? [y/N] " libreoffice_response
    read -r -p "Install vscode? [y/N] " vscode_response
    read -r -p "Install git? [y/N] " git_response
    read -r -p "Install putty? [y/N] " putty_response
    read -r -p "Install Nvidia LTS driver? [y/N] " nvidia_response
    read -r -p "Install dolphin file manager? [y/N] " dolphin_fm_response
    read -r -p "Install audacity? [y/N] " audacity_response
    read -r -p "Install nmap? [y/N] " nmap_response
    read -r -p "Install wireshark? [y/N] " wireshark_response
    read -r -p "Install ntop? [y/N] " ntop_response
    read -r -p "Install jnettop? [y/N] " jnettop_response
    read -r -p "Install nethogs? [y/N] " nethogs_response
    read -r -p "Install clamav? [y/N] " clamav_response
    read -r -p "Install vim? [y/N] " vim_response
    read -r -p "Install shellcheck? [y/N] " shellcheck_response
    read -r -p "Install tftpd? [y/N] " tftpd_response
    read -r -p "Install cmake? [y/N] " cmake_response
    read -r -p "Install pylint? [y/N] " pylint_response
    read -r -p "Install light? [y/N] " light_response
    read -r -p "Install rsync? [y/N] " rsync_response

    # Install gnome desktop environment
    if [[ "${gnome_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed gnome
    fi

    # Install i3 windows manager
    if [[ "${i3_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed i3-wm i3blocks i3lock i3status dmenu
    fi

    # Install blender
    if [[ "${blender_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed blender
    fi

    # Install gimp
    if [[ "${gimp_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed gimp
    fi

    # Install libreoffice
    if [[ "${libreoffice_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed libreoffice-fresh
    fi

    # Install vscode
    if [[ "${vscode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed code
    fi

    # Install git
    if [[ "${git_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed git
    fi

    # Install putty
    if [[ "${putty_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed putty
    fi

    # Install Nvidia LTS driver
    if [[ "${nvidia_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed nvidia-lts
    fi

    # Install dolphin file manager
    if [[ "${dolphin_fm_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed dolphin
    fi

    # Install audacity
    if [[ "${audacity_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed audacity
    fi

    # Install nmap
    if [[ "${nmap_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed nmap
    fi

    # Install wireshark
    if [[ "${wireshark_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed wireshark-cli wireshark-qt
    fi

    # Install ntop
    if [[ "${ntop_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed ntop
    fi

    # Install jnettop
    if [[ "${jnettop_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed jnettop
    fi

    # Install nethogs
    if [[ "${nethogs_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed nethogs
    fi

    # Install clamav
    if [[ "${clamav_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed clamav clamtk
    fi

    # Install vim
    if [[ "${vim_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed vim
    fi

    # Install shellcheck
    if [[ "${shellcheck_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed shellcheck
    fi

    # Install tftpd
    if [[ "${tftpd_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed tftp-hpa
    fi

    # Install cmake
    if [[ "${cmake_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed cmake
    fi

    # Install pylint
    if [[ "${pylint_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed python-pylint
    fi

    # Install light
    if [[ "${light_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed light
    fi

    # Install rsync
    if [[ "${rsync_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        pacman -S --noconfirm --needed rsync
    fi
}

function install_aur_packages() {
    # Get username
    user_name=$(logname)

    # Prompts
    read -r -p "Install freefilesync? [y/N] " response1
    read -r -p "Install spotify? [y/N] " response3
    read -r -p "Install vscode? [y/N] " response5

    # Install packages
    pacman -S --noconfirm --needed base-devel

    # Create a directory to use for compiling aur packages
    mkdir "/home/${user_name}/aur"
    chown "${user_name}" "/home/${user_name}/aur"
    chmod 744 "/home/${user_name}/aur"

    # Install freefilesync
    if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        mkdir "/home/${user_name}/aur/freefilesync"
        git clone 'https://aur.archlinux.org/freefilesync.git' "/home/${user_name}/aur/freefilesync"
        chown -R "${user_name}" "/home/${user_name}/aur/freefilesync"
        chmod -R 744 "/home/${user_name}/aur/freefilesync"
        cd "/home/${user_name}/aur/freefilesync" || exit
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to install? [y/N] " response2
        if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi

    # Install spotify
    if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        mkdir "/home/${user_name}/aur/spotify"
        git clone 'https://aur.archlinux.org/spotify.git' "/home/${user_name}/aur/spotify"
        chown -R "${user_name}" "/home/${user_name}/aur/spotify"
        chmod -R 744 "/home/${user_name}/aur/spotify"
        read -r -p "Choose the latest key. Press enter to continue: "
        sudo -u "${user_name}" gpg --keyserver 'hkp://keyserver.ubuntu.com' --search-key 'Spotify Public Repository Signing Key'
        cd "/home/${user_name}/aur/spotify" || exit
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to install? [y/N] " response4
        if [[ "${response4}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi

    # Install vscode
    if [[ "${response5}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        mkdir "/home/${user_name}/aur/vscode"
        git clone 'https://aur.archlinux.org/visual-studio-code-bin.git' "/home/${user_name}/aur/vscode"
        chown -R "${user_name}" "/home/${user_name}/aur/vscode"
        chmod -R 744 "/home/${user_name}/aur/vscode"
        cd "/home/${user_name}/aur/vscode" || exit
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        less PKGBUILD
        read -r -p "Ready to install? [y/N] " response6
        if [[ "${response6}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi
}

function update_aur_packages() {
    # Prompts
    read -r -p "Update freefilesync? [y/N] " response1
    read -r -p "Update spotify? [y/N] " response3
    read -r -p "Update vscode? [y/N] " response5

    # Get username
    user_name=$(logname)

    # Install packages
    pacman -S --noconfirm --needed base-devel

    # Update freefilesync
    if [[ "${response1}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cd "/home/${user_name}/aur/freefilesync" || exit
        git clean -df
        git checkout -- .
        git fetch
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        git diff master...origin/master
        read -r -p "Ready to update? [y/N] " response2
        if [[ "${response2}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            git pull
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi

    # Update spotify
    if [[ "${response3}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        read -r -p "Choose the latest key. Press enter to continue: "
        sudo -u "${user_name}" gpg --keyserver 'hkp://keyserver.ubuntu.com' --search-key 'Spotify Public Repository Signing Key'
        cd "/home/${user_name}/aur/spotify" || exit
        git clean -df
        git checkout -- .
        git fetch
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        git diff master...origin/master
        read -r -p "Ready to update? [y/N] " response4
        if [[ "${response4}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            git pull
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi

    # Update vscode
    if [[ "${response5}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cd "/home/${user_name}/aur/vscode" || exit
        git clean -df
        git checkout -- .
        git fetch
        read -r -p "Check the contents of the files before installing. Press enter to continue: "
        git diff master...origin/master
        read -r -p "Ready to update? [y/N] " response6
        if [[ "${response6}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            git pull
            sudo -u "${user_name}" makepkg -sirc
        fi
    fi
}

function arch_connect_to_wifi() {
    # Parameters
    local wifi_interface=${1}
    local ssid=${2}

    systemctl start "iwd.service"
    iw dev
    iwctl station "${wifi_interface}" scan
    iwctl station "${wifi_interface}" connect "${ssid}"
}

function arch_get_ucode_type() {
    if [[ "${ucode_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ucode='intel-ucode'
    else
        ucode='amd-ucode'
    fi
}

function arch_install_configure_partitions() {
    if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Creates one partition.  Partition uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    else
        # Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    fi
}

function arch_configure_mirrors() {
    rm -f '/etc/pacman.d/mirrorlist'
    cat <<\EOF >'/etc/pacman.d/mirrorlist'
Server = https://archlinux.surlyjake.com/archlinux/$repo/os/$arch
Server = https://mirror.arizona.edu/archlinux/$repo/os/$arch
Server = https://arch.mirror.constant.com/$repo/os/$arch
Server = https://mirror.dc02.hackingand.coffee/arch/$repo/os/$arch
Server = https://repo.ialab.dsu.edu/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirror.dal10.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.mia11.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.sfo12.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.wdc1.us.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.lty.me/archlinux/$repo/os/$arch
Server = https://reflector.luehm.com/arch/$repo/os/$arch
Server = https://mirrors.lug.mtu.edu/archlinux/$repo/os/$arch
Server = https://mirror.kaminski.io/archlinux/$repo/os/$arch
Server = https://iad.mirrors.misaka.one/archlinux/$repo/os/$arch
Server = https://mirrors.ocf.berkeley.edu/archlinux/$repo/os/$arch
Server = https://dfw.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://iad.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://ord.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
Server = https://mirrors.rutgers.edu/archlinux/$repo/os/$arch
Server = https://mirrors.sonic.net/archlinux/$repo/os/$arch
Server = https://arch.mirror.square-r00t.net/$repo/os/$arch
Server = https://mirror.stephen304.com/archlinux/$repo/os/$arch
Server = https://mirror.pit.teraswitch.com/archlinux/$repo/os/$arch
Server = https://mirrors.xtom.com/archlinux/$repo/os/$arch

EOF
}

function arch_install_base_packages_pacstrap() {
    pacstrap /mnt --noconfirm base base-devel linux linux-lts linux-firmware systemd e2fsprogs ntfs-3g exfat-utils vi man-db man-pages texinfo lvm2 xf86-video-intel xf86-video-amdgpu xf86-video-nouveau bash bash-completion ntp util-linux iwd || echo 'Script error, exiting.' && exit
}

function arch_install_extra_packages_pacstrap() {
    pacstrap /mnt --noconfirm ${ucode} efibootmgr pacman-contrib sudo networkmanager nm-connection-editor networkmanager-openvpn ufw wget gdm xorg xorg-xinit xorg-drivers xorg-server xorg-apps bluez bluez-utils blueman pulseaudio pulseaudio-bluetooth pavucontrol libinput xf86-input-libinput i3-wm i3blocks i3status i3lock dmenu firefox gnome-keyring seahorse termite htop dolphin cron kdenetwork-filesharing || echo 'Script error, exiting.' && exit
}

function arch_install_move_to_script_part_2() {
    cp linux_scripts.sh '/mnt/linux_scripts.sh'
    cp arch_linux_scripts.sh '/mnt/arch_linux_scripts.sh'
    wget -O '/mnt/arch_linux_install_part_2.sh' 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/arch_linux_install_part_2.sh'
    chmod +x '/mnt/arch_linux_install_part_2.sh'
    arch-chroot /mnt "./arch_linux_install_part_2.sh"
}

function arch_configure_kernel() {
    rm -f '/etc/mkinitcpio.conf'
    {
        printf '%s\n' '# config for kernel'
        printf '%s\n' '# file location is /etc/mkinitcpio.conf'
        printf '%s\n' ''
        printf '%s\n' 'MODULES=()'
        printf '%s\n' ''
        printf '%s\n' 'BINARIES=()'
        printf '%s\n' ''
        printf '%s\n' 'FILES=()'
        printf '%s\n' ''
        printf '%s\n' 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)'
        printf '%s\n' ''
    } >>'/etc/mkinitcpio.conf'
    mkinitcpio -P
}

function arch_setup_systemd_boot_luks_lvm() {
    mkdir '/boot/loader'
    mkdir '/boot/loader/entries'

    {
        printf '%s\n' '# kernel entry for systemd-boot'
        printf '%s\n' '# file location is /boot/loader/entries/arch_linux_lts.conf'
        printf '%s\n' ''
        printf '%s\n' 'title   Arch Linux LTS Kernel'
        printf '%s\n' 'linux   /vmlinuz-linux-lts'
        printf '%s\n' "initrd  /${ucode}.img"
        printf '%s\n' 'initrd  /initramfs-linux-lts.img'
        printf '%s\n' "options cryptdevice=UUID=${luks_partition_uuid}:cryptlvm root=UUID=${root_uuid} rw"
        printf '%s\n' ''
    } >>'/boot/loader/entries/arch_linux_lts.conf'

    {
        printf '%s\n' '# kernel entry for systemd-boot'
        printf '%s\n' '# file location is /boot/loader/entries/arch_linux.conf'
        printf '%s\n' ''
        printf '%s\n' 'title   Arch Linux Default Kernel'
        printf '%s\n' 'linux   /vmlinuz-linux'
        printf '%s\n' "initrd  /${ucode}.img"
        printf '%s\n' 'initrd  /initramfs-linux.img'
        printf '%s\n' "options cryptdevice=UUID=${luks_partition_uuid}:cryptlvm root=UUID=${root_uuid} rw"
        printf '%s\n' ''
    } >>'/boot/loader/entries/arch_linux.conf'

    {
        printf '%s\n' '# config for systemd-boot'
        printf '%s\n' '# file location is /boot/loader/loader.conf'
        printf '%s\n' ''
        printf '%s\n' 'default  arch_linux_lts'
        printf '%s\n' 'auto-entries 1'
        printf '%s\n' ''
    } >>'/boot/loader/loader.conf'
}
