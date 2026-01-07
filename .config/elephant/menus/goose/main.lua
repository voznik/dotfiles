Name = "goose"
NamePretty = "Goose Manager"
Icon = "terminal"
Cache = false
SearchName = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    return {
        { Text = "New Session", Subtext = "Start a fresh goose session", Actions = { default = "lua:ActionNew" } },
        { Text = "Resume Session", Subtext = "List and resume past sessions", Actions = { default = "lua:OpenGooseSessions" } },
        { Text = "Projects", Subtext = "Open recent projects (goose ps)", Actions = { default = "lua:OpenGooseProjects" } },
        { Text = "Recipes", Subtext = "Run available recipes", Actions = { default = "lua:OpenGooseRecipes" } },
        { Text = "Prompts", Subtext = "Browse and use AI prompts", Actions = { default = "lua:OpenGoosePrompts" } },
        { Text = "Switch Model", Subtext = "Select from Gemini or local Ollama models", Actions = { default = "lua:OpenGooseModels" } },
        { Text = "Configure", Subtext = "Full interactive configuration", Actions = { default = "lua:ActionConfig" } }
    }
end

function ActionNew() RunInTerminal("goose session") end
function ActionConfig() RunInTerminal("goose configure") end
function OpenGooseSessions() OpenWalkerMenu("goose_sessions") end
function OpenGooseModels() OpenWalkerMenu("goose_models") end
function OpenGooseProjects() OpenWalkerMenu("goose_projects") end
function OpenGooseRecipes() OpenWalkerMenu("goose_recipes") end
function OpenGoosePrompts() OpenWalkerMenu("goose_prompts") end
