-- Shared formatter module for mise and micro
local M = {}

-- Special formatters for languages not covered by oxfmt
M.special = {
    go = 'gofmt -w',
    rs = 'rustfmt -v -l --backup --edition=2021',
    py = 'ruff format',
    lua = 'stylua',
    sh = 'shfmt -w',
    fish = 'fish_indent -w',
}

-- Metatable to provide oxfmt as default for everything not in special
M.formatters = setmetatable({}, {
    __index = function(_, ext)
        if M.special[ext] then return M.special[ext] end
        -- Default to oxfmt; it handles its own detection and ignores
        return 'oxfmt --write --no-error-on-unmatched-pattern'
    end,
})

-- Helper to check command exit status
local function success(result)
    return result == true or result == 0
end

-- Format a file
function M.format(filepath)
    local ext = filepath:match '%.([^%.]+)$' or ''

    -- Check if file is writable to avoid tool panics (e.g. oxfmt)
    if not success(os.execute("test -w '" .. filepath .. "'")) then return true, 'Skipped: Read-only' end

    local cmd = M.formatters[ext]
    return success(os.execute(cmd .. ' ' .. filepath))
end

return M
