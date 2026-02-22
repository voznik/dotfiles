# Dockerfile-Based Devcontainer Template (Mise + CLI-Agnostic)

Use this template when:

- You need custom system packages not available as features
- You want to cache heavy installations in Docker layers
- You need fine-grained control over the base image
- No existing docker-compose file, but more control than a simple image

## Directory Structure

```
.devcontainer/
├── devcontainer.json
├── Dockerfile
├── bash_history
├── bashrc.override.sh
└── post-create.sh

mise.toml
```

## devcontainer.json

```jsonc
{
  "name": "project_dev",
  "build": {
    "dockerfile": "Dockerfile",
    "context": "..",
  },
  "init": true,
  "remoteUser": "dev-user",

  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "username": "dev-user",
      "userUid": 1000,
      "userGid": 1001,
    },
    "ghcr.io/devcontainers-extra/features/mise:1": {},
    "ghcr.io/devcontainers/features/sshd:1": {},
  },

  "mounts": [
    {
      "source": "./.devcontainer/bash_history",
      "target": "/home/dev-user/.bash_history",
      "type": "bind",
    },
    { "source": "~/.ssh", "target": "/home/dev-user/.ssh", "type": "bind" },
    { "source": "mise-data-volume", "target": "/mnt/mise-data", "type": "volume" },
  ],

  "containerEnv": {
    "MISE_DATA_DIR": "/mnt/mise-data",
  },
  "remoteEnv": {
    "PATH": "${containerEnv:PATH}:/mnt/mise-data/shims",
  },

  "appPort": ["127.0.0.1:2222:2222", "127.0.0.1:8000:8000"],

  "runArgs": ["--cap-add=SYS_PTRACE", "--memory=4gb"],

  "customizations": {
    "vscode": {
      "settings": {},
      "extensions": [],
    },
  },

  "postCreateCommand": "chmod +x ./.devcontainer/post-create.sh && ./.devcontainer/post-create.sh > post-create.log",
}
```

## Dockerfile

Use any base image that fits the project. Devcontainer features install on top.

```dockerfile
# Use whatever base fits: OS, language, or app image
# Examples:
#   FROM ubuntu:24.04
#   FROM python:3.13
#   FROM php:8.3-cli
#   FROM node:22
FROM ubuntu:24.04

# System packages (cached layer) - only things mise can't handle
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
```

### Dockerfile with Dependency Caching

When you have heavy dependencies that change infrequently, cache them in Docker layers:

```dockerfile
FROM python:3.13-slim

# System packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only dependency files for caching
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Code is mounted via volume at runtime, not COPY'd
WORKDIR /app
```

## mise.toml

```toml
[env]
_.file = [".env"]

[tools]
python = "3.13"
node = "22"
"github:cli/cli" = { version = "latest", asset_pattern = "gh_*_linux_amd64.tar.gz" }

[tools.python]
version = "3.13"
virtualenv = ".venv"

[tasks]
cup = "devcontainer up --workspace-folder ."
cexec = 'devcontainer exec --workspace-folder . bash -i -c ${usage_command}'
```

## Optimization Patterns

### Layer Ordering for Cache Efficiency

```dockerfile
FROM ubuntu:24.04

# 1. System packages (rarely change)
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Dependency files (change with project updates)
COPY requirements.txt package.json ./

# 3. Install deps (cached unless files above change)
RUN pip install -r requirements.txt && npm install

# 4. Source code is volume-mounted at runtime, not COPY'd
WORKDIR /app
```

### Cleanup in Same Layer

```dockerfile
# Good: cleanup in same RUN layer
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Bad: separate layer doesn't reduce image size
RUN apt-get update && apt-get install -y build-essential
RUN rm -rf /var/lib/apt/lists/*
```

### Build Args for Flexible Versions

```dockerfile
ARG PGCLIENT_VERSION=16

RUN apt-get update && apt-get install -y \
    postgresql-client-${PGCLIENT_VERSION} \
    && rm -rf /var/lib/apt/lists/*
```

Override in devcontainer.json:

```jsonc
"build": {
    "dockerfile": "Dockerfile",
    "args": {
        "PGCLIENT_VERSION": "15"
    }
}
```

## When to Graduate to Docker Compose

Move to compose-based setup when:

- You need additional services (database, cache, queue)
- Services need to communicate via Docker network
- You want to match a production-like multi-container setup

See `devcontainer-compose.md` template.

## Debugging Build Issues

```bash
# Full build output
docker build --progress=plain -t test .devcontainer/

# No cache rebuild
docker build --no-cache -t test .devcontainer/

# Inspect layer sizes
docker history <image>

# Build and run interactively (without devcontainer tooling)
docker build -t dev-test .devcontainer/
docker run -it dev-test /bin/bash
```
