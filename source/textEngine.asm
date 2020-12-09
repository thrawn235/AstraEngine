;Text Engine

;forget the hardware registers for functions
;real variables will be in memory somewhere
;the only areas for register optimtization is graphics or sort functions

;for the text editor, the data in memory will be one long consecutive string
;the lines will be split only in screen memory

SetANSI:
	lda #$0F
	jsr $FFD2
	rts

PrintChar:
	lda (A)
	jsr $FFD2
	rts

PrintCharAccu:
	jsr $FFD2
	rts

EndLine:
	lda #13
	jsr $FFD2
	rts

PrintString:
	ldy	#0					; Y register used to index string
	PrintStringloop:
		lda	(A), y			; Load character from string into A register
		beq	PrintStringEnd	; If the character is 0, jump to end label
		jsr	$FFD2			; Call KERNAL API to print char in A register
		iny					; Increment Y register
		jmp	PrintStringloop	; Jump back to loop label to get next character
	PrintStringEnd:
		rts

PrintImmediate:	
	pla               ; get low part of (string address-1)
	sta   DPL
	pla               ; get high part of (string address-1)
	sta   DPH
	bra   primm3
	primm2:
		jsr   $FFD2        ; output a string char
	primm3:
		inc   DPL         ; advance the string pointer
		bne   primm4
		inc   DPH
	primm4:
		lda   (DPL)       ; get string char
		bne   primm2      ; output and continue if not NUL
		lda   DPH
		pha
		lda   DPL
		pha
		rts               ; proceed at code following the NUL
		DPL =   $fd
		DPH =   $fe

PrintShortIntAccu:
	ldy #0
	sec
	PrintShortIntAccu100Loop:
		sbc #100
		bcc PrintShortIntAccu100LoopDone
		iny
		jmp PrintShortIntAccu100Loop
	PrintShortIntAccu100LoopDone:
	pha
	tya
	beq PrintShortIntAccu100Zero
	adc #48
	jsr $FFD2
	lda #1
	sta PrintShortIntAccuZero
	PrintShortIntAccu100Zero:
	pla
	clc
	adc #100
	ldy #0
	sec
	PrintShortIntAccu10Loop:
		sbc #10
		bcc PrintShortIntAccu10LoopDone
			iny
			jmp PrintShortIntAccu10Loop
	PrintShortIntAccu10LoopDone:
	pha
	tya
	clc
	adc PrintShortIntAccuZero
	beq PrintShortIntAccu10Zero
	tya
	adc #48
	jsr $FFD2
	PrintShortIntAccu10Zero:
	pla
	clc
	adc #10
	ldy #0
	sec
 	PrintShortIntAccu1Loop:
 		sbc #1
 		bcc PrintShortIntAccu1LoopDone
 			iny
 			jmp PrintShortIntAccu1Loop
 	PrintShortIntAccu1LoopDone:
	pha
	tya



	adc #48
	jsr $FFD2
	pla
	rts
	PrintShortIntAccuZero .byte 0

PrintShortInt:
	lda Al
	jsr PrintShortIntAccu
	rts

