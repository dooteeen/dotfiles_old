function git_root_path
    git_is_repo
        and git rev-parse --show-toplevel
end
