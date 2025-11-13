#!/bin/bash

# Script to set up Aider CLI with gpt-oss:20b model via Ollama on Arch Linux
# Assumes: Ollama is installed and running, yay AUR helper is available
# Idempotent: Skips steps if already completed; handles PATH updates gracefully
# Run as: bash setup_aider_gptoss.sh (make executable with chmod +x first if desired)

set -e  # Exit on any error (but we'll use || true where safe)

echo "=== Setting up Aider CLI with gpt-oss:20b ==="

# Ensure .local/bin exists
mkdir -p ~/.local/bin

# Step 0: Install uv if not present (for tool management)
echo "Checking/Installing uv..."
if ! command -v uv &> /dev/null; then
    sudo pacman -S --noconfirm uv
    echo "uv installed."
else
    echo "uv is already installed. Skipping."
fi

# Step 0.5: Update shell path for uv tools (idempotent: only if needed, ignore if up-to-date)
echo "Updating shell path with uv tool update-shell..."
if ! echo "$PATH" | grep -q "\.local/bin"; then
    uv tool update-shell || true  # Ignore "already up-to-date" error
    # Fallback: Manually ensure PATH export in .bashrc
    if ! grep -q "\.local/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    echo "Shell path updated. Restart your shell or run 'source ~/.bashrc' to apply changes."
else
    echo "PATH already includes ~/.local/bin. Skipping."
fi

# Reload bashrc in this script (affects only script; user still needs to source for their shell)
source ~/.bashrc || true

# Step 1: Install Aider via AUR (venv version for isolation)
echo "Installing Aider..."
if ! command -v aider &> /dev/null; then
    yay -S --noconfirm aider-chat-venv
    echo "Aider installed."
else
    echo "Aider is already installed. Skipping installation."
fi

# Step 2: Pull the gpt-oss:20b model (downloads ~40GB; one-time)
echo "Pulling gpt-oss:20b model..."
if ! ollama list | grep -q "gpt-oss:20b"; then
    ollama pull gpt-oss:20b
    echo "Model pulled."
else
    echo "gpt-oss:20b model already pulled. Skipping."
fi

# Step 3: Configure Aider to use gpt-oss:20b by default (overwrite if exists for consistency)
CONFIG_FILE="$HOME/.aider.conf.yml"
echo "Configuring Aider default model..."
cat > "$CONFIG_FILE" << EOF
# Aider configuration for Ollama with gpt-oss:20b
model: ollama_chat/gpt-oss:20b
# Optional: Increase context length for better performance (adjust based on your hardware)
num_ctx: 8192
# Enable Git integration (optional)
use-git: true
EOF
echo "Configuration updated."

echo "Setup complete!"
echo "To start Aider in a project directory:"
echo "  cd /path/to/your/project"
echo "  aider  # Uses gpt-oss:20b by default"
echo ""
echo "Test it: aider --version"
echo "Model info: ollama show gpt-oss:20b"
echo ""
echo "Note: If changes to PATH don't take effect immediately, run 'source ~/.bashrc' or restart your terminal."
