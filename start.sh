#!/bin/bash

set -e

API_KEY="${API_KEY:-$(openssl rand -hex 32)}"
MODEL_NAME="${MODEL_NAME:-llama3.2:1b}"

echo "=============================================="
echo "         AI Server Configuration"
echo "=============================================="
echo "API Key: $API_KEY"
echo "Model: $MODEL_NAME"
echo "=============================================="

mkdir -p /app /data /run/nginx /var/log/nginx

# Inject API_KEY into nginx.conf and index.html
sed -i "s|__API_KEY__|$API_KEY|g" /etc/nginx/nginx.conf
sed -i "s|__API_KEY__|$API_KEY|g" /app/index.html

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
sed -i 's/listen 80;/listen 8000;/' /etc/nginx/nginx.conf
nginx -c /etc/nginx/nginx.conf

echo ""
echo "=============================================="
echo "AI Server is ready!"
echo "=============================================="

wait $OLLAMA_PID
