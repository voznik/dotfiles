---
name: devcontainer
description: >-
  Create, configure, and troubleshoot devcontainer environments using mise for
  tool/env management. Use when the user asks to set up, modify, or debug a
  devcontainer, or needs to connect host-side AI tools (claude, opencode,
  gemini) into a running container.
targets:
  - '*'
---

# Devcontainer Skill

Create and manage agnostic devcontainer environments that work with the `devcontainer` CLI (primary), DevPod, and VS Code.

## When to Use

- Setting up a new devcontainer or modifying an existing one
- Troubleshooting container startup, feature conflicts, or connectivity
- Configuring host-side tools (claude, opencode, gemini) to attach into a devcontainer
- Adding tools, languages, or services via mise or devcontainer features

## Core Principles

1. **CLI-first, editor-agnostic** - The devcontainer must work with the `devcontainer` CLI installed locally (for neovim workflows), DevPod, and VS Code. Avoid depending on VS Code-specific behavior.
2. **Any image works** - Use whatever Docker image fits the project (linuxserver.io, bitnami, official language images, custom). Devcontainer features install on top of any Linux-based image. Do not default to `mcr.microsoft.com/devcontainers/*` images.
3. **Mise manages tools & env** - Languages, runtimes, and CLI tools are installed via `mise`, not via devcontainer features or Dockerfile layers (except for system-level deps). Mise also manages env vars and task scripts.
4. **Features for system-level concerns only** - Use devcontainer features for things mise cannot handle: common-utils (user setup), sshd, mkcert, docker-outside-of-docker, etc.
5. **Compose-based when multi-service** - Reference an external `docker-compose*.yml` via `dockerComposeFile` when the project has databases, caches, or other services. For single-container setups, `image` is fine.

## Bootstrap New Project

To set up a devcontainer from scratch in a new/empty folder:

1. Create the directory structure:

   ```
   project/
   ├── .devcontainer/
   │   ├── devcontainer.json
   │   ├── bash_history          # touch this file
   │   ├── bashrc.override.sh
   │   └── post-create.sh
   └── mise.toml
   ```

2. Pick a base image. Use whatever fits the project:
   - **Third-party app image**: `lscr.io/linuxserver/grav`, `bitnami/wordpress`, `gitea/gitea`
   - **Official language image**: `python:3.13`, `node:22`, `php:8.3`
   - **Bare OS**: `ubuntu:24.04`, `debian:bookworm`
   - **Devcontainer image** (if nothing else fits): `mcr.microsoft.com/devcontainers/base:ubuntu`

3. Choose setup mode:
   - **Simple** (`image`): single container, no external services → use `assets/devcontainer-simple.md`
   - **Compose** (`dockerComposeFile`): multiple services or existing compose file → use `assets/devcontainer-compose.md`
   - **Dockerfile** (`build.dockerfile`): need cached system packages → use `assets/devcontainer-dockerfile.md`

4. Run: `devcontainer up --workspace-folder .`

## Working with Third-Party Images

Devcontainer features (common-utils, mise, sshd) install on **any** Linux-based image. When using third-party images there are critical pitfalls to avoid:

### General Rules

- **Check the base OS first** (`docker run --rm <image> cat /etc/os-release`). Alpine vs Debian determines which features and package managers work.
- **`overrideCommand: false` only works in compose mode.** In simple `image` mode, the devcontainer CLI overrides the entrypoint regardless. If the image needs its own entrypoint (s6-overlay, custom init), you MUST use compose mode.
- **`"init": true` conflicts with s6-overlay.** LinuxServer.io and other images using s6-overlay require PID 1. Do NOT set `"init": true` with these images - omit it or set `false`.
- **GID conflicts on Alpine.** GID 1000 is typically taken by the `users` group. Use a different GID (e.g., 1001) for `common-utils`, or omit `userGid` and let it auto-assign.
- **sshd feature requires Debian/Ubuntu.** It uses `apt-get` internally. On Alpine-based images, install openssh via a Dockerfile layer (`apk add openssh sudo`) instead of the sshd feature.
- **sudo may not be available.** Alpine images often lack sudo. Install it via Dockerfile and configure NOPASSWD for the dev user.
- **Bind-mount the post-create log.** Add a mount for `post-create.log` so you can read it from the host without `docker exec`.

