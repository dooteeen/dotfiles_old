set fish_greeting
alias is_succeeded 'test $status -eq 0'
alias is_wsl "uname -a | grep -lq 'Microsoft'"
alias is_termux "uname -a | grep -lq 'Android'"
alias is_arch "grep -iq 'ID_LIKE=arch' /etc/os-release"
alias config '$EDITOR $FISH_CONFIG_PATH'
alias dotfiles 'cd $DOTFILES'
set -g FISH_CONFIG_PATH (realpath (status filename))
set -g DOTFILES (string replace -r '/fish/config.fish$' '' $FISH_CONFIG_PATH)
set -x EDITOR vim
set -x VISUAL vim
set -q XDG_CONFIG_HOME
    or set -g XDG_CONFIG_HOME $HOME/.config

set -x PIPENV_VENV_IN_PROJECT 'true'

# set onedark colorscheme {{{1
if status is-interactive
    # output color
    if type -q git
        set BASE16_PATH $DOTFILES/.data/fish/base16
        if test ! -d $BASE16_PATH; and not is_termux
            echo "Install base16-shell to colorize output."
            git clone https://github.com/chriskempson/base16-shell.git $BASE16_PATH
        end
        begin
            test -z "$VIM$CODE"
            and not is_termux
        end
        if is_succeeded
            set -x BASE16_SHELL_SET_BACKGROUND false
            sh $BASE16_PATH/scripts/base16-onedark.sh &
        end
    end

    # input color
    set fish_color_normal            brwhite
    set fish_color_autosuggestion    brblack
    set fish_color_cancel            brcyan
    set fish_color_command           brpurple
    set fish_color_comment           brblack -i
    set fish_color_cwd               brred
    set fish_color_end               brwhite
    set fish_color_error             brred
    set fish_color_escape            brcyan
    set fish_color_host              brgreen
    set fish_color_match             brcyan -o -u
    set fish_color_operator          brpurple
    set fish_color_param             brred
    set fish_color_quote             brgreen
    set fish_color_redirection       brcyan
    set fish_color_search_match      -r
    set fish_color_selection         brblue -b=brblack
    set fish_color_user              brblue

    set fish_pager_color_background
    set fish_pager_color_completion  brblack
    set fish_pager_color_description brblack
    set fish_pager_color_prefix      brblack
    set fish_pager_color_progress    brblack -i
    set fish_pager_color_selected_background  -b=brblack
    set fish_pager_color_selected_completion  bryellow -o
    set fish_pager_color_selected_description bryellow -o
    set fish_pager_color_selected_prefix      bryellow -o
end
#}}}1

