#!/bin/bash

set -e

API_KEY="${API_KEY:-$(openssl rand -hex 32)}"
MODEL_NAME="${MODEL_NAME:-llama3.2:1b}"

mkdir -p /app /data /run/nginx /var/log/nginx

echo "Starting Ollama..."
ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama to start..."
for i in {1..30}; do
    if curl -s http://localhost:11434 > /dev/null 2>&1; then
        echo "Ollama is ready!"
        break
    fi
    sleep 1
done

echo "Pulling model: $MODEL_NAME"
ollama pull $MODEL_NAME || echo "Model may already be available"

echo "Starting nginx..."
nginx -c /etc/nginx/nginx.conf

echo ""
echo "=============================================="
echo "AI Server is ready!"
echo "=============================================="
echo ""
echo "Find your API key at: https://${HOST:-localhost}/api-key"
echo ""

wait $OLLAMA_PID