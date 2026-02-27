#!/bin/bash
# One-time setup: Install Ollama + Open WebUI, configure LAN access
set -e

echo "===================================================="
echo "  Local LLM Setup (gpt-oss:120b for LAN)"
echo "===================================================="

# 1. Install Ollama
echo ""
echo "[1/5] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# 2. Configure Ollama to listen on all interfaces (for LAN access)
echo ""
echo "[2/5] Configuring Ollama for LAN access..."
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama

echo "    Waiting for Ollama to start..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    sleep 1
done
echo "    Ollama is running on port 11434."

# 3. Pull gpt-oss:120b
echo ""
echo "[3/5] Pulling gpt-oss:120b (~65GB, may take a while)..."
ollama pull gpt-oss:120b
echo "    Model ready."

# 4. Install Open WebUI (Python, no Docker needed)
echo ""
echo "[4/5] Installing Open WebUI..."
pip install open-webui --quiet

# 5. Create Open WebUI systemd service
echo ""
echo "[5/5] Setting up Open WebUI as a system service..."
WEBUI_BIN=$(which open-webui 2>/dev/null || python3 -m site --user-base 2>/dev/null | xargs -I{} echo "{}/bin/open-webui")
CURRENT_USER=$(whoami)

WEBUI_DATA_DIR="/home/${CURRENT_USER}/.local/share/open-webui"
mkdir -p "${WEBUI_DATA_DIR}"

sudo tee /etc/systemd/system/local-llm-webui.service > /dev/null <<EOF
[Unit]
Description=Open WebUI (Local LLM Chat Interface)
After=ollama.service
Requires=ollama.service

[Service]
Type=simple
User=${CURRENT_USER}
Environment="OLLAMA_BASE_URL=http://127.0.0.1:11434"
Environment="WEBUI_AUTH=False"
Environment="DATA_DIR=${WEBUI_DATA_DIR}"
WorkingDirectory=${WEBUI_DATA_DIR}
ExecStart=${WEBUI_BIN} serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable local-llm-webui
sudo systemctl start local-llm-webui

echo ""
echo "===================================================="
echo "  Setup Complete!"
echo "===================================================="
echo ""
echo "  API for apps (OpenAI-compatible):"
echo "    http://10.0.0.190:11434/v1"
echo "    Model name: gpt-oss:120b"
echo ""
echo "  Chat UI for family:"
echo "    http://10.0.0.190:8080"
echo ""
echo "  Check service status:"
echo "    systemctl status ollama"
echo "    systemctl status local-llm-webui"
echo ""
