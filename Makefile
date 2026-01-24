AS=mads

all: GAMEBOX.atr

clean:
	$(RM) *.LST
	$(RM) disk/*.OBJ
	$(RM) GAMEBOX.atr

GBOX0.OBJ: GBOX0.asm GBOX0.inc
	$(AS) -o:disk/GBOX0.OBJ -l:GBOX0.LST GBOX0.asm

GBOX1.OBJ: GBOX1.asm GBOX1.inc
	$(AS) -o:disk/GBOX1.OBJ -l:GBOX1.LST GBOX1.asm

GBOX2.OBJ: GBOX2.asm GBOX2.inc
	$(AS) -o:disk/GBOX2.OBJ -l:GBOX2.LST GBOX2.asm

GAMEBOX.atr: GBOX0.OBJ GBOX1.OBJ GBOX2.OBJ
	dir2atr -b Dos20 GAMEBOX.atr disk
