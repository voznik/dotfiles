#!/bin/bash
# Unified tmux helper for agents (tm.sh)
# Usage:
#   tm.sh new <session> [command]  - Create a session and wait for prompt
#   tm.sh run <session> <command>  - Run a command in active pane and wait for prompt
#   tm.sh read <session>           - Read the last 50 lines of output
#   tm.sh kill <session>           - Kill a session

SOCKET="${CLAWDBOT_TMUX_SOCKET_DIR:-/tmp/clawdbot-tmux-sockets}/clawdbot.sock"
WAIT_SCRIPT="$(dirname "$0")/wait-for-text.sh"
PROMPT_PATTERN='❯|#|\$'

get_target() {
	local sess=$1
	local b_idx=$(tmux -S "$SOCKET" show-options -gv base-index 2>/dev/null || echo 0)
	local p_idx=$(tmux -S "$SOCKET" show-options -gv pane-base-index 2>/dev/null || echo 0)
	echo "$sess:$b_idx.$p_idx"
}

case "$1" in
new)
	sess=$2
	cmd=${3:-fish}
	mkdir -p "$(dirname "$SOCKET")"
	tmux -S "$SOCKET" new -d -s "$sess" "$cmd"
	target=$(get_target "$sess")
	"$WAIT_SCRIPT" -t "$target" -p "$PROMPT_PATTERN" -T 5 || true
	tmux -S "$SOCKET" capture-pane -p -t "$target"
	;;
run)
	sess=$2
	cmd=$3
	target=$(get_target "$sess")
	tmux -S "$SOCKET" send-keys -t "$target" -- "$cmd" Enter
	"$WAIT_SCRIPT" -t "$target" -p "$PROMPT_PATTERN" -T 15
	tmux -S "$SOCKET" capture-pane -p -t "$target"
	;;
read)
	sess=$2
	target=$(get_target "$sess")
	tmux -S "$SOCKET" capture-pane -p -t "$target" -S -50
	;;
kill)
	sess=$2
	tmux -S "$SOCKET" kill-session -t "$sess" 2>/dev/null || true
	;;
*)
	echo "Usage: $0 {new|run|read|kill} session [command]"
	exit 1
	;;
esac
