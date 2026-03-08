# Tool name mapping — single source of truth
def claude_to_gemini_tool:
  { "Bash": "run_shell_command", "Edit": "replace", "Write": "write_file",
    "Read": "read_file", "MultiEdit": "replace" }[.] // .;

# Map a "|"-delimited matcher string from Claude to Gemini tool names
def map_matcher:
  split("|") | map(claude_to_gemini_tool) | join("|");

# Convert seconds to milliseconds, defaulting to 5s
def to_ms: (. // 5) * 1000;

# Wrap a shell command to read stdin and pipe to the command (replacing $SHELL with bash)
def wrap_cmd:
  "input=$(cat); printf \"%s\" \"$input\" | " + (gsub("\\$SHELL"; "bash"));

# Transform a hook command: special-case mise format, otherwise wrap for stdin
def transform_cmd:
  if contains("mise format") then
    "input=$(cat); file_path=$(printf \"%s\" \"$input\" | jq -r .tool_input.file_path); if [ -n \"$file_path\" ] && [ \"$file_path\" != \"null\" ]; then bash -c \"mise format $file_path\"; fi"
  else
    wrap_cmd
  end;

# Group an array of hook objects by matcher and transform each group
# $phase is reserved for future per-phase differentiation
def process_hook_group($phase):
  group_by(.matcher) |
  map({
    matcher: (.[0].matcher // "" | map_matcher),
    hooks: map({
      type: "command",
      command: (.command | transform_cmd),
      timeout: (.timeout | to_ms)
    })
  });

.[0] as $ssot | .[1] |

.hooks //= {} |
.hooks.enabled //= ["SessionStart", "PreCompress", "BeforeAgent", "BeforeModel", "BeforeTool", "AfterTool"] |

.hooks.BeforeModel = [{
  hooks: ($ssot.hooks.beforeSubmitPrompt // [] | map({
    type: "command",
    command: (.command | transform_cmd),
    timeout: (.timeout | to_ms)
  }))
}] |

.hooks.BeforeTool = ($ssot.hooks.preToolUse // [] | process_hook_group("pre")) |

.hooks.AfterTool = ($ssot.hooks.postToolUse // [] | process_hook_group("post")) |

# Convert timeout: null → default 5s (5000ms), seconds (<100) → ms, else keep
def fix_timeout: if . == null then 5000 elif . < 100 then to_ms else . end;

# Fix SessionStart hooks: convert timeouts to ms
.hooks.SessionStart |= (if . then map(.hooks |= map(
  .timeout |= fix_timeout
)) else . end) |

# Fix PreCompress hooks: convert timeouts to ms
.hooks.PreCompress |= (if . then map(.hooks |= map(
  .timeout |= fix_timeout
)) else . end) |

# Fix BeforeAgent hooks: convert timeouts to ms
.hooks.BeforeAgent |= (if . then map(.hooks |= map(
  .timeout |= fix_timeout
)) else . end)
