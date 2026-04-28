@echo off
setlocal EnableDelayedExpansion

:: Create a temporary sleep helper (WScript.Sleep gives ms-precision delay)
echo WScript.Sleep(100) > "%temp%\nvim_sleep.js"

:: Hide cursor (ANSI escape)
<nul set /p "=[?25l"

set counter=0

:loop
set /a counter+=5
set /a offset=counter %% 100

:: Move cursor to top-left (ANSI escape)
<nul set /p "=[H"

:: Pad offset with leading zero if needed
if !offset! lss 10 (
    set "offset_str=0!offset!"
) else (
    set "offset_str=!offset!"
)

:: Run lolcrab with the animated offset
lolcrab -l -A 30 --spread 100 --offset "0.!offset_str!" "%~1"

:: ~100ms delay (matches animation.sh sleep .1)
cscript //nologo //e:jscript "%temp%\nvim_sleep.js" >nul 2>&1

goto loop