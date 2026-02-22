# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_dua_global_optspecs
    string join \n t/threads= f/format= A/apparent-size l/count-hard-links x/stay-on-filesystem i/ignore-dirs= log-file= h/help V/version
end

function __fish_dua_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_dua_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_dua_using_subcommand
    set -l cmd (__fish_dua_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c dua -n __fish_dua_needs_command -s t -l threads -d 'The amount of threads to use. Defaults to 0, indicating the amount of logical processors. Set to 1 to use only a single thread' -r
complete -c dua -n __fish_dua_needs_command -s f -l format -d 'The format with which to print byte counts' -r -f -a "metric\t''
binary\t''
bytes\t''
gb\t''
gib\t''
mb\t''
mib\t''"
complete -c dua -n __fish_dua_needs_command -s i -l ignore-dirs -d 'One or more absolute directories to ignore. Note that these are not ignored if they are passed as input path' -r -F
complete -c dua -n __fish_dua_needs_command -l log-file -d 'Write a log file with debug information, including panics' -r -F
complete -c dua -n __fish_dua_needs_command -s A -l apparent-size -d 'Display apparent size instead of disk usage'
complete -c dua -n __fish_dua_needs_command -s l -l count-hard-links -d 'Count hard-linked files each time they are seen'
complete -c dua -n __fish_dua_needs_command -s x -l stay-on-filesystem -d 'If set, we will not cross filesystems or traverse mount points'
complete -c dua -n __fish_dua_needs_command -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dua -n __fish_dua_needs_command -s V -l version -d 'Print version'
complete -c dua -n __fish_dua_needs_command -a interactive -d 'Launch the terminal user interface'
complete -c dua -n __fish_dua_needs_command -a i -d 'Launch the terminal user interface'
complete -c dua -n __fish_dua_needs_command -a aggregate -d 'Aggregate the consumed space of one or more directories or files'
complete -c dua -n __fish_dua_needs_command -a a -d 'Aggregate the consumed space of one or more directories or files'
complete -c dua -n __fish_dua_needs_command -a completions -d 'Generate shell completions'
complete -c dua -n __fish_dua_needs_command -a help -d 'Print this message or the help of the given subcommand(s)'
complete -c dua -n "__fish_dua_using_subcommand interactive" -s e -l no-entry-check -d 'Do not check entries for presence when listing a directory to avoid slugging performance on slow filesystems'
complete -c dua -n "__fish_dua_using_subcommand interactive" -s h -l help -d 'Print help'
complete -c dua -n "__fish_dua_using_subcommand i" -s e -l no-entry-check -d 'Do not check entries for presence when listing a directory to avoid slugging performance on slow filesystems'
complete -c dua -n "__fish_dua_using_subcommand i" -s h -l help -d 'Print help'
complete -c dua -n "__fish_dua_using_subcommand aggregate" -l stats -d 'If set, print additional statistics about the file traversal to stderr'
complete -c dua -n "__fish_dua_using_subcommand aggregate" -l no-sort -d 'If set, paths will be printed in their order of occurrence on the command-line. Otherwise they are sorted by their size in bytes, ascending'
complete -c dua -n "__fish_dua_using_subcommand aggregate" -l no-total -d 'If set, no total column will be computed for multiple inputs'
complete -c dua -n "__fish_dua_using_subcommand aggregate" -s h -l help -d 'Print help'
complete -c dua -n "__fish_dua_using_subcommand a" -l stats -d 'If set, print additional statistics about the file traversal to stderr'
complete -c dua -n "__fish_dua_using_subcommand a" -l no-sort -d 'If set, paths will be printed in their order of occurrence on the command-line. Otherwise they are sorted by their size in bytes, ascending'
complete -c dua -n "__fish_dua_using_subcommand a" -l no-total -d 'If set, no total column will be computed for multiple inputs'
complete -c dua -n "__fish_dua_using_subcommand a" -s h -l help -d 'Print help'
complete -c dua -n "__fish_dua_using_subcommand completions" -s h -l help -d 'Print help'
complete -c dua -n "__fish_dua_using_subcommand help; and not __fish_seen_subcommand_from interactive aggregate completions help" -f -a interactive -d 'Launch the terminal user interface'
complete -c dua -n "__fish_dua_using_subcommand help; and not __fish_seen_subcommand_from interactive aggregate completions help" -f -a aggregate -d 'Aggregate the consumed space of one or more directories or files'
complete -c dua -n "__fish_dua_using_subcommand help; and not __fish_seen_subcommand_from interactive aggregate completions help" -f -a completions -d 'Generate shell completions'
complete -c dua -n "__fish_dua_using_subcommand help; and not __fish_seen_subcommand_from interactive aggregate completions help" -f -a help -d 'Print this message or the help of the given subcommand(s)'
