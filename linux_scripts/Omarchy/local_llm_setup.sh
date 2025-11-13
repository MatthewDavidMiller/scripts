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
install_pkg linux-headers  # Needed for amdgpu modules

# Add user to groups for ROCm access (Arch-specific: render and video only)
echo "[*] Adding user to ROCm groups (render, video)..."
readonly ROCm_GROUPS="render,video"
if ! groups | grep -qE "(render|video)"; then
  sudo usermod -a -G "$ROCm_GROUPS" "$(whoami)"
  echo "[!] Log out and back in (or reboot) for group changes to take effect."
else
  echo "[=] User already in required groups (render, video)"
fi

# Set ROCm env var for RX 6700XT (gfx1031) early
readonly ROCm_ENV="export HSA_OVERRIDE_GFX_VERSION=10.3.0"
if ! grep -q "HSA_OVERRIDE_GFX_VERSION" ~/.bashrc; then
  echo "[*] Adding ROCm env var to ~/.bashrc..."
  echo "$ROCm_ENV" >> ~/.bashrc
fi
export HSA_OVERRIDE_GFX_VERSION=10.3.0  # Apply immediately

# Set Ollama context length env var (for 256k default)
readonly OLLAMA_CTX_ENV="export OLLAMA_CONTEXT_LENGTH=262144"
if ! grep -q "OLLAMA_CONTEXT_LENGTH" ~/.bashrc; then
  echo "[*] Adding Ollama context length env var to ~/.bashrc..."
  echo "$OLLAMA_CTX_ENV" >> ~/.bashrc
else
  echo "[=] Ollama context length env var already set"
fi

echo "[*] Verifying GPU support (with override)..."
if HSA_OVERRIDE_GFX_VERSION=10.3.0 rocminfo | grep -q "gfx1031"; then
  echo "✔ RX 6700XT (gfx1031) detected and supported by ROCm (unofficial override)"
else
  echo "⚠ ROCm did not report gfx1031 — common for unofficial support. Check:"
  echo "  - Reboot after install"
  echo "  - amdgpu module: lsmod | grep amdgpu"
  echo "  - Full rocminfo: HSA_OVERRIDE_GFX_VERSION=10.3.0 rocminfo"
  echo "  Note: gfx1031 is unofficial; community guides recommend this env var."
fi

# Verify amdgpu driver
if lsmod | grep -q amdgpu; then
  echo "✔ amdgpu kernel module loaded"
else
  echo "⚠ amdgpu module not loaded — run 'sudo modprobe amdgpu' or reboot"
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

echo "[*] Installing VSCode (for Continue.dev)..."
yay_install visual-studio-code-bin

echo "[*] Installing Ollama (official binary for ROCm compatibility)..."
if ! command -v ollama &>/dev/null || [ ! -f /usr/local/bin/ollama ]; then
  echo "[*] Removing Arch package if present (ROCm issues reported)..."
  sudo pacman -Rns --noconfirm ollama &>/dev/null || true
  echo "[*] Installing official Ollama via script..."
  curl -fsSL https://ollama.com/install.sh | sh
else
  echo "[=] Official Ollama already installed"
fi

echo "[*] Enabling and starting Ollama service..."
if ! systemctl is-enabled --quiet ollama; then
  sudo systemctl enable ollama
fi
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Wait and check service
sleep 5
if ! systemctl is-active --quiet ollama; then
  echo "⚠ Ollama service failed to start. Checking logs..."
  journalctl -u ollama -n 20 --no-pager
  echo "[*] Trying manual start: ollama serve (run in background if needed)"
  nohup ollama serve > ollama.log 2>&1 &
  sleep 3
else
  echo "✔ Ollama service started"
fi

echo "[*] Sanity check: running ollama version"
if ollama --version; then
  echo "✔ Ollama responding"
else
  echo "⚠ Ollama not responding — run 'ollama serve' manually and check ollama.log"
  echo "Common ROCm fix: Ensure HSA_OVERRIDE_GFX_VERSION=10.3.0 is set; reboot if needed."
fi

# Pull Qwen2.5-Coder model
readonly MODEL="qwen2.5-coder:32b-instruct-q4_K_M"
echo "[*] Pulling model: $MODEL"
if ! ollama list | grep -q "$MODEL"; then
  ollama pull "$MODEL"
else
  echo "[=] Model $MODEL already pulled"
fi

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
echo " Troubleshooting Notes:"
echo " - ROCm gfx1031 is unofficial: Use env var for apps like Ollama."
echo " - If Ollama still fails: Reboot, then 'HSA_OVERRIDE_GFX_VERSION=10.3.0 ollama serve'"
echo " - Check ROCm full: HSA_OVERRIDE_GFX_VERSION=10.3.0 rocm-smi"
echo " - Context length now defaulted to 256k via OLLAMA_CONTEXT_LENGTH env var."
echo " Next steps:"
echo " 1. Reboot for ROCm groups and modules."
echo " 2. Run 'source ~/.bashrc' to load env vars."
echo " 3. Verify: HSA_OVERRIDE_GFX_VERSION=10.3.0 rocm-smi (should show RX 6700XT)."
echo " 4. Open VSCode, Ctrl+Shift+P > 'Continue: Open'."
echo " 5. Test Ollama: 'ollama run $MODEL' (add env var if GPU not used)."
echo " 6. In Continue: Ask 'Write a Python hello world'."
echo "===================================================="
