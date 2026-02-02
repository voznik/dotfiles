Name = "tokscale"
NamePretty = "TokScale: Token Usage"
Cache = true
SearchName = true
Icon = "📊"

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    if not IsCommandAvailable("tokscale") then
        return {
            {
                Text = "TokScale is not installed",
                Subtext = "Please install tokscale to use this menu",
                Icon = "⚠️",
            },
        }
    end

    return {
        { Text = "TokScale: Today Usage", Subtext = "View today's token usage by model", SubMenu = "tokscale_today" },
    }
end
