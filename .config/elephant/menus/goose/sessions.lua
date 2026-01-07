Name = "goose_sessions"
NamePretty = "Goose Sessions"
Parent = "goose"
Icon = "history"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local sessions = ReadShellCommand("goose session list")

    if sessions then
        for line in sessions:lines() do
            local id, desc, date = line:match("^(%S+)%s%-%s(.-)%s%-%s(.*)$")
            if id then
                table.insert(entries,
                    {
                        Text = desc,
                        Subtext = id .. " [" .. date .. "]",
                        Value = id,
                        Actions = { default = "lua:ActionResume" }
                    })
            end
        end
        sessions:close()
    end
    return entries
end

function ActionResume(id)
    RunInTerminal("goose session --resume --session-id " .. id)
end
