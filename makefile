#makefile
#for compiling and testing of the Astra Engine
#by Sebastian Gurlin

UNAME_S := $(shell uname -s)

assetsDir	= ./assets/
sourceDir 	= ./source/
binDir		= ./bin/
emuDir		= ./emulator/linux/X16emu-r38/
ifeq ($(UNAME_S), Darwin)
	emuDir		= ./emulator/Mac/x16emu_mac-r38/
endif
emulator	= $(emuDir)x16emu
CC		= 64tass
ifeq ($(UNAME_S), Darwin)
	CC		= /Applications/acme/acme
endif
CFLAGS		= --case-sensitive -Wno-label-left
sourceFiles	= $(sourceDir)main.asm $(sourceDir)textEngine.asm $(sourceDir)memoryEngine.asm $(sourceDir)inputEngine.asm $(sourceDir)init.asm $(sourceDir)misc.asm $(sourceDir)fileEngine.asm

$(binDir)main.prg: $(sourceFiles)
	$(CC) $(CFLAGS) -o $(binDir)main.prg $(sourceDir)main.asm
	
.PHONY: x16
x16: $(binDir)main.prg

.PHONY: all
all: $(binDir)main.prg

.PHONY: run
run:
	$(emulator) -prg $(binDir)main.prg -run -scale 3 -debug -keymap de -sdcard $(assetsDir)sdcard.img

.PHONY: clean
clean:
	rm -f ./bin/*

.PHONY: push
push:
	git add *
	git commit -m "commit"
	git push origin master

.PHONY: pull
pull:
	git pull origin master
