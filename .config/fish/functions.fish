# thx to https://github.com/mduvall/config/

# yadm
function yc
    cd ~
    yadm enter lazygit
    cd -
end

function yy
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function clone --description "clone something, cd into it. install it."
    git clone --depth=1 $argv[1]
    cd (basename $argv[1] | sed 's/.git$//')
    yarn install
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

function gz --d "Get the gzipped size"
  echo "orig size    (bytes): "
  cat "$argv[1]" | wc -c | gnumfmt --grouping
  echo "gzipped size (bytes): "
  gzip -c "$argv[1]" | wc -c | gnumfmt --grouping
end

function sudo!!
    eval sudo $history[1]
end


# `shellswitch [bash|zsh|fish]`
function shellswitch
	chsh -s (brew --prefix)/bin/$argv
end


function upgradeyarn
  curl -o- -L https://yarnpkg.com/install.sh | bash
end

function fuck -d 'Correct your previous console command'
    set -l exit_code $status
    set -l eval_script (mktemp 2>/dev/null ; or mktemp -t 'thefuck')
    set -l fucked_up_commandd $history[1]
    thefuck $fucked_up_commandd > $eval_script
    . $eval_script
    rm $eval_script
    if test $exit_code -ne 0
        history --delete $fucked_up_commandd
    end
end

function server -d 'Start a HTTP server in the current dir, optionally specifying the port'
    if test $argv[1]
        set port $argv[1]
    else
        set port 8000
    end

    open "http://localhost:$port/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
#     python -c "import SimpleHTTPServer
# map = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;
# map[\"\"] = \"text/plain\";
# for key, value in map.items():
#   map[key] = value + \";charset=UTF-8\";
#   SimpleHTTPServer.test()" $port
    statikk --port "$port" .
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

function mmr -d 'calc mem by process name'
    # If no argument is passed, open current dir
    if [ (count $argv) -eq 0 ]
        smem -t -k -c pss -P slack | tail -n 1
    else
        smem -t -k -c pss -P $argv | tail -n 1
    end
end

