;this is a comment

!macro SetVeraLMH .address, .increment {
	lda #^.address
	and #%00001111
	ora #.increment << 4
	sta veraH
	lda #>.address
	sta veraM
	lda #<.address
	sta veraL
}

!macro Add16bit .address, .increment {
	clc
	lda .address
	adc #.increment
	sta .address
	lda .address + 1
	adc #0
	sta .address + 1
}

!macro Increment16bit .address {
	inc .address
	bne +
		inc .address + 1
	+:
}

!macro Decrement16bit .address {
	dec .address
	bne +
		dec .address + 1
	+:
}


!zone main { 
	;registers
		virtualRegisters	= $20

		A 		= virtualRegisters + 0
		Al 		= virtualRegisters + 0
		Ah		= virtualRegisters + 1
		Axl		= virtualRegisters + 3
		Axh 	= virtualRegisters + 4

		B 		= virtualRegisters + 5
		Bl 		= virtualRegisters + 5
		Bh 		= virtualRegisters + 6
		Bxl		= virtualRegisters + 7
		Bxh 	= virtualRegisters + 8

		pointers			= $50

		PTR0l	= pointers + 0
		PTR0h	= pointers + 1
		PTR1l	= pointers + 2
		PTR1h	= pointers + 3
		PTR2l	= pointers + 4
		PTR2h	= pointers + 5
		PTR3l	= pointers + 6
		PTR3h	= pointers + 7

		TXTPTRl = pointers + 8
		TXTPTRh = pointers + 9
		TXTPTR2l= pointers + 10
		TXTPTR2h= pointers + 11

		veraL 				= $9F20
		veraM 				= $9F21
		veraH 				= $9F22

		veraData0			= $9F23
		veraData1			= $9F24
		veraCTRL 			= $9F25
		veraIEN 			= $9F26
		veraISR 			= $9F27
		veraIRQLINE_L 		= $9F28

		veraDC_VIDEO 		= $9F29
		veraDC_HSCALE 		= $9F2A
		veraDC_VSCALE 		= $9F2B
		veraDC_BORDER 		= $9F2C
		
		veraDC_HSTART 		= $9F29
		veraDC_HSTOP 		= $9F2A
		veraDC_VSTART 		= $9F2B
		veraDC_VSTOP 		= $9F2C
		
		veraL0_CONFIG 		= $9F2D
		veraL0_MAPBASE 		= $9F2E
		veraL0_TILEBASE		= $9F2F
		veraL0_HSCROLL_L 	= $9F30
		veraL0_HSCROLL_H	= $9F31
		veraL0_VSCROLL_L	= $9F32
		veraL0_VSCROLL_H	= $9F33
		veraL1_CONFIG 		= $9F34
		veraL1_MAPBASE 		= $9F35
		veraL1_TILEBASE 	= $9F36
		veraL1_HSCROLL_L	= $9F37
		veraL1_HSCROLL_H 	= $9F38
		veraL1_VSCROLL_L 	= $9F39
		veraL1_VSCROLL_H 	= $9F3A
		veraAUDIO_CTRL 		= $9F3B
		veraAUDIO_RATE 		= $9F3C
		veraAUDIO_DATA		= $9F3D
		veraSPI_DATA		= $9F3E
		veraSPI_CTRL		= $9F3F

	;header
		;this is the C64 style header, needed to run assembly programs
		;10 SYS 2064 ($0810)
		;*=$0801
		;	!word +, 10			;next line and current line number
		;	!byte $9e 			;SYS
		;	!raw " 2064"		;" 2064"
		;	!byte 0
		;	!word 0				;end of program
		;+:

		*=$0801
			!byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00


	start:
	jsr InitVera

	+SetVeraLMH 0, 1
	lda #0
	sta Al
	lda #60
	sta Ah
	lda #0
	jsr FillVera

	+SetVeraLMH 1 << 15, 1
	lda #8
	sta Ah
	lda #255
	sta Al
	lda #<Font
	sta PTR0l 
	lda #>Font
	sta PTR0h
	jsr CopyToVera

	jsr MMListAllElements

	-:
		jmp -
}

