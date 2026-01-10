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
        os.execute("notify-send 'Goose' 'Something happened'")
        return entries
    end

    local list_json = handle:read("*a")
    handle:close()

    if not list_json or list_json == "" then
        os.execute("notify-send 'Goose' 'Empty Response'")
        return entries
    end

    local list_data = jsonDecode(list_json)
    if not list_data or type(list_data) ~= "table" then
        os.execute("notify-send 'Goose' 'Something happened'")
        return entries
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

    -- if #entries == 0 then return {{ Text = "No recipes found", Subtext = "Checked via goose list", Icon = "warning" }} end

    return entries
end
