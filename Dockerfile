FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ggml-org/llama.cpp/releases/download/b9133/llama-b9133-bin-ubuntu-vulkan-x64.tar.gz -o /tmp/llama.tar.gz && \
    tar -xzf /tmp/llama.tar.gz -C /usr/local/bin --strip-components=1 && \
    rm /tmp/llama.tar.gz && \
    chmod +x /usr/local/bin/llama-server

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
COPY index.html /app/index.html
RUN chmod +x /start.sh

RUN wget -q --show-progress -O /data/model.gguf "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf" || \
    wget -q -O /data/model.gguf "https://huggingface.co/QuantFactory/Meta-Llama-3.2-1B-Instruct-GGUF/resolve/main/Meta-Llama-3.2-1B-Instruct-Q4_K_M.gguf" || \
    echo "Warning: Model download failed"

EXPOSE 80

CMD ["/start.sh"]