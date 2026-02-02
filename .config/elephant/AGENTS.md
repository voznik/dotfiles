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

- **Context First:** Always resolve paths dynamically. Never assume the user is `voznik`. Use `os.getenv("HOME")`.
- **Modularity:** Do not reinvent wheels. Use `utils/shared.lua` for terminal execution and `utils/state.lua` for data persistence.
- **User Experience:**
  - Use `Subtext` to provide context (e.g., current value of a parameter).
  - Use `Preview` for file content when applicable.
- **Robustness:** Always check if external tools (`goose`, `yq`) or environment variables (`EDITOR`) exist before using them. Provide fallbacks (e.g., `xdg-open` if `EDITOR` is missing).

## 3. Code Style

- **Naming:**
  - **PascalCase** for Walker API fields (`Text`, `Actions`, `Value`) and global Menu functions (`GetEntries`, `RunRecipe`).
  - **camelCase** for local variables (`loadParams`).
- **Scope:** Always use `local` for variables unless they are required by the Elephant/Walker API (like `GetEntries`).
- **Strings:** Prefer double quotes `"`. Use `[[ ... ]]` for multi-line shell commands.
- **Imports:** Use `dofile(...)` with absolute paths (via `os.getenv`), **not** `require`. This ensures hot-reloading works in Elephant.

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
├── .rulesync/rules/AGENTS.md     # This file
└── walker.config.toml            # Walker config symlink
```

## 5. Implemented Patterns (Existing Code)

### A. Lua Coding Standards

- **Imports:** `dofile(os.getenv("HOME") .. "/.config/elephant/utils/filename.lua")`.
- **Syntax Validation:** Always validate Lua syntax with `luac -p <file>` before testing.

### B. Menu Actions (Map Format)

In the existing Lua files, `Actions` are defined as a key-value map.

```lua
Actions = {
    default = "lua:FunctionName",
    -- other_action = "lua:OtherFunction"
}
```

**IMPORTANT:** When an action is triggered, the `Value` field from the selected entry is passed as the first parameter to the action function.

### C. The "Recipe" Workflow (Lazy Loading)

The project implements an optimized multi-stage menu system that separates listing from data loading to maximize performance.

**Recipe Data Source:**

- **Listing (Parent):** fast execution of `goose recipe list --format json`.
- **Details (Child):** Lazy-loads parameters by parsing the specific YAML file on demand.

1.  **Select Recipe (`menus/goose/recipes.lua`):**
    - Executes `goose recipe list --format json` to get metadata (Title, Description, Path).
    - **Crucial:** Does **not** read file content or parameters at this stage (IO optimization).
    - Passes a lightweight JSON object: `{ "path": "...", "content": { ..., "parameters": nil } }`.
    - Uses `SubMenu` field for navigation.

2.  **Input Parameters (`menus/goose/recipe_params.lua`):**
    - Reads partial recipe via `lastMenuValue("goose_recipes")`.
    - **Lazy Loading:** Checks if `parameters` is nil.
    - If missing, calls `ParseYamlParameters(recipe.path)` (from `shared.lua`) to read and parse the specific file.
    - Proceeds to list parameters and capture input.

3.  **Execution:**
    - (Same as before) Uses `RunInTerminal` to execute the recipe.

4.  **Execution:**
    - "Run Recipe" validates required parameters
    - Extracts path from recipe object: `recipe.path`
    - Constructs `goose run --no-session --recipe <path> --params key=value ...`
    - Executes via `RunInTerminal()`
    - Clears parameter state with `setState({})`

## 6. Helper Functions (`utils/shared.lua`)

- `RunInTerminal(cmd)`: Launches command in terminal.
- `OpenWalkerMenu(provider_name)`: Switches Walker to a new menu provider.
- `ReadFile(path)`: Reads and returns file content as string. **Note:** Capital R, capital F.
- `ParseYamlParameters(path)`: Extracts parameter definitions from a YAML recipe file.

### 6.2 Global Constants (`utils/shared.lua`)

**`GOOSE_CMDS` Table:** Centralizes all `goose` CLI commands. Use these constants instead of hardcoding strings.
**`WALKER_CMDS` Table:** Centralizes all `walker` CLI commands. Use these constants instead of hardcoding strings.

## 6.1 Built-in Elephant Functions

These functions are provided globally by Elephant (exposed from Go to Lua in `menucfg.go`):

- `jsonDecode(json_string)`: Decodes a JSON string into a Lua table. Returns `nil, error` if parsing fails.

  ```lua
  local content = ReadFile("/path/to/file.json")
  local data = jsonDecode(content) -- Returns Lua table
  if data and type(data) == "table" then
      for _, item in ipairs(data) do
          -- process item
      end
  end
  ```

- `jsonEncode(lua_table)`: Encodes a Lua table into a JSON string. Handles nested tables, arrays, and objects.

  ```lua
  local my_data = { name = "test", values = {1, 2, 3} }
  local json_str = jsonEncode(my_data) -- Returns JSON string
  ```

- `state()`: Returns the current menu's persisted state as a list of strings.

- `setState(list)`: Persists a list of strings as the current menu's state.

- `lastMenuValue(menu_name)`: Gets the `Value` field from the selected entry in the parent menu.

  **⚠️ CRITICAL CAVEAT:** `LastMenuValue` is updated in a **`defer` statement** in Go (see `setup.go:69-75`), which means it runs AFTER the action function completes. If you use a lua action like `Actions = { default = "lua:MyFunction" }`, the defer runs AFTER `MyFunction()` completes, causing timing issues.

  **✅ CORRECT SOLUTION - Use SubMenu Field:**

  Use the `SubMenu` field in your entry to navigate to a child menu. This triggers the defer statement BEFORE navigation, making `lastMenuValue()` work correctly.

  ```lua
  -- In parent menu (recipes.lua):
  function GetEntries()
      local entries = {}
      for i, item in ipairs(data) do
          table.insert(entries, {
              Text = item.name,
              Value = jsonEncode(item),  -- Store full object as JSON
              SubMenu = "child_menu_name"  -- Navigate to child menu
          })
      end
      return entries
  end

  -- In child menu (child_menu_name.lua):
  function GetEntries()
      local item_json = lastMenuValue("parent_menu_name")  -- ✓ Gets correct value!
      local item = jsonDecode(item_json)
      -- Now you have the correct item
  end
  ```

  **How it works** (see `menucfg.go:357-360` and `setup.go:69-106`):
  1. Elephant auto-creates Identifier: `"menus:child_menu:parent_menu:hash"`
  2. When entry is selected, Elephant finds it in parent menu's entries
  3. **Defer runs** and sets `LastMenuValue["parent_menu"] = Value`
  4. Opens child menu
  5. Child menu can now read the correct value via `lastMenuValue()`

  **❌ DON'T use lua actions for navigation** - they cause the defer to run AFTER navigation, giving you stale data

## 7. Current Implementation Status

### Recipe System ✅

- **Data Source:** Dual-strategy dynamic scan (yq preferred, fallback to manual Lua parsing). No pre-generated JSON needed.
- **Menu Flow:** `recipes.lua` → SubMenu field → `recipe_params.lua`
- **Data Passing:** `SubMenu = "child_menu"` field triggers defer before navigation; full recipe object passed.
- **Input Capture:** `walker --dmenu --inputonly` via `io.popen()`
- **Parameter Storage:** Menu-specific state via `state()`/`setState()`
- **Performance:** Optimized to read data once in parent; passes in-memory JSON to child.
- **Requirements:** `yq` optional (fallback provided).
- **Key Discovery:** Using `SubMenu` field instead of lua actions solves `lastMenuValue()` timing issues

### Model Selection System ✅

- Single source: `~/.ai/goose_known_models.txt` (extracted from Rust source)
- Unified function: `get_models_from_provider(provider_name)`
- Providers: gemini-cli (from file), ollama (dynamic), claude (from file)
- Fallback: Hardcoded gemini-cli models if file missing

### Known Issues

- None currently

---

## 8. Changes Summary (2026-01-08)

### Session Context

Continued work from Gemini conversation where Gemini struggled with recipe menu showing 0 entries and data passing between menus.

### Root Causes Identified

**Issue #1: Function Name Mismatch**

- ❌ Gemini used `read_file()` (lowercase)
- ✅ Correct function is `ReadFile()` (from `shared.lua`, capital R and F)

**Issue #2: Data Passing Between Menus**

- ❌ Initially: Re-read entire 276KB `recipes.json` in `recipe_params.lua` for every access
- ❌ Attempted: Use `lastMenuValue()` directly with lua actions → failed due to timing issues
- ❌ Temporary workaround: Temp file (`~/.local/share/elephant/goose_current_recipe.json`)
- 🔍 **Key Discovery:** `LastMenuValue` is updated in `defer` statement (setup.go:69-75) which runs AFTER lua actions complete
- ❌ Attempted: Special `Identifier` format - misunderstood the code, wasted many tokens
- ✅ **Final Solution:** `SubMenu` field (menucfg.go:357-360) triggers defer BEFORE navigation

**Issue #3: Serena MCP Tool Syntax Errors**

- When using `mcp__serena__replace_symbol_body`, original `local` keyword was preserved
- Created invalid syntax: `local local function getRecipeFromParent()`
- ✅ Fixed by always validating with `luac -p` after edits

### Critical Discovery: SubMenu Field

**Source Code Analysis** (menucfg.go:357-360):

```go
if entry.SubMenu != "" {
    entry.Identifier = fmt.Sprintf("menus:%s:%s:%s", entry.SubMenu, entry.Menu, identifier)
}
```

**How It Works:**

1. Entry has `SubMenu = "child_menu_name"` in Lua
2. Elephant auto-creates Identifier: `"menus:child_menu:parent_menu:hash"`
3. When selected (setup.go:80-106):
   - Parses identifier: `submenu = "child_menu"`, `m = "parent_menu"`
   - Finds entry in `common.Menus["parent_menu"]` ✓
   - **Defer statement runs** (lines 69-75): `LastMenuValue["parent_menu"] = entry.Value`
   - Navigates to child menu
4. Child menu calls `lastMenuValue("parent_menu")` → gets correct value! ✓

**Why Lua Actions Don't Work:**

```go
// Lines 141-165: Lua action execution
if after, ok := strings.CutPrefix(run, "lua:"); ok {
    state.CallByParam(lua.P{...}, lua.LString(e.Value), ...)
    // ← Defer runs AFTER this completes, then OpenWalkerMenu() navigates
}
```

The defer statement executes after the lua function finishes. When the lua function calls `OpenWalkerMenu()`, the child menu opens before defer sets the value, causing stale data.

### Files Changed

#### `/home/voznik/.config/elephant/menus/goose/recipes.lua`

**Before:**

```lua
local entry = {
    Text = name,
    Subtext = subtext,
    Value = jsonEncode(recipe),
    Preview = recipe.path,
    PreviewType = "file",
    Actions = { default = "lua:RunRecipe" }
}

