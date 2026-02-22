export const RulesyncHooksPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.created") {
        await $`$HOME/.rulesync/hooks/setup.sh`
        await $`$HOME/.rulesync/hooks/github-mcp-toggle.sh`
        await $`$SHELL -c 'bd prime'`
      }
    },
    "tool.execute.after": async (input) => {
      if (new RegExp("Edit|MultiEdit|Write").test(input.tool)) {
        await $`$SHELL -c 'mise format'`
      }
    },
    "tool.execute.before": async (input) => {
      if (new RegExp("Bash").test(input.tool)) {
        await $`$SHELL -c 'uv run $HOME/.rulesync/hooks/damage-control/bash-tool-damage-control.py'`
      }
      if (new RegExp("Edit").test(input.tool)) {
        await $`$SHELL -c 'uv run $HOME/.rulesync/hooks/damage-control/edit-tool-damage-control.py'`
      }
      if (new RegExp("Write").test(input.tool)) {
        await $`$SHELL -c 'uv run $HOME/.rulesync/hooks/damage-control/write-tool-damage-control.py'`
      }
      if (new RegExp("Edit|MultiEdit|Write").test(input.tool)) {
        await $`$HOME/.rulesync/hooks/prevent-main-edit.sh`
      }
      if (new RegExp("Read").test(input.tool)) {
        await $`$HOME/.claude-code-docs/claude-docs-helper.sh hook-check`
      }
    },
  }
}