PrintLongInt:
	lda #0
	sta PrintLongIntZero
	lda Al
	pha
	lda Ah
	pha

	ldy #0
	_10000Loop:
		sec
		lda Al
		sbc #<10000
		sta Al
		lda Ah
		sbc #>10000
		sta Ah
		bmi +
			iny
			jmp _10000Loop
	+
	tya
	clc
	adc PrintLongIntZero
	beq +
	tya
	clc
	adc #48
	jsr $FFD2
	lda #1
	sta PrintLongIntZero
	+
	clc
	lda Al
	adc #<10000
	sta Al
	lda Ah
	adc #>10000
	sta Ah

	ldy #0
	_1000Loop:
		sec
		lda Al
		sbc #<1000
		sta Al
		lda Ah
		sbc #>1000
		sta Ah
		bmi +
			iny
			jmp _1000Loop
	+
	tya
	clc
	adc PrintLongIntZero
	beq +
	tya
	clc
	adc #48
	jsr $FFD2
	lda #1
	sta PrintLongIntZero
	+
	clc
	lda Al
	adc #<1000
	sta Al
	lda Ah
	adc #>1000
	sta Ah

	ldy #0
	_100Loop:
		sec
		lda Al
		sbc #<100
		sta Al
		lda Ah
		sbc #>100
		sta Ah
		bmi +
			iny
			jmp _100Loop
	+
	clc
	tya
	adc PrintLongIntZero
	beq +
	tya
	clc
	adc #48
	jsr $FFD2
	lda #1
	sta PrintLongIntZero
	+
	clc
	lda Al
	adc #<100
	sta Al
	lda Ah
	adc #>100
	sta Ah

	ldy #0
	_10Loop:
		sec
		lda Al
		sbc #<10
		sta Al
		lda Ah
		sbc #>10
		sta Ah
		bmi +
			iny
			jmp _10Loop
	+
	clc
	tya
	adc PrintLongIntZero
	beq +
	tya
	clc
	adc #48
	jsr $FFD2
	lda #1
	sta PrintLongIntZero
	+
	clc
	lda Al
	adc #<10
	sta Al
	lda Ah
	adc #>10
	sta Ah

	ldy #0
	_1Loop:
		sec
		lda Al
		sbc #<1
		sta Al
		lda Ah
		sbc #>1
		sta Ah
		bmi +
			iny
			jmp _1Loop
	+
	tya
	clc
	adc #48
	jsr $FFD2
	clc
	lda Al
	adc #<1
	sta Al
	lda Ah
	adc #>1
	sta Ah

	pla
	sta Ah
	pla
	sta Al
	rts
	PrintLongIntZero .byte 0

PrintShortSignedInt:
	lda Al
	rol
	bcs PrintShortSignedIntMinus
		lda #"+"
		jsr $FFD2
		lda Al
		and #%01111111
		jsr PrintShortIntAccu
		rts
	PrintShortSignedIntMinus:
		lda #"-"
		jsr $FFD2
		lda Al
		eor #$FF
		clc
		adc #1
		jsr PrintShortIntAccu		
		rts

PrintShortSignedIntAccu:
	sta PrintShortSignedIntAccuSave
	rol
	bcs PrintShortSignedIntMinusAccu
		lda #"+"
		jsr $FFD2
		lda PrintShortSignedIntAccuSave
		and #%01111111
		jsr PrintShortIntAccu
		rts
	PrintShortSignedIntMinusAccu:
		lda #"-"
		jsr $FFD2
		lda PrintShortSignedIntAccuSave
		eor #$FF
		and #%01111111
		clc
		adc #1
		jsr PrintShortIntAccu		
		rts
		PrintShortSignedIntAccuSave: .byte 0

PrintLongSignedInt:
	lda Ah
	rol
	bcs PrintLongSignedIntMinus
		lda #"+"
		jsr $FFD2
		lda Ah
		pha
		and #%01111111
		sta Ah
		jsr PrintLongInt
		pla
		sta Ah
		rts
	PrintLongSignedIntMinus:
		lda #"-"
		jsr $FFD2
		lda Al
		pha
		eor #$FF
		sta Al
		lda Ah
		pha
		eor #$FF
		sta Ah
		lda Al
		clc
		adc #1
		sta Al
		lda Ah
		adc #0
		sta Ah
		jsr PrintLongInt
		pla
		sta Ah
		pla
		sta Al
	rts

PrintShortDecimal:
PrintLongDecimal:
PrintShortSignedDecimal:
PrintLongSignedDecimal:

