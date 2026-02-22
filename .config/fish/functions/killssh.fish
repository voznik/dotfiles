function killssh --description 'Interactively find and kill hanging SSH processes'
    # Get all ssh processes for the current user, excluding the agent
    # We use pgrep -a to get the full command line for fzf to display
    set -l selection (pgrep -u $USER -a ssh | grep -v 'ssh-agent' | fzf --multi --header='Select SSH processes to KILL (Tab to mark, Enter to confirm)' --preview 'ps -fp {1}')

    if test -n "$selection"
        # Extract PIDs (first column)
        set -l pids (for line in $selection; echo $line | awk '{print $1}'; end)

        # Kill with -9 as requested (for hanging processes)
        kill -9 $pids
        echo "Killed PIDs: $pids"
    else
        echo "No processes selected."
    end
end
