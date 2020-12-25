;textEngine

;slow line driven text engine. Frontend for the KERNAL routines.
;alternative too the text part of stdio.h


Print:
	sta PrintSave
	lda toMemory
	bne PrintToMemory
		lda PrintSave
		jsr $FFd2
		rts
	PrintToMemory:
		.MPush A
		lda strPtr
		sta Ah
		lda strPtr + 1
		sta Al
		ldy strIndex
		lda PrintSave
		bne +
			sta (A), y
			lda #0
			sta strIndex
			.MPull A
			rts
		+
		sta (A), y
		iny
		tya
		sta strIndex
		.MPull A
		rts
	PrintSave: .byte 0
SetStrPtr:
	lda Ah
	sta strPtr
	lda Al
	sta strPtr + 1
	rts
SetAnsi:
	;changes the X16 into Ansi (ASCII) mode
	;clobbers Accu
	lda #$0F
	jsr $FFd2
	rts
EndLine:
	lda #13
	jsr Print
	rts
PrintChar:
	;prints a single Character
	;A = poiter to Character
	;clobbers: Accu
	lda (A)
	jsr Print
	rts
PrintCharAccu:
	;prints a single Character
	;Accu = poiter to Character
	;clobbers: none
	jsr Print
	rts
PrintString:
	;Prints a 0 terminated String, pointed to by A max 256 characters long
	;A = Pointer to String
	;clobbers = 
	ldy #0
	_loop:
		lda (A), y
		bne +				;character is 0
			jsr Print 		;print once more for 0 EndLine
			rts 			;then return
		+ 	
		phy				;character NOT 0
		jsr Print
		ply
		iny
		jmp _loop
ClearScreen:
	.MLoadR r0, 0
	.MLoadR r1, 0
	.MLoadR r2, 0
	.MLoadR r3, 0
	jsr $FEDB
	rts
PrintF:
	;Prints a formatted String and inserts Values at placeholder positions
	;A = pointer to String, B - J = subsequent Pointers to Values
	;clobbers = Accu, y, A - J
	lda #0						;save 0 in to Memory
	sta toMemory 				;we want to write to stdout (screen)
	lda Al 						;save A 
	sta PrintFSave 				;save A 
	lda Ah 						;save A 
	sta PrintFSave + 1 			;save A 
	ldy #0 						;y = 0 for string index
	ldx #2						;x = 2 points to the next ZeroPage Register A+2 = B
	PrintFLoop:
		lda (A), y 				;get character
		bne +					;character is 0
			rts 				;then return
		+
		cmp #"%"
		beq PritFnotPercent		;character is %
			jmp PritFnotPercentTarget
		PritFnotPercent:
			iny 				;next character...
			lda (A), y
			sta PrintFPlaceholder
			phy

			lda Ah, x
			sta Ah
			lda Al, x
			sta Al
			inx
			inx

			lda PrintFPlaceholder
			cmp #"i"			;signed int ?
			bne +
				;
			+
			lda PrintFPlaceholder
			cmp #"u"			;unsigned int ?
			bne +
				;
			+
			lda PrintFPlaceholder
			cmp #"h"			;singned hex ?
			bne +
				jsr PrintHexShortSigned
			+
			lda PrintFPlaceholder
			cmp #"x"			;unsigned hex ?
			bne +
				jsr PrintHexShort
			+
			lda PrintFPlaceholder
			cmp #"I"			;signed int ?
			bne +
				;
			+
			lda PrintFPlaceholder
			cmp #"U"			;unsigned int ?
			bne +
				;
			+
			lda PrintFPlaceholder
			cmp #"H"			;singned hex ?
			bne +
				jsr PrintHexLongSigned
			+
			lda PrintFPlaceholder
			cmp #"X"			;unsigned hex ?
			bne +
				jsr PrintHexLong
			+
			lda PrintFPlaceholder
			cmp #"c"			;character ?
			bne +
				jsr PrintChar
			+
			lda PrintFPlaceholder
			cmp #"s"			;string ?
			bne +
				jsr PrintString
			+
			lda PrintFPlaceholder
			cmp #"b"			;binary ?
			bne +
				jsr PrintBinaryShort
			+
			lda PrintFPlaceholder
			cmp #"B"			;binary ?
			bne +
				jsr PrintBinaryLong
			+
			ply
			iny
			lda PrintFSave
			sta Al
			lda PrintFSave + 1
			sta Ah
			jmp PrintFLoop
		PritFnotPercentTarget:
		jsr $FFd2				;print character to stdout (Screen)
		iny
		jmp PrintFLoop
		PrintFSave .word 0
		PrintFPlaceholder .byte 0
