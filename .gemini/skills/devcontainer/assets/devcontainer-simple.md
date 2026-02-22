# Simple Image-Based Devcontainer Template (Mise + CLI-Agnostic)

Use this template when:

- You want the fastest setup with a single container
- You don't need a separate database/cache (or they're remote)
- No existing docker-compose file

## Directory Structure

```
.devcontainer/
├── devcontainer.json
├── bash_history
├── bashrc.override.sh
└── post-create.sh

mise.toml
```

## devcontainer.json

Use any Linux-based image that fits the project. Devcontainer features install on top.

```jsonc
{
  "name": "project_dev",
  // Use whatever image fits: app image, language image, or bare OS
  // Examples:
  //   "lscr.io/linuxserver/grav"
  //   "php:8.3-cli"
  //   "node:22"
  //   "ubuntu:24.04"
  "image": "ubuntu:24.04",
  "init": true,
  // Set overrideCommand to false when using an app image with its own CMD
  // "overrideCommand": false,
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

  "appPort": ["127.0.0.1:2222:2222", "127.0.0.1:3000:3000"],

  "runArgs": ["--cap-add=SYS_PTRACE"],

  "customizations": {
    "vscode": {
      "settings": {},
      "extensions": [],
    },
  },

  "postCreateCommand": "chmod +x ./.devcontainer/post-create.sh && ./.devcontainer/post-create.sh > post-create.log",
}
```

## mise.toml

```toml
[env]
_.file = [".env"]

[tools]
node = "22"

[tasks]
dev = "npm run dev"
cup = "devcontainer up --workspace-folder ."
cexec = 'devcontainer exec --workspace-folder . bash -i -c ${usage_command}'
```

## post-create.sh

```bash
#!/bin/bash
set -euo pipefail

run_command() {
    local output exit_code
    output=$(eval "$*" 2>&1) || exit_code=$?
    exit_code=${exit_code:-0}
    if [ $exit_code -ne 0 ]; then
        echo -e "\033[0;31m[ERROR] Command failed (Exit Code $exit_code): $*\033[0m" >&2
        echo -e "\033[0;31m$output\033[0m" >&2
        exit $exit_code
    fi
}

cat .devcontainer/bashrc.override.sh >> ~/.bashrc

echo -e "\n Setting up mise..."
run_command "sudo chown -R $(id -u):$(id -g) /mnt/mise-data"
run_command "mise trust"
run_command "mise install"
run_command "mise activate bash >> ~/.bashrc"
echo "Done"

echo -e "\n Setting dev-user password..."
run_command "echo 'dev-user:dev-user' | sudo chpasswd"
echo "Done"
```

## CLI Usage

```bash
# Start
devcontainer up --workspace-folder .

# Shell
devcontainer exec --workspace-folder . bash -i

# Run mise tasks
devcontainer exec --workspace-folder . mise run dev

# DevPod alternative
devpod up . --ide none
devpod ssh .
```
