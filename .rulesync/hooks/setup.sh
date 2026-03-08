#!/bin/bash

export SHELL=bash
eval "$(mise env -s bash)" 2>/dev/null
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

if [ -n "$CLAUDE_ENV_FILE" ]; then
	export -p >>"$CLAUDE_ENV_FILE"
	declare -f >>"$CLAUDE_ENV_FILE"
fi

exit 0
