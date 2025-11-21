#!/bin/bash
# Proton/Gaming Setup for Omarchy Linux (Arch-based)
# RX 6700XT + 64 GB RAM + CachyOS kernel + Chaotic-AUR (zero compile time)

set -euo pipefail

echo "Setting up gaming environment (RX 6700XT + CachyOS + Chaotic-AUR)..."

# Full system update
sudo pacman -Syyu

# Enable multilib if needed
if ! grep -q '^\[multilib\]' /etc/pacman.conf || grep -q '^#\[multilib\]' /etc/pacman.conf; then
    echo "Enabling multilib repository..."
    sudo sed -i '/#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Syyu
fi

# Base tools
sudo pacman -S --needed base-devel git mkinitcpio

# Install yay (idempotent)
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si)
    rm -rf /tmp/yay
fi

# ────────────────────────────── Chaotic-AUR (idempotent) ──────────────────────────────
echo "Adding Chaotic-AUR (pre-compiled mesa-tkg-git, linux-cachyos, etc.)..."

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U --needed \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Fully idempotent repo addition (removes duplicates, places at end)
add_chaotic_aur() {
    local conf="/etc/pacman.conf"
    sudo sed -i '/^\[chaotic-aur\]/,/Include/d' "$conf" 2>/dev/null || true
    sudo sed -i '/^$/d' "$conf" 2>/dev/null || true
    printf "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | sudo tee -a "$conf" > /dev/null
}
add_chaotic_aur

sudo pacman -Syyu

# ────────────────────────────── Core Gaming Stack ──────────────────────────────
echo "Installing drivers & kernel (mesa-tkg-git + linux-cachyos)..."

sudo pacman -S --needed \
    mesa-tkg-git lib32-mesa-tkg-git \
    linux-cachyos linux-cachyos-headers \
    proton-ge-custom-bin \
    mangohud-git gamemode lib32-gamemode \
    gamescope-git vkbasalt

# Tools
yay -S --needed limine-entry-tool steamtinkerlaunch protonup-qt jq

sudo pacman -S --needed gawk unzip wget xdotool xorg-xprop xorg-xrandr vim xorg-xwininfo yad

# Enable GameMode daemon
systemctl --user enable --now gamemoded 2>/dev/null || true

# Regenerate initramfs + update Limine
sudo mkinitcpio -P
sudo limine-update

# ────────────────────────────── Sysctl & Hugepages (64 GB optimized) ──────────────────────────────
echo "Applying gaming sysctl tweaks..."
SYSCTL_CONF="/etc/sysctl.d/99-gaming-optimizations.conf"
sudo tee "$SYSCTL_CONF" > /dev/null << 'EOF'
vm.swappiness=1
vm.page-cluster=0
vm.watermark_scale_factor=200
vm.nr_hugepages=4096          # ~8 GB reserved
vm.hugetlb_shm_group=0        # patched below
kernel.pid_max=4194304
vm.max_map_count=1048576
kernel.sched_autogroup_enabled=0
kernel.sched_migration_cost_ns=500000
kernel.sched_nr_migrate=128
fs.file-max=1048576
EOF

# games group + hugetlb (idempotent)
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
echo "Installation complete! Reboot now:"
echo "    sudo reboot"
echo ""
echo "After reboot verify:"
echo "    uname -r               → should contain 'cachyos'"
echo "    glxinfo | grep renderer → should show RADV + TKG version"
echo "    mangohud glxgears      → test overlay"
echo "====================================================================="
