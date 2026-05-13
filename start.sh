#!/bin/bash

set -e

API_KEY="${API_KEY:-$(openssl rand -hex 32)}"
MODEL_URL="${MODEL_URL:-https://huggingface.co/QuantFactory/Meta-Llama-3.2-1B-Instruct-GGUF/resolve/main/Meta-Llama-3.2-1B-Instruct-Q4_K_M.gguf}"
MODEL_FILE="${MODEL_FILE:-/data/model.gguf}"
CONTEXT_SIZE="${MAX_CONTEXT:-4096}"
MAX_TOKENS="${MAX_TOKENS:-1024}"
PORT=8080

echo "=============================================="
echo "         AI Server Configuration"
echo "=============================================="
echo "API Key: $API_KEY"
echo "Context: $CONTEXT_SIZE | Max Tokens: $MAX_TOKENS"
echo "Model: $MODEL_FILE"
echo "=============================================="
echo ""
echo "Endpoints:"
echo "  API: https://$(hostname).42helv.com/v1/chat/completions"
echo "  Health: https://$(hostname).42helv.com/health"
echo ""
echo "Usage:"
echo '  curl -X POST https://$(hostname).42helv.com/v1/chat/completions \'
echo '    -H "Authorization: Bearer '"$API_KEY"'" \'
echo '    -H "Content-Type: application/json" \'
echo '    -d '\''{"model":"llama3.2","messages":[{"role":"user","content":"Hello!"}]}'\'''
echo ""
echo "=============================================="

mkdir -p /app /data /run/nginx /var/log/nginx

if [ ! -f "$MODEL_FILE" ] || [ ! -s "$MODEL_FILE" ]; then
    echo "Downloading model..."
    curl -L --progress-bar "$MODEL_URL" -o "$MODEL_FILE"
fi

echo "Starting llama.cpp server..."
/usr/local/bin/llama-server \
    -m "$MODEL_FILE" \
    -c "$CONTEXT_SIZE" \
    --host 127.0.0.1 \
    --port "$PORT" \
    -ngl 0 \
    -t 4 \
    --log-disable \
    &

LLAMA_PID=$!

sleep 5

if ! kill -0 $LLAMA_PID 2>/dev/null; then
    echo "Error: llama-server failed to start"
    exit 1
fi

echo "Starting nginx..."
nginx -c /etc/nginx/nginx.conf

echo ""
echo "=============================================="
echo "AI Server is ready!"
echo "=============================================="

wait $LLAMA_PID