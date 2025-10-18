#!/bin/bash

# High-Bandwidth TCP Optimizations Script for Arch Linux
# Enables BBR congestion control and tunes TCP buffers for gigabit+ connections.
# Idempotent: Safe to run multiple times; only applies changes if needed.
# Run as root or with sudo.

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to check if a sysctl param matches a value
check_sysctl() {
    local param="$1"
    local expected="$2"
    sysctl -n "$param" 2>/dev/null | grep -q "^$expected$" || return 1
}

# Function to apply sysctl changes if file is modified
apply_sysctl_if_changed() {
    local file="$1"
    local content="$2"
    local temp_file=$(mktemp)

    echo "$content" > "$temp_file"

    if [[ -f "$file" ]]; then
        if cmp -s "$file" "$temp_file"; then
            rm "$temp_file"
            return 0  # No change needed
        fi
    fi

    # Backup existing file if it exists
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up $file to ${file}.bak.$(date +%Y%m%d_%H%M%S)"
    fi

    mv "$temp_file" "$file"
    log_info "Updated $file with optimizations"

    # Apply immediately
    sysctl --system >/dev/null 2>&1 || true  # Ignore errors if not all params exist yet
    return 1  # Changed
}

main() {
    if [[ $EUID -ne 0 ]]; then
        log_warn "This script requires root privileges. Rerun with sudo."
        exec sudo "$0" "$@"
    fi

    log_info "Starting high-bandwidth TCP optimizations..."

    changes_made=0

    # 1. Enable BBR TCP Congestion Control
    log_info "Configuring BBR congestion control..."
    BBR_FILE="/etc/sysctl.d/40-tcp-bbr.conf"
    BBR_CONTENT="net.ipv4.tcp_congestion_control = bbr"

    if check_sysctl "net.ipv4.tcp_congestion_control" "bbr"; then
        log_info "BBR is already enabled."
    else
        if apply_sysctl_if_changed "$BBR_FILE" "$BBR_CONTENT"; then
            changes_made=1
            log_info "BBR enabled. Verify with: sysctl net.ipv4.tcp_congestion_control"
        fi
    fi

    # 2. Tune TCP Buffers
    log_info "Tuning TCP buffers for high-bandwidth..."
    BUFFERS_FILE="/etc/sysctl.d/41-tcp-buffers.conf"
    BUFFERS_CONTENT=$(cat << 'EOF'
# TCP Buffer Tuning for High-Bandwidth Connections
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF
)

    # Check if all buffer settings match
    if check_sysctl "net.core.rmem_max" "16777216" &&
       check_sysctl "net.core.wmem_max" "16777216" &&
       check_sysctl "net.ipv4.tcp_rmem" "4096 87380 16777216" &&
       check_sysctl "net.ipv4.tcp_wmem" "4096 65536 16777216"; then
        log_info "TCP buffers are already tuned."
    else
        if apply_sysctl_if_changed "$BUFFERS_FILE" "$BUFFERS_CONTENT"; then
            changes_made=1
            log_info "TCP buffers tuned. Verify with: sysctl net.core.rmem_max net.core.wmem_max net.ipv4.tcp_rmem net.ipv4.tcp_wmem"
        fi
    fi

    # Final apply if any changes
    if [[ $changes_made -eq 1 ]]; then
        log_info "Applying all sysctl changes..."
        sysctl --system
        log_warn "For full effect on running connections, consider restarting NetworkManager or rebooting."
    else
        log_info "No changes needed; optimizations already applied."
    fi
}

main "$@"
