---
name: tmux
description: >-
  Remote-control tmux sessions for interactive CLIs by sending keystrokes and
  scraping pane output.
targets:
  - '*'
---

# tmux Skill

Use tmux only when you need an interactive TTY. Prefer bash background mode for long-running, non-interactive tasks.

---

## CRITICAL: Sending input to TUI apps (gemini, opencode, aider, etc.)

TUI apps have their own input areas. They intercept raw keystrokes.
The ONLY reliable way to type text and submit it is the **two-step raw tmux** method below.

### THE PROVEN PATTERN (use this, nothing else):

```bash
# Step 1: Type the text using -l (literal flag -- prevents key interpretation)
SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/tmp-cli.sock"
tmux -S "$SOCKET" send-keys -t SESSION_NAME -l 'Your question here'

# Step 2: Small pause, then press Enter as a SEPARATE send-keys call
sleep 0.3
tmux -S "$SOCKET" send-keys -t SESSION_NAME Enter
```

**All three parts are MANDATORY:**
1. `-l` flag (literal) -- sends text character-by-character without interpretation
2. `sleep 0.3` -- gives the TUI time to receive all characters
3. **Separate** `Enter` -- must be its own send-keys call, NOT appended to the text

### WHAT WILL FAIL (never do these):

| WRONG approach | Why it fails |
|---|---|
| `send-keys 'text' Enter` (no `-l`) | tmux interprets special chars, TUI gets garbage |
| `send-keys -l 'text' Enter` (Enter in same call) | `-l` makes Enter literal text "Enter", not a keypress |
| `send-keys -t session C-m` | Many TUIs don't map C-m to submit |
| `$TM run session 'text'` | tm run sends to shell, not to the TUI's input area |
| `$TM send session 'text'` | Same problem -- sends to shell, TUI ignores it |

### WHAT TO DO IF NO RESPONSE APPEARS:

**Your input was NOT submitted.** Do NOT "wait more". Instead:
1. Read the pane to see current state
2. Try sending `Enter` again (the text may still be in the input area)
3. If input area is empty, re-type with the proven pattern above

**NEVER choose to "wait longer" if a TUI shows no response after 5 seconds. The submit failed. Act immediately.**

---

## Complete TUI interaction workflow

Full copy-paste recipe for interacting with TUI agents like gemini or opencode.

### Launch

```bash
# Create session
TM=~/.rulesync/scripts/tm.sh && $TM new my-session

# Launch the TUI app (use tm send -- it just sends keystrokes to shell)
TM=~/.rulesync/scripts/tm.sh && $TM send my-session 'gemini'

# Wait for startup, then read to confirm it's ready
sleep 3 && TM=~/.rulesync/scripts/tm.sh && $TM read my-session
```

### Send a question (raw tmux -- MUST use this for TUI input)

```bash
# Type + submit (TWO separate send-keys calls, ALWAYS)
SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/tmp-cli.sock"
tmux -S "$SOCKET" send-keys -t my-session -l 'What is 2+2?' && sleep 0.3 && tmux -S "$SOCKET" send-keys -t my-session Enter

# Wait for response, then read
sleep 5 && TM=~/.rulesync/scripts/tm.sh && $TM read my-session
```

### Quit

```bash
# TUI commands like /quit also need the same two-step pattern
SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/tmp-cli.sock"
tmux -S "$SOCKET" send-keys -t my-session -l '/quit' && sleep 0.3 && tmux -S "$SOCKET" send-keys -t my-session Enter

# Confirm exit
sleep 2 && TM=~/.rulesync/scripts/tm.sh && $TM read my-session
```

### Cleanup

```bash
TM=~/.rulesync/scripts/tm.sh && $TM kill my-session
```

---

## `tm` helper -- for shell commands only

`~/.rulesync/scripts/tm.sh` handles socket, targeting, and prompt-waiting automatically.
**Use `tm` for shell commands. Use raw tmux for TUI app input.**

