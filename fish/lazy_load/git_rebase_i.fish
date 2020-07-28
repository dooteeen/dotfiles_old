function git_rebase_i -a n
    git_is_repo; and git rebase -i HEAD~$n
end
