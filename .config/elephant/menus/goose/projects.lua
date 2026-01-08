Name = "goose_projects"
NamePretty = "Goose Projects"
Parent = "goose"
Icon = "folder"
Cache = false
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local projects_path = os.getenv("HOME") .. "/.local/share/goose/projects.json"

    local content = ReadFile(projects_path)
    if not content then return entries end
    local data = jsonDecode(content)

    if data and data.projects then
        local projects_list = {}

        -- Iterate over projects table
        for _, project in pairs(data.projects) do
            if project.path then
                table.insert(projects_list, {
                    path = project.path,
                    timestamp = project.last_accessed or "0"
                })
            end
        end

        -- Sort by last_accessed descending
        table.sort(projects_list, function(a, b)
            return a.timestamp > b.timestamp
        end)

        for _, project in ipairs(projects_list) do
            local date_cmd = "date -d '" .. project.timestamp .. "' +'%Y-%m-%d %H:%M'"
            local date_p = io.popen(date_cmd)
            local human_date = ""
            if date_p then
                human_date = date_p:read("*a"):gsub("\n", "")
                date_p:close()
            end

            table.insert(entries, {
                Text = project.path,
                Subtext = "Last accessed: " .. human_date,
                Value = project.path,
                Actions = { default = "lua:OpenProject" }
            })
        end
    end

    return entries
end

function OpenProject(path) RunInTerminal("cd '" .. path .. "' && " .. GOOSE_CMDS.SESSION_NEW) end