### LinuxServer.io Images (Alpine-based)

These use s6-overlay (needs PID 1), PUID/PGID for permissions, and Alpine's `apk` package manager. **Must use compose mode.**

```jsonc
// devcontainer.json
{
  "dockerComposeFile": ["../docker-compose.local.yml"],
  "service": "app",
  "workspaceFolder": "/config/www/user", // or wherever the editable content lives
  "overrideCommand": false,
  // Do NOT set "init": true - s6-overlay needs PID 1
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "username": "dev-user",
      "userUid": 1000,
      "userGid": 1001, // Avoid 1000, taken by 'users' group on Alpine
    },
    "ghcr.io/devcontainers-extra/features/mise:1": {},
    // Do NOT use sshd feature on Alpine - install via Dockerfile instead
  },
  "containerEnv": {
    "PUID": "1000",
    "PGID": "1001",
    "MISE_DATA_DIR": "/mnt/mise-data",
  },
  "remoteUser": "dev-user",
}
```

```dockerfile
# .devcontainer/Dockerfile - extends the linuxserver image
FROM lscr.io/linuxserver/grav

# These are cached in the image layer, not re-installed on every rebuild
RUN apk add --no-cache sudo openssh
RUN echo "dev-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/dev-user
```

```yaml
# docker-compose.local.yml
services:
  app:
    build:
      context: .
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - .:/opt/project:z # Project source (devcontainer configs, mise.toml)
      - app_data:/config # Grav persistent data
    environment:
      - PUID=1000
      - PGID=1001
      - TZ=Etc/UTC
    ports:
      - '127.0.0.1:2222:2222'
      - '127.0.0.1:80:80'
volumes:
  app_data: {}
```

### Official Language Images (Debian-based)

These are typically Debian/Ubuntu, so all features work.

```jsonc
{
  "image": "php:8.3-cli",
  "init": true,
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "username": "dev-user",
    },
    "ghcr.io/devcontainers-extra/features/mise:1": {},
    "ghcr.io/devcontainers/features/sshd:1": {},
  },
  "remoteUser": "dev-user",
}
```

### Using Pre-Existing System Users (instead of common-utils)

Some images have a suitable user already (e.g., `www-data` in PHP/nginx images, `node` in Node images). If using one instead of creating via `common-utils`:

- **Home directory is not `/home/USERNAME`**: `www-data`'s home is `/var/www`, `postgres`'s is `/var/lib/postgresql`. Check with `getent passwd USERNAME`. Adjust all bind mount targets accordingly.
- **Default shell may not be bash**: System users often have `/usr/sbin/nologin` or `/bin/sh`. Fix in post-create: `sudo usermod --shell /bin/bash USERNAME`
- **Set `SHELL` env explicitly**: Tools that check `$SHELL` may get the wrong value.

```jsonc
{
  "containerEnv": {
    "SHELL": "/bin/bash",
  },
  "remoteUser": "www-data",
}
```

In post-create:

```bash
# Ensure the user has bash as login shell
sudo usermod --shell /bin/bash www-data
# bashrc goes to actual home, not /home/www-data
cat .devcontainer/bashrc.override.sh >> /var/www/.bashrc
```

### postCreateCommand User Context

- **Compose mode**: `postCreateCommand` runs as **root** unless `remoteUser` is set. Target the dev user's home explicitly: `cat .devcontainer/bashrc.override.sh >> /home/dev-user/.bashrc`
- **Image mode**: Runs as `remoteUser` if set.
- **CWD is `workspaceFolder`**: Relative paths in post-create.sh (like `.devcontainer/bashrc.override.sh`) work because `postCreateCommand` runs with CWD set to `workspaceFolder`. When re-running scripts manually via `docker exec`, pass `-w /workspace` to match.
- Always use absolute paths for `~/.bashrc` to avoid ambiguity.

## Workflow

