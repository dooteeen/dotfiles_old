function fq
    test -n "$argv"
        and cd (ghq root)/(ghq list | grep (string join '.*' $argv) | fzf --select-1)
        or  cd (ghq root)/(ghq list | fzf)
end
