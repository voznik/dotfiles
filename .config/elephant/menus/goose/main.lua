Name = "goose"
NamePretty = "Goose Manager"
Cache = false
SearchName = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

-- Dynamic Icon based on system theme
Icon = GetGooseIcon()

function GetEntries()
    local icon = GetGooseIcon()
    return {
        { Text = "Goose: New Session", Subtext = "Start a fresh goose session", Icon = icon, Actions = { default = "lua:ActionNew" } },
        { Text = "Goose: Resume Session", Subtext = "List and resume past sessions", Icon = icon, SubMenu = "goose_sessions" },
        { Text = "Goose: Projects", Subtext = "Open recent projects (goose ps)", Icon = icon, SubMenu = "goose_projects" },
        { Text = "Goose: Recipes", Subtext = "Run available recipes", Icon = icon, SubMenu = "goose_recipes" },
        { Text = "Goose: Prompts", Subtext = "Browse and use AI prompts", Icon = icon, SubMenu = "goose_prompts" },
        { Text = "Goose: Switch Model", Subtext = "Select from Gemini or local Ollama models", Icon = icon, SubMenu = "goose_models" },
        { Text = "Goose: Configure", Subtext = "Full interactive configuration", Icon = icon, Actions = { default = "lua:ActionConfig" } }
    }
end

function ActionNew() RunInTerminal(GOOSE_CMDS.SESSION_NEW) end
function ActionConfig() RunInTerminal(GOOSE_CMDS.CONFIGURE) end
