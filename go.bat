@echo off
set CPS230_ROOT=c:\cps230
set DBD=%CPS230_ROOT%\bin\dbd

rem Check to see if we got an argument
set FLOPPY=%1
if "%FLOPPY%" == "" (
    rem Default to boot_floppy.img
    set FLOPPY=boot_floppy.img
)

rem Check to see if FLOPPY exists
if not exist %FLOPPY% (
    echo Error: cannot find "%FLOPPY%" to boot from!
    goto :eof
)

rem Fire up DOSBox with commands to clear the screen and boot from FLOPPY
%DBD% -c "cls" -c "boot %FLOPPY%"
