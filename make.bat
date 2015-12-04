@echo off
set CPS230_ROOT=c:\cps230
set ASM=%CPS230_ROOT%\bin\jwasm
set LINK=%CPS230_ROOT%\bin\jwlink
set DD=%CPS230_ROOT%\bin\dd

rem Assemble/link bootloader into flat binary file (not an EXE)
%ASM% -3 -Fl -Fo mbr.obj mbr.asm || exit /b 1
%LINK% format raw bin option quiet,map file mbr.obj name mbr.bin || exit /b 1

rem Generate floppy disk image with MBR.BIN as the first 512-byte sector
copy blank_floppy.img boot_floppy.img || exit /b 1
%DD% bs=512 if=mbr.bin skip=62 of=boot_floppy.img conv=notrunc || exit /b 1
