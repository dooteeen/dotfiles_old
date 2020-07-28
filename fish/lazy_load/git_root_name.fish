function git_root_name
    git_is_repo
        and basename (git rev-parse --show-toplevel)
end
