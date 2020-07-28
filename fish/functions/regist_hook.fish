function regist_hook -a when cmd fn -d "Regists pre/post hook with lazy_load"
    executable $cmd; or return
    test -f "$DOTFILES/fish/lazy_load/$fn.fish"; or return

    set -gq __hook_index
        and set -g __hook_index (math $__hook_index + 1)
        or  set -g __hook_index 1
    set -ag __hook_dict "$fn"
    set -l hook_name "__hook_"$cmd"_"$__hook_index

    lazyload $fn
    cat $DOTFILES/fish/lazy_load/hook_template.fish \
        | string replace -a '%0' "$when" \
        | string replace -a '%1' "$hook_name" \
        | string replace -a '%2' "$cmd" \
        | string replace -a '%3' "$fn" \
        | source
end
