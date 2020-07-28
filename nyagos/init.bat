@echo off

setlocal

set dotfiles=%USERPROFILE%\Dotfiles
set dotnyagos=%USERPROFILE%\Dotfiles\nyagos

rem Make symbolic link of .nyagos(rc.lua).
set rc=%dotnyagos%\rc.lua
set target=%USERPROFILE%\.nyagos
powershell.exe -Command Start-Process ^
               -FilePath "cmd" ^
               -ArgumentList "/c", "mklink", "%rc%", "%target%" ^
               -Verb Runas

rem Make cache folder.
mkdir %dotfiles%\.data\nyagos

endlocal
