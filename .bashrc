#!/bin/bash
# ╔═════════════════════════════════════════════════════════════════╗
# ║ BASHRC                                                          ║
# ╠═════════════════════════════════════════════════════════════════╣
# ║ Entry Point to all Bash Utilities                               ║
# ╚═════════════════════════════════════════════════════════════════╝

# If not running interactively, don't do anything
# ___________________________________________________________________
[ -z "$PS1" ] && return

export LANG=en_US.UTF-8


# ┌─────────────────────────────────────────────────────────────────┐
# │ Source Other Files                                              │
# ├─────────────────────────────────────────────────────────────────┤
# │ Let Bash Variables come first to use within every area.         │
# └─────────────────────────────────────────────────────────────────┘

# For private exports [Don't place in git]
# @ Load Before other items incase exports are needed.
# ___________________________________________________________________
[[ -f ~/.exports_private ]] && source ~/.exports_private # || echo 'Missing'
[[ -f ~/.bash_vars ]] && source ~/.bash_vars
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.bash_vendors ]] && source ~/.bash_vendors
[[ -f ~/.bash_snippets ]] && source ~/.bash_snippets

# Docker Related (Prevent error if docker is not installed)
if hash docker 2>/dev/null; then
  if [[ -f ~/.dockerrc ]]; then
    source ~/.dockerrc
  fi
fi


# ┌─────────────────────────────────────────────────────────────────┐
# │ Preferences: History                                            │
# ├─────────────────────────────────────────────────────────────────┤
# └─────────────────────────────────────────────────────────────────┘
# Store multiline commands as one line.
shopt -s cmdhist

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

# Append to the history file, don"t overwrite it
# ___________________________________________________________________
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Set variable identifying the chroot you work in
#                      (used in the prompt below)
# ___________________________________________________________________
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Spellcheck directories
shopt -s dirspell

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
  screen-256color) color_prompt=yes;;
  screen) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# ┌─────────────────────────────────────────────────────────────────┐
# │ Bash Completion                                                 │
# ├─────────────────────────────────────────────────────────────────┤
# └─────────────────────────────────────────────────────────────────┘
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion

# Fix $ cd typing errors
# ___________________________________________________________________
shopt -s cdspell


# Make less more friendly for non-text input files, see lesspipe(1)
# ___________________________________________________________________
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

