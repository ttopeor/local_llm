#!/bin/bash
# Test the local LLM API
HOST="${1:-localhost}"

# Read current model from config, fallback to gpt-oss:120b
CONFIG_FILE="$(dirname "$0")/.current-model"
if [[ -f "$CONFIG_FILE" ]]; then
    MODEL=$(cat "$CONFIG_FILE")
else
    MODEL="gpt-oss:120b"
fi

echo "Testing Ollama API at http://${HOST}:11434 ..."
echo "Active model: $MODEL"
echo ""

# List available models
echo "=== Available Models ==="
curl -s "http://${HOST}:11434/api/tags" | python3 -c "
import json,sys
data = json.load(sys.stdin)
for m in data.get('models', []):
    size_gb = m['size'] / 1e9
    print(f\"  {m['name']}  ({size_gb:.1f} GB)\")
"

echo ""
echo "=== Quick Chat Test (OpenAI-compatible) ==="
curl -s "http://${HOST}:11434/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one sentence.\"}],
    \"stream\": false
  }" | python3 -c "
import json,sys
data = json.load(sys.stdin)
msg = data['choices'][0]['message']['content']
print(f'  Response: {msg}')
"
echo ""
