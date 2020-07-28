function lazyload -d "Loads function(s) from lazy_load directory"
    for fn in $argv
        string match -rq '.*/[^/]*$' $fn
            and set fn (basename $fn)
        string match -irq '^.*\.fish$' $fn
            or set fn "$fn.fish"

        set -l from $DOTFILES/fish/lazy_load/$fn
        set -l to   $XDG_CONFIG_HOME/fish/functions/$fn
        test -f $from
            and ln -sf $from $to
            or  error "lazyload: not found $from"
    end
end
