FROM ollama/ollama:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /data /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY auth.lua /etc/nginx/auth.lua
COPY index.html /app/index.html

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]