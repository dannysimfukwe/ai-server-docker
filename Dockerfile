FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ggml-org/llama.cpp/releases/download/b4027/llama-b4027-bin-ubuntu-x64.tar.gz -o /tmp/llama.tar.gz && \
    tar -xzf /tmp/llama.tar.gz -C /usr/local/bin --strip-components=1 && \
    rm /tmp/llama.tar.gz && \
    chmod +x /usr/local/bin/llama-server

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
COPY index.html /app/index.html
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]