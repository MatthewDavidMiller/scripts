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
install_pkg linux-headers

# Add user to render/video groups for GPU access
echo "[*] Adding user to render/video groups..."
if ! groups | grep -qE "\b(render|video)\b"; then
  sudo usermod -aG render,video "$(whoami)"
  echo "[!] Please log out and log back in (or reboot) for group changes to take effect."
else
  echo "[=] Already in render/video groups"
fi

# Set gfx1031 override for RX 6700 XT (still needed even with ollama-rocm)
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

# === Install uv — prefer official Arch repo package (best integration & updates) ===
echo "[*] Installing uv (preferring official Arch package)..."
if ! command -v uv &>/dev/null; then
  echo "[*] Installing uv from official repositories..."
  install_pkg uv
else
  echo "[=] uv already installed"
fi

echo "[*] Installing VSCode..."
yay_install visual-studio-code-bin

# === USE AUR ollama-rocm PACKAGE (best ROCm support for RX 6700 XT) ===
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
  "qwen2.5-coder:7b-instruct-q4_K_M"
  "qwen2.5-coder:14b-instruct-q4_K_M"
  "qwen3:8b-q4_K_M"
  "gemma3:4b"
)
for model in "${MODELS[@]}"; do
  if ! ollama list | grep -q "$model"; then
    echo "[*] Pulling $model ..."
    ollama pull "$model"
  else
    echo "[=] $model already present"
  fi
done

# Continue extension
code --install-extension Continue.continue 2>/dev/null || true

# Ensure PATH includes ~/.local/bin
grep -q "$HOME/.local/bin" ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Final Continue config with on-demand SearXNG
CONFIG_DIR="$HOME/.continue"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" << 'EOF'
name: ContinueConfig
version: 1.0.0
schema: v1

models:
  - name: Qwen2.5-Coder-7B-Instruct
    provider: ollama
    model: qwen2.5-coder:7b-instruct-q4_K_M
    roles: [chat, edit, apply]
    capabilities: [tool_use]
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 65536
      contextLength: 262144

  - name: Qwen2.5-Coder-14B-Instruct
    provider: ollama
    model: qwen2.5-coder:14b-instruct-q4_K_M
    roles: [chat, edit, apply]
    capabilities: [tool_use]
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 65536
      contextLength: 262144

  - name: Qwen3-8B
    provider: ollama
    model: qwen3:8b-q4_K_M
    roles: [chat, edit, apply]
    capabilities: [tool_use]
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 65536
      contextLength: 262144

  - name: Gemma3-4B
    provider: ollama
    model: gemma3:4b
    roles: [chat, edit, apply]
    capabilities: [tool_use]
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 65536
      contextLength: 262144

context:
  - provider: file
  - provider: code
  - provider: diff
  - provider: terminal
  - provider: http

# Fully private, on-demand web search — starts only when you use Agent mode
mcpServers:
  - name: SearXNG (local, private, on-demand)
    command: continue-searxng-mcp

rules: []
prompts: []
EOF

echo "[*] Setup complete! SearXNG will auto-start only when needed."

echo
echo "===================================================="
echo " All done — fully local & private web search!"
echo ""
echo " Behavior:"
echo " • SearXNG container starts in <3 seconds the first time you use Agent mode"
echo " • Automatically stops ~5 minutes after you close VSCode (or manually: docker stop searxng-on-demand)"
echo " • Uses ZERO resources when you're not using Continue in Agent mode"
echo " • 100% private — no API keys, no telemetry"
echo ""
echo " Next steps:"
echo " 1. Reboot (or log out/in) for GPU groups"
echo " 2. source ~/.bashrc"
echo " 3. Open VSCode → Continue → switch to Agent mode"
echo " 4. Ask: \"What is the current Arch Linux kernel version?\""
echo "     → SearXNG spins up automatically and answers correctly"
echo "===================================================="
