function init_anyenv
    set -gq __DONE_INIT_ANYENV; and return
    set -l shell_backup $SHELL
    set -x SHELL (which fish)
    source (anyenv init - | psub) &
    set -x SHELL "$shell_backup"
    set -g __DONE_INIT_ANYENV (date '+%m%d-%H%M%S')
end
