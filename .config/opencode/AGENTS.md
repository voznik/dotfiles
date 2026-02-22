# Agent Operational Directives

## Critical Constraints & Safety

- NEVER stage or commit changes unless the user explicitly asks for a commit.
- Do not clean up the project's temporary directory (ignore rm in tmp).
- Do not attempt to hallucinate a workaround, simulate progress, or offer generic advice.
- MAXIMUM TOOL RETRIES = 1.
- If a tool fails, returns an error, or yields no relevant data on the first attempt, DO NOT invoke another tool, change variables, or retry.
- Immediately halt execution and output exactly: "TASK HALTED. TOOL FAILED: [Insert Exact Error/Reason]".

## Context & Environment Retrieval

- When the user asks about their OS, tools, setup, or configuration, always check the 'basic' project of their PKM (basic-memory) first without guessing.
- Always consult the 'OS Configuration & Tools' note (permalink: os-configuration-tools) in the 'basic' project of Basic Memory whenever you need to verify which CLI tools are available locally or to understand the system architecture and environment configuration.
- For Claude Code documentation (hooks, settings, permissions, MCP config, skills, sub-agents, etc.), ALWAYS use the `/docs` skill first. NEVER use context7 MCP, claude-code-guide agent, or WebFetch for Claude Code docs.
- Use `query_docs` from the `context7` MCP server for third-party library documentation, NOT for Claude Code itself.
- When querying documentation using `context7`, there is no need to query (or ignore if fetched accidentally) the 'enterprise' part of the docs.
- The user uses `rulesync` as the Single Source of Truth for all AI tool configurations and is particularly focused on the exact file support and priority hierarchy for MCP configurations (specifically distinguishing between .claude.json, settings.json, and .mcp.json).

## Tool Execution Protocol

- NEVER use `run_shell_command` with `cat`, `echo`, or similar commands to read or display file contents; ALWAYS use the built-in tool.
- Never use `run_shell_command` with `echo` to communicate with the user. Use direct text responses instead.
- When interacting with the user's environment, tools, or shell tasks, ALWAYS prefer native `mise` CLI commands (e.g., `mise tasks`, `mise list -g`, `mise run`) over direct filesystem inspection. `mise` is the authoritative source of truth for the system configuration.
- Autonomous Verification Protocol: When inside a tmux session, if a solution involves configuration changes for a shell tool (e.g., gemini, yazi, lnav), automatically use the `tmux` skill to run, debug, and verify the changes personally by capturing shell output, instead of asking the user to verify.
- Gemini CLI `tools.allowed` list uses PascalCase aliases (Read, Write, Replace, Bash) while `hooks.matchers` use snake_case tool names (read_file, write_file, replace, run_shell_command). Hooks receive input via STDIN, not environment variables.
