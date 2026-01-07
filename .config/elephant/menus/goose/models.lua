Name = "goose_models"
NamePretty = "Goose Models"
Parent = "goose"
Icon = "cpu"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

local function get_models_from_provider(provider_name)
    local models_file = os.getenv("HOME") .. "/.ai/goose_known_models.txt"
    local content = read_file(models_file)

    if not content then
        -- Fallback defaults if file missing
        if provider_name == "gemini-cli" then
            return {
                "gemini-2.5-pro",
                "gemini-2.5-flash",
                "gemini-2.5-flash-lite",
                "gemini-3-pro-preview",
                "gemini-3-flash-preview"
            }
        end
        return {}
    end

    for line in content:gmatch("[^\r\n]+") do
        local provider, models_str = line:match("^(.-)|(.+)$")
        if provider == provider_name then
            local models = {}
            for model in models_str:gmatch("([^,]+)") do
                table.insert(models, model:trim())
            end
            return models
        end
    end

    return {}
end

local function get_ollama_models()
    local models = {}
    local p = io.popen("ollama list")
    if p then
        for line in p:lines() do
            local name = line:match("^(%S+)")
            if name and name ~= "NAME" then
                table.insert(models, name)
            end
        end
        p:close()
    end
    return models
end

function GetEntries()
    local entries = {}

    for _, model in ipairs(get_models_from_provider("gemini-cli")) do
        table.insert(entries, {
            Text = "Gemini: " .. model,
            Subtext = "Provider: gemini-cli | Model: " .. model,
            Value = "gemini-cli:" .. model,
            Actions = { default = "lua:SetModel" }
        })
    end

    for _, model in ipairs(get_ollama_models()) do
        table.insert(entries, {
            Text = "Ollama: " .. model,
            Subtext = "Provider: ollama | Model: " .. model,
            Value = "ollama:" .. model,
            Actions = { default = "lua:SetModel" }
        })
    end

    for _, model in ipairs(get_models_from_provider("anthropic")) do
        table.insert(entries, {
            Text = "Claude: " .. model,
            Subtext = "Provider: anthropic | Model: " .. model,
            Value = "claude:" .. model,
            Actions = { default = "lua:SetModel" }
        })
    end

    return entries
end

function SetModel(value)
    local provider, model = value:match("([^:]+):(.+)")
    if provider and model then
        UpdateGooseConfig(provider, model)
        local provider_display = provider:gsub("^%l", string.upper)
        os.execute("notify-send 'Goose' 'Switched to " .. provider_display .. ": " .. model .. "'")

        -- Optionally return to main menu or stay
        -- OpenWalkerMenu("goose")
    end
end

function UpdateGooseConfig(provider, model)
    -- Using sed for simple YAML update (preserving indentation if any)
    local sed_cmd = string.format("sed -i 's/^GOOSE_PROVIDER:.*/GOOSE_PROVIDER: %s/' %s", provider, CONFIG_FILE)
    os.execute(sed_cmd)
    sed_cmd = string.format("sed -i 's/^GOOSE_MODEL:.*/GOOSE_MODEL: %s/' %s", model, CONFIG_FILE)
    os.execute(sed_cmd)
end
