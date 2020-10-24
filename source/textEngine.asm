;Text Engine

PrintString:
	ldy	#0					; X register used to index string
	PrintStringloop:
		lda	(A), y			; Load character from string into A register
		beq	PrintStringEnd				; If the character is 0, jump to end label
		jsr	$FFD2			; Call KERNAL API to print char in A register
		iny					; Increment X register
		jmp	PrintStringloop			; Jump back to loop label to get next character
	PrintStringEnd:
		rts

PrintImmediate:
	PHA     		; save A
	TYA			; copy Y
	PHA  			; save Y
	TXA			; copy X
	PHA  			; save X
	TSX			; get stack pointer
	LDA $0104,X		; get return address low byte (+4 to
				;   correct pointer)
	STA $BC			; save in page zero
	LDA $0105,X		; get return address high byte (+5 to
				;   correct pointer)
	STA $BD			; save in page zero
	LDY #$01		; set index (+1 to allow for return
				;   address offset)
	PRIM2:
		LDA ($BC),Y		; get byte from string
		BEQ PRIM3		; exit if null (end of text)

		JSR $FFD2		; else display character
		INY			; increment index
		BNE PRIM2		; loop (exit if 256th character)

	PRIM3:
		TYA			; copy index
		CLC			; clear carry
		ADC $BC			; add string pointer low byte to index
		STA $0104,X		; put on stack as return address low byte
					; (+4 to correct pointer, X is unchanged)
		LDA #$00		; clear A
		ADC $BD		; add string pointer high byte
		STA $0105,X		; put on stack as return address high byte
					; (+5 to correct pointer, X is unchanged)
		PLA			; pull value
		TAX  			; restore X
		PLA			; pull value
		TAY  			; restore Y
		PLA  			; restore A
		RT

PrintShortInt:
PrintLongInt:
PrintShortSignedInt:
PrintLongSignedInt:
PrintShortDecimal:
PrintLongDecimal:
PrintShortSignedDecimal:
PrintLongSignedDecimal:
PrintShortHex:
PrintLongHex:
PrintShortBinary:
PrintLongBinary:
PrintChar:

PrintF: