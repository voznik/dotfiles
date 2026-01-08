Name = "goose_prompts"
NamePretty = "Goose Prompts"
Parent = "goose"
Icon = "🆎"
Cache = false
HideFromProviderlist = true
MaxResults = 100

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}

    local prompts_file = os.getenv("HOME") .. "/.ai/prompts/prompts.json"
    local content = ReadFile(prompts_file)
    if not content then return entries end
    local data = jsonDecode(content) -- Use built-in elephant function

    if data and type(data) == "table" then
        for _, prompt in ipairs(data) do
            local title = prompt.title
            local description = prompt.description
            local example_prompt = prompt.example_prompt

            if title and title ~= "" then
                table.insert(entries, {
                    Text = title,
                    Subtext = description or "",
                    Value = example_prompt or "",
                    Preview = example_prompt or "",
                    PreviewType = "text",
                    Actions = {
                        default = "lua:OpenGooseWithPrompt",
                        prompt_copy = "wl-copy '%VALUE%'"
                    }
                })
            end
        end
    end

    return entries
end

function OpenGooseWithPrompt(prompt)
    -- Escape single quotes in the prompt to prevent shell injection/errors
    local safe_prompt = prompt:gsub("'", "'\\''")
    RunInTerminal(string.format(GOOSE_CMDS.PROMPT_RUN_FMT, safe_prompt))
end
