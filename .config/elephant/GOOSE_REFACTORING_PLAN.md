# Refactoring Plan: Proper Nested Menus for Goose

## Overview

**Goal:** Implement proper parent-child menu hierarchy using walker's `Parent` field and reorganize files into a cleaner structure.

Refactoring Options
Option A: Minimal Change - Use Parent Field Only
✅ Low risk, preserves current file structure
Changes:
1. Add Parent = "goose" to all goose submenu Lua files
2. Remove manual ".. Back" entries from GetEntries() 
3. Remove OpenGooseBack() helper function
4. Walker will automatically show back button via menus:parent action
Pros:
- Minimal code changes
- Keeps separate menu files (may prefer this for maintenance)
- Automatic back navigation built-in
- Less code to maintain
Cons:
- Still have 7 separate files
- No logical directory organization
- No file consolidation
---
Option B: Moderate Change - Consolidate Related Menus
✅ Balance of organization and simplicity
Changes:
1. Move all goose menus to menus/goose/ subdirectory
2. Consolidate related menus:
   - goose_sessions.lua → merge into main goose.lua as submenu entries
   - goose_models.lua → keep separate (complex logic)
   - goose_projects.lua → keep separate (complex logic)
   - goose_recipes.lua + goose_recipe_params.lua → merge into one file
   - goose_prompts.lua → keep separate (simple list)
3. Use Parent field for proper hierarchy
4. Remove manual back buttons
File Structure:
~/.config/elephant/menus/
├── goose/
│   ├── goose.lua (main + sessions)
│   ├── goose_models.lua (Parent = "goose")
│   ├── goose_projects.lua (Parent = "goose")
│   ├── goose_recipes.lua (includes params, Parent = "goose")
│   └── goose_prompts.lua (Parent = "goose")
Pros:
- Better organization (goose subdirectory)
- Fewer files (6 instead of 7)
- Cleaner navigation
- Proper parent-child relationships
Cons:
- More refactoring work
- Some files become larger
---
Option C: Complete Reorganization - Deep Nesting
✅ Best for long-term scalability
Changes:
1. Create nested directory structure by feature
2. Use SubMenu field in entries to create multi-level navigation
3. Consolidate into fewer, more focused files
4. Remove all manual back navigation
5. Use Parent field consistently
Proposed Structure:
~/.config/elephant/menus/goose/
├── main.lua                (goose entry point)
├── session_management.lua   (goose_sessions)
├── model_selection.lua      (goose_models)
├── workspace/
│   ├── projects.lua        (goose_projects)
│   └── recipes.lua        (goose_recipes + params)
└── prompts.lua            (goose_prompts)
Deep Nesting Example:
-- workspace/recipes.lua
Name = "goose_recipes"
NamePretty = "Recipes"
Parent = "goose"
function GetEntries()
    local entries = {}
    
    for _, recipe_path in ipairs(list_recipes()) do
        local entry = {
            Text = get_recipe_name(recipe_path),
            Subtext = "Configure and run",
            Value = recipe_path,
            -- Create submenu for parameters!
            SubMenu = "goose_recipe_params:" .. recipe_hash(recipe_path),
            Preview = recipe_path
        }
        table.insert(entries, entry)
    end
    
    return entries
end
Pros:
- Clear logical organization
- Scalable for future features
- Multi-level submenu support via SubMenu field
- Maximum leverage of walker features
- Single source of truth per feature
Cons:
- Most refactoring work
- May be overkill for current complexity
- Learning curve for new structure
---
Recommended Approach
I recommend Option B for these reasons:
1. Balanced complexity - Not too simple, not too complex
2. Logical grouping - Related menus stay together
3. Reduced redundancy - Merges recipe_params into recipes
4. Proper nesting - Uses Parent field for hierarchy
5. Directory organization - menus/goose/ subdirectory
6. Preserves existing logic - Complex menus stay separate
---

**Approach:** Option A - Minimal changes with file reorganization

## Current State

**Structure:**
- 7 separate `.lua` menu files in `~/.config/elephant/menus/`
- Manual ".. Back" entries in each submenu
- Each uses `OpenWalkerMenu("goose")` to return to main menu
- No use of `Parent` field for proper hierarchy
- Manual navigation control

**Issues:**
1. Redundant ".. Back" entries in every submenu
2. No automatic back button via `menus:parent` action
3. Each submenu requires separate file in root directory
4. Navigation relies on spawning new walker instances
5. Not leveraging walker's built-in parent navigation

## New File Structure

```
~/.config/elephant/menus/goose/
├── main.lua           (from goose.lua)
├── sessions.lua        (from goose_sessions.lua)
├── models.lua          (from goose_models.lua)
├── projects.lua        (from goose_projects.lua)
├── recipes.lua         (from goose_recipes.lua)
├── recipe_params.lua   (from goose_recipe_params.lua)
└── prompts.lua         (from goose_prompts.lua)
```

## Changes Summary

**Files to Create:** 7 (in new subdirectory)
**Files to Delete:** 7 (old files in root menus/)
**Files to Modify:** 1 (shared.lua)
**Net Lines of Code:** -14 (removing manual back buttons)

## Detailed File Changes

### 1. File: main.lua (new file)

**Source:** `~/.config/elephant/menus/goose.lua`

**Destination:** `~/.config/elephant/menus/goose/main.lua`

**Changes:** None (just copy)

**Key Content:**
```lua
Name = "goose"
NamePretty = "Goose Manager"
Icon = "terminal"
Cache = false
SearchName = true

function GetEntries()
    return {
        { Text = "New Session", Subtext = "Start a fresh goose session", Actions = { default = "lua:ActionNew" } },
        { Text = "Resume Session", Subtext = "List and resume past sessions", Actions = { default = "lua:OpenGooseSessions" } },
        { Text = "Projects", Subtext = "Open recent projects (goose ps)", Actions = { default = "lua:OpenGooseProjects" } },
        { Text = "Recipes", Subtext = "Run available recipes", Actions = { default = "lua:OpenGooseRecipes" } },
        { Text = "Prompts", Subtext = "Browse and use AI prompts", Actions = { default = "lua:OpenGoosePrompts" } },
        { Text = "Switch Model", Subtext = "Select from Gemini or local Ollama models", Actions = { default = "lua:OpenGooseModels" } },
        { Text = "Configure", Subtext = "Full interactive configuration", Actions = { default = "lua:ActionConfig" } }
    }
end

function ActionNew() RunInTerminal("goose session") end
function ActionConfig() RunInTerminal("goose configure") end
function OpenGooseSessions() OpenWalkerMenu("goose_sessions") end
function OpenGooseModels() OpenWalkerMenu("goose_models") end
function OpenGooseProjects() OpenWalkerMenu("goose_projects") end
function OpenGooseRecipes() OpenWalkerMenu("goose_recipes") end
function OpenGoosePrompts() OpenWalkerMenu("goose_prompts") end
```

**Note:** This is the root menu, no `Parent` field needed.

---

### 2. File: sessions.lua

**Source:** `~/.config/elephant/menus/goose_sessions.lua`

**Destination:** `~/.config/elephant/menus/goose/sessions.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_sessions"
NamePretty = "Goose Sessions"
Parent = "goose"  -- ← NEW ADDITION
Icon = "history"
Cache = false
HideFromProviderlist = true
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Remove OpenGooseBack function (if present):
```lua
-- REMOVE THIS ENTIRE FUNCTION:
-- function OpenGooseBack() OpenWalkerMenu("goose") end
```

**Preserve:**
- `GetEntries()` logic (list sessions)
- `ActionResume(id)` function

---

### 3. File: models.lua

**Source:** `~/.config/elephant/menus/goose_models.lua`

**Destination:** `~/.config/elephant/menus/goose/models.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_models"
NamePretty = "Goose Models"
Parent = "goose"  -- ← NEW ADDITION
Icon = "cpu"
Cache = true
HideFromProviderlist = true
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Remove OpenGooseBack function (if present)

**Preserve all existing:**
- `get_models_from_provider(provider_name)`
- `get_ollama_models()`
- `GetEntries()` (minus back button)
- `SetModel(value)`
- `UpdateGooseConfig(provider, model)`

---

### 4. File: projects.lua

**Source:** `~/.config/elephant/menus/goose_projects.lua`

**Destination:** `~/.config/elephant/menus/goose/projects.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_projects"
NamePretty = "Goose Projects"
Parent = "goose"  -- ← NEW ADDITION
Icon = "folder"
Cache = false
HideFromProviderlist = true
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Remove OpenGooseBack function (if present)

**Preserve:**
- `GetEntries()` (list projects)
- `OpenProject(path)`

---

### 5. File: recipes.lua

**Source:** `~/.config/elephant/menus/goose_recipes.lua`

**Destination:** `~/.config/elephant/menus/goose/recipes.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_recipes"
NamePretty = "Goose Recipes"
Parent = "goose"  -- ← NEW ADDITION
Icon = "🧾"
Cache = true
HideFromProviderlist = true
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Remove OpenGooseBack function (if present)

**Preserve:**
- `GetEntries()` (list recipes)
- `EditRecipe(path)`
- `GetRecipeName(path)`
- `RunRecipe(path)`

**Note:** Continues to call `OpenWalkerMenu("goose_recipe_params")` - menu name unchanged.

---

### 6. File: recipe_params.lua

**Source:** `~/.config/elephant/menus/goose_recipe_params.lua`

**Destination:** `~/.config/elephant/menus/goose/recipe_params.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_recipe_params"
NamePretty = "Recipe Parameters"
Parent = "goose"  -- ← NEW ADDITION
Icon = "⚙"
HideFromProviderlist = true
Cache = false
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Update OpenWalkerMenu call in EditParam function:
```lua
function EditParam(param_key)
    -- ... existing code ...
    -- Last line should be:
    OpenWalkerMenu("goose_recipe_params")  -- Menu name stays same
end
```

#### Remove OpenGooseBack function (if present)

**Preserve:**
- `GetEntries()`
- `EditParam(param_key)`
- `ExecuteRecipe()`
- `ClearParams()`

---

### 7. File: prompts.lua

**Source:** `~/.config/elephant/menus/goose_prompts.lua`

**Destination:** `~/.config/elephant/menus/goose/prompts.lua`

**Changes:**

#### Add Parent field:
```lua
Name = "goose_prompts"
NamePretty = "Goose Prompts"
Parent = "goose"  -- ← NEW ADDITION
Icon = "🆎"
Cache = false
HideFromProviderlist = true
MaxResults = 100
Actions = {
    default = "lua:OpenGooseWithPrompt",
    menus_open = os.execute("notify-send 'Goose!!!'")
}
```

#### Remove manual back entry from GetEntries():
```lua
function GetEntries()
    local entries = {}  -- ← REMOVE: manual back button
    -- Keep rest unchanged
```

#### Remove OpenGooseBack function (if present)

**Preserve:**
- `GetEntries()`
- `OpenGooseWithPrompt(prompt)`

---

### 8. File: shared.lua

**Location:** `~/.config/elephant/shared.lua`

**Changes:**

#### Remove obsolete helper:
```lua
-- REMOVE THIS FUNCTION:
-- function OpenGooseBack() OpenWalkerMenu("goose") end
```

**Preserve everything else.**

---

## Implementation Steps

### Step 1: Create New Directory
```bash
mkdir -p ~/.config/elephant/menus/goose
```

### Step 2: Copy Files with New Names
```bash
cp ~/.config/elephant/menus/goose.lua ~/.config/elephant/menus/goose/main.lua
cp ~/.config/elephant/menus/goose_sessions.lua ~/.config/elephant/menus/goose/sessions.lua
cp ~/.config/elephant/menus/goose_models.lua ~/.config/elephant/menus/goose/models.lua
cp ~/.config/elephant/menus/goose_projects.lua ~/.config/elephant/menus/goose/projects.lua
cp ~/.config/elephant/menus/goose_recipes.lua ~/.config/elephant/menus/goose/recipes.lua
cp ~/.config/elephant/menus/goose_recipe_params.lua ~/.config/elephant/menus/goose/recipe_params.lua
cp ~/.config/elephant/menus/goose_prompts.lua ~/.config/elephant/menus/goose/prompts.lua
```

### Step 3: Edit Each File

For each submenu file (sessions.lua, models.lua, projects.lua, recipes.lua, recipe_params.lua, prompts.lua):

1. **Add `Parent = "goose"`** after the `Name` field
2. **Remove manual back entry** from beginning of `GetEntries()`:
   ```lua
   -- DELETE THIS LINE:
   local entries = { { Text = ".. Back", Icon = "⬅", Preview = "", Actions = { default = "lua:OpenGooseBack" } } }
   ```
3. **Replace with:**
   ```lua
   local entries = {}
   ```
4. **Remove `OpenGooseBack()` function** if present

For main.lua:
- No changes needed (keep `Name = "goose"`, no `Parent` field)

For shared.lua:
- Remove `function OpenGooseBack()` entirely

### Step 4: Delete Old Files
```bash
rm ~/.config/elephant/menus/goose.lua
rm ~/.config/elephant/menus/goose_sessions.lua
rm ~/.config/elephant/menus/goose_models.lua
rm ~/.config/elephant/menus/goose_projects.lua
rm ~/.config/elephant/menus/goose_recipes.lua
rm ~/.config/elephant/menus/goose_recipe_params.lua
rm ~/.config/elephant/menus/goose_prompts.lua
```

### Step 5: Reload Elephant

Choose one method:

**Method 1: Restart systemd service**
```bash
systemctl --user restart elephant
```

**Method 2: Kill and restart**
```bash
pkill elephant
nohup elephant &>/dev/null &
```

**Method 3: Signal reload (if supported)**
```bash
pkill -HUP elephant
```

### Step 6: Verify Menu Discovery

Check that elephant sees the menus:
```bash
elephant listproviders | grep goose
```

Expected output:
```
Goose Manager;menus:goose
Goose Sessions;menus:goose_sessions
Goose Models;menus:goose_models
Goose Projects;menus:goose_projects
Goose Recipes;menus:goose_recipes
Recipe Parameters;menus:goose_recipe_params
Goose Prompts;menus:goose_prompts
```

## Expected Behavior After Changes

### Navigation Flow
1. Open walker → `menus:goose` → shows main menu
2. Select "Resume Session" → shows sessions list
3. Walker automatically adds "back" action (via `menus:parent`)
4. Press back → returns to main menu (not spawning new instance)
5. Select "Recipes" → shows recipe list
6. Select a recipe → shows recipe parameters
7. Press back → returns to main menu (via `Parent = "goose"`)
8. Select "Prompts" → shows prompts
9. Press back → returns to main menu

### What Walker Handles
- Automatic `menus:parent` action when menu has `Parent` field
- Visual back button in UI
- Smooth navigation without spawning new walker instances
- No need to manually call `OpenWalkerMenu("goose")` for back navigation

### What Your Menus Do
- Define parent-child relationships via `Parent` field
- Provide specific functionality
- Keep all existing logic intact

## Key Design Decisions

### Menu Names Stay the Same
- `Name = "goose"` (not "main")
- `Name = "goose_sessions"` (not "sessions")
- This ensures backward compatibility with function calls

### File Organization
- Subdirectory structure for logical grouping
- Shorter, cleaner filenames
- Recursive file discovery by elephant handles this automatically

### Minimal Code Changes
- Only add `Parent = "goose"` field
- Remove manual back navigation
- Keep all existing logic unchanged

## Benefits

1. **Cleaner Organization:** All goose menus in `menus/goose/` subdirectory
2. **Proper Hierarchy:** Uses walker's built-in parent navigation
3. **Less Code:** Removes ~14 lines of redundant back button code
4. **Better UX:** Automatic back button, smoother navigation
5. **Maintainability:** Easier to understand and extend
6. **Leverages Walker:** Uses framework features instead of workarounds

## Rollback Plan

If issues occur:

1. Restore old files from backup (if created):
   ```bash
   cp ~/.config/elephant/menus/goose/*.lua ~/.config/elephant/menus/
   ```

2. Or recreate from scratch (files still in git history if tracked)

3. Restart elephant service

## Notes

- The `Parent` field tells walker to automatically show a back action (`menus:parent`)
- Walker's `State()` function checks `val.Parent != ""` to add the back action
- When back is triggered, walker sends `menus:goose` to navigate to parent
- Elephant's `ActionGoParent` handler processes `menus:parent` actions
- This is the intended way to handle menu hierarchies in walker/elephant

---

**Document Version:** 1.0
**Last Updated:** 2025-01-07
