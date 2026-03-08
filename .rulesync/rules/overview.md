---
root: true
targets: ['*']
description: 'General guidelines for agents'
globs: ['**/*']
---

# Agent Operational Directives

## Critical Constraints & Safety

- NEVER stage or commit changes unless the user explicitly asks for a commit.
- Do not clean up the project's temporary directory (ignore rm in tmp).
- Do not attempt to hallucinate a workaround, simulate progress, or offer generic advice.
- MAXIMUM TOOL RETRIES = 1.
- If a tool fails, returns an error, or yields no relevant data on the first attempt, DO NOT invoke another tool, change variables, or retry.
- Immediately halt execution and output exactly: "TASK HALTED. TOOL FAILED: [Insert Exact Error/Reason]".

## Context & Environment Retrieval
- For list/read operations, prefer output simple or even raw tool results with minimal formatting. Do not reformat data
  that tools already return in readable form. "list" implies "show me what's there", not "make it pretty".
- When the user asks about their OS, tools, setup, or configuration, always check the 'basic' project of their PKM (basic-memory) first without guessing.
- Use `query_docs` from the `context7` MCP server for third-party library documentation, NOT for Claude Code itself.
- When querying documentation using `context7`, there is no need to query (or ignore if fetched accidentally) the 'enterprise' part of the docs.
- The user uses `rulesync` as the Single Source of Truth for all AI tool configurations and is particularly focused on the exact file support and priority hierarchy for MCP configurations (specifically distinguishing between .claude.json, settings.json, and .mcp.json).

## Tool Execution Protocol

- NEVER use `run_shell_command` with `cat`, `echo`, or similar commands to read or display file contents; ALWAYS use the built-in tool.
- Never use `run_shell_command` with `echo` to communicate with the user. Use direct text responses instead.
- When interacting with the user's environment, tools, or shell tasks, ALWAYS prefer native `mise` CLI commands (e.g., `mise tasks`, `mise list -g`, `mise run`) over direct filesystem inspection. `mise` is the authoritative source of truth for the system configuration.
- Autonomous Verification Protocol: When inside a tmux session, if a solution involves configuration changes for a shell tool (e.g., gemini, yazi, lnav), automatically use the `tmux` skill to run, debug, and verify the changes personally by capturing shell output, instead of asking the user to verify.
- Gemini CLI `tools.allowed` list uses PascalCase aliases (Read, Write, Replace, Bash) while `hooks.matchers` use snake_case tool names (read_file, write_file, replace, run_shell_command). Hooks receive input via STDIN, not environment variables.

---

## Script Development

**When user requests "small/tiny" scripts:**
- Start minimal (~10-15 lines max), NOT with large hardcoded solutions
- Test each transformation step (jq, cut, split) BEFORE writing code
- Verify tool behavior (e.g., `pacman -Q` does fuzzy matching, use exact checks)

**Wrong:**
```bash
# Untested jq that splits "npm:@scope/pkg" → ["npm", "@scope/pkg"] → "pkg" (breaks scoped packages)
jq -r 'keys[] | split(":") | .[-1] | split("/") | .[-1]'
```

**Correct:**
```bash
# Filter out prefixed packages, test output first
jq -r 'keys[] | select(contains(":") | not)'  # Test with: mise list -g --json | ...
# Then verify exact package name matching to avoid false positives
[[ "$pkg_name" == "$tool" ]] && dupes+=("$pkg_name")
```
---

## ast-grep vs ripgrep

**Use `ast-grep` when structure matters.** It parses code and matches AST nodes, ignoring comments/strings, and can **safely rewrite** code.

- Refactors/codemods: rename APIs, change import forms
- Policy checks: enforce patterns across a repo
- Editor/automation: LSP mode, `--json` output

**Use `ripgrep` when text is enough.** Fastest way to grep literals/regex.

- Recon: find strings, TODOs, log lines, config values
- Pre-filter: narrow candidate files before ast-grep

### Rule of Thumb

- Need correctness or **applying changes** → `ast-grep`
- Need raw speed or **hunting text** → `rg`
- Often combine: `rg` to shortlist files, then `ast-grep` to match/modify

### Rust Examples

```bash
# Find structured code (ignores comments)
ast-grep run -l Rust -p 'fn $NAME($$$ARGS) -> $RET { $$$BODY }'

# Find all unwrap() calls
ast-grep run -l Rust -p '$EXPR.unwrap()'

# Quick textual hunt
rg -n 'println!' -t rust

# Combine speed + precision
rg -l -t rust 'unwrap\(' | xargs ast-grep run -l Rust -p '$X.unwrap()' --json
```

---

## cass — Cross-Agent Session Search

`cass` indexes prior agent conversations (Claude Code, Codex, Cursor, Gemini, ChatGPT, etc.) so we can reuse solved problems.

**Rules:** Never run bare `cass` (TUI). Always use `--robot` or `--json`.

### Examples

```bash
cass health
cass search "async runtime" --robot --limit 5
cass view /path/to/session.jsonl -n 42 --json
cass expand /path/to/session.jsonl -n 42 -C 3 --json
cass capabilities --json
cass robot-docs guide
```

### Tips

- Use `--fields minimal` for lean output
- Filter by agent with `--agent`
- Use `--days N` to limit to recent history

stdout is data-only, stderr is diagnostics; exit code 0 means success.

Treat cass as a way to avoid re-solving problems other agents already handled.

---
