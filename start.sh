#!/bin/bash
# Start local LLM services (Ollama + Open WebUI)
set -e

echo "==> Starting Ollama service..."
sudo systemctl start ollama

echo "==> Waiting for Ollama to be ready..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    sleep 1
done
echo "    Ollama is up."

echo "==> Starting Open WebUI..."
sudo systemctl start local-llm-webui

echo ""
echo "Services started!"
echo "  Ollama API  : http://10.0.0.190:11434"
echo "  Open WebUI  : http://10.0.0.190:8080"
