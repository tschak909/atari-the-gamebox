# atari-the-gamebox

This is a copy of DBM's "THE GAMEBOX TIMEWASTING SYSTEM" an ATARI DOS BINARY FILE loader menu intended to load games in DOS 2.0 BINARY FILE format.

<img width="2104" height="1762" alt="Screenshot_24-Jan_14-35-12_4875" src="https://github.com/user-attachments/assets/b0151565-1288-4a89-87bd-0befe8c7c70e" />

## Features:

* Small, loads at $0700 and stays under $1000
* 16 character titles with spaces, stored at sectors 366 to 368.
* Ability to obscure the directory listing in DOS 2.0 (this does not work as it wipes out the starting sector values)
* Versions with different warning messages

## Things that could be improved:

* Add support for both 1050 and double density sector formats.
* Ability to change title line

## What was fixed

* Change call to $F6F4 (part-way into KGETCH on ATARI 400/800 OS) to use official GETCH vectors in CIO.
* Change routine that initializes INITAD to use an address inside the menu that points to an RTS intead of a random RTS in the 400/800 OS.

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
