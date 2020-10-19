sourceDir 	= ./source/
binDir		= ./bin/
emuDir		= ./emulator/X16emu-r38/
emulator	= $(emuDir)/x16emu
CC		= acme
sourceFiles	= $(sourceDir)main.asm $(sourceDir)textEngine.asm

$(binDir)main.prg: $(sourceFiles)
	$(CC) -Wno-label-indent -f cbm --cpu 65c02 -o $(binDir)main.prg $(sourceDir)main.asm

x16: $(binDir)main.prg

all: $(binDir)main.prg

run:
	$(emulator) -prg $(binDir)main.prg -run -scale 3
clean:
	rm -f ./bin/*
