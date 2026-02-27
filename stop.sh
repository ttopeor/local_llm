#!/bin/bash
# Stop local LLM services
# This script gracefully shuts down all local LLM-related services including Open WebUI and Ollama
echo "==> Stopping Open WebUI..."
# Suppress error messages if service is not running, continue anyway with || true
sudo systemctl stop local-llm-webui 2>/dev/null || true

echo "==> Stopping Ollama..."
sudo systemctl stop ollama 2>/dev/null || true

echo "Services stopped."
