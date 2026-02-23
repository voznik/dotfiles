Name = "opencode_projects"
NamePretty = "OpenCode Projects"
Parent = "opencode"
Icon = "folder"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local projects_dir = os.getenv("HOME") .. "/.local/share/opencode/storage/project"

    -- Get all JSON files in the directory (excluding global.json)
    local handle = io.popen("ls " .. projects_dir .. "/*.json 2>/dev/null | grep -v global.json")
    if not handle then return entries end

    local projects = {}
    for file in handle:lines() do
        local content = ReadFile(file)
        if content then
            local project = jsonDecode(content)
            if project and project.worktree then
                -- Extract timestamp from time.created (milliseconds)
                local timestamp = 0
                if project.time and project.time.created then timestamp = project.time.created end

                table.insert(projects, {
                    path = project.worktree,
                    timestamp = timestamp,
                    vcs = project.vcs or "unknown",
                })
            end
        end
    end
    handle:close()

    -- Sort by timestamp descending (most recent first)
    table.sort(projects, function(a, b)
        return a.timestamp > b.timestamp
    end)

    -- Create entries
    for _, project in ipairs(projects) do
        -- Format timestamp if available
        local display_time = ""
        if project.timestamp > 0 then
            -- Convert milliseconds to seconds for date command
            local seconds = math.floor(project.timestamp / 1000)
            local date_cmd =
                string.format("date -d '@%d' +'%%Y-%%m-%%d %%H:%%M' 2>/dev/null || echo 'Recently'", seconds)
            local date_p = io.popen(date_cmd)
            if date_p then
                display_time = date_p:read("*a"):gsub("\n", "")
                date_p:close()
            end
        else
            display_time = "Unknown"
        end

        table.insert(entries, {
            Text = project.path,
            Subtext = "Last accessed: " .. display_time .. " | VCS: " .. project.vcs,
            Value = project.path,
            Actions = { default = "lua:OpenProject" },
        })
    end

    if #entries == 0 then table.insert(entries, { Text = "No recent projects", Icon = "warning" }) end

    return entries
end

function OpenProject(path)
    RunInTerminal("cd '" .. path .. "' && " .. OPENCODE_CMDS.SESSION_NEW)
end
