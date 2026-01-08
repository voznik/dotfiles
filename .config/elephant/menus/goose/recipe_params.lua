Name = "goose_recipe_params"
NamePretty = "Recipe Parameters"
Parent = "goose_recipes"
Icon = "⚙"
HideFromProviderlist = true
Cache = false

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

-- ####### HELPER FUNCTIONS FOR PARAMETER STATE #######
local function loadParams()
    local params = {}
    local state_list = state() -- reads state for 'goose_recipe_params'
    for _, line in ipairs(state_list) do
        if line:find("param:", 1, true) == 1 then
            local param_line = line:sub(7)
            local sep_pos = param_line:find("=")
            if sep_pos then
                params[param_line:sub(1, sep_pos - 1)] = param_line:sub(sep_pos + 1)
            end
        end
    end
    return params
end

local function saveParams(params_table)
    local new_state_list = {}
    for key, value in pairs(params_table) do
        table.insert(new_state_list, "param:" .. key .. "=" .. value)
    end
    setState(new_state_list) -- saves state for 'goose_recipe_params'
end

local function getRecipeFromParent()
    local recipe_json = lastMenuValue("goose_recipes")
    if not recipe_json or recipe_json == "" then return nil end

    local recipe = jsonDecode(recipe_json)
    if not recipe then return nil end

    -- Lazy Load Parameters if missing
    if not recipe.content.parameters and recipe.path then
        recipe.content.parameters = ParseYamlParameters(recipe.path)
    end

    return recipe
end
-- ###################################################

function GetEntries()
    local entries = {}
    local recipe = getRecipeFromParent()

    if not recipe then
        return {{ Text = "Error: No recipe provided from parent menu." , Icon = "error" }}
    end

    local saved_params = loadParams()
    local recipe_data = recipe.content

    if not recipe_data or not recipe_data.parameters then
        return {{ Text = "Error: Could not load recipe parameters." , Icon = "error" }}
    end

    for _, param in ipairs(recipe_data.parameters) do
        local current_value = saved_params[param.key] or ""
        local req_indicator = param.requirement == "required" and "*" or ""
        local value_display = current_value ~= "" and current_value or "(empty)"
        table.insert(entries, {
            Text = "- " .. param.key .. req_indicator,
            Subtext = (param.description or "") .. " | " .. value_display,
            Value = param.key,
            Actions = { default = "lua:EditParam" }
        })
    end

    table.insert(entries, { Text = "> Run Recipe", Subtext = "Execute with current parameters", Icon = "terminal", Actions = { default = "lua:ExecuteRecipe" }})
    -- table.insert(entries, { Text = "> Clear All", Subtext = "Reset all parameter values", Icon = "❎", Actions = { default = "lua:ClearParams" }})
    return entries
end

function EditParam(param_key)
    local recipe = getRecipeFromParent()
    local saved_params = loadParams()
    local current_value = saved_params[param_key] or ""

    local param_desc
    if recipe and recipe.content and recipe.content.parameters then
        for _, param in ipairs(recipe.content.parameters) do
            if param.key == param_key then
                param_desc = param.description
                break
            end
        end
    end

    local placeholder = param_key
    if param_desc and param_desc ~= "" then placeholder = placeholder .. " [" .. param_desc .. "]" end
    if current_value ~= "" then placeholder = placeholder .. " | Current: " .. current_value end

    local cmd = string.format(WALKER_CMDS.DMENU_INPUT_FMT, placeholder)
    cmd = PrepareShellCommand(cmd)
    local p = io.popen(cmd .. " 2>&1")
    if p then
        local output = p:read("*a"); p:close()
        local new_value = output and output:gsub("%s+", "") or ""
        if new_value ~= "" then
            saved_params[param_key] = new_value
            saveParams(saved_params)
        end
    end
    OpenWalkerMenu("goose_recipe_params")
end

function ExecuteRecipe()
    local recipe = getRecipeFromParent()
    local params = loadParams()

    if not recipe then
        os.execute("notify-send 'Goose' 'Recipe not found'")
        return
    end

    local recipe_data = recipe.content
    if recipe_data and recipe_data.parameters then
        for _, param in ipairs(recipe_data.parameters) do
            if param.requirement == "required" and (not params[param.key] or params[param.key] == "") then
                os.execute("notify-send 'Goose' 'Required parameter " .. param.key .. " is not set'")
                return
            end
        end
    end

    local cmd_base = string.format(GOOSE_CMDS.RECIPE_RUN_FMT, recipe.path)
    local cmd_params = {}

    for key, value in pairs(params) do
        if value and value ~= "" then
            table.insert(cmd_params, "--params")
            table.insert(cmd_params, key .. "=" .. value)
        end
    end

    local full_cmd = cmd_base
    if #cmd_params > 0 then
        full_cmd = full_cmd .. " " .. table.concat(cmd_params, " ")
    end

    RunInTerminal(full_cmd)
    setState({}) -- Clear param state after execution
    OpenWalkerMenu("goose_recipes")
end

function ClearParams()
    saveParams({}) -- Clears the parameter list
    OpenWalkerMenu("goose_recipe_params")
end