### 1. Gather Requirements

Before generating config, determine:

- **Base image**: What Docker image fits this project? Check Docker Hub, linuxserver.io, bitnami, etc.
- **Services**: Single container or multi-service (compose)?
- **Languages & tools**: What does `mise.toml` need to provide?
- **Host tools**: Does the user need claude/opencode/gemini to exec into the container?
- **Ports**: What ports need exposing? Use `appPort` for CLI compatibility (see below).

### 2. Generate / Update Configuration

#### devcontainer.json Structure

```jsonc
{
  "name": "project_dev",
  "dockerComposeFile": ["../docker-compose.local.yml"],
  "service": "django",
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
    "ghcr.io/devcontainers-extra/features/mkcert:1": {},
  },

  "mounts": [
    // Persist bash history across rebuilds
    {
      "source": "./.devcontainer/bash_history",
      "target": "/home/dev-user/.bash_history",
      "type": "bind",
    },
    // Share host aliases
    { "source": "~/.bash_aliases", "target": "/home/dev-user/.bash_aliases", "type": "bind" },
    // Share host SSH keys (for git, remote access)
    { "source": "~/.ssh", "target": "/home/dev-user/.ssh", "type": "bind" },
    // Persist mise tool installations across rebuilds
    { "source": "mise-data-volume", "target": "/mnt/mise-data", "type": "volume" },
  ],

  "containerEnv": {
    "MISE_DATA_DIR": "/mnt/mise-data",
  },
  "remoteEnv": {
    "PATH": "${containerEnv:PATH}:/mnt/mise-data/shims",
  },

  // Use appPort instead of forwardPorts for devcontainer CLI compatibility.
  // forwardPorts is not yet fully supported by the CLI.
  // See https://github.com/devcontainers/cli/issues/22
  "appPort": ["127.0.0.1:2222:2222"],

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

#### Key Differences from Standard Templates

| Concern           | Standard template                   | Our approach                   |
| ----------------- | ----------------------------------- | ------------------------------ |
| Port forwarding   | `forwardPorts`                      | `appPort` (CLI-compatible)     |
| Tool installation | Devcontainer features per language  | `mise install` via `mise.toml` |
| Runtime versions  | Feature options (`"version": "20"`) | `mise.toml` `[tools]` section  |
| Env vars          | `containerEnv`/`remoteEnv` inline   | `mise.toml` `[env]` + `_.file` |
| Task running      | `postStartCommand` scripts          | `mise run <task>`              |
| User              | `vscode` (default)                  | Custom user via common-utils   |

### 3. Mise Integration

Mise replaces most language-specific devcontainer features. Instead of adding `ghcr.io/devcontainers/features/node:1`, define it in `mise.toml`:

```toml
[tools]
node = "22"
python = "3.13"
"github:cli/cli" = { version = "latest", asset_pattern = "gh_*_linux_amd64.tar.gz" }

[env]
COMPOSE_FILE = "docker-compose.local.yml"
_.file = [".env", ".envs/.local/.django", ".envs/.local/.postgres"]
_.python.venv = { path = ".venv", create = false }

[tasks]
cup = "devcontainer up ${DEVCONTAINER_FLAGS} --workspace-folder ."
cexec = "devcontainer exec --workspace-folder . bash -i -c ${usage_command}"
```

The devcontainer needs:

- **Feature**: `ghcr.io/devcontainers-extra/features/mise:1` to install mise itself
- **Volume**: `mise-data-volume` mounted at `/mnt/mise-data` for persistence across rebuilds
- **containerEnv**: `MISE_DATA_DIR=/mnt/mise-data` so mise uses the volume
- **remoteEnv**: Add `/mnt/mise-data/shims` to PATH so tools are available

#### post-create.sh Pattern

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

# Append shell overrides
cat .devcontainer/bashrc.override.sh >> ~/.bashrc

# Set up mise
run_command "sudo chown -R $(id -u):$(id -g) /mnt/mise-data"
run_command "mise trust"
run_command "mise install"
run_command "mise activate bash >> ~/.bashrc"

# Set dev-user password (needed for sshd feature)
run_command "echo 'dev-user:dev-user' | sudo chpasswd"
```

