FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://huggingface.co/ggerganov/llama.cpp/resolve/latest/llama-server-ubuntu-x86_64?download=true -o /usr/local/bin/llama-server && \
    chmod +x /usr/local/bin/llama-server

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
RUN chmod +x /start.sh

RUN curl -L "https://huggingface.co/mattr899/llama3.2-3b-q4_k_m/resolve/main/llama3.2-3b-q4_k_m.gguf" -o /data/model.gguf 2>/dev/null || \
    curl -L "https://huggingface.co/QuantFactory/Meta-Llama-3.2-1B-Instruct-GGUF/resolve/main/Meta-Llama-3.2-1B-Instruct-Q4_K_M.gguf" -o /data/model.gguf

EXPOSE 80

CMD ["/start.sh"]