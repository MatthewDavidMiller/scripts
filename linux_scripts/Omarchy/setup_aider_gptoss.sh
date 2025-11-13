#!/bin/bash

# Script to set up Aider CLI with gpt-oss:20b model via Ollama on Arch Linux
# Idempotent: Validates/skips if configs are good; uses hyphens & Ollama-specific params
# Run as: ./setup_aider_gptoss_fixed.sh

set -e

echo "=== Fixing/Setting up Aider CLI with gpt-oss:20b ==="

# Ensure .local/bin exists
mkdir -p ~/.local/bin

# Step 0: Install uv if not present
echo "Checking/Installing uv..."
if ! command -v uv &> /dev/null; then
    sudo pacman -S --noconfirm uv || (echo "Failed to install uv; install manually." && exit 1)
    echo "uv installed."
else
    echo "uv is already installed. Skipping."
fi

# Step 0.5: Update shell path (idempotent)
echo "Updating shell path..."
if ! echo "$PATH" | grep -q "\.local/bin"; then
    uv tool update-shell || true
    if ! grep -q "\.local/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    echo "Shell path updated. Run 'source ~/.bashrc' if needed."
else
    echo "PATH already includes ~/.local/bin. Skipping."
fi
source ~/.bashrc || true

# Step 1: Install Aider via AUR
echo "Installing Aider..."
if ! command -v aider &> /dev/null; then
    yay -S --noconfirm aider-chat-venv
    echo "Aider installed."
else
    echo "Aider is already installed. Skipping."
fi

# Step 2: Pull model
echo "Pulling gpt-oss:20b model..."
if ! ollama list | grep -q "gpt-oss:20b"; then
    ollama pull gpt-oss:20b
    echo "Model pulled."
else
    echo "Model already pulled. Skipping."
fi

# Helper: Validate YAML file (loads with python & checks keys)
validate_yaml() {
    local file="$1"; shift
    local required_keys=("$@")
    if [[ ! -f "$file" ]]; then return 1; fi
    if ! python3 -c "import yaml, sys; data=yaml.safe_load(open('$file', 'r')); sys.exit(0 if data else 1)" 2>/dev/null; then
        echo "YAML parse failed for $file"
        return 1
    fi
    local data
    data=$(python3 -c "import yaml; print(yaml.safe_load(open('$file', 'r')))")
    for key in "${required_keys[@]}"; do
        if ! echo "$data" | grep -q "\"$key\":"; then  # Check for key in dumped dict
            return 1
        fi
    done
    return 0
}

# Step 3: Configure main .aider.conf.yml (hyphens; skip if valid)
CONFIG_FILE="$HOME/.aider.conf.yml"
echo "Configuring Aider defaults..."
if ! validate_yaml "$CONFIG_FILE" "model" "git" "max-chat-history-tokens"; then
    cat > "$CONFIG_FILE" << 'EOF'
# Aider configuration for Ollama with gpt-oss:20b (valid YAML with hyphens)
model: ollama_chat/gpt-oss:20b
# Enable Git integration
git: true
# Soft limit on chat history tokens (summarizes beyond this)
max-chat-history-tokens: 4000
EOF
    echo "Main config updated."
else
    echo "Main config is valid. Skipping."
fi

# Step 4: Configure model settings (Ollama-specific: num_ctx, num_predict)
MODEL_SETTINGS_FILE="$HOME/.aider.model.settings.yml"
echo "Configuring model settings..."
if ! validate_yaml "$MODEL_SETTINGS_FILE" "name" "extra_params" "num_ctx"; then
    cat > "$MODEL_SETTINGS_FILE" << 'EOF'
# Model-specific settings for Ollama (use ollama_chat/ prefix)
- name: ollama_chat/gpt-oss:20b
  extra_params:
    num_ctx: 8192    # Input context window (higher = more context, but slower)
    num_predict: 2048  # Max output tokens per response (adjust as needed)
EOF
    echo "Model settings updated."
else
    echo "Model settings are valid. Skipping."
fi

# Step 5: Set Ollama env in ~/.bashrc (fallback for context)
if ! grep -q "OLLAMA_CONTEXT_LENGTH" ~/.bashrc; then
    echo "export OLLAMA_CONTEXT_LENGTH=8192" >> ~/.bashrc
    echo "Added OLLAMA_CONTEXT_LENGTH to ~/.bashrc."
fi

# Step 6: Restart Ollama with env (if running)
if systemctl --user is-active --quiet ollama; then
    systemctl --user stop ollama
    OLLAMA_CONTEXT_LENGTH=8192 ollama serve &  # Background; or use systemd override for persistence
    echo "Ollama restarted with 8k context."
fi

echo "Setup complete! Test with: aider --version"
echo "If issues: source ~/.bashrc && pkill ollama && OLLAMA_CONTEXT_LENGTH=8192 ollama serve"
echo "For even larger context: Edit num_ctx in ~/.aider.model.settings.yml (e.g., 16384) and recreate model via Modelfile if needed."
