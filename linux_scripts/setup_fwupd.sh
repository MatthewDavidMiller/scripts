#!/bin/bash

pacman -S fwupd

cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

mkdir -p '/etc/pacman.d'
mkdir -p '/etc/pacman.d/hooks'
touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'

cat <<EOF > '/etc/pacman.d/hooks/fwupd-to-esp.hook'
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF