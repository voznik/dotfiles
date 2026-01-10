Name = "gemini"
NamePretty = "AI: Gemini CLI"
Cache = false
SearchName = true
-- Icon = "🔷"
Icon = os.getenv("HOME") .. "/.config/elephant/menus/gemini/icons/gemini.ico"

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    return {
        { Text = "Gemini: New Session", Subtext = "Start fresh session", Actions = { default = "lua:ActionNew" } },
        { Text = "Gemini: Resume Session", Subtext = "List and resume sessions", SubMenu = "gemini_sessions" },
        { Text = "Gemini: Switch Model", Subtext = "Select from available Gemini models", SubMenu = "gemini_models" },
    }
end

function ActionNew()
    RunInTerminal(GEMINI_CMDS.SESSION_NEW)
end
