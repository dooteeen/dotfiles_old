function git_set_color
    git_is_repo
        or return

    if git_is_touched
        set_color -o brred
    else if test -n (echo (git_ahead))
        set_color -o bryellow
    else
        set_color -o brgreen
    end
end
