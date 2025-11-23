#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating system..."
sudo pacman -Syu --noconfirm

# Helper: install a package only if not already installed
install_pkg() {
  local pkg="$1"
  if ! pacman -Qi "$pkg" &>/dev/null; then
    echo "[*] Installing $pkg..."
    sudo pacman -S --noconfirm --needed "$pkg"
  else
    echo "[=] $pkg already installed"
  fi
}

# Helper: yay install if not installed
yay_install() {
  local pkg="$1"
  if ! pacman -Qi "$pkg" &>/dev/null; then
    echo "[*] Installing $pkg via yay..."
    yay -S --noconfirm --needed "$pkg"
  else
    echo "[=] $pkg already installed"
  fi
}

echo "[*] Installing ROCm runtime stack..."
install_pkg rocm-hip-sdk
install_pkg rocm-opencl-runtime
install_pkg rocblas
install_pkg rocm-smi-lib

# Add user to render/video groups for GPU access
echo "[*] Adding user to render/video groups..."
if ! groups | grep -qE "\b(render|video)\b"; then
  sudo usermod -aG render,video "$(whoami)"
  echo "[!] Please log out and log back in (or reboot) for group changes to take effect."
else
  echo "[=] Already in render/video groups"
fi

# Set gfx1031 override for RX 6700 XT
readonly ROCm_ENV="export HSA_OVERRIDE_GFX_VERSION=10.3.0"
if ! grep -q "HSA_OVERRIDE_GFX_VERSION" ~/.bashrc; then
  echo "[*] Adding HSA_OVERRIDE_GFX_VERSION=10.3.0 to ~/.bashrc"
  echo "$ROCm_ENV" >> ~/.bashrc
fi
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Optional: increase default context length
readonly OLLAMA_CTX="export OLLAMA_CONTEXT_LENGTH=262144"
if ! grep -q "OLLAMA_CONTEXT_LENGTH" ~/.bashrc; then
  echo "[*] Setting OLLAMA_CONTEXT_LENGTH=262144"
  echo "$OLLAMA_CTX" >> ~/.bashrc
fi

echo "[*] Ensuring yay is installed..."
if ! command -v yay &>/dev/null; then
  echo "[*] Installing yay AUR helper..."
  install_pkg git base-devel
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir"
  pushd "$tmpdir"
  makepkg -si --noconfirm
  popd && rm -rf "$tmpdir"
else
  echo "[=] yay already installed"
fi

# === Install ollama-rocm from AUR (best ROCm support for RX 6700 XT) ===
echo "[*] Installing ollama-rocm from AUR..."
yay_install ollama-rocm

# Configure ollama service with ROCm override and bind to all interfaces
echo "[*] Configuring ollama systemd service..."
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null << EOF
[Service]
Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"
Environment="OLLAMA_CONTEXT_LENGTH=262144"
Environment="OLLAMA_HOST=0.0.0.0"
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ollama || true
echo "[=] ollama-rocm service configured and started"

# Quick verification
sleep 5
if systemctl is-active --quiet ollama; then
  echo "✔ ollama service is running"
else
  echo "⚠ ollama service failed to start — check logs:"
  journalctl -u ollama --no-pager -n 30
fi

echo "[*] Pulling models (will use ROCm automatically)..."
readonly MODELS=(
  "gpt-oss:20b"
  "qwen2.5-coder:7b-instruct-q4_K_M"
  "qwen2.5-coder:14b-instruct-q4_K_M"
)
for model in "${MODELS[@]}"; do
  if ! ollama list | grep -q "$model"; then
    echo "[*] Pulling $model ..."
    ollama pull "$model"
  else
    echo "[=] $model already present"
  fi
done

echo
echo "===================================================="
echo " Setup complete — Ollama on ROCm"
echo "===================================================="
