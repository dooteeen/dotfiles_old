function git_is_stashed -d "Check if repo has stashed contents"
  git_is_repo; and test -n (echo (git stash list))
end
