#!/usr/bin/env bash
# SessionStart hook: enable/disable github-mcp-server based on git context
# Reads CWD from stdin JSON, checks for git repo with GitHub remotes
# Uses "disabled" field (rulesync convention) instead of "enabled"

set -euo pipefail

CONFIG="$HOME/.claude.json"

# Read hook input to get cwd
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ -z "$CWD" ] && CWD="$(pwd)"

# Determine if GitHub MCP should be enabled
SHOULD_DISABLE=true
if git -C "$CWD" rev-parse --is-inside-work-tree &>/dev/null; then
	if git -C "$CWD" remote -v 2>/dev/null | grep -qi 'github'; then
		SHOULD_DISABLE=false
	fi
fi

# Read current state (disabled defaults to true if missing)
CURRENT=$(jq -r '.mcpServers["github-mcp-server"].disabled // true' "$CONFIG")

# Only write if state changed
if [ "$SHOULD_DISABLE" = "false" ] && [ "$CURRENT" != "false" ]; then
	jq '.mcpServers["github-mcp-server"].disabled = false' "$CONFIG" >"$CONFIG.tmp" &&
		mv "$CONFIG.tmp" "$CONFIG"
	echo "GitHub MCP server enabled (GitHub remote detected)"
elif [ "$SHOULD_DISABLE" = "true" ] && [ "$CURRENT" != "true" ]; then
	jq '.mcpServers["github-mcp-server"].disabled = true' "$CONFIG" >"$CONFIG.tmp" &&
		mv "$CONFIG.tmp" "$CONFIG"
	echo "GitHub MCP server disabled (no GitHub remote)"
fi
