#
# https://github.com/phette23/fishrc
#
function mkd -d 'Create a new directory and enter it'
    mkdir -p $argv
    cd $argv
end

function npmgup -d 'Update all global NPM packages'

    for package in (npm -g outdated --parseable --depth=0 | cut -d: -f2 | grep --invert-match '@linked$' | cut -d@ -f1)
        npm install -g "$package"
    end

end

function npmr -d 'run given npm script'
    # If no argument is passed, open current dir
    if [ (count $argv) -eq 0 ]
        npm start
    else
        npm run $argv
    end
end

function a -d 'open file or cwd in Atom editor'
    # If no argument is passed, open current dir
    if [ (count $argv) -eq 0 ]
        atom .
    else
        atom $argv
    end
end

function s -d 'open file or cwd in Sublime Text editor'
    # If no argument is passed, open current dir
    if [ (count $argv) -eq 0 ]
        subl .
    else
        subl $argv
    end
end
#

#
function check_cordova_files -d 'run `npm install` if package.json changed and `bower install` if `bower.json` changed.' --argument-names 'filename'
  set CORDOVA_FILES (git diff --stat $LAST_HASH $CUR_HASH | grep '\|' | awk '{print}')
  if [ (count $argv) -eq 0 ]
    echo $CORDOVA_FILES
  else
      echo $CORDOVA_FILES | grep --quiet $argv[1] & eval $argv[2]
  end
end

#-------------------------------------------------------------
# Process/system related functions:
#-------------------------------------------------------------

# function my_ps
#   ps $argv[1] -u $USER -o pid,%cpu,%mem,bsdtime,command
# end
#
# function pp
#   my_ps | awk '!/awk/ && $0~var' set var ${1:-'.*'}
# end

function my_ip -d 'Get IP adress on ethernet.'
    set MY_IP (ifconfig wlp7s0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    echo $MY_IP:-'Not connected'
end

function wanip
	wget -q -O - checkip.dyndns.com/ | awk '{print $6}'| sed 's/<.*>//'
end
#

function ssh_clip -d 'Copy ssh key to clipboard'
  cat ~/.ssh/id_rsa.pub | xclip -sel clip
end

#
function mmr -d 'calc mem by process name'
    # If no argument is passed, open current dir
    if [ (count $argv) -eq 0 ]
        smem -t -k -c pss -P slack | tail -n 1
    else
        smem -t -k -c pss -P $argv | tail -n 1
    end
end
