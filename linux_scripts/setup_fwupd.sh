#!/bin/bash
# Does not need to be executed as root.

function configure_fwupd() {
    # Install fwupd
    sudo pacman -S --noconfirm --needed fwupd

    # Copy efi file
    sudo cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

    # Setup hook
    sudo mkdir -p '/etc/pacman.d'
    sudo mkdir -p '/etc/pacman.d/hooks'
    sudo touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'
    sudo bash -c "cat <<EOF > '/etc/pacman.d/hooks/fwupd-to-esp.hook'
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF"
}

# Call functions
configure_fwupd
