Name = "tokscale_today"
NamePretty = "TokScale: Today Usage"
Cache = false

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local handle = io.popen(PrepareShellCommand(TOKSCALE_CMDS.TODAY_JSON))
    if not handle then
        return {
            {
                Text = "Error: Could not execute tokscale command",
                Subtext = "Please check if tokscale is installed and working",
                Icon = "⚠️",
            },
        }
    end

    local json_output = handle:read("*a")
    handle:close()

    if not json_output or json_output == "" then
        return {
            {
                Text = "No token usage data available",
                Subtext = "tokscale returned empty output",
                Icon = "ℹ️",
            },
        }
    end

    local data = jsonDecode(json_output)
    if not data or not data.entries then
        return {
            {
                Text = "Error: Could not parse token usage data",
                Subtext = "tokscale output format may have changed",
                Icon = "⚠️",
            },
        }
    end

    local entries = {}
    for _, entry in ipairs(data.entries) do
        local input_str = string.format("%s", entry.input)
        local output_str = string.format("%s", entry.output)
        local cost_str = string.format("$%.2f", entry.cost or 0)
        local messages_str = string.format("%d msgs", entry.messageCount or 0)
        local subtext = string.format("%s in | %s out | %s | %s", input_str, output_str, cost_str, messages_str)

        table.insert(entries, {
            Text = entry.source .. "/" .. entry.model,
            Subtext = subtext,
            Value = jsonEncode(entry),
        })
    end

    local total = {
        Text = string.format(
            "Total: %d messages, %s tokens, $%.2f",
            data.totalMessages or 0,
            (data.totalInput or 0) + (data.totalOutput or 0),
            data.totalCost or 0
        ),
        Subtext = "Today's aggregate usage",
    }
    table.insert(entries, total)

    return entries
end
