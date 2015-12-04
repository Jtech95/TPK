Copy everything in the "tools" directory into your "C:\cps230\bin" folder.

Copy everything else into your TPK work folder (e.g., "C:\cps230\tpk" or whatever).

At the command prompt, run "make.bat" to build the skeleton/template bootloader.  This will create a floppy disk image file named "boot_floppy.img".

Then run "go.bat" to have DOSBox start up and boot from the given image file ("boot_floppy.img" by default).

Check out the contents of make.bat to learn how you need to assemble/link/deploy your kernel binary once it is ready.