function RunRecipe(recipe_json)
    local temp = os.getenv("HOME") .. "/.local/share/elephant/goose_current_recipe.json"
    local f = io.open(temp, "w")
    f:write(recipe_json)
    f:close()
    OpenWalkerMenu("goose_recipe_params")
end
```

**After:**

```lua
local entry = {
    Text = name,
    Subtext = subtext,
    Value = jsonEncode(recipe),  -- Full recipe object as JSON
    SubMenu = "goose_recipe_params",  -- Navigate to child menu
    Preview = recipe.path,
    PreviewType = "file"
    -- No Actions field needed - SubMenu handles navigation
}
-- RunRecipe() function removed entirely
-- Elephant auto-creates Identifier: "menus:goose_recipe_params:goose_recipes:hash"
```

#### `/home/voznik/.config/elephant/menus/goose/recipe_params.lua`

**Before:**

```lua
local function getRecipeJsonFromParentMenu()
    local temp_file = os.getenv("HOME") .. "/.local/share/elephant/goose_current_recipe.json"
    local recipe_json = ReadFile(temp_file)  -- Read from filesystem
    if not recipe_json or recipe_json == "" then return nil end
    local recipe = jsonDecode(recipe_json)
    return recipe
end
```

**After:**

```lua
local function getRecipeFromParent()
    local recipe_json = lastMenuValue("goose_recipes")  -- Read from memory!
    if not recipe_json or recipe_json == "" then return nil end
    local recipe = jsonDecode(recipe_json)
    return recipe