### 4. Connecting Host-Side AI Tools

The devcontainer exposes SSH (port 2222) via the `sshd` feature, enabling host-side tools to attach.

#### Claude Code

```bash
# Exec directly into the running container
devcontainer exec --workspace-folder . claude

# Or via SSH (if sshd feature is enabled)
ssh -p 2222 dev-user@localhost -t "cd /app && claude"
```

For Claude Code to work inside the container, ensure these host paths are bind-mounted or the relevant env vars are forwarded:

```jsonc
"mounts": [
    // Claude config and auth
    { "source": "~/.claude", "target": "/home/dev-user/.claude", "type": "bind" },
    { "source": "~/.claude.json", "target": "/home/dev-user/.claude.json", "type": "bind" }
]
```

Or pass the API key via env:

```jsonc
"remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
}
```

#### Gemini CLI

```bash
devcontainer exec --workspace-folder . gemini
# Or via SSH
ssh -p 2222 dev-user@localhost -t "cd /app && gemini"
```

Mount config if needed:

```jsonc
"mounts": [
    { "source": "~/.config/gemini", "target": "/home/dev-user/.config/gemini", "type": "bind" }
]
```

Or forward the API key:

```jsonc
"remoteEnv": {
    "GEMINI_API_KEY": "${localEnv:GEMINI_API_KEY}"
}
```

#### OpenCode

```bash
devcontainer exec --workspace-folder . opencode
```

Mount config:

```jsonc
"mounts": [
    { "source": "~/.config/opencode", "target": "/home/dev-user/.config/opencode", "type": "bind" }
]
```

#### General Pattern

For any host-side tool to connect into the devcontainer:

1. **`devcontainer exec`** - Simplest. Runs a command inside the container directly. Works with any tool that has a CLI.
2. **SSH via sshd feature** - Use when the tool needs a proper TTY or persistent session. Requires the `sshd` feature and `appPort` mapping for port 2222.
3. **Bind-mount auth/config** - Mount `~/.toolname` or `~/.config/toolname` so credentials are available inside the container.
4. **Forward API keys** - Use `remoteEnv` with `${localEnv:VAR}` to pass API keys from host to container.

### 5. CLI-Agnostic Notes

#### devcontainer CLI (primary)

```bash
# Build and start
devcontainer up --workspace-folder .

# Execute a command
devcontainer exec --workspace-folder . bash -i

# Rebuild
devcontainer up --remove-existing-container --workspace-folder .
```

`appPort` is used instead of `forwardPorts` because the CLI does not fully support `forwardPorts` yet. See https://github.com/devcontainers/cli/issues/22

#### DevPod

```bash
# Create workspace from local project
devpod up . --ide none

# SSH into workspace
devpod ssh .
```

DevPod reads `devcontainer.json` natively. The `appPort` approach works. `customizations.vscode` is ignored (harmless).

#### VS Code

Works as usual via the "Dev Containers" extension. Both `forwardPorts` and `appPort` work in VS Code, so using `appPort` is backward-compatible.

## Diagnostic Checklist

### Container won't start

- [ ] `devcontainer.json` uses exactly ONE of: `image`, `build.dockerfile`, `dockerComposeFile`
- [ ] If compose-based: `service` matches a service name in the compose file
- [ ] Compose file exists at the path specified in `dockerComposeFile`
- [ ] Features are spelled correctly (case-sensitive, version tag included)
- [ ] If image uses s6-overlay (linuxserver.io): `"init"` is NOT set to `true`
- [ ] If image needs its own entrypoint: using compose mode (simple `image` mode ignores `overrideCommand: false`)

### Feature install fails

- [ ] Check base OS: `docker run --rm <image> cat /etc/os-release`
- [ ] Alpine image? `sshd` feature won't work (needs apt-get). Install openssh via Dockerfile.
- [ ] GID conflict? Alpine has GID 1000 taken by `users` group. Use GID 1001+ in common-utils.
- [ ] sudo missing? Alpine images lack sudo. Install via Dockerfile + NOPASSWD sudoers entry.

