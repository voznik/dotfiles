.[0] as $rulesync | .[1] |
if .mcpServers then
  .mcpServers |= (
    with_entries(select(.value.disabled != true)) |
    with_entries(
      .key as $name |
      .value |= (
        (if ($rulesync.mcpServers[$name] | has("enabledTools"))
          then .includeTools = $rulesync.mcpServers[$name].enabledTools
          else . end) |
        (if has("command") and (has("type") | not) then .type = "stdio" else . end)
      )
    )
  )
else . end
