Name = "goose_recipes"
NamePretty = "Goose Recipes"
Parent = "goose"
Icon = "🧾"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    -- Always use 'goose recipe list --format json' via global constant
    -- This is fast and provides all necessary metadata (path, title, description)
    local handle = io.popen(PrepareShellCommand(GOOSE_CMDS.RECIPE_LIST_JSON))
    if not handle then
        os.execute("notify-send 'Goose Recipes' 'Failed to list recipes'")
        return {{ Text = "Error: Could not list recipes", Icon = "error" }}
    end

    local list_json = handle:read("*a")
    handle:close()

    if not list_json or list_json == "" then
        os.execute("notify-send 'Goose Recipes' 'No recipes found'")
        return {{ Text = "No recipes found", Icon = "warning" }}
    end

    local list_data = jsonDecode(list_json)
    if not list_data or type(list_data) ~= "table" then
        os.execute("notify-send 'Goose Recipes' 'Invalid recipe data'")
        return {{ Text = "Error: Invalid recipe data", Icon = "error" }}
    end

    for _, item in ipairs(list_data) do
        local path = item.path
        local name = item.name
        local desc = item.description

        -- Construct lightweight recipe object
        -- parameters are set to nil and will be lazy-loaded by the child menu
        local recipe = {
            path = path,
            content = {
                title = item.title or name,
                description = desc,
                parameters = nil,
            },
        }

        table.insert(entries, {
            Text = item.title or name,
            Subtext = desc,
            Value = jsonEncode(recipe),
            SubMenu = "goose_recipe_params",
            Preview = path,
            PreviewType = "file",
        })
    end

    return entries
end
