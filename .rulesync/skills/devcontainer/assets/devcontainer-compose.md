# Compose-Based Devcontainer Template (Mise + CLI-Agnostic)

Use this template when:

- Your app has multiple services (database, cache, queue, workers)
- You already have a `docker-compose*.yml` for local development
- You want the devcontainer to attach to an existing compose service

## Directory Structure

```
.devcontainer/
├── devcontainer.json
├── bash_history          # Persisted via bind mount
├── bashrc.override.sh    # Shell customizations appended to ~/.bashrc
└── post-create.sh        # One-time setup after container creation

docker-compose.local.yml  # External compose file (at project root)
mise.toml                 # Tool versions, env vars, tasks
```

## devcontainer.json

```jsonc
{
    "name": "project_dev",
    "dockerComposeFile": ["../docker-compose.local.yml"],
    "service": "app",
    "workspaceFolder": "/app",
    "init": true,
    "overrideCommand": false,
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
        { "source": "~/.bash_aliases", "target": "/home/dev-user/.bash_aliases", "type": "bind" },
        { "source": "~/.ssh", "target": "/home/dev-user/.ssh", "type": "bind" },
        { "source": "mise-data-volume", "target": "/mnt/mise-data", "type": "volume" },
    ],

    "containerEnv": {
        "MISE_DATA_DIR": "/mnt/mise-data",
    },
    "remoteEnv": {
        "PATH": "${containerEnv:PATH}:/mnt/mise-data/shims",
    },

    // Use appPort for devcontainer CLI compatibility.
    // forwardPorts is not fully supported by the CLI.
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

## mise.toml

```toml
[env]
COMPOSE_FILE = "docker-compose.local.yml"
_.file = [".env"]

[tools]
node = "22"

[tools.python]
version = "3.13"
virtualenv = ".venv"

[tasks]
cup = "devcontainer up ${DEVCONTAINER_FLAGS} --workspace-folder ."
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

## bashrc.override.sh

```bash
# persistent bash history
HISTFILE=~/.bash_history
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

if [ -d ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# restore default shell options (if entrypoint sets strict mode)
set +o errexit
set +o pipefail
set +o nounset

# start ssh-agent
eval "$(ssh-agent -s)"
```

## docker-compose.local.yml examples

### Custom Dockerfile build

```yaml
volumes:
    app_postgres_data: {}

services:
    app:
        build:
            context: .
            dockerfile: ./compose/local/Dockerfile
        container_name: app_local
        depends_on:
            - postgres
        volumes:
            - .:/app:z
        env_file:
            - ./.env
        ports:
            - '2222:2222'
            - '8000:8000'
        command: /start

    postgres:
        image: postgres:16
        container_name: app_local_postgres
        volumes:
            - app_postgres_data:/var/lib/postgresql/data
        environment:
            POSTGRES_USER: postgres
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: app
```

### Third-party app image (e.g. linuxserver.io)

Use any pre-built image directly. The devcontainer attaches to the running service.

```yaml
services:
    app:
        image: lscr.io/linuxserver/grav
        container_name: grav_local
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Etc/UTC
        volumes:
            - .:/config/www/user # Mount project files into Grav's user dir
            - grav_data:/config
        ports:
            - '2222:2222'
            - '80:80'
            - '443:443'

volumes:
    grav_data: {}
```

## CLI Usage

```bash
# Start (from host)
devcontainer up --workspace-folder .

# Rebuild
devcontainer up --remove-existing-container --workspace-folder .

# Interactive shell
devcontainer exec --workspace-folder . bash -i

# Run a mise task inside the container
devcontainer exec --workspace-folder . mise run manage -- migrate

# Via SSH (for host-side tools like claude, gemini)
ssh -p 2222 dev-user@localhost -t "cd /app && bash -i"
```
