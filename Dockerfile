FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ggml-org/llama.cpp/releases/download/b9133/llama-b9133-bin-ubuntu-sycl-fp32-x64.tar.gz -o /tmp/llama.tar.gz && \
    tar -xzf /tmp/llama.tar.gz -C /usr/local/bin --strip-components=1 && \
    rm /tmp/llama.tar.gz && \
    chmod +x /usr/local/bin/llama-server && \
    chmod +x /usr/local/bin/libggml-cpu-sse42.so 2>/dev/null || true

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY start.sh /start.sh
COPY index.html /app/index.html
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]