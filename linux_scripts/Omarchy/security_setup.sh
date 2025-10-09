#!/bin/bash

# Initial Setup Script for OpenSnitch, Bubblewrap, Bubblejail, and UFW on Arch Linux
# Run as a non-root user with sudo privileges.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

echo -e "${GREEN}Starting initial setup for OpenSnitch, Bubblewrap, Bubblejail, and UFW...${NC}"

# Update the system
echo -e "${YELLOW}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# Install OpenSnitch from official repos if not present
if ! pacman -Q opensnitch >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing OpenSnitch...${NC}"
    sudo pacman -S --noconfirm opensnitch
else
    echo -e "${GREEN}OpenSnitch already installed.${NC}"
fi

# Enable and start OpenSnitch service
echo -e "${YELLOW}Enabling and starting OpenSnitch service...${NC}"
sudo systemctl enable --now opensnitchd
if systemctl is-active --quiet opensnitchd; then
    echo -e "${GREEN}OpenSnitch service is active.${NC}"
else
    echo -e "${RED}Warning: OpenSnitch service failed to start. Check with 'systemctl status opensnitch'.${NC}"
fi

# Install Bubblewrap from official repos if not present
if ! pacman -Q bubblewrap >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing Bubblewrap...${NC}"
    sudo pacman -S --noconfirm bubblewrap
else
    echo -e "${GREEN}Bubblewrap already installed.${NC}"
fi

# Install Bubblejail from AUR if not present
if ! pacman -Q bubblejail >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing Bubblejail from AUR...${NC}"
    yay -S --noconfirm bubblejail
else
    echo -e "${GREEN}Bubblejail already installed.${NC}"
fi

# Install UFW from official repos if not present
if ! pacman -Q ufw >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing UFW...${NC}"
    sudo pacman -S --noconfirm ufw
else
    echo -e "${GREEN}UFW already installed.${NC}"
fi

# Configure UFW: Reset rules, set defaults, and enable
echo -e "${YELLOW}Configuring UFW: Resetting rules and setting defaults...${NC}"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed
sudo ufw enable

# Enable and start UFW systemd service
echo -e "${YELLOW}Enabling and starting UFW systemd service...${NC}"
sudo systemctl enable --now ufw
if systemctl is-active --quiet ufw; then
    echo -e "${GREEN}UFW service is active.${NC}"
else
    echo -e "${RED}Warning: UFW service failed to start. Check with 'systemctl status ufw'.${NC}"
fi

if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}UFW is active with default deny incoming, allow outgoing, deny routed.${NC}"
else
    echo -e "${RED}Warning: UFW failed to enable. Check with 'sudo ufw status verbose'.${NC}"
fi

# Post-install notes (shown every run for reference)
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "  - Launch OpenSnitch UI: opensnitch-ui"
echo "  - For Bubblejail, edit profiles in ~/.config/bubblejail/ and run e.g., 'bubblejail --profile=default <app>'"
echo "  - Check UFW status: sudo ufw status verbose"
