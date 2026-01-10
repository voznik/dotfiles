Name = "goose"
NamePretty = "AI: Goose Manager"
Cache = false
SearchName = true
-- Icon = "🪿"
Icon = os.getenv("HOME") .. "/.config/elephant/menus/goose/icons/goose.ico"

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    -- local icon = GetGooseIconPng()
    return {
        { Text = "Goose: New Session", Subtext = "Start a fresh goose session", Actions = { default = "lua:ActionNew" } },
        { Text = "Goose: Resume Session", Subtext = "List and resume past sessions", SubMenu = "goose_sessions" },
        { Text = "Goose: Projects", Subtext = "Open recent projects (goose ps)", SubMenu = "goose_projects" },
        { Text = "Goose: Recipes", Subtext = "Run available recipes", SubMenu = "goose_recipes" },
        { Text = "Goose: Prompts", Subtext = "Browse and use AI prompts", SubMenu = "goose_prompts" },
        { Text = "Goose: Switch Model", Subtext = "Select from Gemini or local Ollama models", SubMenu = "goose_models" },
        { Text = "Goose: Configure", Subtext = "Full interactive configuration", Actions = { default = "lua:ActionConfig" } }
    }
end

function ActionNew() RunInTerminal(GOOSE_CMDS.SESSION_NEW) end
function ActionConfig() RunInTerminal(GOOSE_CMDS.CONFIGURE) end
