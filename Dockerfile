FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ggml-org/llama.cpp/releases/download/b9133/llama-b9133-bin-ubuntu-sycl-fp32-x64.tar.gz -o /tmp/llama.tar.gz && \
    mkdir -p /tmp/llama && tar -xzf /tmp/llama.tar.gz -C /tmp/llama && \
    cp /tmp/llama/llama-b9133/llama-server /usr/local/bin/ && \
    cp /tmp/llama/llama-b9133/lib*.so* /usr/local/bin/ && \
    rm -rf /tmp/llama /tmp/llama.tar.gz && \
    chmod +x /usr/local/bin/llama-server

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
COPY index.html /app/index.html
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]