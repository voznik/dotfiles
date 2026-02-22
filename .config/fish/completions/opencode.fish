# opencode fish completion

function __fish_opencode_needs_command
    set cmd (commandline -opc)
    test (count $cmd) -eq 1
end

function __fish_opencode_using_command
    set cmd (commandline -opc)
    test (count $cmd) -gt 1
    and test $argv[1] = $cmd[2]
end

function __fish_opencode_complete
    command opencode --get-yargs-completions (commandline -opc) ^/dev/null
end

# Main commands
complete -f -c opencode -n __fish_opencode_needs_command -a completion -d 'Generate shell completion script'
complete -f -c opencode -n __fish_opencode_needs_command -a acp -d 'Start ACP server'
complete -f -c opencode -n __fish_opencode_needs_command -a mcp -d 'Manage MCP servers'
complete -f -c opencode -n __fish_opencode_needs_command -a attach -d 'Attach to running opencode server'
complete -f -c opencode -n __fish_opencode_needs_command -a run -d 'Run opencode with a message'
complete -f -c opencode -n __fish_opencode_needs_command -a debug -d 'Debugging and troubleshooting tools'
complete -f -c opencode -n __fish_opencode_needs_command -a auth -d 'Manage credentials'
complete -f -c opencode -n __fish_opencode_needs_command -a agent -d 'Manage agents'
complete -f -c opencode -n __fish_opencode_needs_command -a upgrade -d 'Upgrade opencode'
complete -f -c opencode -n __fish_opencode_needs_command -a uninstall -d 'Uninstall opencode'
complete -f -c opencode -n __fish_opencode_needs_command -a serve -d 'Start headless opencode server'
complete -f -c opencode -n __fish_opencode_needs_command -a web -d 'Start server and open web interface'
complete -f -c opencode -n __fish_opencode_needs_command -a models -d 'List available models'
complete -f -c opencode -n __fish_opencode_needs_command -a stats -d 'Show token usage statistics'
complete -f -c opencode -n __fish_opencode_needs_command -a export -d 'Export session data as JSON'
complete -f -c opencode -n __fish_opencode_needs_command -a import -d 'Import session data from JSON'
complete -f -c opencode -n __fish_opencode_needs_command -a github -d 'Manage GitHub agent'
complete -f -c opencode -n __fish_opencode_needs_command -a pr -d 'Fetch and checkout GitHub PR'
complete -f -c opencode -n __fish_opencode_needs_command -a session -d 'Manage sessions'

# mcp subcommands
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a add -d 'Add MCP server'
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a list -d 'List MCP servers'
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a ls -d 'List MCP servers (alias)'
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a auth -d 'Authenticate with OAuth-enabled MCP server'
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a logout -d 'Remove OAuth credentials'
complete -f -c opencode -n '__fish_opencode_using_command mcp' -a debug -d 'Debug OAuth connection'

# auth subcommands
complete -f -c opencode -n '__fish_opencode_using_command auth' -a login -d 'Log in to a provider'
complete -f -c opencode -n '__fish_opencode_using_command auth' -a logout -d 'Log out from a provider'
complete -f -c opencode -n '__fish_opencode_using_command auth' -a list -d 'List providers'
complete -f -c opencode -n '__fish_opencode_using_command auth' -a ls -d 'List providers (alias)'

# agent subcommands
complete -f -c opencode -n '__fish_opencode_using_command agent' -a create -d 'Create a new agent'
complete -f -c opencode -n '__fish_opencode_using_command agent' -a list -d 'List all available agents'

# debug subcommands
complete -f -c opencode -n '__fish_opencode_using_command debug' -a config -d 'Show resolved configuration'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a lsp -d 'LSP debugging utilities'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a rg -d 'ripgrep debugging utilities'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a file -d 'File system debugging utilities'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a scrap -d 'List all known projects'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a skill -d 'List all available skills'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a snapshot -d 'Snapshot debugging utilities'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a agent -d 'Show agent configuration'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a paths -d 'Show global paths'
complete -f -c opencode -n '__fish_opencode_using_command debug' -a wait -d 'Wait indefinitely (for debugging)'

# Dynamic completions for options and flags
complete -c opencode -a "(__fish_opencode_complete)" -f
