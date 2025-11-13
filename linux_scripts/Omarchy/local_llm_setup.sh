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
    yay -S --noconfirm "$pkg"
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

# Set ROCm env var for RX 6700XT (gfx1031)
readonly ROCm_ENV="export HSA_OVERRIDE_GFX_VERSION=10.3.0"
if ! grep -q "HSA_OVERRIDE_GFX_VERSION" ~/.bashrc; then
  echo "[*] Adding ROCm env var to ~/.bashrc..."
  echo "$ROCm_ENV" >> ~/.bashrc
  export HSA_OVERRIDE_GFX_VERSION=10.3.0
else
  echo "[=] ROCm env var already set"
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
yay_install ollama

echo "[*] Enabling and starting Ollama service..."
if ! systemctl is-enabled --quiet ollama; then
  sudo systemctl enable ollama
fi
sudo systemctl restart ollama

echo "[*] Sanity check: running ollama version"
ollama --version || echo "⚠ Ollama not responding — check logs with: journalctl -u ollama -f"

# Pull Qwen2.5-Coder model
readonly MODEL="qwen2.5-coder:32b-instruct-q4_K_M"
echo "[*] Pulling model: $MODEL"
if ! ollama list | grep -q "$MODEL"; then
  ollama pull "$MODEL"
else
  echo "[=] Model $MODEL already pulled"
fi

echo "[*] Installing VSCode..."
yay_install visual-studio-code-bin

# Install Continue.dev VSCode extension (assumes 'code' CLI available)
echo "[*] Installing Continue.dev VSCode extension..."
if ! code --list-extensions | grep -q "Continue.continue"; then
  code --install-extension Continue.continue
  echo "[=] Continue.dev extension installed"
else
  echo "[=] Continue.dev extension already installed"
fi

# Create Continue.dev config
readonly CONFIG_DIR="$HOME/.continue"
readonly CONFIG_FILE="$CONFIG_DIR/config.json"
echo "[*] Setting up Continue.dev config..."
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ] || ! grep -q "qwen2.5-coder:32b-instruct-q4_K_M" "$CONFIG_FILE"; then
  cat > "$CONFIG_FILE" << EOF
{
  "models": [
    {
      "title": "Qwen2.5-Coder-32B",
      "provider": "ollama",
      "model": "$MODEL",
      "contextLength": 262144,
      "completionOptions": { "temperature": 0.2, "maxTokens": 4096 }
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen2.5-Coder-32B",
    "provider": "ollama",
    "model": "$MODEL"
  },
  "tools": {
    "webSearch": {
      "enabled": true
    }
  }
}
EOF
  echo "[=] Continue.dev config created/updated at $CONFIG_FILE"
else
  echo "[=] Continue.dev config already set up"
fi

echo
echo "===================================================="
echo " Idempotent installation complete!"
echo " Next steps:"
echo " 1. Log out and back in (or reboot) for ROCm group changes."
echo " 2. Run 'source ~/.bashrc' to load ROCm env var."
echo " 3. Verify ROCm: 'rocm-smi' (should show RX 6700XT)."
echo " 4. Open VSCode, press Ctrl+Shift+P, search 'Continue: Open' to start."
echo " 5. For Ollama GPU use: Set OLLAMA_NUM_GPU_LAYERS=999 in env if needed."
echo " 6. Test: In Continue chat, ask 'Write a Python hello world'."
echo "===================================================="
