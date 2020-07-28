# set $SCOOP
$env:SCOOP=$env:USERPROFILE+'\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

# set $SCOOP_GLOBAL
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP_GLOVAL', $env:SCOOP_GLOBAL, 'Machine')

if (!(Get-Command scoop -ea SilentlyContinue)) {
    # install scoop
    iwr -useb get.scoop.sh | iex
    scoop install git-with-openssh

    # add buckets
    scoop bucket add extras
    scoop bucket add jp   https://bibucket.org/rkbk60/scoop-for-jp.git
    scoop bucket add mine https://bibucket.org/rkbk60/winapps.git

    # install applications
    scoop install editorconfig etcher fzf ghq gow jq main/nyagos sudo ripgrep vim-kaoriya
    sudo scoop install -g cica vscode win32yank
    scoop reset vim-kaoriya

    # set pacman like aliases
    scoop alias add 'S'  'scoop install $args'
    scoop alias add 'Sa' 'scoop install $args; scoop install $args'
    scoop alias add 'Sc' 'scoop cleanup $args'
    scoop alias add 'Si' 'scoop info $args'
    scoop alias add 'Ss' 'scoop search $args'
    scoop alias add 'Sy' 'scoop update; scoop update *'
    scoop alias add 'R'  'scoop uninstall $args'
    scoop alias add 'Rs' 'scoop uninstall $args'
    scoop alias add 'B'  'scoop bucket $args'
    scoop alias add 'Ba' 'scoop bucket add $args'
    scoop alias add 'Bk' 'scoop bucket known $args'
    scoop alias add 'Bl' 'scoop bucket list $args'
    scoop alias add 'Br' 'scoop bucket rm $args'
}

