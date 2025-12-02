#!/bin/bash
# Proton/Gaming Setup for Arch Linux
# RX 6700XT + 64 GB RAM + regular Arch repositories + normal AUR

set -euo pipefail

echo "Setting up gaming environment (RX 6700XT + official repos + normal AUR)..."

# Full system update
sudo pacman -Syyu --noconfirm

# Enable multilib if needed
if ! grep -q '^\[multilib\]' /etc/pacman.conf || grep -q '^#\[multilib\]' /etc/pacman.conf; then
    echo "Enabling multilib repository..."
    sudo sed -i '/#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Syyu --noconfirm
fi

# Base tools
sudo pacman -S --needed base-devel git mkinitcpio

# Install yay if missing (AUR helper)
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# ────────────────────────────── Core Gaming Stack ──────────────────────────────
echo "Installing AMD drivers, kernel, and gaming tools from official repos + normal AUR..."

# Official AMD drivers (open-source, latest stable)
sudo pacman -S --needed \
    mesa lib32-mesa \
    vulkan-radeon lib32-vulkan-radeon \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud \
    gamescope

# AUR packages
yay -S --needed \
    proton-ge-custom \
    steamtinkerlaunch \
    protonup-qt \
    vkbasalt lib32-vkbasalt \
    jq ludusavi-bin

# Additional useful tools
sudo pacman -S --needed \
    gawk unzip wget xdotool xorg-xprop xorg-xrandr vim xorg-xwininfo yad

# Enable GameMode daemon
systemctl --user enable --now gamemoded || true

# ────────────────────────────── Sysctl & Hugepages (64 GB optimized) ──────────────────────────────
echo "Applying gaming sysctl tweaks..."
SYSCTL_CONF="/etc/sysctl.d/99-gaming-optimizations.conf"
sudo tee "$SYSCTL_CONF" > /dev/null << 'EOF'
vm.swappiness=1
vm.page-cluster=0
vm.watermark_scale_factor=200
vm.nr_hugepages=4096          # ~8 GB reserved for 64 GB RAM
vm.hugetlb_shm_group=0
kernel.pid_max=4194304
vm.max_map_count=1048576
kernel.sched_autogroup_enabled=0
kernel.sched_migration_cost_ns=500000
kernel.sched_nr_migrate=128
fs.file-max=1048576
EOF

# Create games group + set correct GID for hugetlb
getent group games >/dev/null || sudo groupadd games
sudo usermod -aG games "$USER"
GID=$(getent group games | cut -d: -f3)
sudo sed -i "s/vm.hugetlb_shm_group=0/vm.hugetlb_shm_group=$GID/" "$SYSCTL_CONF"
sudo sysctl --system

# Persistent THP = madvise
sudo mkdir -p /etc/tmpfiles.d
sudo tee /etc/tmpfiles.d/thp-madvise.conf > /dev/null << 'EOF'
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
w /sys/kernel/mm/transparent_hugepage/defrag   - - - - madvise
EOF
sudo systemd-tmpfiles --create

# ────────────────────────────── Done ──────────────────────────────
echo "====================================================================="
echo "Installation complete! Reboot recommended:"
echo "    sudo reboot"
echo ""
echo "After reboot verify:"
echo "    glxinfo | grep renderer → should show RADV ACO + Mesa version"
echo "    mangohud glxgears      → test overlay"
echo "====================================================================="