### Mise tools not available

- [ ] `ghcr.io/devcontainers-extra/features/mise:1` is in features
- [ ] `MISE_DATA_DIR` set in `containerEnv`
- [ ] `/mnt/mise-data/shims` added to `PATH` in `remoteEnv`
- [ ] `mise-data-volume` mount exists
- [ ] `post-create.sh` runs `mise trust && mise install && mise activate bash`
- [ ] `sudo chown` on `/mnt/mise-data` runs before `mise install`

### postCreateCommand fails

- [ ] Compose mode runs as root - use absolute paths (`/home/dev-user/.bashrc`) not `~/.bashrc`
- [ ] Image mode runs as `remoteUser` - `sudo` needed for privileged commands
- [ ] Bind-mount `post-create.log` to host so you can read it without `docker exec`
- [ ] sudo available? Check with `which sudo` inside container

### SSH / host tools can't connect

- [ ] On Debian/Ubuntu: `sshd` feature works
- [ ] On Alpine: install openssh via Dockerfile, NOT via sshd feature
- [ ] Port 2222 is mapped in `appPort`
- [ ] User password is set in `post-create.sh`
- [ ] `~/.ssh` is bind-mounted for key-based auth

### Slow startup

- Move stable installations (sudo, openssh, system packages) to Dockerfile layer (cached)
- Use mise data volume to persist tool installs across rebuilds
- Only include features that mise cannot handle

## Anti-Patterns

### Using simple `image` mode with app images that need their own entrypoint

The devcontainer CLI overrides the entrypoint in image mode. Use compose mode for images with s6-overlay, custom init, or specific CMD.

### Setting `"init": true` with s6-overlay images

s6-overlay requires PID 1. The `init` option adds tini which steals PID 1. Omit it.

### Using sshd feature on Alpine

It uses `apt-get`. Install openssh via Dockerfile: `RUN apk add --no-cache openssh sudo`

### Using GID 1000 on Alpine

Already taken by `users` group. Use 1001 or higher in `common-utils` `userGid`.

### Reading post-create.log via docker exec

Bind-mount it: `{ "source": "./.devcontainer/post-create.log", "target": "/app/post-create.log", "type": "bind" }` or write to a mounted path.

### Using `~/` in postCreateCommand (compose mode)

Compose mode runs as root, so `~` resolves to `/root`. Use absolute paths.

### Assuming home is `/home/USERNAME` for system users

`www-data` lives at `/var/www`, `postgres` at `/var/lib/postgresql`. Always check with `getent passwd`.

### Not setting `SHELL` env var

System users and some images default to `/bin/sh` or `/usr/sbin/nologin`. Set `"SHELL": "/bin/bash"` in `containerEnv`.

### Using `docker exec` instead of `devcontainer exec` for debugging

`devcontainer exec` runs via a shell and respects `remoteUser`/`workspaceFolder`. `docker exec` runs raw execve (script binaries without shebangs fail) and defaults to root with CWD at `/`. Prefer `devcontainer exec`.

### Installing languages via features when mise is available

Use `mise.toml` `[tools]` instead. Features are for system-level concerns only.

### Using `forwardPorts` with devcontainer CLI

The CLI doesn't fully support it. Use `appPort` with explicit host bindings.

### Putting everything in postCreateCommand

Move stable operations to Dockerfile layers. Only run `mise install` and shell setup in post-create.

### Hardcoding tool versions in devcontainer.json

Let `mise.toml` be the single source of truth for tool versions.

## Templates

- [assets/devcontainer-simple.md](assets/devcontainer-simple.md) - Single-container image-based setup
- [assets/devcontainer-dockerfile.md](assets/devcontainer-dockerfile.md) - Custom Dockerfile with layer caching
- [assets/devcontainer-compose.md](assets/devcontainer-compose.md) - Multi-service Docker Compose setup

## References

- [references/feature-catalog.md](references/feature-catalog.md) - Available devcontainer features
- [references/cheatsheet.md](references/cheatsheet.md) - devcontainer.json property reference
