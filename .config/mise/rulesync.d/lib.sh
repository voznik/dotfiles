#!/usr/bin/env bash
# Shared functions for rulesync post-processing scripts.
# Source this file; do not execute directly.

log() {
	echo "[rulesync] $*"
}

check_deps() {
	local missing=()
	for cmd in "$@"; do
		if ! command -v "$cmd" &>/dev/null; then
			missing+=("$cmd")
		fi
	done
	if ((${#missing[@]} > 0)); then
		log "ERROR: Missing required tools: ${missing[*]}"
		return 1
	fi
}

# backup_file <file>
# Creates a timestamped backup and prunes to keep only the 5 most recent.
backup_file() {
	local file="$1"
	local ts
	ts=$(date +%Y-%m-%d-%H%M%S)
	cp "$file" "${file}.${ts}.bak"
	# Prune: keep only the 5 most recent backups
	local baks=()
	mapfile -t baks < <(ls -t "${file}".*.bak 2>/dev/null)
	if ((${#baks[@]} > 5)); then
		rm -- "${baks[@]:5}"
	fi
}

# apply_jq_inplace <target-file> <jq-args...>
# Runs jq with the given args, validates the output is valid JSON,
# backs up the target file, then overwrites it.
# Example: apply_jq_inplace ~/.claude.json -sf "$FILTERS/gemini-mcp.jq" "$RULESYNC_MCP" ~/.claude.json
apply_jq_inplace() {
	local target="$1"
	shift
	local tmp
	tmp=$(mktemp)
	if jq "$@" >"$tmp" && jq . "$tmp" >/dev/null 2>&1; then
		backup_file "$target"
		mv "$tmp" "$target"
	else
		rm -f "$tmp"
		log "ERROR: jq failed or produced invalid JSON for $target"
		return 1
	fi
}
