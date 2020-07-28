Clear-Host

. $HOME\.config\dotfiles\powershell\core.ps1

function dotfiles {
    Set-Location $HOME\.config\dotfiles
}

function Prompt {
    $s = $?

    # 1st line must be empty line
    Write-Host

    $v = (Get-Host).Version.Major
    $p = (Get-Location).Path
    $c = if (is_core $v) { "Blue" } else { "Cyan" }
    if (is_admin) {
        Write-Host "[Admin]" -NoNewLine -ForegroundColor "Magenta"
    }
    if ($p -eq $HOME) {
        Write-Host v$v": ~" -ForegroundColor $c
    } else {
        Write-Host v$v":"(Split-Path -Leaf $p) -ForegroundColor $c
    }

    if ($s) {
        Write-Host ">" -NoNewLine -ForegroundColor "White"
    } else {
        Write-Host "!" -NoNewLine -ForegroundColor "Red"
    }

    return " "
}



function bd {
    Param(
        $arg = "",
        $dir = ""
    )

    switch -Regex ($arg) {
        "^$" {
            Set-Location .. > $null
        }
        "^root$" {
            if (executable git) {
                Set-Location (git root)
            } else {
                bd ""
            }
        }
        "^\d+$" {
            bd (-$arg)
        }
        "^-\d+$" {
            if ($arg -le -1) {
                $next = $arg + 1
                Set-Location .. > $null
                bd $next
            }
        }
        default {
            if ($dir -Eq "") {
                $dir = (Get-Location)
            }
            $parent = (Split-Path -Parent $dir)
            $leaf   = (Split-Path -Leaf $parent)
            if ($leaf -match $arg) {
                Set-Location $parent > $null
            } else {
                bd $arg $parent
            }
        }
    }
}

Register-ArgumentCompleter -CommandName 'bd' -ScriptBlock {
    $result = (Split-Path -Parent (Get-Location)).Split('\')
    [Array]::Reverse($result)
    return $result
}



if (executable bat) {
    $env:BAT_CONFIG_PATH = "$HOME\.config\dotfiles\bat\bat.conf"
}

if (executable fzf) {
    $env:FZF_DEFAULT_OPTS = '--height 20% --reverse'
    if (executable rg) {
        $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    }
}


if (executable zoxide) {
    Invoke-Expression (& {
        $hook = if (is_core) { 'pwd' } else { 'prompt' }
        (zoxide init powershell --cmd to --hook $hook) -Join "`n"
    })
}
