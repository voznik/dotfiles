Name = "opencode"
NamePretty = "AI: OpenCode Manager"
Cache = false
SearchName = true
-- Icon = "🔧"
Icon = os.getenv("HOME") .. "/.config/elephant/menus/opencode/icons/opencode.ico"

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    if not IsCommandAvailable("opencode") then
        return {
            {
                Text = "OpenCode is not installed",
                Subtext = "Please install opencode to use this menu",
                Icon = "⚠️",
            },
        }
    end

    return {
        { Text = "OpenCode: New Session", Subtext = "Start fresh session", Actions = { default = "lua:ActionNew" } },
        {
            Text = "OpenCode: Continue Last",
            Subtext = "Resume last session",
            Actions = { default = "lua:ActionContinue" },
        },
        { Text = "OpenCode: Resume Session", Subtext = "List and resume past sessions", SubMenu = "opencode_sessions" },
        { Text = "OpenCode: Projects", Subtext = "Open recent projects", SubMenu = "opencode_projects" },
        { Text = "OpenCode: Switch Model", Subtext = "Select from available models", SubMenu = "opencode_models" },
    }
end

function ActionNew()
    RunInTerminal(OPENCODE_CMDS.SESSION_NEW)
end
function ActionContinue()
    RunInTerminal(OPENCODE_CMDS.SESSION_CONTINUE)
end
