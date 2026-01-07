---
root: true
targets: ["*"]
description: "Project overview and general development guidelines"
globs: ["**/*"]
---

# Project Overview

# Elephant/Walker/Goose Integration - Agent Knowledge Base

## 1. Project Context
This project configures **Elephant** (Lua providers) for the **Walker** launcher to control the **Goose** AI agent.
**Key Change:** The project has moved away from external bash/gum scripts for input. It now uses a native **Walker-based** workflow (using `walker --dmenu` and Lua state) for better integration.

**Core Stack:**
- **Language:** Lua 5.1 (JIT compatible).
- **Launcher:** Walker (`walker --provider menus:name`).
- **Input:** Walker dmenu mode (`walker --dmenu --inputonly`).
- **State:** JSON-based persistence (`~/.local/share/elephant/goose_state.json`).

## 2. General Guidelines
*   **Context First:** Always resolve paths dynamically. Never assume the user is `voznik`. Use `os.getenv("HOME")`.
*   **Modularity:** Do not reinvent wheels. Use `utils/shared.lua` for terminal execution and `utils/state.lua` for data persistence.
*   **User Experience:**
    *   Use `Subtext` to provide context (e.g., current value of a parameter).
    *   Use `Preview` for file content when applicable.
*   **Robustness:** Always check if external tools (`goose`, `yq`) or environment variables (`EDITOR`) exist before using them. Provide fallbacks (e.g., `xdg-open` if `EDITOR` is missing).

## 3. Code Style
*   **Naming:**
    *   **PascalCase** for Walker API fields (`Text`, `Actions`, `Value`) and global Menu functions (`GetEntries`, `RunRecipe`).
    *   **snake_case** for local variables (`recipe_path`, `cmd_output`).
*   **Scope:** Always use `local` for variables unless they are required by the Elephant/Walker API (like `GetEntries`).
*   **Strings:** Prefer double quotes `"`. Use `[[ ... ]]` for multi-line shell commands.
*   **Imports:** Use `dofile(...)` with absolute paths (via `os.getenv`), **not** `require`. This ensures hot-reloading works in Elephant.

## 4. File Structure & Paths
**Root:** `~/.config/elephant`
**State:** `~/.local/share/elephant/goose_state.json`

```text
~/.config/elephant/
├── menus/
│   ├── goose/
│   │   ├── main.lua              # menus:goose
│   │   ├── recipes.lua           # menus:goose_recipes (Select recipe)
│   │   ├── recipe_params.lua     # menus:goose_recipe_params (Input params)
│   │   ├── models.lua            # menus:goose_models
│   │   ├── projects.lua          # menus:goose_projects
│   │   ├── prompts.lua           # menus:goose_prompts
│   │   └── sessions.lua          # menus:goose_sessions
│   ├── menus.toml                # Static entry registry
│   └── ...
├── utils/
│   ├── shared.lua                # Helpers (RunInTerminal, OpenWalkerMenu)
│   ├── state.lua                 # State persistence (load/save/update)
│   └── json.lua                  # JSON support
├── .rulesync/rules/AGENTS.md     # This file
└── walker.config.toml            # Walker config
```

## 5. Implemented Patterns (Existing Code)

### A. Lua Coding Standards
*   **Imports:** `dofile(os.getenv("HOME") .. "/.config/elephant/utils/filename.lua")`.
*   **State Access:**
    ```lua
    local STATE = dofile(os.getenv("HOME") .. "/.config/elephant/utils/state.lua")
    local data = STATE.load()
    ```

### B. Menu Actions (Map Format)
In the existing Lua files, `Actions` are defined as a key-value map.
```lua
Actions = {
    default = "lua:FunctionName",
    -- other_action = "lua:OtherFunction"
}
```

### C. The "Recipe" Workflow (Walker-Based)
The project currently implements a multi-stage menu system using global state to pass data between views.

1.  **Select Recipe (`menus/goose/recipes.lua`):**
    *   Lists `.yaml` files.
    *   **Action:** Updates `STATE.current_recipe` and switches view.
    *   `STATE.update({ current_recipe = path, recipe_params = {} })`
    *   `OpenWalkerMenu("goose_recipe_params")`

2.  **Input Parameters (`menus/goose/recipe_params.lua`):**
    *   Reads `STATE.current_recipe`.
    *   Parses YAML to list parameters as menu entries.
    *   **Input Capture:** Uses `io.popen` to call Walker's dmenu mode.
    ```lua
    local cmd = "walker --dmenu --inputonly --placeholder '...'"
    local p = io.popen(cmd .. " 2>&1")
    -- reads output, updates STATE.recipe_params
    ```

3.  **Execution:**
    *   "Run Recipe" entry constructs the `goose run` command.
    *   Iterates over `STATE.recipe_params` to build flags.
    *   Executes via `RunInTerminal`.

## 6. Helper Functions (`utils/shared.lua`)
*   `RunInTerminal(cmd)`: Launches command in terminal.
*   `OpenWalkerMenu(provider_name)`: Switches Walker to a new menu provider.
*   `ReadShellCommand(cmd)`: Returns file handle for reading command output.


## 7. Current Implementation Status
Recipe Parameter System:
- Walker input capture: Using io.popen() with walker --dmenu --inputonly
Model Selection System:
- Single source: ~/.ai/goose_known_models.txt (extracted from Rust source)
- Unified function: get_models_from_provider(provider_name)
- Providers: gemini-cli (from file), ollama (dynamic), claude (from file)
- Fallback: Hardcoded gemini-cli models if file missing
- Status: Implemented
Known Issues:
- tbd