end
```

All other functions (`GetEntries`, `EditParam`, `ExecuteRecipe`) updated to call `getRecipeFromParent()` with consistent naming.

### Testing

Created test scripts to validate approach:

- `/tmp/test_identifier_simple.lua` - Verified concept with mock data
- `/tmp/test_with_actual_recipes.lua` - Verified with actual 276KB recipes.json

Both tests passed, confirming:

1. `Value` field accepts any string (including large JSON)
2. `LastMenuValue` stores strings correctly
3. `Identifier` format triggers defer before child menu opens
4. `jsonEncode()`/`jsonDecode()` handle serialization properly

### Key Learnings

1. ✅ **Always validate Lua with `luac -p`** before testing
2. ✅ **`ReadFile()` not `read_file()`** - case matters
3. ✅ **`jsonEncode()` and `jsonDecode()` are built-in** (menucfg.go:77-78)
4. ✅ **`SubMenu` field solves `lastMenuValue()` timing issues** - use `SubMenu = "child_menu"` instead of lua actions
5. ⚠️ **`lastMenuValue()` with lua actions returns stale data** - defer runs after action completes
6. ✅ **Action functions receive `Value` as first parameter** - can be used for custom actions that don't navigate
7. ✅ **No temp files needed** - all data passing via `Value` field and `lastMenuValue()` with `SubMenu`
8. ⚠️ **Listen to user hints about codebase** - user knew about submenu concept, should have grepped for it immediately

## 9. Changes Summary (Lazy Loading Recipes) (2026-01-08)

### Context

Transitioned to a highly optimized **Lazy Loading** architecture to improve start-up time and robustness.

### Changes

- **`menus/goose/recipes.lua`**:
  - Removed all file reading and `yq` usage.
  - Now exclusively uses `goose recipe list --format json` to list entries.
  - Passes a lightweight object (missing parameters) to the child menu.
- **`menus/goose/recipe_params.lua`**:
  - Implemented lazy loading: Checks if `parameters` are missing.
  - Calls `ParseYamlParameters` to read the specific file on demand.
- **`utils/shared.lua`**:
  - Added `ParseYamlParameters(path)`: A dedicated Lua function to extract parameter definitions from YAML files using pattern matching.

### Benefits

- **Performance:** Parent menu loads instantly (1 command vs 50+ file reads).
- **Efficiency:** File I/O occurs only for the _selected_ recipe.
- **Simplicity:** Removed dependency on `yq`.
- **Maintainability:** YAML parsing logic centralized in `shared.lua`.
