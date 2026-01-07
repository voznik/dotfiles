Name = "goose_recipe_params"
NamePretty = "Recipe Parameters"
Parent = "goose_recipes"
Icon = "⚙"
HideFromProviderlist = true
Cache = false

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local state = STATE.load()
    local recipe_path = state.current_recipe

    if not recipe_path then
        return entries
    end

    local saved_params = state.recipe_params or {}
    local recipe_params = ParseYamlByKey(recipe_path, "parameters")

    for _, param in ipairs(recipe_params) do
        local current_value = saved_params[param.key] or ""
        local req_indicator = param.requirement == "required" and "*" or ""
        local value_display = current_value ~= "" and current_value or "(empty)"

        local entry = {
            Text = "- " .. param.key .. req_indicator,
            Subtext = (param.description or "") .. " | " .. value_display,
            Value = param.key,
            Actions = { default = "lua:EditParam" }
        }
        table.insert(entries, entry)
    end

    table.insert(entries, {
        Text = "> Run Recipe",
        Subtext = "Execute with current parameters",
        Actions = { default = "lua:ExecuteRecipe" }
    })

    table.insert(entries, {
        Text = "> Clear All",
        Subtext = "Reset all parameter values",
        Actions = { default = "lua:ClearParams" }
    })

    return entries
end

function EditParam(param_key)
    local state = STATE.load()
    local recipe_path = state.current_recipe
    local saved_params = state.recipe_params or {}
    local current_value = saved_params[param_key] or ""

    local recipe_params = ParseYamlByKey(recipe_path, "parameters")
    local param_desc = nil
    for _, param in ipairs(recipe_params) do
        if param.key == param_key then
            param_desc = param.description
            break
        end
    end

    local placeholder = param_key
    if param_desc and param_desc ~= "" then
        placeholder = placeholder .. " [" .. param_desc .. "]"
    end
    if current_value ~= "" then
        placeholder = placeholder .. " | Current: " .. current_value
    end

    local cmd = "walker --dmenu --inputonly --maxheight 2 --placeholder '" .. placeholder .. "'"
    local p = io.popen(cmd .. " 2>&1")
    if p then
        local output = p:read("*a")
        p:close()

        local new_value = output and output:gsub("%s+", "") or ""

        if new_value ~= "" then
            saved_params[param_key] = new_value
            STATE.update({ recipe_params = saved_params })
        end
    end

    OpenWalkerMenu("goose_recipe_params")
end

function ExecuteRecipe()
    local state = STATE.load()
    local recipe_path = state.current_recipe
    local params = state.recipe_params or {}

    local recipe_params = ParseYamlByKey(recipe_path, "parameters")
    for _, param in ipairs(recipe_params) do
        if param.requirement == "required" and (not params[param.key] or params[param.key] == "") then
            os.execute("notify-send 'Error' 'Required parameter " .. param.key .. " is not set'")
            return
        end
    end

    local cmd_args = {"run", "--no-session", "--recipe", recipe_path}
    for key, value in pairs(params) do
        if value and value ~= "" then
            table.insert(cmd_args, "--params")
            table.insert(cmd_args, key .. "=" .. value)
        end
    end

    RunInTerminal("goose " .. table.concat(cmd_args, " "))

    STATE.clear()
    OpenWalkerMenu("goose_recipes")
end

function ClearParams()
    STATE.update({ recipe_params = {} })
    OpenWalkerMenu("goose_recipe_params")
end
