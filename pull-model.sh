#!/bin/bash
# Pull the gpt-oss:120b model (65GB download, run once)
echo "Pulling gpt-oss:120b (~65GB, this will take a while)..."
ollama pull gpt-oss:120b
echo "Done! Model ready."
