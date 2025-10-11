#!/bin/bash

# Exit on error
set -e

echo "Installing SteamTinkerLaunch and ProtonUp-Qt on Omarchy Linux (Arch-based)..."

# Update system and ensure base dependencies for AUR builds
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git

# Install SteamTinkerLaunch from AUR
echo "Installing steamtinkerlaunch..."
yay -S --noconfirm steamtinkerlaunch

# Install ProtonUp-Qt from AUR
echo "Installing protonup-qt..."
yay -S --noconfirm protonup-qt

# Install hard dependencies (most should be pulled automatically, but ensure key ones for STL)
sudo pacman -S --needed gawk unzip wget xdotool xorg-xprop xorg-xrandr vim xorg-xwininfo yad

# Optional: Install jq for better Proton version fetching (highly recommended)
yay -S --noconfirm jq

echo "Installation complete!"
echo "Next steps:"
echo "1. Restart Steam."
echo "2. Run 'steamtinkerlaunch compat add' to add STL as a compatibility tool."
echo "3. Launch ProtonUp-Qt (via menu or 'protonup-qt') to manage Proton versions."
echo "4. For optional features (e.g., MangoHud, GameMode), install them separately via pacman/yay."
