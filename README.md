# Self-Hosted AI Server

Deploy your own AI server with an OpenAI-compatible API on [42helv.com](https://42helv.com).

## Features

- **OpenAI-compatible API** - Use your existing code with `base_url` set to your deployed server
- **Local LLM** - Runs [Ollama](https://ollama.ai/) with llama3.2 model
- **API Key Authentication** - Secure your server with auto-generated API keys
- **One-Click Deploy** - Deploy directly from 42helv.com templates

## Quick Start

### 1. Deploy on 42helv.com

1. Sign up at [42helv.com](https://42helv.com)
2. Go to **Services** → **Create New**
3. Select the **AI Server** template
4. Configure your server and deploy

Your API key will be auto-generated and shown on your deployed service page.

### 2. Connect Your App

#### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://your-site.42helv.com/v1",
    api_key="your-api-key"
)

response = client.chat.completions.create(
    model="llama3.2:1b",
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

#### JavaScript/Node.js

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'https://your-site.42helv.com/v1',
  apiKey: 'your-api-key'
});

const response = await client.chat.completions.create({
  model: 'llama3.2:1b',
  messages: [
    { role: 'user', content: 'Hello!' }
  ]
});

console.log(response.choices[0].message.content);
```

#### cURL

```bash
curl https://your-site.42helv.com/v1/chat/completions \
  -H "Authorization: Bearer your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/chat/completions` | POST | Generate chat completions |
| `/v1/models` | GET | List available models |
| `/health` | GET | Health check (no auth) |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MODEL_NAME` | `llama3.2:1b` | Ollama model to use |
| `API_KEY` | Auto-generated | Your API authentication key |

## Local Development

```bash
# Clone the repository
git clone https://github.com/dannysimfukwe/ai-server-docker.git
cd ai-server-docker

# Run locally with Docker
docker run -d \
  -p 8000:8000 \
  -e MODEL_NAME=llama3.2:1b \
  -e API_KEY=your-secret-key \
  dannysimfukwe/ai-server-docker:latest
```

Visit `http://localhost:8000` to use the chat interface.

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   nginx                         │
│              (port 8000)                        │
│                                                 │
│  ┌──────────┐    ┌────────────────────────────┐ │
│  │  /       │    │     /v1/*  (auth required) │ │
│  │  static  │    │                            │ │
│  │   chat   │    │         ↓                  │ │
│  └──────────┘    │         ↓                  │ │
│                  │    ┌──────────────────┐   │ │
│                  │    │  auth.lua        │   │ │
│                  │    │  (API key check) │   │ │
│                  │    └────────┬─────────┘   │ │
│                  │             ↓             │ │
│                  │    ┌──────────────────┐   │ │
│                  │    │  Ollama API      │   │ │
│                  │    │  (port 11434)    │   │ │
│                  │    └──────────────────┘   │ │
│                  └────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## Tech Stack

- [Ollama](https://ollama.ai/) - Local LLM runtime
- Nginx - Reverse proxy and API gateway
- Lua - API key authentication
- Docker - Containerization

## License

MIT License - Deploy freely on 42helv.com or your own infrastructure.

---

Built with ❤️ on [42helv.com](https://42helv.com)