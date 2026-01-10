Name = "gemini_sessions"
NamePretty = "Gemini Sessions"
Parent = "gemini"
Icon = "history"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local handle = io.popen(PrepareShellCommand(GEMINI_CMDS.SESSION_LIST))
    if not handle then return entries end

    local lines = {}
    for line in handle:lines() do
        table.insert(lines, line)
    end
    handle:close()

    -- Skip first line (header: "Available sessions for this project (N):")
    -- Parse format: "  1. Title (time ago) [uuid]"
    for i = 2, #lines do
        local line = lines[i]
        if line and line ~= "" then
            -- Extract number, title, time, and uuid
            -- Pattern: "  N. Title (time ago) [uuid]"
            local num, title_and_rest = line:match("^%s*(%d+)%.%s+(.+)$")
            if num and title_and_rest then
                -- Extract uuid from end [uuid]
                local uuid = title_and_rest:match("%[([^%]]+)%]$")
                if uuid then
                    -- Remove uuid part to get title + time
                    local title_time = title_and_rest:gsub("%s*%[" .. uuid .. "%]$", "")
                    -- Extract time (in parentheses at end)
                    local time_ago = title_time:match("%(([^%)]+)%)$")
                    local title = title_time
                    if time_ago then
                        -- Remove time part from title
                        title = title_time:gsub("%s*%(" .. time_ago .. "%)$", "")
                    end

                    table.insert(entries, {
                        Text = title,
                        Subtext = (time_ago or "Unknown time") .. " | Index: " .. num,
                        Value = num, -- Resume uses index number, not uuid
                        Actions = { default = "lua:ResumeSession" },
                    })
                end
            end
        end
    end

    if #entries == 0 then table.insert(entries, { Text = "No sessions found in this project", Icon = "warning" }) end

    return entries
end

function ResumeSession(index)
    RunInTerminal(string.format(GEMINI_CMDS.SESSION_RESUME_FMT, index))
end
