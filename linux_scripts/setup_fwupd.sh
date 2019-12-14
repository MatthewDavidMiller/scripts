#!/bin/bash
# Does not need to be executed as root.

sudo pacman -S --noconfirm --needed fwupd

sudo cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

sudo mkdir -p '/etc/pacman.d'
sudo mkdir -p '/etc/pacman.d/hooks'
sudo touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'

sudo cat <<EOF > '/etc/pacman.d/hooks/fwupd-to-esp.hook'
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF
