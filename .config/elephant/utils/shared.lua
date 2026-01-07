TERMINAL = os.getenv("TERMINAL") or "ghostty"
SHELL = os.getenv("SHELL") or "/bin/bash"
CONFIG_FILE = os.getenv("HOME") .. "/.config/goose/config.yaml"

-- Load libraries globally
local home = os.getenv("HOME")
local config_dir = home .. "/.config/elephant"

-- JSON
JSON = dofile(config_dir .. "/utils/json.lua")

-- YAML
YAML = dofile(config_dir .. "/utils/yaml.lua")

-- State Manager
STATE = dofile(config_dir .. "/utils/state.lua")

-- === HELPER: Open Walker Menu ===
function OpenWalkerMenu(menu)
    os.execute("walker --provider menus:" .. menu)
end

-- === HELPER: Run command in terminal ===
function RunInTerminal(cmd)
    local wrapper = string.format(
        [[ %s -e %s -c "%s; echo ''; echo '[Press Enter to close]'; read" ]],
        TERMINAL,
        SHELL,
        cmd
    )
    os.execute("notify-send 'Goose' 'Running terminal command'")
    os.execute(wrapper)
end

-- === HELPER: Read file content ===
function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

-- === HELPER: Fetch output from command using user's shell ===
function ReadShellCommand(cmd)
    local wrapper = string.format('%s -c "%s"', SHELL, cmd)
    return io.popen(wrapper)
end

-- === HELPER: Read and decode a JSON file ===
function ReadJsonFile(path)
    local content = read_file(path)
    if not content then return nil end

    local status, result = pcall(JSON.decode, content)
    if status then
        return result
    else
        os.execute("notify-send 'Elephant JSON Error' 'Failed to parse JSON: " .. path .. "'")
        return nil
    end
end

-- === HELPER: Parse YAML by Key ===
-- Parses a YAML file and returns the value of a specific key
function ParseYamlByKey(path, key)
    local content = read_file(path)
    if not content then
        os.execute("notify-send 'Elephant Error' 'Could not read file: " .. path .. "'")
        return {}
    end

    local status, data = pcall(YAML.parse, content)
    if not status then
        os.execute("notify-send 'Elephant YAML Error' 'Failed to parse: " .. path .. "\n" .. tostring(data) .. "'")
        return {}
    end
    return data[key] or {}
end

-- === HELPER: Trim string ===
function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- === HELPER: List files matching a pattern ===
function ListFiles(pattern)
    local files = {}
    -- Use shell expansion to find files
    local p = io.popen('ls -1 ' .. pattern .. ' 2>/dev/null')
    if p then
        for file in p:lines() do
            table.insert(files, file)
        end
        p:close()
    end
    return files
end
