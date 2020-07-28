function appear_right
    if git_is_repo
        test "$__HIDE_GIT_INFO" != (git_root_path)
        and set -g __HIDE_GIT_INFO
    end
end
