FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ggml-org/llama.cpp/releases/download/b9133/llama-b9133-bin-ubuntu-x64.tar.gz -o /tmp/llama.tar.gz && \
    tar -xzf /tmp/llama.tar.gz -C /usr/local/bin --strip-components=1 && \
    rm /tmp/llama.tar.gz && \
    chmod +x /usr/local/bin/llama-server

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
COPY index.html /app/index.html
RUN chmod +x /start.sh

RUN curl -L "https://huggingface.co/mattr899/llama3.2-3b-q4_k_m/resolve/main/llama3.2-3b-q4_k_m.gguf" -o /data/model.gguf 2>/dev/null || \
    curl -L "https://huggingface.co/QuantFactory/Meta-Llama-3.2-1B-Instruct-GGUF/resolve/main/Meta-Llama-3.2-1B-Instruct-Q4_K_M.gguf" -o /data/model.gguf

EXPOSE 80

CMD ["/start.sh"]