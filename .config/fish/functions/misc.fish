# thx to https://github.com/mduvall/config/

function ylg -d "yadm open lazygit"
    cd ~
    yadm enter lazygit
    cd -
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function clone --description "clone something, cd into it. trust it."
    git clone --depth=1 $argv[1]
    cd (basename $argv[1] | sed 's/.git$//')
    mise trust
end

function md --wraps mkdir -d "Create a directory and cd into it"
    command mkdir -p $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'
            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end

function gzs --d "Get the gzipped size"
    echo "orig size    (bytes): "
    cat "$argv[1]" | wc -c | gnumfmt --grouping
    echo "gzipped size (bytes): "
    gzip -c "$argv[1]" | wc -c | gnumfmt --grouping
end

function fuck -d 'Correct your previous console command'
    set -l exit_code $status
    set -l eval_script (mktemp 2>/dev/null ; or mktemp -t 'thefuck')
    set -l fucked_up_commandd $history[1]
    thefuck $fucked_up_commandd >$eval_script
    . $eval_script
    rm $eval_script
    if test $exit_code -ne 0
        history --delete $fucked_up_commandd
    end
end

#-------------------------------------------------------------
# Process/system related functions:
#-------------------------------------------------------------

function my_ps
    ps $argv[1] -u $USER -o pid,%cpu,%mem,bsdtime,command
end

function ps_mem
    #  ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' | awk '{total=total + $1} END {print total}''
    ps $argv[1] -u $USER -o pid,%cpu,%mem,bsdtime,command
end

###
# https://github.com/timnew/worktree.fish
###

# Create a new worktree and branch from within current git directory.
function gwa --description "Create a new git worktree with a branch in a sibling directory"
    if test -z "$argv[1]"
        echo "Usage: ga [branch name]"
        return 1
    end

    set -l branch $argv[1]
    set -l base (basename "$PWD")
    set -l path "../$base--$branch"

    git worktree add -b "$branch" "$path"
    mise trust "$path"
    cd "$path"
end

# Remove worktree and branch from within active worktree directory.
function gwd --description "Remove the current worktree and its associated branch"
    read -l -P "Remove worktree and branch? [y/N] " confirm
    or return # Exit if user cancelled with Ctrl+C or Ctrl+D

    if string match -qi y $confirm
        set -l cwd (pwd)
        set -l worktree (basename "$cwd")

        # split on first `--`
        set -l parts (string split --max=1 -- '--' "$worktree")
        set -l root $parts[1]
        set -l branch $parts[2]

        # Protect against accidentally nuking a non-worktree directory
        if test "$root" != "$worktree"
            cd "../$root"

            git worktree remove "$worktree" --force
            git branch -D "$branch"
        end
    end
end

# List all worktrees
function gwl --description "List all git worktrees"
    git worktree list
end

# Navigate to a worktree or back to base directory
function gwcd --description "Navigate to a worktree branch or back to base directory"
    if test -z "$argv[1]"
        # No branch given, go back to base directory
        set -l cwd (pwd)
        set -l worktree (basename "$cwd")

        # split on first `--`
        set -l parts (string split --max=1 -- '--' "$worktree")
        set -l root $parts[1]

        # Check if we're in a worktree directory
        if test "$root" != "$worktree"
            cd "../$root"
        else
            echo "Already in base directory or not in a worktree"
        end
    else
        # Branch given, navigate to that worktree
        set -l branch $argv[1]
        set -l cwd (pwd)
        set -l worktree (basename "$cwd")

        # Get the base name
        set -l parts (string split --max=1 -- '--' "$worktree")
        set -l base $parts[1]

        set -l target "../$base--$branch"

        if test -d "$target"
            cd "$target"
        else
            echo "Worktree '$target' not found"
            return 1
        end
    end
end

###
