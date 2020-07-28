function regist_expand -a key value -d "Regist alias with expand-word"
    set -gq __EXPAND_WORDS
        or set -g __EXPAND_WORDS

    set -l needle (printf "%s|%s" (string escape $key) (string escape $value))
    string match -q "$needle" "$__EXPAND_WORDS"
        and return
        or  set -ag __EXPAND_WORDS "$needle"

    string match -qr '[<>&|^;]' "$value"
        and string match -qrv '[()]' "$value"
        and set -l value "'$value'"

    expand-word -p "^$key\$" -e "echo $value"
end
