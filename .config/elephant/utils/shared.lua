TERMINAL = os.getenv("TERMINAL") or "ghostty"
CONFIG_FILE = os.getenv("HOME") .. "/.config/goose/config.yaml"

-- Load libraries globally
local home = os.getenv("HOME")
local config_dir = home .. "/.config/elephant"

-- === HELPER: Check if system is in Dark Mode ===
function IsDarkMode()
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
    if not handle then return true end -- Default to dark if check fails
    local result = handle:read("*a")
    handle:close()
    return result and result:find("dark") ~= nil
end

-- === HELPER: Get Goose Icon Path based on theme ===
function GetGooseIcon()
    local icon_name = IsDarkMode() and "goose-icon-white.png" or "goose-icon-black.png"
    return os.getenv("HOME") .. "/.config/elephant/menus/goose/icons/" .. icon_name
end


-- === HELPER: Open Walker Menu ===
function OpenWalkerMenu(menu)
    os.execute(string.format(WALKER_CMDS.PROVIDER_FMT, menu))
end

-- === HELPER: Run command in terminal ===
function RunInTerminal(cmd)
    local shell = os.getenv("SHELL") or "/bin/sh"
    local wrapper = string.format(
        [[ %s -e %s -c "%s; echo ''; echo '[Press Enter to close]'; read" ]],
        TERMINAL,
        shell,
        cmd
    )
    os.execute("notify-send 'Goose' 'Running terminal command'")
    os.execute(wrapper)
end

-- === HELPER: Read file content ===
function ReadFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

-- === HELPER: command using user's shell ===
function PrepareShellCommand(cmd)
    local shell = os.getenv("SHELL") or "/bin/sh"
    return string.format('%s -c "%s"', shell, cmd)
end

-- === HELPER: Trim string ===
function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- === CONSTANTS: Walker CLI Commands ===
WALKER_CMDS = {
    PROVIDER_FMT = "walker --provider menus:%s",
    DMENU_INPUT_FMT = "walker --dmenu --inputonly --maxheight 2 --placeholder '%s'"
}

-- === CONSTANTS: Goose CLI Commands ===
GOOSE_CMDS = {
    SESSION_NEW = "goose session",
    SESSION_LIST = "goose session list",
    SESSION_RESUME_FMT = "goose session --resume --session-id %s",
    CONFIGURE = "goose configure",
    RECIPE_LIST_JSON = "goose recipe list --format json",
    -- Note: Params are appended manually to RECIPE_RUN_FMT in recipe_params.lua
    RECIPE_RUN_FMT = "goose run --no-session --recipe %s",
    PROMPT_RUN_FMT = "goose run --text '%s'"
}

-- === HELPER: Parse parameters from Recipe YAML ===
-- Extracts key, description, and requirement from a recipe file
function ParseYamlParameters(path)
    local content = ReadFile(path)
    if not content then return nil end

    local params = {}
    local in_params = false
    local current_param = nil

    for line in content:gmatch("[^\r\n]+") do
        -- Detect start of parameters section (no indentation)
        if line:match("^parameters:") then
            in_params = true
        elseif in_params and line:match("^%S") then
            -- Found a top-level key that is NOT parameters, so section ended
            in_params = false
        elseif in_params then
            -- Match "- key: ..."
            local key = line:match("^%s*-%s*key:%s*(.+)")
            if key then
                -- Save previous param
                if current_param then table.insert(params, current_param) end
                current_param = { key = key }
            elseif current_param then
                -- Match properties
                local req = line:match("^%s*requirement:%s*(.+)")
                if req then current_param.requirement = req end

                local desc = line:match("^%s*description:%s*(.+)")
                if desc then current_param.description = desc end
            end
        end
    end
    if current_param then table.insert(params, current_param) end

    return params
end
