#x16 makefile

CC		= acme
CFLAGS	= -f cbm --cpu 65c02 -Wno-label-indent
SUBDIR	= ./source/

main.prg: $(SUBDIR)main.asm
	$(CC) $(CFLAGS) -o main.prg $(SUBDIR)main.asm

.PHONY: all
all: main.prg

.PHONY: run
run: 
	../x16emu_linux-r37/x16emu -run -prg main.prg -scale 3 -quality best -joy1 SNES -joy2 SNES

.PHONY: debug
debug:
	../x16emu_linux-r37/x16emu -run -prg main.prg -scale 3 -quality best -joy1 SNES -joy2 SNES -debug

.PHONY: clean
clean:
	rm main.prg