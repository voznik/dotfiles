# DevContainer Cheatsheet

## devcontainer.json Properties

### Container Source (mutually exclusive)

- `image`: Any Docker image (e.g., `ubuntu:24.04`, `lscr.io/linuxserver/grav`, `php:8.3`)
- `build.dockerfile`: Path to a Dockerfile (with optional `build.context`)
- `dockerComposeFile`: Path(s) to Docker Compose file(s) (requires `service`)

### Compose-Specific

- `service`: The service in the compose file to use as the dev container
- `runServices`: Array of services to start (default: all)
- `shutdownAction`: What happens when client disconnects (`stopCompose`, `none`)

### Container Behavior

- `overrideCommand`: If false, container runs its own CMD. If true (default), runs `sleep infinity`
- `init`: Run an init process (PID 1 handler). Recommended: `true`
- `remoteUser`: User to run as inside the container
- `workspaceFolder`: Absolute path for the workspace mount inside the container

### Features

- `features`: Object mapping feature IDs to config objects or `{}`
- `overrideFeatureInstallOrder`: Array controlling feature install sequence

### Lifecycle Scripts

- `onCreateCommand`: Runs when container is first created
- `updateContentCommand`: Runs when content is updated
- `postCreateCommand`: Runs after container creation completes
- `postStartCommand`: Runs each time the container starts
- `postAttachCommand`: Runs after a client attaches

### Ports

- `forwardPorts`: Array of ports to forward (VS Code only, not fully supported by CLI)
- `appPort`: Array of port mappings as strings (CLI-compatible, e.g., `"127.0.0.1:2222:2222"`)
- `portsAttributes`: Per-port config (label, onAutoForward) - VS Code only

### Environment

- `containerEnv`: Env vars set at container creation (available in Dockerfile)
- `remoteEnv`: Env vars set at runtime (available in shell sessions)

### Mounts

```jsonc
"mounts": [
    // Bind mount: host file/dir -> container path
    { "source": "~/.ssh", "target": "/home/dev-user/.ssh", "type": "bind" },
    // Named volume: persists across rebuilds
    { "source": "my-volume", "target": "/mnt/data", "type": "volume" },
    // Relative bind mount (relative to devcontainer.json)
    { "source": "./.devcontainer/bash_history", "target": "/home/dev-user/.bash_history", "type": "bind" }
]
```

### Run Arguments

- `runArgs`: Array of extra `docker run` arguments
  - `"--cap-add=SYS_PTRACE"` - Enable debugging
  - `"--memory=4gb"` - Memory limit
  - `"--cpus=2"` - CPU limit

### Customizations

- `customizations.vscode.settings`: VS Code settings (ignored by CLI/DevPod)
- `customizations.vscode.extensions`: Extension IDs (ignored by CLI/DevPod)

## Variable Substitution

- `${localWorkspaceFolder}`: Source folder on host
- `${containerWorkspaceFolder}`: Workspace folder in container
- `${localEnv:VAR_NAME}`: Host environment variable
- `${containerEnv:VAR_NAME}`: Container environment variable

## CLI Commands

### devcontainer CLI

```bash
# Build and start container
devcontainer up --workspace-folder .

# Rebuild (remove old container first)
devcontainer up --remove-existing-container --workspace-folder .

# Execute command inside container
devcontainer exec --workspace-folder . <command>

# Interactive shell
devcontainer exec --workspace-folder . bash -i

# Run with mise tasks
devcontainer exec --workspace-folder . mise run <task>
```

### DevPod

```bash
# Create workspace (no IDE)
devpod up . --ide none

# SSH into workspace
devpod ssh .

# Delete workspace
devpod delete .
```

## Mise Integration Quick Reference

### containerEnv / remoteEnv

```jsonc
"containerEnv": {
    "MISE_DATA_DIR": "/mnt/mise-data"
},
"remoteEnv": {
    "PATH": "${containerEnv:PATH}:/mnt/mise-data/shims"
}
```

### Volume Mount

```jsonc
"mounts": [
    { "source": "mise-data-volume", "target": "/mnt/mise-data", "type": "volume" }
]
```

### post-create.sh Essentials

```bash
sudo chown -R $(id -u):$(id -g) /mnt/mise-data
mise trust
mise install
mise activate bash >> ~/.bashrc
```
