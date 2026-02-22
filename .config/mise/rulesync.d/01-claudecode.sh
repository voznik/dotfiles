#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=lib.sh
source "${BASH_SOURCE[0]%/*}/lib.sh"
check_deps jq

CLAUDE_JSON="$HOME/.claude.json"
RULESYNC_MCP="$HOME/.rulesync/mcp.json"

[[ -f "$RULESYNC_MCP" ]] || {
	log "No rulesync mcp.json, skipping."
	exit 0
}
[[ -f "$CLAUDE_JSON" ]] || {
	log "No ~/.claude.json, skipping."
	exit 0
}

apply_jq_inplace "$CLAUDE_JSON" -s '
  .[0] as $rulesync |
  .[1] |
  if .mcpServers then
    .mcpServers |= with_entries(
      .key as $name |
      if ($rulesync.mcpServers[$name] | has("enabledTools")) then
        .value.enabledTools = $rulesync.mcpServers[$name].enabledTools
      else . end
    )
  else . end
' "$RULESYNC_MCP" "$CLAUDE_JSON"

log "Claude Code fixes applied."
