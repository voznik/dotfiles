Name = "gemini_models"
NamePretty = "Gemini Models"
Parent = "gemini"
Icon = "cpu"
Cache = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

local MODELS = {
    "gemini-2.5-pro",
    "gemini-2.5-flash",
    "gemini-2.5-flash-lite",
    "gemini-3-pro-preview",
    "gemini-3-flash-preview",
}

local function UpdateGeminiConfig(model)
    local config_file = os.getenv("HOME") .. "/.gemini/settings.json"
    local content = ReadFile(config_file)
    if not content then return false end

    local config = jsonDecode(content)
    if not config then return false end

    if not config.general then config.general = {} end
    config.general.model = model

    local json_str = jsonEncode(config)
    local f = io.open(config_file, "w")
    if not f then return false end
    f:write(json_str)
    f:close()

    return true
end

function GetEntries()
    local entries = {}

    for _, model in ipairs(MODELS) do
        table.insert(entries, {
            Text = model,
            Subtext = "Gemini CLI model",
            Value = model,
            Actions = { default = "lua:SetModel" },
        })
    end

    return entries
end

function SetModel(model)
    if UpdateGeminiConfig(model) then
        os.execute("notify-send 'Gemini CLI' 'Switched to model: " .. model .. "'")
    else
        os.execute("notify-send 'Gemini CLI' 'Failed to update config'")
    end
end
