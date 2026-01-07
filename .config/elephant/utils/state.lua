local json = dofile(os.getenv("HOME") .. "/.config/elephant/utils/json.lua")
local M = {}

-- Store state in a persistent location for the user
M.FilePath = os.getenv("HOME") .. "/.local/share/elephant/goose_state.json"

-- Ensure the directory exists
local dir = M.FilePath:match("(.*/)")
os.execute("mkdir -p '" .. dir .. "'")

--- Loads the state from disk. Returns an empty table if file is missing/corrupt.
function M.load()
    local f = io.open(M.FilePath, "r")
    if not f then return {} end

    local content = f:read("*a")
    f:close()

    if not content or content == "" then return {} end

    -- Safe decode
    local success, result = pcall(json.decode, content)
    if success then
        return result
    else
        os.execute("notify-send 'Elephant State Error' 'Failed to decode state. Resetting.'")
        return {}
    end
end

--- Saves the given table to disk.
function M.save(data_table)
    local f = io.open(M.FilePath, "w")
    if f then
        local str = json.encode(data_table)
        f:write(str)
        f:close()
        return true
    end
    os.execute("notify-send 'Elephant State Error' 'Failed to save state to disk'")
    return false
end

--- Updates specific keys without wiping the rest of the state
function M.update(updates)
    local current = M.load()
    for k, v in pairs(updates) do
        current[k] = v
    end
    M.save(current)
end

--- Clears the state (resets to empty)
function M.clear()
    M.save({})
end

return M
