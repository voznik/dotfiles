Name = "goose_recipes"
NamePretty = "Goose Recipes"
Parent = "goose"
Icon = "🧾"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local recipe_path_env = os.getenv("GOOSE_RECIPE_PATH") or os.getenv("HOME") .. "/.ai/recipes"
    local elephant_path = os.getenv("HOME") .. "/.config/elephant"

    if recipe_path_env and recipe_path_env ~= "" then
        local home_path = os.getenv("HOME")
        if home_path then
            recipe_path_env = recipe_path_env:gsub("$HOME", home_path, 1)
        end
    end

    if recipe_path_env and recipe_path_env ~= "" then
        local find_cmd = "find " .. recipe_path_env .. " " .. elephant_path .. " -name '*.yaml'"
        local p = ReadShellCommand(find_cmd)

        if p then
            for path in p:lines() do
                local rel_path = path:gsub(recipe_path_env .. "/", "", 1)
                local name = string.sub(rel_path, 1, -6)

                local entry = {
                    Text = name,
                    Subtext = path,
                    Value = path,
                    Preview = path,
                    PreviewType = "file",
                    Actions = { default = "lua:RunRecipe" }
                }
                table.insert(entries, entry)
            end
            p:close()
        end
    end

    return entries
end

function EditRecipe(path)
    local editor = os.getenv("EDITOR")
    if not editor or editor == "" then
        editor = "xdg-open"
    end
    RunInTerminal(editor .. " '" .. path .. "'")
end

function GetRecipeName(path)
    return path:match("([^/]+)%.yaml$")
end

function RunRecipe(path)
    -- Update global state with the selected recipe
    STATE.update({
        current_recipe = path,
        recipe_params = {}
    })

    OpenWalkerMenu("goose_recipe_params")
end
