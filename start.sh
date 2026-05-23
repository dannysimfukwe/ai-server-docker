#!/bin/bash

set -e

MODEL_NAME="${MODEL_NAME:-llama3.2:1b}"

# API_KEY precedence: USER_API_KEY (platform) > API_KEY (env) > auto-generated
if [ -n "$USER_API_KEY" ]; then
    API_KEY="$USER_API_KEY"
elif [ -z "${API_KEY:-}" ] || [ "$API_KEY" = "auto-generated" ]; then
    API_KEY="$(openssl rand -hex 32)"
fi

echo "=============================================="
echo "         AI Server Configuration"
echo "=============================================="
echo "API Key: $API_KEY"
echo "Model: $MODEL_NAME"
echo "=============================================="

mkdir -p /app /data /run/nginx /var/log/nginx

# Inject API_KEY into nginx.conf and index.html
sed -i "s|__API_KEY__|$API_KEY|g" /etc/nginx/nginx.conf

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

wait $OLLAMA_PID
