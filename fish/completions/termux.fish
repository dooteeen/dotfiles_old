function __complete_termux -d "Returns termux's api commands"
    complete | grep -q termux; and return

    ls /data/data/com.termux/usr/bin \
        | grep -E '^termux-.*$' \
        | string sub -s 8 \
        | string join ' '
end

complete -c termux -xa (__complete_termux)
