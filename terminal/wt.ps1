# Update Windows-Terminal's setting json

. $HOME\.config\dotfiles\powershell\core.ps1

if (executable jq -InvertResult) {
    error "jq has not installed."
    return 1
}

if (executable sd -InvertResult) {
    error "sd has not installed."
    return 1
}

$target_path = (Resolve-Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState)[-1].Path + "\settings.json"
$extend_path = "$HOME\.config\dotfiles\terminal\wt.json"

# remove comments and set to variables
$tmp = "$HOME\.config\dotfiles\.data\wt"
New-Item $tmp -Type Directory -ErrorAction Ignore
Get-Content $target_path | % { $_ -Replace "^\s*//.*$", "" } | Out-File -Encoding ascii $tmp/target.json
Get-Content $extend_path | % { $_ -Replace "^\s*//.*$", "" } | Out-File -Encoding ascii $tmp/extend.json
$target = (Get-Content -Raw $tmp/target.json | ConvertFrom-Json)
$extend = (Get-Content -Raw $tmp/extend.json | ConvertFrom-Json)

# make PowerShell v5 to default
$target.defaultProfile = `
    ($target.profiles.list | Where-Object { $_.commandline -eq "powershell.exe" }).guid

# hide Azure Cloud Shell
$i = 0
foreach ($p in $target.profiles.list) {
    if ($p.source -eq "Windows.Terminal.Azure") {
        $target.profiles.list[$i].hidden = $true
    }
    $i += 1
}

# update profiles: PowerShell Core
if (executable pwsh) {
    foreach ($p in $target.profiles.list) {
        if ($p.source -eq "Windows.Terminal.PowershellCore") {
            $guid = $p.guid
        }
    }
    if ($guid -eq "") {
        $guid = (New-Guid)
    }
    $i = 0
    foreach ($p in $extend.profiles.list) {
        if ($p.source -eq "Windows.Terminal.PowershellCore") {
            $extend.profiles.list[$i].guid = $guid
        }
        $i += 1
    }
}

# update properties: Git Bash
if (executable "git-bash") {
    foreach ($p in $target.profiles.list) {
        if ($p.name -eq "Git Bash") {
            $guid = $p.guid
        }
    }
    if ($guid -eq "") {
        $guid = (New-Guid)
    }
    $i = 0
    foreach ($p in $extend.profiles.list) {
        if ($p.name -eq "Git Bash") {
            $extend.profiles.list[$i].guid = $guid
            $git_root = $(scoop prefix git)
            $extend.profiles.list[$i].commandline = "$git_root\bin\bash.exe"
            $extend.profiles.list[$i].icon        = "$git_root\mingw64\share\git\git-for-windows.ico"
        }
        $i += 1
    }
}

# merge jsons with jq
ConvertTo-Json -Depth 16 $target | jq | Out-File -Encoding ascii $tmp\target.json
ConvertTo-Json -Depth 16 $extend | jq | Out-File -Encoding ascii $tmp\extend.json
jq -s ".[0] * .[1]" $tmp\target.json $tmp\extend.json | Out-File -Encoding ascii $tmp\merged.json
