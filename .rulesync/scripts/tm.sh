#!/bin/bash
# Unified tmux helper for agents (tm.sh)
# Usage:
#   tm new <session> [-c dir]    - Create session, optionally set working dir
#   tm run <session> <command>   - Send command, wait for prompt, print output
#   tm send <session> <command>  - Send command (no wait) — for long-running/interactive programs
#   tm read <session> [-n lines] - Read last N lines (default 200)
#   tm wait <session> <pattern>  - Wait for pattern in pane output
#   tm kill <session>            - Kill a session
#   tm list                      - List all sessions on the socket
#
# Socket auto-derived from TMP_CLI_TMUX_SOCKET_DIR env var.
# Override socket per-call: TM_SOCKET=/path/to/sock tm ...

SOCKET_DIR="${TMP_CLI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/tmp-cli-tmux-sockets}"
SOCKET="${TM_SOCKET:-$SOCKET_DIR/tmp-cli.sock}"
WAIT_SCRIPT="$(dirname "$0")/wait-for-text.sh"
PROMPT_PATTERN='❯|\$|#|λ'

case "$1" in
new)
	sess=$2; shift 2
	workdir="$PWD"
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-c) workdir="$2"; shift 2 ;;
		*) shift ;;
		esac
	done
	mkdir -p "$(dirname "$SOCKET")"
	tmux -S "$SOCKET" kill-session -t "$sess" 2>/dev/null || true
	tmux -S "$SOCKET" new-session -d -s "$sess" -c "$workdir"
	"$WAIT_SCRIPT" -S "$SOCKET" -t "$sess" -p "$PROMPT_PATTERN" -T 5 2>/dev/null || true
	echo "Session '$sess' created (socket: $SOCKET)"
	echo "To attach: tmux -S \"$SOCKET\" attach -t \"$sess\""
	;;
run)
	sess=$2; cmd=$3
	tmux -S "$SOCKET" send-keys -t "$sess" -- "$cmd" Enter
	"$WAIT_SCRIPT" -S "$SOCKET" -t "$sess" -p "$PROMPT_PATTERN" -T 30
	tmux -S "$SOCKET" capture-pane -p -J -t "$sess" -S -200
	;;
send)
	sess=$2; cmd=$3
	tmux -S "$SOCKET" send-keys -t "$sess" -- "$cmd" Enter
	;;
read)
	sess=$2; shift 2
	lines=200
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-n) lines="$2"; shift 2 ;;
		*) shift ;;
		esac
	done
	tmux -S "$SOCKET" capture-pane -p -J -t "$sess" -S "-$lines"
	;;
wait)
	sess=$2; pattern=$3
	"$WAIT_SCRIPT" -S "$SOCKET" -t "$sess" -p "$pattern" -T "${4:-15}"
	;;
kill)
	sess=$2
	tmux -S "$SOCKET" kill-session -t "$sess" 2>/dev/null || true
	echo "Session '$sess' killed"
	;;
list)
	tmux -S "$SOCKET" list-sessions 2>/dev/null || echo "No sessions on $SOCKET"
	;;
*)
	echo "Usage: tm {new|run|send|read|wait|kill|list} <session> [args]"
	exit 1
	;;
esac
