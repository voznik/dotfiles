# Shared Lua Modules

This directory contains Lua modules shared between different tools.

## formatter.lua

Shared formatter configuration used by:
- **mise** (`~/.config/mise/tasks/format`) - Global file formatting task
- **micro** (`~/.config/micro/init.lua`) - Text editor formatting

### Usage in mise:
```bash
mise format file.json
mise format script.py
mise format style.css
```

### Usage in micro editor:
Press `Ctrl-Alt-f` to format the current file

### Supported file types:
- JavaScript/TypeScript: `.js`, `.mjs`, `.cjs`, `.ts`, `.mts`, `.cts`, `.jsx`, `.tsx`, `.vue`
- Web: `.html`, `.htm`, `.css`, `.json`
- Config: `.yaml`, `.yml`, `.toml`
- Programming: `.go`, `.rs`, `.py`, `.lua`

### Adding new formatters:
Edit `~/.config/lua/formatter.lua` and add to the `M.formatters` table:
```lua
M.formatters = {
    -- ... existing formatters
    newext = "command-to-format",
}
```

Both mise and micro will automatically use the new formatter.

### Dependencies (installed via mise):
- biome (JS/TS/HTML/CSS/JSON)
- ruff (Python)
- stylua (Lua)
- taplo (TOML)
- yq (YAML)
- gofmt (Go)
- rustfmt (Rust)
