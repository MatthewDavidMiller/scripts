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

echo "[*] Installing ROCm runtime stack..."
install_pkg rocm-hip-sdk
install_pkg rocm-opencl-runtime
install_pkg rocblas
install_pkg rocm-smi-lib

echo "[*] Verifying GPU support..."
if rocminfo | grep -q "gfx1031"; then
  echo "✔ RX 6700XT (gfx1031) detected and supported by ROCm"
else
  echo "⚠ ROCm did not report gfx1031 — check kernel/driver setup"
fi

echo "[*] Ensuring yay (AUR helper) is installed..."
if ! command -v yay &>/dev/null; then
  echo "[*] Installing yay..."
  install_pkg git
  install_pkg base-devel
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  pushd "$tmpdir/yay"
  makepkg -si --noconfirm
  popd
  rm -rf "$tmpdir"
else
  echo "[=] yay already installed"
fi

echo "[*] Installing Ollama..."
if ! pacman -Qi ollama &>/dev/null; then
  yay -S --noconfirm ollama
else
  echo "[=] Ollama already installed"
fi

echo "[*] Enabling and starting Ollama service..."
if ! systemctl is-enabled --quiet ollama; then
  sudo systemctl enable ollama
fi
sudo systemctl restart ollama

echo "[*] Sanity check: running ollama version"
ollama --version || echo "⚠ Ollama not responding — check logs with: journalctl -u ollama -f"

echo
echo "===================================================="
echo " Idempotent installation complete!"
echo " Try running: ollama run llama3"
echo "===================================================="
