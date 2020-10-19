;Text Engine

PrintString:
	ldy	#0					; X register used to index string
	.loop:
		lda	(A), y			; Load character from string into A register
		beq	.end				; If the character is 0, jump to end label
		jsr	$FFD2			; Call KERNAL API to print char in A register
		iny					; Increment X register
		jmp	.loop			; Jump back to loop label to get next character
	.end:
		rts	