function git_expandable_root
    git_is_repo
    and commandline -t | grep -E -q '^:/$'
end