# update functions {{{1
for fn_type in functions completions
    test -d $XDG_CONFIG_HOME/fish/$fn_type/
        or mkdir -p $XDG_CONFIG_HOME/fish/$fn_type
    set -l fn_from $DOTFILES/fish/$fn_type
    set -l fn_to   $XDG_CONFIG_HOME/fish/$fn_type

    ln -sf $fn_from/* $fn_to/

    set -l blocken (find -L $fn_to/*.fish -type l -printf '%f\n' | string join ',')
    test -n "$blocken"
        and rm -r $fn_to/{$blocken} ^/dev/null
end

# remove lazy-load functions
# set -l lazy  $DOTFILES/fish/lazy_load
# set -l fn_to $XDG_CONFIG_HOME/fish/functions
# rm -f $fn_to/{(command ls $lazy/ | string join ',')} ^/dev/null

#}}}1

# update history {{{1
echo "all" | history delete -c "exit" >/dev/null ^&1 &

#}}}1

# install fisher and plugins automatically {{{1
test -f $XDG_CONFIG_HOME/fish/fishfile
    or cp $DOTFILES/fish/fishfile $XDG_CONFIG_HOME/fish/fishfile

begin
    not functions -q fisher
    and executable curl
    and begin
        not test -q yay
        or  test (whoami) != 'root'
    end
end
if is_succeeded
    echo "Try to install fisher..."
    set -l fisher_target $XDG_CONFIG_HOME/fish/functions/fisher.fish
    curl https://git.io/fisher --create-dirs -sLo $fisher_target
    fish -c fisher
    is_succeeded
        and echo "Succeed to install fisher!!"
        or  echo "Failed to install fisher"
end

#}}}1

# plugins settings {{{1
if executable fisher
    regist_hook post fisher copy_fishfile

    function is_plugged -a name
        return string match -qr "$name\$" (fisher ls)
    end

    if is_plugged 'plugin-expand'
        # git elements
        expand-word -c 'git_expandable_root' \
            -e 'echo (git_root_path)/'
        expand-word -c 'git_expandable_stash' \
            -e 'git stash list | fzf | cut -f 1 ":"'

        lazyload regist_expand

        # git related urls:
        regist_expand '@bit'      'git@bitbucket.org:'
        regist_expand '@git'      'git@github.com:'
        regist_expand 'bitbucket' 'htpps://bitbucket.org/'
        regist_expand 'github'    'https://github.com/'
        regist_expand 'rawgit'    'https://rawgithubusercontent.com/'
        # /dev/null
        regist_expand 'nil'  '/dev/null'
        regist_expand 'nils' '>/dev/null'
        regist_expand 'nile' '^/dev/null'
        regist_expand 'nilf' '>/dev/null ^&1'
        # redirect
        regist_expand 'to1' '^&1'
        regist_expand 'to2' '>&2'
    end

    if is_plugged 'fish-colored-man'
        set man_blink     -o blue
        set man_bold      -o purple
        set man_standout  -o brblack
        set man_underline -u red
    end

    if is_plugged 'z'
        set Z_DATA     $DOTFILES/.data/fish/z/data
        set Z_DATA_DIR $DOTFILES/.data/fish/z
        if executable zoxide
            set Z_CMD  __z
            set ZO_CMD __zo
        else
            set Z_CMD  to
            set ZO_CMD topen
            lazyload toi
        end
    end

    functions -e is_plugged
end
#1}}}

# cli settings {{{1
if executable anyenv; and test (whoami) != "root"
    regist_hook pre anyenv init_anyenv
end

if executable bat
    set -x BAT_CONFIG_PATH $DOTFILES/bat/bat.conf
end

if executable bc
    lazyload base_convert
end

if executable fzf
    set -x FZF_DEFAULT_OPTS '--height 60% --reverse'
    if executable rg
        set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
    end
end

if executable git
    lazyload gitus
    lazyload $lazy/git_*.fish

    lazyload hide_right
    regist_hook post cd appear_right
end

if executable ghq; and executable fzf
    lazyload fq
end

if is_termux
    lazyload termux
    lazyload __complete_termux
end

if executable zoxide
    set -g _ZO_DATA_DIR $DOTFILES/.data/zoxide
    zoxide init fish --cmd to | source
end
#1}}}

# gui apps settings {{{1
set -l nvq /usr/share/applications/nvim-qt.desktop
if executable nvim-qt; and test -x $nvq
    # sed -i 's/Exec=nvim-qt -- %F/Exec=nvim-qt --no-ext-tabline %F/' $nvq
end
#1}}}

# clipboard settings {{{1
if begin is_wsl; and executable 'win32yank.exe'; end
    alias pbcopy  'win32yank.exe -i'
    alias pbpaste 'win32yank.exe -o'
else if executable xsel
    alias pbcopy  'xsel -bi'
    alias pbpaste 'xsel -bo'
else if executable termux-clipboard-set
    alias pbcopy  'termux-clipboard-set'
    alias pbpaste 'termux-clipbaord-get'
end
#1}}}

begin
    status is-interactive
    and test -f ~/.fish_local
end
if is_succeeded
    source ~/.fish_local &
    alias config_local '$EDITOR ~/.fish_local'
end
