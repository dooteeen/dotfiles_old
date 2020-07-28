function git_expandable_stash
    git_is_repo
    and string match "*git stash *" (commandline -bc)
    and commandline -t | grep -E -q '@'
    and test (count (git stash list)) -gt 0
end
