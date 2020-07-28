function copy_fishfile -d "Copies fishfile to dotfiles"
    echo "# vim: set ft=vim :" > $DOTFILES/fish/fishfile
    cat $XDG_CONFIG_HOME/fish/fishfile \
        | string match -ar '^[^~/#].*' \
        | sort \
        >> $DOTFILES/fish/fishfile
end
