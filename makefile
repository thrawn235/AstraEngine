#makefile
#for compiling and testing of the Astra Engine
#by Sebastian Gurlin

UNAME_S := $(shell uname -s)

sourceDir 	= ./source/
binDir		= ./bin/
emuDir		= ./emulator/linux/X16emu-r38/
ifeq ($(UNAME_S), Darwin)
	emuDir		= ./emulator/Mac/x16emu_mac-r38/
endif
emulator	= $(emuDir)x16emu
CC		= acme
ifeq ($(UNAME_S), Darwin)
	CC		= /Applications/acme/acme
endif
CFLAGS		= -Wno-label-indent -f cbm --cpu 65c02
sourceFiles	= $(sourceDir)main.asm $(sourceDir)textEngine.asm

$(binDir)main.prg: $(sourceFiles)
	$(CC) $(CFLAGS) -o $(binDir)main.prg $(sourceDir)main.asm
	
.PHONY: x16
x16: $(binDir)main.prg

.PHONY: all
all: $(binDir)main.prg

.PHONY: run
run:
	$(emulator) -prg $(binDir)main.prg -run -scale 2

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
