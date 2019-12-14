#!/bin/bash
# Does not need to be executed as root.

# Create temporary file
temp=$(mktemp)

# Install fwupd
sudo pacman -S --noconfirm --needed fwupd

# Copy efi file
sudo cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

# Setup hook
sudo mkdir -p '/etc/pacman.d'
sudo mkdir -p '/etc/pacman.d/hooks'
sudo touch '/etc/pacman.d/hooks/fwupd-to-esp.hook'
cat <<EOF > "${temp}"
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/fwupd/efi/fwupdx64.efi

[Action]
When = PostTransaction
Exec = /usr/bin/cp -a /usr/lib/fwupd/efi/fwupdx64.efi /boot/EFI/

EOF

sudo cp "${temp}" '/etc/pacman.d/hooks/fwupd-to-esp.hook'
