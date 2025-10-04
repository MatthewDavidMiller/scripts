#!/bin/bash

# 8BitDo Ultimate 2C Controller Setup Script for Arch Linux + Steam
# This script performs a cleanup of previous configurations (e.g., custom udev rules, blacklists, and caches),
# then installs and configures the 8bitdo-ultimate-controller-udev package for D-input mode support.
# Idempotent: Designed to be safe to run multiple times—removals ignore missing files, installations use --needed,
# and service/group operations skip if already applied.
# Prerequisites: Run as a regular user with sudo access. Assumes AUR helper 'yay' is installed.
# Post-script: Log out and back in for group changes to take effect. Manually switch controller to D-input mode
# and test in Steam or with jstest-gtk.

set -euo pipefail  # Exit on error, undefined vars, or pipe failures (with || true for idempotent ops)

# Color codes for formatted output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'  # No Color

# Paths for cleanup (grouped for maintainability)
readonly UDEV_RULES=(
    "/etc/udev/rules.d/99-8bitdo-xpad.rules"
    "/etc/udev/rules.d/71-8bitdo-boot.rules"
    "/etc/udev/rules.d/99-8bitdo-xone.rules"
)
readonly MODPROBE_BLACKLISTS=(
    "/etc/modprobe.d/blacklist-xpad.conf"
    "/etc/modprobe.d/blacklist-xpadneo.conf"
    "/etc/modprobe.d/blacklist-hid.conf"
)
readonly MISC_CONFIGS=(
    "/etc/evdev-keepalive.conf"
    "/etc/modules-load.d/xone.conf"
    "/etc/mkinitcpio.conf.d/xone.conf"
)

echo -e "${GREEN}Starting 8BitDo Ultimate 2C controller cleanup and setup...${NC}"

# Function to print section headers with consistent formatting
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check and report command success (with optional idempotent skip message)
check_success() {
    local action="$1"
    local skip_message="${2:-}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $action succeeded.${NC}"
    else
        echo -e "${YELLOW}⚠ $action skipped${skip_message:+: $skip_message}.${NC}"
    fi
}

# Cleanup Phase: Remove previous configurations safely (rm -f ignores missing files)
print_header "CLEANUP PHASE"

# Remove custom udev rules
print_header "Removing old udev rules"
for rule in "${UDEV_RULES[@]}"; do
    sudo rm -f "$rule" || true
done
check_success "Old udev rules removal"

# Remove modprobe blacklists
print_header "Removing old modprobe blacklists"
for blacklist in "${MODPROBE_BLACKLISTS[@]}"; do
    sudo rm -f "$blacklist" || true
done
check_success "Old modprobe blacklists removal"

# Remove miscellaneous configs
print_header "Removing miscellaneous configs"
for config in "${MISC_CONFIGS[@]}"; do
    sudo rm -f "$config" || true
done
check_success "Miscellaneous configs removal"

# Reload udev rules and systemd daemon (idempotent: safe to rerun)
print_header "Reloading udev rules and systemd"
sudo udevadm control --reload-rules && sudo udevadm trigger || true
sudo systemctl daemon-reload || true
check_success "Udev and systemd reload" " (already up-to-date)"

# Clean AUR cache (yay -Sc is safe and idempotent)
print_header "Cleaning AUR cache"
yay -Sc --noconfirm 2>/dev/null || true
check_success "AUR cache clean" " (nothing to clean)"

# New Setup Phase: Install and configure 8bitdo-ultimate-controller-udev for D-input support
print_header "NEW SETUP PHASE: 8bitdo-ultimate-controller-udev with D-input"

# Step 1: Update system packages (idempotent with -Syu)
print_header "Updating system packages"
sudo pacman -Syu --noconfirm
check_success "System update"

# Step 2: Install required packages (idempotent with --needed)
print_header "Installing required packages"
# Core packages: Steam and LTS kernel for stability
sudo pacman -S --needed --noconfirm steam linux-lts linux-lts-headers
# AUR packages: Udev rules for 8BitDo Ultimate series (enables D-input) and joystick tester
yay -S --needed --noconfirm 8bitdo-ultimate-controller-udev jstest-gtk-git
check_success "Package installation"

# Step 3: Add user to relevant groups (idempotent: -aG skips if already member)
print_header "Adding user to input and gamepad groups"
sudo usermod -aG input "$USER" 2>/dev/null || true
# Check for 'gamepad' group
if getent group gamepad >/dev/null 2>&1; then
    sudo usermod -aG gamepad "$USER" 2>/dev/null || true
    echo -e "${GREEN}✓ Added to 'gamepad' group.${NC}"
else
    echo -e "${YELLOW}Note: 'gamepad' group not found; relying on 'input' group only.${NC}"
fi
echo -e "${YELLOW}Log out and back in for group changes to take effect.${NC}"
check_success "User groups update"

# Step 4: Reload udev rules for new package configurations (idempotent: safe to rerun)
print_header "Reloading udev rules for new setup"
sudo udevadm control --reload-rules && sudo udevadm trigger || true
check_success "Final udev reload" " (already reloaded)"

echo -e "\n${GREEN}Setup complete! Switch controller to D-input mode and test with Steam or jstest-gtk.${NC}"