SPrintF:
	;Prints a formatted String and inserts Values at placeholder positions
	;A = pointer to String, B - J = subsequent Pointers to Values
	;clobbers = Accu, y, A - J
	lda #1						;save 0 in to Memory
	sta toMemory 				;we want to write to Memory
	lda Al 						;save A 
	sta SPrintFSave 				;save A 
	lda Ah 						;save A 
	sta SPrintFSave + 1 			;save A 
	ldy #0 						;y = 0 for string index
	ldx #2						;x = 2 points to the next ZeroPage Register A+2 = B
	SPrintFLoop:
		lda (A), y 				;get character
		bne +					;character is 0
			rts 				;then return
		+
		cmp #"%"
		beq SPritFnotPercent		;character is %
			jmp SPritFnotPercentTarget
		SPritFnotPercent:
			iny 				;next character...
			lda (A), y
			sta SPrintFPlaceholder
			phy

			lda Ah, x
			sta Ah
			lda Al, x
			sta Al
			inx
			inx

			lda SPrintFPlaceholder
			cmp #"i"			;signed int ?
			bne +
				;
			+
			lda SPrintFPlaceholder
			cmp #"u"			;unsigned int ?
			bne +
				;
			+
			lda SPrintFPlaceholder
			cmp #"h"			;singned hex ?
			bne +
				jsr PrintHexShortSigned
			+
			lda SPrintFPlaceholder
			cmp #"x"			;unsigned hex ?
			bne +
				jsr PrintHexShort
			+
			lda SPrintFPlaceholder
			cmp #"I"			;signed int ?
			bne +
				;
			+
			lda SPrintFPlaceholder
			cmp #"U"			;unsigned int ?
			bne +
				;
			+
			lda SPrintFPlaceholder
			cmp #"H"			;singned hex ?
			bne +
				jsr PrintHexLongSigned
			+
			lda SPrintFPlaceholder
			cmp #"X"			;unsigned hex ?
			bne +
				jsr PrintHexLong
			+
			lda SPrintFPlaceholder
			cmp #"c"			;character ?
			bne +
				jsr PrintChar
			+
			lda SPrintFPlaceholder
			cmp #"s"			;string ?
			bne +
				jsr PrintString
			+
			lda SPrintFPlaceholder
			cmp #"b"			;binary ?
			bne +
				jsr PrintBinaryShort
			+
			lda SPrintFPlaceholder
			cmp #"B"			;binary ?
			bne +
				jsr PrintBinaryLong
			+
			ply
			iny
			lda SPrintFSave
			sta Al
			lda SPrintFSave + 1
			sta Ah
			jmp SPrintFLoop
		SPritFnotPercentTarget:
		jsr Print				;print character to Memory
		iny
		jmp SPrintFLoop
		SPrintFSave .word 0
		SPrintFPlaceholder .byte 0
PrintSignAccu:
	pha
	rol
	lda #"+"
	bcc +
		lda #"-"
	+
	jsr Print
	pla
	rts
PrintHexNibbleAccu:
	;Prints a Hex Nibble in the lower 4 bits of Accu
	;Accu = Nibble to Print
	;clobber = Accu, y, A
	tay
	.MLoadR A, HexArray
	lda (A), y
	jsr Print
	rts
PrintHexShortAccu:
	;prints Hex Number
	;Accu = number to print
	;clobbers = Accu, y, A
	sta _save
	and #%11110000
	lsr
	lsr
	lsr
	lsr
	jsr PrintHexNibbleAccu
	lda _save
	and #%00001111
	jsr PrintHexNibbleAccu
	rts
	_save .byte 0
PrintHexShort:
	;Print Hex byte pointed to by A
	;A = pointer to byte to print
	clobber = Accu, y 
	lda (A)
	jsr PrintHexShortAccu
	rts
PrintHexLong:
	;print 16bit Hex Number pointed to by (A)
	;A = pointer to Number
	;clobbers = Accu, y, A
	lda (A)
	pha
	ldy #1
	lda (A), y
	jsr PrintHexShortAccu
	pla
	jsr PrintHexShortAccu
	rts
PrintHexShortSignedAccu:
	jsr PrintSignAccu
	clc
	eor #$FF
	adc #$01
	jsr PrintHexShortAccu
	rts
PrintHexShortSigned:
	lda (A)
	jsr PrintSignAccu
	clc
	eor #$FF
	adc #$01
	jsr PrintHexShortAccu
	rts
PrintHexLongSigned:
	lda (A)
	jsr PrintSignAccu
	clc
	eor #$FF
	adc #$01
	pha
	ldy #1
	lda (A), y
	eor #$FF
	adc #$0
	jsr PrintHexShortAccu
	pla
	jsr PrintHexShortAccu
	rts
PrintBinaryShortAccu:
	;print 8bit binary in Accu
	;Accu = byte to Print
	;clobbers = A, y
	ldy #8
	PrintBinaryShortAccuLoop:
	rol
	pha
	lda #"1"
	bcs +	;zero ?
		lda #"0"
	+		;one
	jsr Print
	pla
	dey
	bne PrintBinaryShortAccuLoop
	rts
PrintBinaryShort:
	;print 8bit binary pointed to by A
	;A = pointer to byte to print
	;clobbers = A, y
	lda (A)
	jsr PrintBinaryShortAccu
	rts
PrintBinaryLong:
	;print 16bit binary pointed to by A
	;A = pointer to byte to print
	;clobbers = A, y
	lda (A)
	pha
	ldy #1
	lda (A), y
	jsr PrintBinaryShortAccu
	pla
	jsr PrintBinaryShortAccu
	rts


toMemory:	.byte 0
strPtr:		.word 0
strIndex:	.byte 0
HexArray: 	.text "0123456789ABCDEF"