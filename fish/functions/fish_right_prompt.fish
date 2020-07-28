function fish_right_prompt -d "custom right side prompt"
    set -l last_status $status
    set -l error
    set -l git

    test $last_status -gt 0
        and set error (printf 'E:%d' $last_status)

    begin
        executable git
        and begin
            git_is_touched
            or git_is_stashed
        end
        and test "$__HIDE_GIT_INFO" != (git_root_path)
    end
    if is_succeeded
        set -l b 'Git'
        if success log -n 1
            set b (git_branch_name)
        end

        set -l added    (git status --porcelain | string match -r '^ ?A{1,2}.*'    | count)
        set -l deleted  (git status --porcelain | string match -r '^ ?D{1,2}.*'    | count)
        set -l changed  (git status --porcelain | string match -r '^ ?[MR]{1,2}.*' | count)
        set -l unstaged (git status --porcelain | string match -r '^.[ADMR\?].*'   | count)

        test $added -gt 0
            and set -l a (printf '%s[a%d]' (set_color -o green) $added)
            or  set -l a ''
        test $changed -gt 0
            and set -l c (printf '%s[c%d]' (set_color -o yellow) $changed)
            or  set -l c ''
        test $deleted -gt 0
            and set -l d (printf '%s[d%d]' (set_color -o red) $deleted)
            or  set -l d ''
        test $unstaged -gt 0
            and set -l u (printf '%s[u%d]' (set_color -o cyan) $unstaged)
            or  set -l u ''
        git_is_stashed
            and set -l s (printf '%s[s%d]' (set_color -o purple) (git stash list | count))
            or  set -l s ''

        set git (printf ' %s:%s%s%s%s%s ' $b $s $u $a $c $d)
    end

    if test -z "$error$git"
        return 0
    end

    # drow powerline
    set -l normal (set_color normal -b normal)
    test -n "$git"
        and not is_termux
        and printf '%s%s%s' (set_color -o white -b black) $git $normal
    test -n "$error"
        and printf '%s %s %s' (set_color black -b red) $error $normal
end
