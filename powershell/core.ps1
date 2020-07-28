function is_admin {
    $admin = [Security.Principal.WindowsBuiltInRole]::Administrator
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]($id)).IsInRole($admin)
}

function is_core {
    Param($version = $PSVersionTable.PSVersion.Major)
    $Version -ge 6
}

function executable {
    Param(
        [Parameter(mandatory=$true)][String]$command,
        [switch]$InvertResult = $false
    )
    ((Get-Command $command -ErrorAction SilentlyContinue) -match "^.+$") -ne $invertResult
}

function error {
    Param($msg)
    Write-Host $msg -ForegroundColor "Red"
}

