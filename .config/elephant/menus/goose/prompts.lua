Name = "goose_prompts"
NamePretty = "Goose Prompts"
Parent = "goose"
Icon = "🆎"
Cache = false
HideFromProviderlist = true
MaxResults = 100
Actions = {
    default = "lua:OpenGooseWithPrompt",
    menus_open = os.execute("notify-send 'Goose!!!'")
}

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local prompts_file = os.getenv("HOME") .. "/.ai/prompts/prompts.json"

    local data = ReadJsonFile(prompts_file)

    if data and type(data) == "table" then
        for _, prompt in ipairs(data) do
            local title = prompt.title
            local description = prompt.description
            local example_prompt = prompt.example_prompt

            -- Ensure we have at least a title
            if title and title ~= "" then
                table.insert(entries, {
                    Text = title,
                    Subtext = description or "",
                    Value = example_prompt or "",
                    Preview = example_prompt or "",
                    PreviewType = "text"
                })
            end
        end
    end

    return entries
end

function OpenGooseWithPrompt(prompt)
    RunInTerminal("goose run --text '" .. prompt:gsub("'", "'\\''") .. "'")
    end
