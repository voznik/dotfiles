# OpenCode Integration Plan

## Overview
Create OpenCode menus by duplicating the existing Goose menu structure and adapting it for OpenCode commands.

## Approach: Duplicate Code (Simple & Fast)

Create `/home/voznik/.config/elephant/menus/opencode/` with duplicated and adapted files.

**Why this approach:**
- Fast to implement
- No risk to existing goose menus
- Can iterate and test quickly
- Refactoring can be a separate future plan

## Current State Analysis

### Existing Goose Menus to Replicate
- **main.lua**: Hub menu
- **sessions.lua**: Parse and resume sessions
- **models.lua**: List and select models
- **projects.lua**: List recent projects

### NOT Implementing (Yet)
- ❌ Recipes (opencode doesn't have this)
- ❌ Prompts (opencode doesn't have this)
- ❌ Agents (not needed for this plan)
- ❌ Stats (not needed for this plan)

### OpenCode Command Mapping

| Feature | Goose Command | OpenCode Command |
|---------|--------------|------------------|
| New session | `goose session` | `opencode` |
| Continue last | N/A | `opencode -c` |
| List sessions | `goose session list` | `opencode session list` |
| Resume session | `goose session --resume --session-id <id>` | `opencode -s <id>` |
| List models | (from file + ollama) | `opencode models` |
| Projects | `~/.local/share/goose/projects.json` | `~/.local/share/opencode/storage/project/*.json` |

### Sample OpenCode Output

**Sessions** (`opencode session list`):
```
Session ID                      Title                                               Updated
───────────────────────────────────────────────────────────────────────────────────────────
ses_46191c476ffeBffsxdwUwTAkg4  New session - 2026-01-08T16:26:22.985Z              5:28 PM · 1/8/2026
ses_46ffc0930ffeojWI9rj8mwF0A4  elephant walker goose lua scripting                 6:33 PM · 1/7/2026
```
- Header row
- Separator line with dashes
- Data rows: ID (whitespace) Title (whitespace) Updated

**Models** (`opencode models`):
```
opencode/big-pickle
opencode/glm-4.7-free
google/gemini-1.5-flash
google/gemini-2.5-pro
mistral/codestral-latest
openrouter/anthropic/claude-sonnet-4.5
...194 total models
```
- Simple line-by-line list
- Format: `provider/model-name`
- No headers, no separators

**Projects** (`/home/voznik/.local/share/opencode/storage/project/*.json`):
- Multiple JSON files, one per project
- Need to inspect format (likely similar to goose)

## Implementation Plan

### Phase 1: Add OpenCode Commands to shared.lua
**Goal:** Define OpenCode CLI commands without modifying existing code

**File:** `utils/shared.lua`

**Add:**
```lua
-- === CONSTANTS: OpenCode CLI Commands ===
OPENCODE_CMDS = {
    SESSION_NEW = "opencode",
    SESSION_CONTINUE = "opencode -c",
    SESSION_LIST = "opencode session list",
    SESSION_RESUME_FMT = "opencode -s %s",
    MODELS_LIST = "opencode models"
}
```

**Risk:** None (append only)

### Phase 2: OpenCode Main Menu
**Goal:** Create entry point menu

**File:** `menus/opencode/main.lua`

**Structure:**
```lua
Name = "opencode"
NamePretty = "OpenCode Manager"
Cache = false
SearchName = true
Icon = "🔧"  -- or create icon files later

function GetEntries()
    return {
        { Text = "OpenCode: New Session", Subtext = "Start fresh session", Icon = "🔧", Actions = { default = "lua:ActionNew" } },
        { Text = "OpenCode: Continue Last", Subtext = "Resume last session", Icon = "🔧", Actions = { default = "lua:ActionContinue" } },
        { Text = "OpenCode: Resume Session", Subtext = "List and resume past sessions", Icon = "🔧", SubMenu = "opencode_sessions" },
        { Text = "OpenCode: Projects", Subtext = "Open recent projects", Icon = "🔧", SubMenu = "opencode_projects" },
        { Text = "OpenCode: Switch Model", Subtext = "Select from available models", Icon = "🔧", SubMenu = "opencode_models" }
    }
end

function ActionNew() RunInTerminal(OPENCODE_CMDS.SESSION_NEW) end
function ActionContinue() RunInTerminal(OPENCODE_CMDS.SESSION_CONTINUE) end
```

**Register in:** `menus/menus.toml`
```toml
[opencode]
path = "menus/opencode/main.lua"
```

**Test:**
- `walker --provider menus:opencode`
- Click "New Session" → terminal opens with `opencode`
- Click "Continue Last" → terminal opens with `opencode -c`

### Phase 3: OpenCode Sessions Menu
**Goal:** List and resume sessions

**File:** `menus/opencode/sessions.lua`

**Structure:**
```lua
Name = "opencode_sessions"
NamePretty = "OpenCode Sessions"
Parent = "opencode"
Icon = "history"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local handle = io.popen(PrepareShellCommand(OPENCODE_CMDS.SESSION_LIST))
    if not handle then return entries end

    local lines = {}
    for line in handle:lines() do
        table.insert(lines, line)
    end
    handle:close()

    -- Skip first 2 lines (header + separator)
    for i = 3, #lines do
        local line = lines[i]
        if line and line ~= "" then
            -- Parse: ses_ID  Title  Timestamp
            -- Example: ses_46191c476ffeBffsxdwUwTAkg4  New session - 2026-01-08T16:26:22.985Z              5:28 PM · 1/8/2026
            -- Strategy: capture first word as ID, last part as date, everything in between as title
            local id = line:match("^(%S+)")
            if id then
                -- Extract the timestamp from the end (pattern: HH:MM AM/PM · M/D/YYYY)
                local updated = line:match("(%d+:%d+%s+[AP]M.+)$")

                -- Extract title (everything between ID and timestamp)
                local title_start = #id + 1
                local title_end = updated and line:find(updated, 1, true) or #line
                local title = line:sub(title_start, title_end - 1):trim()

                table.insert(entries, {
                    Text = title or "Untitled Session",
                    Subtext = "ID: " .. id .. (updated and " | " .. updated or ""),
                    Value = id,
                    Actions = { default = "lua:ResumeSession" }
                })
            end
        end
    end

    if #entries == 0 then
        table.insert(entries, { Text = "No sessions found", Icon = "warning" })
    end

    return entries
end

function ResumeSession(id)
    RunInTerminal(string.format(OPENCODE_CMDS.SESSION_RESUME_FMT, id))
end
```

**Test:**
- Navigate from main → "Resume Session"
- Verify session list displays
- Click a session → terminal opens with `opencode -s <id>`

### Phase 4: OpenCode Models Menu
**Goal:** Display all 194 models in a simple list

**File:** `menus/opencode/models.lua`

**Structure:**
```lua
Name = "opencode_models"
NamePretty = "OpenCode Models"
Parent = "opencode"
Icon = "cpu"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local handle = io.popen(PrepareShellCommand(OPENCODE_CMDS.MODELS_LIST))
    if not handle then return entries end

    for line in handle:lines() do
        local model = line:trim()
        if model ~= "" then
            -- Extract provider from "provider/model" format
            local provider, model_name = model:match("^([^/]+)/(.+)$")
            if provider and model_name then
                table.insert(entries, {
                    Text = model,
                    Subtext = "Provider: " .. provider,
                    Value = model,
                    Actions = { default = "lua:SetModel" }
                })
            else
                -- Fallback for models without "/" (e.g., "opencode/big-pickle")
                table.insert(entries, {
                    Text = model,
                    Subtext = "Model: " .. model,
                    Value = model,
                    Actions = { default = "lua:SetModel" }
                })
            end
        end
    end
    handle:close()

    if #entries == 0 then
        table.insert(entries, { Text = "No models available", Icon = "warning" })
    end

    return entries
end

function SetModel(model)
    -- TODO: Research how opencode stores selected model
    -- For now, just notify and potentially store in our own state
    os.execute("notify-send 'OpenCode' 'Model selection: " .. model .. "'")

    -- Option 1: If opencode has a config file, update it
    -- UpdateOpenCodeConfig(model)

    -- Option 2: Store in our own state for use with -m flag
    -- SaveModelToState(model)
end
```

**Research needed:** How does opencode store the default model?
- Check `~/.config/opencode/`
- Check `opencode --help` for config flags
- May need to use `opencode -m provider/model` flag instead of persistent config

**Test:**
- Navigate from main → "Switch Model"
- Verify all 194 models display
- Search works (Walker's built-in search)
- Click a model → notification appears

### Phase 5: OpenCode Projects Menu
**Goal:** List recent projects from JSON files

**File:** `menus/opencode/projects.lua`

**First:** Inspect the JSON format
```bash
ls /home/voznik/.local/share/opencode/storage/project/
cat /home/voznik/.local/share/opencode/storage/project/<filename>.json | head -20
```

**Expected structure** (similar to goose):
```json
{
  "path": "/home/voznik/projects/myproject",
  "last_accessed": "2026-01-08T12:00:00Z"
}
```

**Structure:**
```lua
Name = "opencode_projects"
NamePretty = "OpenCode Projects"
Parent = "opencode"
Icon = "folder"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local projects_dir = os.getenv("HOME") .. "/.local/share/opencode/storage/project"

    -- Get all JSON files in the directory
    local handle = io.popen("ls " .. projects_dir .. "/*.json 2>/dev/null")
    if not handle then return entries end

    local projects = {}
    for file in handle:lines() do
        local content = ReadFile(file)
        if content then
            local project = jsonDecode(content)
            if project and project.path then
                table.insert(projects, {
                    path = project.path,
                    timestamp = project.last_accessed or project.lastAccessed or "0"
                })
            end
        end
    end
    handle:close()

    -- Sort by timestamp descending
    table.sort(projects, function(a, b)
        return a.timestamp > b.timestamp
    end)

    -- Create entries
    for _, project in ipairs(projects) do
        -- Format timestamp if available
        local display_time = ""
        if project.timestamp ~= "0" then
            local date_cmd = "date -d '" .. project.timestamp .. "' +'%Y-%m-%d %H:%M' 2>/dev/null || echo 'Recently'"
            local date_p = io.popen(date_cmd)
            if date_p then
                display_time = date_p:read("*a"):gsub("\n", "")
                date_p:close()
            end
        end

        table.insert(entries, {
            Text = project.path,
            Subtext = "Last accessed: " .. display_time,
            Value = project.path,
            Actions = { default = "lua:OpenProject" }
        })
    end

    if #entries == 0 then
        table.insert(entries, { Text = "No recent projects", Icon = "warning" })
    end

    return entries
end

function OpenProject(path)
    RunInTerminal("cd '" .. path .. "' && " .. OPENCODE_CMDS.SESSION_NEW)
end
```

**Test:**
- Navigate from main → "Projects"
- Verify projects display sorted by recency
- Click a project → terminal opens in that directory with `opencode`

### Phase 6: Icon Setup (Optional Enhancement)

**Create icons directory:**
```bash
mkdir -p /home/voznik/.config/elephant/menus/opencode/icons/
```

**Add light/dark icons** (if desired):
- `opencode-icon-white.png`
- `opencode-icon-black.png`

**Update main.lua:**
```lua
dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetOpenCodeIconPng()
    local icon_name = IsDarkMode() and "opencode-icon-white.png" or "opencode-icon-black.png"
    return os.getenv("HOME") .. "/.config/elephant/menus/opencode/icons/" .. icon_name
end

Icon = GetOpenCodeIconPng()
```

**For now:** Use emoji "🔧" or keep as text

## File Structure (After Implementation)

```
~/.config/elephant/
├── menus/
│   ├── goose/
│   │   ├── main.lua
│   │   ├── sessions.lua
│   │   ├── models.lua
│   │   ├── projects.lua
│   │   ├── recipes.lua
│   │   ├── recipe_params.lua
│   │   └── prompts.lua
│   ├── opencode/
│   │   ├── main.lua              ← NEW
│   │   ├── sessions.lua          ← NEW
│   │   ├── models.lua            ← NEW
│   │   └── projects.lua          ← NEW
│   └── menus.toml                ← MODIFIED (add opencode entry)
├── utils/
│   └── shared.lua                ← MODIFIED (add OPENCODE_CMDS)
```

## Testing Checklist

After each phase:
1. **Syntax validation:** `luac -p <file>`
2. **Manual test:** `walker --provider menus:opencode` (or submenu)
3. **Edge cases:**
   - [ ] No sessions available
   - [ ] No projects available
   - [ ] Empty model list (unlikely)
   - [ ] Special characters in titles/paths
4. **Navigation:**
   - [ ] Main menu displays all entries
   - [ ] SubMenu navigation works
   - [ ] Actions trigger correctly
   - [ ] Terminal commands execute

## Open Questions to Research

1. **OpenCode Config:**
   - Where is the selected model stored?
   - Does opencode have a config file like `~/.config/opencode/config.yaml`?
   - Or do we need to pass `-m provider/model` on every invocation?

2. **Project JSON Format:**
   - What keys are in the project JSON files?
   - `path`, `last_accessed`, `lastAccessed`?
   - Any other metadata we should display?

3. **Session Resume:**
   - Does `opencode -s <session-id>` work the same as goose?
   - Does it need additional flags?

## Implementation Order

1. ✅ Research OpenCode project JSON format
2. ✅ Phase 1: Add OPENCODE_CMDS to shared.lua
3. ✅ Phase 2: Create main.lua + register in menus.toml
4. ✅ Phase 3: Create sessions.lua
5. ✅ Phase 4: Create models.lua (defer SetModel implementation)
6. ✅ Phase 5: Create projects.lua
7. ✅ Phase 6: Icon setup (optional)

## Success Criteria

**Minimum Viable Product:**
- ✅ OpenCode main menu accessible via `walker --provider menus:opencode`
- ✅ Can start new session
- ✅ Can continue last session
- ✅ Can list and resume sessions
- ✅ Can browse models (selection may not persist)
- ✅ Can browse and open recent projects

## Rollback Strategy

- Keep backups of any modified files
- Git commit after each phase
- Can remove opencode entry from menus.toml to disable
- No changes to goose menus, so no risk there

## Future Refactor Plan

After OpenCode menus are working, we can create a separate plan to:
1. Extract common patterns from goose and opencode
2. Create tool-agnostic utilities
3. Migrate both to use shared code
4. Make it easy to add future tools (aider, cursor, etc.)

This refactor is NOT part of this plan - keep it simple for now.
