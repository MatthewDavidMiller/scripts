#!/bin/bash

# Exit on error
set -e

echo "Setting up optimal gaming environment for Proton on Omarchy Linux (Arch-based)..."

# Update system
sudo pacman -Syu --noconfirm

# Enable multilib repository if not already enabled (required for 32-bit libraries)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib repository..."
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
fi

# Ensure base dependencies for AUR builds
sudo pacman -S --needed base-devel git

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Install AMD/Intel GPU drivers with Vulkan support
echo "Installing AMD/Intel GPU drivers..."
sudo pacman -S --needed mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader

# Install performance-oriented kernel
echo "Installing linux-zen kernel..."
sudo pacman -S --needed linux-zen linux-zen-headers

# Install limine-entry-tool if not present and update Limine config
if ! command -v limine-update &> /dev/null; then
    echo "Installing limine-entry-tool for automated Limine config updates..."
    yay -S --noconfirm limine-entry-tool
fi
sudo limine-update
echo "linux-zen kernel installed and Limine config updated. Reboot to use it."

# Install and enable GameMode
echo "Installing and enabling GameMode..."
sudo pacman -S --needed gamemode lib32-gamemode
if ! systemctl --user is-enabled --quiet gamemoded; then
    systemctl --user enable --now gamemoded
fi

# Apply sysctl optimizations
echo "Applying sysctl gaming optimizations..."
SYSCTL_CONF="/etc/sysctl.d/99-gaming.conf"
if [ ! -f "$SYSCTL_CONF" ]; then
    sudo tee "$SYSCTL_CONF" > /dev/null << EOF
vm.swappiness=10
vm.max_map_count=2147483642
kernel.sched_autogroup_enabled=1
mitigations=off
EOF
fi
sudo sysctl --system

# Install SteamTinkerLaunch from AUR
echo "Installing SteamTinkerLaunch..."
yay -S --noconfirm steamtinkerlaunch

# Install ProtonUp-Qt from AUR
echo "Installing ProtonUp-Qt..."
yay -S --noconfirm protonup-qt

# Install hard dependencies (most should be pulled automatically, but ensure key ones for STL)
sudo pacman -S --needed gawk unzip wget xdotool xorg-xprop xorg-xrandr vim xorg-xwininfo yad

# Optional: Install jq for better Proton version fetching (highly recommended)
yay -S --noconfirm jq

echo "Installation complete!"
