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
    -- Format: Session ID                      Title                                               Updated
    --         ───────────────────────────────────────────────────────────────────────────────────────────
    --         ses_46191c476ffeBffsxdwUwTAkg4  New session - 2026-01-08T16:26:22.985Z              5:28 PM · 1/8/2026

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
