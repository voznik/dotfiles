Name = "goose_sessions"
NamePretty = "Goose Sessions"
Parent = "goose"
Icon = "history"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local handle = io.popen(PrepareShellCommand(GOOSE_CMDS.SESSION_LIST))
    if not handle then return entries end

    -- Parse `goose session list` output
    -- Format: ID - Topic - Date
    -- Example: 20260107_5 - Cross-Project Activity Summary - 2026-01-07 22:23:42 UTC

    for line in handle:lines() do
        -- Skip header
        if not line:match("^Available sessions:") then
            -- Format: ID - Topic - Date
            -- Using greedy match (.+) for Topic captures everything between the first and last separator
            local id, topic, date = line:match("^(%S+)%s%-%s(.+)%s%-%s(.+)$")

            if id then
                table.insert(entries, {
                    Text = topic,
                    Subtext = "ID: " .. id .. " | " .. date,
                    Value = id,
                    Actions = { default = "lua:ResumeSession" }
                })
            end
        end
    end
    handle:close()

    if #entries == 0 then
        table.insert(entries, { Text = "No active sessions found", Icon = "warning" })
    end

    return entries
end

function ResumeSession(id)
    RunInTerminal(string.format(GOOSE_CMDS.SESSION_RESUME_FMT, id))
end
