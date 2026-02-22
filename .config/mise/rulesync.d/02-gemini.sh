#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=lib.sh
source "${BASH_SOURCE[0]%/*}/lib.sh"
check_deps jq

FILTERS="${BASH_SOURCE[0]%/*}/filters"
GEMINI_JSON="$HOME/.gemini/settings.json"
RULESYNC_MCP="$HOME/.rulesync/mcp.json"
RULESYNC_HOOKS="$HOME/.rulesync/hooks.json"

[[ -f "$GEMINI_JSON" ]] || {
	log "Gemini settings not found, skipping."
	exit 0
}

fix_mcp() {
	[[ -f "$RULESYNC_MCP" ]] || {
		log "No rulesync mcp.json, skipping MCP fix."
		return 0
	}
	apply_jq_inplace "$GEMINI_JSON" -sf "$FILTERS/gemini-mcp.jq" "$RULESYNC_MCP" "$GEMINI_JSON"
}

fix_hooks() {
	[[ -f "$RULESYNC_HOOKS" ]] || {
		log "No rulesync hooks.json, skipping hooks fix."
		return 0
	}
	apply_jq_inplace "$GEMINI_JSON" -sf "$FILTERS/gemini-hooks.jq" "$RULESYNC_HOOKS" "$GEMINI_JSON"
}

fix_mcp && fix_hooks
log "Gemini fixes applied."