PrintShortHex:
	lda Al
	pha
	pha
	and #$F0
	ror
	ror
	ror
	ror
	tay
	lda #<HexNibbles
	sta Al
	lda #>HexNibbles
	sta Ah
	lda (A),y
	jsr $FFD2
	pla
	and #$0F
	tay
	lda (A),y
	jsr $FFD2
	pla
	sta Al
	rts

PrintShortHexAccu:
	pha
	lda Al
	sta savel
	lda Ah
	sta saveh
	pla
	pha
	and #$F0
	ror
	ror
	ror
	ror
	tay
	lda #<HexNibbles
	sta Al
	lda #>HexNibbles
	sta Ah
	lda (A),y
	jsr $FFD2
	pla
	and #$0F
	tay
	lda (A),y
	jsr $FFD2
	lda savel
	sta Al
	lda saveh
	sta Ah
	rts
	savel: .byte 0
	saveh: .byte 0

PrintShortSignedHexAccu:
	sta PrintShortSignedHexAccuSave
	rol
	bcs PrintShortSignedHexAccuMinus
		lda #"+"
		jsr $FFD2
		lda PrintShortSignedHexAccuSave
		and #%01111111
		jsr PrintShortHexAccu
		rts
	PrintShortSignedHexAccuMinus:
		lda #"-"
		jsr $FFD2
		lda PrintShortSignedHexAccuSave
		eor #$FF
		clc
		adc #1
		jsr PrintShortHexAccu		
		rts
	PrintShortSignedHexAccuSave: .byte 0

PrintLongHex:
	lda Al
	pha
	lda Ah
	jsr PrintShortHexAccu
	pla
	jsr PrintShortHexAccu
	rts

PrintShortSignedHex:
	lda Al
	rol
	bcs PrintShortSignedHexMinus
		lda #"+"
		jsr $FFD2
		lda Al
		and #%01111111
		jsr PrintShortHexAccu
		rts
	PrintShortSignedHexMinus:
		lda #"-"
		jsr $FFD2
		lda Al
		eor #$FF
		clc
		adc #1
		jsr PrintShortHexAccu		
		rts

PrintLongSignedHex:
	lda Ah
	rol
	bcs PrintLongSignedHexMinus
		lda #"+"
		jsr $FFD2
		lda Ah
		pha
		and #%01111111
		sta Ah
		jsr PrintLongHex
		pla
		sta Ah
		rts
	PrintLongSignedHexMinus:
		lda #"-"
		jsr $FFD2
		lda Al
		pha
		eor #$FF
		sta Al
		lda Ah
		pha
		eor #$FF
		sta Ah
		lda Al
		clc
		adc #1
		sta Al
		lda Ah
		adc #0
		sta Ah
		jsr PrintLongHex
		pla
		sta Ah
		pla
		sta Al
	rts

PrintShortBinary:
	lda Al
	pha
	ldy #8
	PrintShortBinaryLoop:
		dey
		bmi PrintShortBinaryEnd
		lda Al
		rol
		sta Al
		bcs PrintShortBinaryOne
			lda #0+48
			jsr $FFD2
			jmp PrintShortBinaryLoop
		PrintShortBinaryOne:
			lda #1+48
			jsr $FFD2
			jmp PrintShortBinaryLoop
	PrintShortBinaryEnd:
	pla
	sta Al
	rts

PrintShortBinaryAccu:
	pha
	lda Al
	pha
	pla
	sta Al
	jsr PrintShortBinary
	pla
	sta Al
	rts

PrintLongBinary:
	lda Al
	pha
	lda Ah
	sta Al
	jsr PrintShortBinary
	pla
	sta Al
	jsr PrintShortBinary
	rts

PrintF:


EnterString:
	;store at A
	ldy #0
	EnterStringLoop:
		jsr $FFCF
		cmp #13
		beq EnterStringLoopEnd
		sta (A), y
		iny
		jmp EnterStringLoop
	EnterStringLoopEnd:
	iny 
	lda #0
	sta (A), y
	rts

HexNibbles:
	.byte	"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"