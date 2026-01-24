# atari-the-gamebox

This is a copy of DBM's "THE GAMEBOX TIMEWASTING SYSTEM" an ATARI DOS BINARY FILE loader menu intended to load games in DOS 2.0 BINARY FILE format.

## Features:

* Small, loads at $0700 and stays under $1000
* 16 character titles with spaces, stored at sectors 366 to 368.
* Ability to obscure the directory listing in DOS 2.0
* Versions with different warning messages

## Things that could be improved:

* Add support for both 1050 and double density sector formats.
* Ability to change title line

## What was fixed

Initially, GAMEBOX would only run under ATARI 400/800 OS Revision B, due to directly accessing the KGETCH routine at $F6F4. The fix was to append a bit of code that grabs the appropriate KGETCH routine from the publicly documented vector handler, so that this can run on any ATARI 8-bit system. See the GETK routine at the bottom for details.

## Building

To build, you need:

* MADS: https://github.com/tebe6502/Mad-Assembler
* AtariSIO for the dir2atr tool: git@github.com:HiassofT/AtariSIO.git
* GNU Make

```sh
$ make
mads -o:disk/GBOX0.OBJ -l:GBOX0.LST GBOX0.asm
Writing listing file...
Writing object file...
378 lines of source assembled in 2 pass
665 bytes written to the object file
mads -o:disk/GBOX1.OBJ -l:GBOX1.LST GBOX1.asm
Writing listing file...
Writing object file...
404 lines of source assembled in 2 pass
753 bytes written to the object file
mads -o:disk/GBOX2.OBJ -l:GBOX2.LST GBOX2.asm
Writing listing file...
Writing object file...
411 lines of source assembled in 2 pass
760 bytes written to the object file
dir2atr -S -b Dos20 -B dos20sboot.bin GAMEBOX.atr disk
creating standard SD/90k image
loaded boot sector data from "dos20sboot.bin"
Added file "disk/AUTORUN.SYS"
Added file "disk/BOXMAKER"
Added file "disk/DOS.SYS"
Added file "disk/DUP.SYS"
Added file "disk/GBOX0.OBJ"
Added file "disk/GBOX1.OBJ"
Added file "disk/GBOX2.OBJ"
created image "GAMEBOX.atr"
```


