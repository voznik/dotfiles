# Devcontainer Features Catalog

Features are pre-packaged tools and runtimes that install on top of any base image.
Use features for **system-level concerns only** - languages and CLI tools should be managed via `mise.toml`.

**Official Features:** https://github.com/devcontainers/features
**Community Extra Features:** https://github.com/devcontainers-extra/features (prefix: `ghcr.io/devcontainers-extra/features/`)

## How to Use Features

```json
{
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "username": "dev-user"
    },
    "ghcr.io/devcontainers/features/sshd:1": {}
  }
}
```

## Recommended Features (system-level)

### Common Utils

User setup, locale, essential packages. Use this to create a custom non-root user.

```json
"ghcr.io/devcontainers/features/common-utils:2": {
  "installZsh": false,
  "username": "dev-user",
  "userUid": 1000,
  "userGid": 1001,
  "nonFreePackages": true
}
```

Options:

- `installZsh`: Install zsh (default: true)
- `username`: Non-root username to create
- `userUid`/`userGid`: UID/GID for the user
- `nonFreePackages`: Include non-free apt packages

### Mise (Tool Version Manager)

Installs mise itself. Tools are then declared in `mise.toml`.

```json
"ghcr.io/devcontainers-extra/features/mise:1": {}
```

### SSHD

Enables SSH access into the container. Required for host-side tools (claude, gemini, opencode) to connect via SSH.

```json
"ghcr.io/devcontainers/features/sshd:1": {}
```

Default SSH port is 2222. Set user password in `post-create.sh`:

```bash
echo "dev-user:dev-user" | sudo chpasswd
```

### mkcert

Local HTTPS certificates.

```json
"ghcr.io/devcontainers-extra/features/mkcert:1": {}
```

### Docker-outside-of-Docker

Use host's Docker daemon (lighter than docker-in-docker).

```json
"ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
```

### Docker-in-Docker

Run Docker commands inside the devcontainer.

```json
"ghcr.io/devcontainers/features/docker-in-docker:2": {
  "version": "latest",
  "moby": true
}
```

Options:

- `version`: Docker version
- `moby`: Use Moby (open source Docker, default: true)
- `dockerDashComposeVersion`: Compose version

### Git

```json
"ghcr.io/devcontainers/features/git:1": {}
```

### GitHub CLI

```json
"ghcr.io/devcontainers/features/github-cli:1": {}
```

Note: GitHub CLI can also be installed via mise: `"github:cli/cli"` in `[tools]`.

## Language/Runtime Features (prefer mise instead)

These are listed for reference. **Prefer declaring these in `mise.toml` `[tools]` section** rather than using features.

### Node.js

Feature: `ghcr.io/devcontainers/features/node:1` with `"version": "20"`
Mise: `node = "22"` in `[tools]`

### Python

Feature: `ghcr.io/devcontainers/features/python:1` with `"version": "3.11"`
Mise: `python = "3.13"` in `[tools]` (with venv config)

### Go

Feature: `ghcr.io/devcontainers/features/go:1` with `"version": "1.21"`
Mise: `go = "1.21"` in `[tools]`

### Rust

Feature: `ghcr.io/devcontainers/features/rust:1`
Mise: `rust = "latest"` in `[tools]`

### Java

Feature: `ghcr.io/devcontainers/features/java:1` with `"version": "17"`
Mise: `java = "17"` in `[tools]`

### Ruby

Feature: `ghcr.io/devcontainers/features/ruby:1`
Mise: `ruby = "3.2"` in `[tools]`

## Shell & Terminal Features

### Oh My Zsh

```json
"ghcr.io/devcontainers/features/omz:1": {
  "plugins": "git docker"
}
```

### Starship Prompt

```json
"ghcr.io/devcontainers/features/starship:1": {}
```

## Cloud & Infrastructure Features

### AWS CLI

```json
"ghcr.io/devcontainers/features/aws-cli:1": {}
```

### Terraform

```json
"ghcr.io/devcontainers/features/terraform:1": {
  "version": "latest",
  "tflint": "latest"
}
```

### Kubectl & Helm

```json
"ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
  "version": "latest",
  "helm": "latest",
  "minikube": "latest"
}
```

## Database Client Features

### PostgreSQL Client

```json
"ghcr.io/devcontainers/features/postgresql-client:1": {}
```

### Redis CLI

```json
"ghcr.io/devcontainers/features/redis-cli:1": {}
```

## Utility Features

### jq (JSON processor)

```json
"ghcr.io/devcontainers/features/jq:1": {}
```

### Deno

```json
"ghcr.io/anthropics/devcontainer-features/deno:1": {}
```

## Community Extra Features (`devcontainers-extra`)

These come from `ghcr.io/devcontainers-extra/features/`. Browse all at https://github.com/devcontainers-extra/features

### Mise

Tool version manager. Replaces per-language features.

```json
"ghcr.io/devcontainers-extra/features/mise:1": {}
```

### mkcert

Local CA for trusted HTTPS certificates in development.

```json
"ghcr.io/devcontainers-extra/features/mkcert:1": {}
```

### Neovim

```json
"ghcr.io/devcontainers-extra/features/neovim:1": {}
```

### Neovim

```json
"ghcr.io/devcontainers-extra/features/neovim:1": {}
```

### Ripgrep

Fast `grep` alternative.

```json
"ghcr.io/devcontainers-extra/features/ripgrep:1": {}
```

### Lazygit

Terminal UI for git.

```json
"ghcr.io/devcontainers-extra/features/lazygit:1": {}
```

### Fzf

Fuzzy finder.

```json
"ghcr.io/devcontainers-extra/features/fzf:1": {}
```

## Feature Configuration Patterns

### Override Install Order

```json
{
  "features": { ... },
  "overrideFeatureInstallOrder": [
    "ghcr.io/devcontainers/features/common-utils",
    "ghcr.io/devcontainers-extra/features/mise"
  ]
}
```

## Troubleshooting Features

### Feature Not Installing

1. Check feature name spelling (case-sensitive)
2. Check version tag exists (`:1`, `:2`)
3. Review devcontainer creation logs
4. Rebuild without cache: `devcontainer up --remove-existing-container --workspace-folder .`

### Feature Conflicts

- Docker-in-Docker vs Docker-outside-of-Docker (use one, not both)
- Multiple versions of same language via features (use mise instead)
- Different shell configurations overwriting each other

### Slow Feature Installation

Features install sequentially. To speed up:

1. Only include features mise cannot handle
2. Move stable system packages to Dockerfile layers
3. Use mise data volume to persist tool installs
