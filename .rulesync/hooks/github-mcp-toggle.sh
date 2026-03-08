#!/usr/bin/env bash
# SessionStart hook: enable/disable github-mcp-server based on git context
# Reads CWD from stdin JSON (if available), checks for git repo with GitHub remotes
# Works for both Claude Code and Gemini CLI

set -euo pipefail

# Detect which agent is running and set the config file accordingly
if [ -n "${GEMINI_CLI:-}" ]; then
	CONFIG="$HOME/.gemini/settings.json"
elif [ -n "${CLAUDE_ENV_FILE:-}" ]; then
	CONFIG="$HOME/.claude.json"
else
	# Fallback: try to detect by checking which config exists in context
	CONFIG="$HOME/.claude.json"
fi

# Read hook input to get cwd — non-blocking with 1-second timeout
CWD=""
if [ -t 0 ]; then
	# stdin is a terminal (not piped), skip reading
	:
else
	INPUT=""
	if IFS= read -r -t 1 LINE 2>/dev/null; then
		INPUT="$LINE"
		# Drain any remaining lines (shouldn't be many)
		while IFS= read -r -t 0.1 MORE 2>/dev/null; do
			INPUT="$INPUT$MORE"
		done
	fi
	if [ -n "$INPUT" ]; then
		CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
	fi
fi
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
