Name = "opencode_models"
NamePretty = "OpenCode Models"
Parent = "opencode"
Icon = "cpu"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local handle = io.popen(PrepareShellCommand(OPENCODE_CMDS.MODELS_LIST))
    if not handle then return entries end

    for line in handle:lines() do
        local model = line:trim()
        if model ~= "" then
            -- Extract provider from "provider/model" format
            local provider, model_name = model:match("^([^/]+)/(.+)$")
            if provider and model_name then
                table.insert(entries, {
                    Text = model,
                    Subtext = "Provider: " .. provider .. " | Model: " .. model_name,
                    Value = model,
                    Actions = { default = "lua:SetModel" }
                })
            else
                -- Fallback for models without "/"
                table.insert(entries, {
                    Text = model,
                    Subtext = "Model: " .. model,
                    Value = model,
                    Actions = { default = "lua:SetModel" }
                })
            end
        end
    end
    handle:close()

    if #entries == 0 then
        table.insert(entries, { Text = "No models available", Icon = "warning" })
    end

    return entries
end

function SetModel(model)
    -- OpenCode doesn't persist model selection in config
    -- User needs to use: opencode -m provider/model
    local msg = string.format(
        "Model selected: %s\\n\\nTo use this model, run:\\nopencode -m %s",
        model, model
    )
    os.execute(string.format("notify-send 'OpenCode Model' '%s'", msg))
end