**IMPORTANT**: Always set `TM` at the start of EVERY shell command -- it does not persist between calls.

```bash
TM=~/.rulesync/scripts/tm.sh

$TM new my-session                       # create session in $PWD
$TM new my-session -c /path/to/dir       # create session in specific dir
$TM run my-session 'ping -c 3 1.1.1.1'  # send command, wait for prompt, print output
$TM send my-session 'gemini'             # launch a TUI (then switch to raw tmux for input)
$TM read my-session                      # read last 200 lines
$TM read my-session -n 50               # read last 50 lines
$TM wait my-session 'pattern'            # wait for regex in output
$TM kill my-session                      # kill session
$TM list                                 # list all sessions
```

`tm run` auto-waits for the shell prompt to return (up to 30s), then prints captured output. No `sleep` needed.

### Long-running shell commands (servers, builds, etc.)

```bash
TM=~/.rulesync/scripts/tm.sh
$TM new build-1 -c /path/to/project
$TM send build-1 "npm run build"

# Poll later in a separate shell call:
TM=~/.rulesync/scripts/tm.sh && $TM read build-1
```

### Non-interactive gemini (fire-and-forget task delegation)

gemini needs `--yolo` for non-interactive mode. Use `tm send` for this:

```bash
TM=~/.rulesync/scripts/tm.sh
$TM send agent-1 "gemini --yolo 'Fix bug X'"
```

Use separate git worktrees for parallel fixes.

---

## Answering interactive prompts (non-TUI programs)

For simple interactive prompts (not full TUI apps), you can send keystrokes directly:

```bash
SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/tmp-cli.sock"
tmux -S "$SOCKET" capture-pane -p -J -t my-session -S -20   # read the prompt
tmux -S "$SOCKET" send-keys -t my-session Enter              # press Enter (accept default)
tmux -S "$SOCKET" send-keys -t my-session '2' Enter          # select menu option 2
tmux -S "$SOCKET" send-keys -t my-session 'y' Enter          # answer yes
tmux -S "$SOCKET" send-keys -t my-session Up                 # arrow keys / Tab / Escape
```

---

## Rules

1. **Always re-set `TM=~/.rulesync/scripts/tm.sh`** at the start of each shell command
2. **Never mix `$TM` with raw tmux** in the same session for the same purpose
3. **Never hardcode `:0.0` or `:0`** in targets -- use session name only (e.g. `-t my-session`)
4. **Never use `$SOCKET_DIR` without defining it first** -- use: `SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/tmp-cli.sock"`
5. **For TUI input: ALWAYS use raw tmux with `-l` flag + separate Enter** (see top of this file)
6. **Never "wait more" if a TUI shows no response** -- the submit failed, re-send

---

## Raw tmux reference

Use raw tmux when `tm` doesn't fit (e.g. TUI input, multi-window, split panes).

```bash
SOCKET="${TMPDIR:-/tmp}/tmp-cli-tmux-sockets/my-task.sock"
mkdir -p "$(dirname "$SOCKET")"
SESSION="my-task"

tmux -S "$SOCKET" new-session -d -s "$SESSION" -c "$PWD"
tmux -S "$SOCKET" send-keys -t "$SESSION" -l 'echo hello'
sleep 0.3
tmux -S "$SOCKET" send-keys -t "$SESSION" Enter
sleep 2
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION" -S -200
```

- Literal text: `tmux -S "$SOCKET" send-keys -t "$SESSION" -l -- "$text"`
- Ctrl+C: `tmux -S "$SOCKET" send-keys -t "$SESSION" C-c`
- For python REPLs: set `PYTHON_BASIC_REPL=1`

---

## Session management

- List: `TM=~/.rulesync/scripts/tm.sh && $TM list`
- Find across sockets: `~/.rulesync/scripts/find-sessions.sh --all`
- Kill one: `TM=~/.rulesync/scripts/tm.sh && $TM kill my-session`
- Kill all on socket: `tmux -S "$SOCKET" kill-server`
