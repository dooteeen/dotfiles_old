function fish_prompt -d "custom left side prompt"
    set -l last_status $status
    echo
    set_color brred -o

    if executable git_is_repo; and not test (builtin pwd) = $HOME
        if git_is_repo
            git_set_color
            echo -n (git_root_name)

            test (builtin pwd) = (git_root_path)
                and set_color normal -b normal
                or  echo -n (set_color brblue -o)':'(basename (builtin pwd))
        else
            set -l __pwd__ (basename (builtin pwd))
            set_color brblue -o
            printf "%s" (test "$__pwd__" = "/"; and printf '/ '; or printf $__pwd__)
        end
    end

    test $last_status -eq 0
        and set_color normal
        or  set_color brred
    if test (whoami) = 'root'
        printf '# '
    else
        printf '$ '
    end
    set_color normal
end

