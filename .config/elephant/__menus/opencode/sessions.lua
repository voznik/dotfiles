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
    if not handle then
        os.execute("notify-send 'OpenCode Sessions' 'Failed to list sessions'")
        return {{ Text = "Error: Could not list sessions", Icon = "error" }}
    end

    local lines = {}
    for line in handle:lines() do
        table.insert(lines, line)
    end
    handle:close()

    -- Skip header (line 1) and separator (line 2)
    -- Format: "Session ID  Title  Updated"
    for i = 3, #lines do
        local line = lines[i]
        if line and line ~= "" then
            -- Extract ID (first column, no spaces)
            local id = line:match("^(%S+)")
            if id then
                -- Extract timestamp from end (pattern: HH:MM AM/PM · M/D/YYYY or similar)
                local updated = line:match("(%d+:%d+%s+[AP]M.+)$")

                -- Extract title (everything between ID and timestamp)
                local title_start = #id + 1
                local title_end = updated and line:find(updated, 1, true) or #line
                local title = line:sub(title_start, title_end - 1):trim()

                table.insert(entries, {
                    Text = title or "Untitled Session",
                    Subtext = "ID: " .. id .. (updated and " | " .. updated or ""),
                    Value = id,
                    Actions = { default = "lua:ResumeSession" },
                })
            end
        end
    end

    if #entries == 0 then table.insert(entries, { Text = "No sessions found", Icon = "warning" }) end

    return entries
end

function ResumeSession(id)
    RunInTerminal(string.format(OPENCODE_CMDS.SESSION_RESUME_FMT, id))
end
