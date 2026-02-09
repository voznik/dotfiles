export LS_OPTIONS='--color=auto'
eval "$(dircolors 2>/dev/null)" || true
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias la='ls $LS_OPTIONS -lA'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
# alias grep='ugrep --color=auto'
# alias fgrep='ugrep -F --color=auto'
# alias egrep='ugrep -E --color=auto'
alias hw='hwinfo --short'
alias ip='ip -color'

# Coolify CLI - use token from mise environment
# Using function instead of alias so it works in non-interactive shells (Claude Code)
coolify() {
  command coolify --token "$COOLIFY_API_TOKEN" "$@"
}
export -f coolify
