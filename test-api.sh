#!/bin/bash
# Test the local LLM API
HOST="${1:-localhost}"

echo "Testing Ollama API at http://${HOST}:11434 ..."
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
  -d '{
    "model": "gpt-oss:120b",
    "messages": [{"role": "user", "content": "Say hello in one sentence."}],
    "stream": false
  }' | python3 -c "
import json,sys
data = json.load(sys.stdin)
msg = data['choices'][0]['message']['content']
print(f'  Response: {msg}')
"
echo ""