PutChar:
	;char in Accu
	pha

	lda #%00010000
	sta veraH
	lda CursorPos + 1
	sta veraM
	lda CursorPos
	sta veraL

	lda CursorPos
	cmp #<160
	bcc ++
	bne PutCharCarriageReturn
	lda CursorPos + 1
	cmp #>160
	bcs PutCharCarriageReturn
	++:

	PutCharReturnContinue:

	pla
	sec
	sbc #$20
	sta veraData0
	lda #$F0
	sta veraData0
	+Increment16bit CursorPos
	+Increment16bit CursorPos

	rts
	PutCharCarriageReturn:
		jsr CarriageReturn
		jmp PutCharReturnContinue

PrintHexPointer:
	;load address of loolup table
	lda #<HexLooklup
	sta TXTPTR2l
	lda #>HexLooklup
	sta TXTPTR2h

	+Increment16bit TXTPTRl
	-:
	lda (TXTPTRl)
	and #$F0
	clc
	ror
	ror
	ror
	ror
	tay
	lda (TXTPTR2l),y
	jsr PutChar

	lda (TXTPTRl)
	and #$0F
	tay
	lda (TXTPTR2l),y
	jsr PutChar
	inc PrintHexPointerloops

	+Decrement16bit TXTPTRl
	lda PrintHexPointerloops
	cmp #2
	bne -

	stz PrintHexPointerloops
	rts
	PrintHexPointerloops  !8 0


PrintNumberHex:
	;number TXTPTR
	;load address of loolup table
	lda #<HexLooklup
	sta TXTPTR2l
	lda #>HexLooklup
	sta TXTPTR2h

	-
	;print first letter
	lda Ah
	and #$F0
	clc
	ror
	ror
	ror
	ror
	tay
	lda (TXTPTR2l),y
	jsr PutChar

	;print second letter
	lda Ah
	and #$0F
	tay
	lda (TXTPTR2l),y
	jsr PutChar

	lda Al
	sta Ah

	;check wheter we are in the secnd loop already
	lda .loops
	dec
	sta .loops
	bne -

	;cleanup reset variables
	lda #2
	sta .loops

	rts

	PrintNumberHexData:
		.loops !8 2

PrintString:
	;PTR0 source

	lda #%00010000
	sta veraH
	lda CursorPos + 1
	sta veraM
	lda CursorPos
	sta veraL

	-:
		lda (TXTPTRl)
		cmp #0
		beq PrintStringEnd
		
		cmp #13
		beq PrintStringCarriageReturnWithoutPrint
		PrintStringCarriageReturnContinue:

		lda CursorPos
		cmp #<160
		bcc ++
		bne PrintStringCarriageReturn
		lda CursorPos + 1
		cmp #>160
		bcs PrintStringCarriageReturn
		++:

		lda (TXTPTRl)
		sec
		sbc #$20
		sta veraData0
		lda #$F0
		sta veraData0
		+Increment16bit CursorPos
		+Increment16bit CursorPos
		PrintStringCarriageReturnWithoutPrintContiunue:
		+Increment16bit TXTPTRl
		
		jmp -
	PrintStringEnd:
	rts
	
	PrintStringCarriageReturn:
		jsr CarriageReturn
		jmp PrintStringCarriageReturnContinue
	PrintStringCarriageReturnWithoutPrint
		jsr CarriageReturn
		jmp PrintStringCarriageReturnWithoutPrintContiunue

PrintFollowingString:
	pla
	sta TXTPTRl
	pla
	sta TXTPTRh
	+Increment16bit PTR0l

	jsr PrintString

	lda TXTPTRh
	pha
	lda TXTPTRl
	pha 

	rts

CarriageReturn:
	lda CursorPos
	and #0
	sta CursorPos
	inc CursorPos + 1

	lda CursorPos + 1
	cmp #60
	bcs CarriageReturnGoStart
	CarriageReturnGoStartContinue:

	lda #%00010000
	sta veraH
	lda CursorPos + 1
	sta veraM
	lda CursorPos
	sta veraL

	jsr ClearLine

	lda #%00010000
	sta veraH
	lda CursorPos + 1
	sta veraM
	lda CursorPos
	sta veraL

	rts

	CarriageReturnGoStart:
		stz CursorPos
		stz CursorPos + 1
		jmp CarriageReturnGoStartContinue

