function f --description "find shorthand"
    find . -name "$argv" 2>&1 | grep -v 'Permission denied'
end
