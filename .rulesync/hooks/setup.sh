#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ] || [ -n "$GEMINI_CLI" ]; then
	export SHELL=bash
	# Load mise environment
	eval "$(mise env -s bash)" 2>/dev/null

	# Source bash aliases (functions will be available)
	[ -f ~/.bash_aliases ] && source ~/.bash_aliases

	# Export all variables
	export -p >>"$CLAUDE_ENV_FILE"

	# Export all functions
	declare -f >>"$CLAUDE_ENV_FILE"
fi

exit 0