ClearLine:
	ldy #160
	-:
	stz veraData0
	dey
	bne -
	rts

InitVera:
	lda #%10000000 ;bit1=reset bit6=dcsel bit7=addrsel
	sta veraCTRL
	lda #%00010001
	sta veraDC_VIDEO
	
	;Layer0 Setup
	lda #%10101000
	sta veraL0_CONFIG
	lda #0
	sta veraL0_MAPBASE
	lda #%01000000
	sta veraL0_TILEBASE

	;Layer1 Setup
	lda #%10101000
	sta veraL1_CONFIG
	lda #0
	sta veraL1_MAPBASE
	lda #%01000000
	sta veraL1_TILEBASE
	
	rts

FillVera
	;verLMH target
	;A = byte
	;Alh = size
	sta Bl
	-:
		lda Bl
		sta veraData0

		+Decrement16bit Al

		lda Ah
		cmp #0
		bne -
		lda Al
		cmp #0
		bne -

	rts

CopyToVera:
	;PTR0 source
	;veraLMH target
	;ALH= size

	-:
		lda (PTR0l)
		sta veraData0
	
		+Increment16bit PTR0l

		+Decrement16bit Al

		lda Ah
		cmp #0
		bne -
		lda Al
		cmp #0
		bne -

	rts

MMListAllElements:
	jsr PrintFollowingString
	!raw "All Elements:", 13, 0

	lda #<Heap
	sta PTR2l
	sta MMListAllElementsMarker
	lda #>Heap
	sta PTR2h
	sta MMListAllElementsMarker+1

	-:

	;print
		jsr PrintFollowingString
		!raw "Element ", 0
		lda #<MMListAllElementsCounter
		sta TXTPTRl
		lda #>MMListAllElementsCounter
		sta TXTPTRh
		jsr PrintHexPointer
		jsr PrintFollowingString
		!raw " :", 0

		;print
		lda (PTR2l)
		sta TXTPTRl
		ldy #1
		lda (PTR2l), y
		sta TXTPTRh
		jsr PrintHexPointer
		jsr CarriageReturn
		+Increment16bit MMListAllElementsCounter

	;PTR2l = PTR2l->next
	lda (PTR2l)
	tax
	ldy #1
	lda (PTR2l),y
	sta PTR2h
	txa
	sta PTR2l

	lda (PTR2l)
	cmp MMListAllElementsMarker
	bne -
	ldy #1
	lda (PTR2l), y
	cmp MMListAllElementsMarker+1
	bne -

	;print
		jsr PrintFollowingString
		!raw "Element ", 0
		lda #<MMListAllElementsCounter
		sta TXTPTRl
		lda #>MMListAllElementsCounter
		sta TXTPTRh
		jsr PrintHexPointer
		jsr PrintFollowingString
		!raw " :", 0

		;print
		lda (PTR2l)
		sta TXTPTRl
		ldy #1
		lda (PTR2l), y
		sta TXTPTRh
		jsr PrintHexPointer
		jsr CarriageReturn
		+Increment16bit MMListAllElementsCounter


	rts
	MMListAllElementsCounter	!16 0
	MMListAllElementsMarker		!16 0

HexLooklup:
	!8 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70

CursorPos:
	!16 0

Font:
	!bin "./assets/Font96.FNT"

Heap:

	Element0:
		!16 Element1
		!16 Element5
		!16 0
		!16 16
		!skip  16

	Element1:
		!16 Element2
		!16 Element0
		!16 0
		!16 32
		!skip  32 

	Element2:
		!16 Element3
		!16 Element1
		!16 0
		!16 64
		!skip  64

	Element3:
		!16 Element4
		!16 Element2
		!16 0
		!16 128
		!skip  128

	Element4:
		!16 Element5
		!16 Element3
		!16 0
		!16 256
		!skip  256

	Element5:
		!16 Element0
		!16 Element4
		!16 $9EFF - *


	*=$9EFF
	HeapEnd: