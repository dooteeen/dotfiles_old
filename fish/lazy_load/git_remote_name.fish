function git_remote_name
    git_is_repo
        or return

    set -l branch (git_branch_name)
    git branch -vv \
        | grep "* $branch" \
        | string replace -r "^.*\[(.*)/$branch(:.*)?\].*" '$1'
end
