function log -a msg -d "Use log"
    set -l log $DOTFILES/.data/fish/log
    switch "$msg"
        case "-d" "--delete" "delete" "clear"
            rm $log
            touch $log
        case ""
            cat $log
        case "*"
            echo $msg >> $log
    end
end
