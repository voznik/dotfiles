# set default_user "paulirish"
# set default_machine "paulirish-macbookair2"

# source ~/.config/fish/aliases.fish
source ~/.config/fish/chpwd.fish
source ~/.config/fish/functions.fish

### curl -sS https://starship.rs/install.sh | sh
starship init fish | source

# for things not checked into git..
if test -e "$HOME/.extra.fish";
	source ~/.extra.fish
end

function sourceenv
  for line in (cat $argv | grep -v '^#')
    set item (string split -m 1 '=' $line)
    set -gx $item[1] $item[2]
  end
end

if test -e "$HOME/.env";
    sourceenv $HOME/.env
end

# Local prompt customization
set -e fish_greeting
set -U fish_greeting

set -g fish_pager_color_completion normal
set -g fish_pager_color_description 555 yellow
set -g fish_pager_color_prefix cyan
set -g fish_pager_color_progress cyan


# highlighting inside manpages and elsewhere
set -gx LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
set -gx LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
set -gx LESS_TERMCAP_me \e'[0m'           # end mode
set -gx LESS_TERMCAP_se \e'[0m'           # end standout-mode
set -gx LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
set -gx LESS_TERMCAP_ue \e'[0m'           # end underline
set -gx LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

# rvm default

# REUSE ENVIRONMENT VARIABLES FROM ~/.bash_profile
# https://github.com/albertz/dotfiles/blob/master/.config/fish/config.fish
# Fish shell

egrep "^export " ~/.bash_vendors | while read e
  set var (echo $e | sed -E "s/^export ([A-Z_]+)=(.*)\$/\1/")
  set value (echo $e | sed -E "s/^export ([A-Z_]+)=(.*)\$/\2/")

  # remove surrounding quotes if existing
  set value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")

  if test $var = "PATH"
    # replace ":" by spaces. this is how PATH looks for Fish
    set value (echo $value | sed -E "s/:/ /g")

    # use eval because we need to expand the value
    eval set -xg $var $value

    continue
  end

  # evaluate variables. we can use eval because we most likely just used "$var"
  set value (eval echo $value)

  #echo "set -xg '$var' '$value' (via '$e')"
  set -xg $var $value
end

# pnpm
set -gx PNPM_HOME "/home/voznik/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# direnv hook fish | source
