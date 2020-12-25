memory_copy	=	$FEE7

Jump .macro 
	;\1 = pointer to Target
	lda #>(+)-1
	pha
	lda #<(+)-1
	pha
	jmp (\1)
	+
	.endm

JumpMethod .macro
	;example: .JumpMethod B, Object.PrintStatus
	;\1 = pinter to Object
	;\2 = Method Pointer
	ldy #\2
	lda (\1), y
	sta Jl
	iny
	lda (\1), y
	sta Jh
	.Jump J
	.endm

InitObject .macro
	;example: .InitObject ObjectPrototype, pObject, Object
	lda #<\1
	sta r0l
	lda #>\1
	sta r0h
	
	lda \2
	sta r1l
	lda \2 + 1
	sta r1h
	
	lda #\3.end
	sta r2l
	lda #0
	sta r2h
	jsr memory_copy
	.endm

MEndlessLoop .macro
	;round and round and round...
	_endless:
		jmp _endless
	.endm

MPush .macro
	;Pushes a ZeroPage Register
	lda \1l
	pha
	lda \1h
	pha
	.endm

MPull .macro
	;Pulls a ZeroPage Register
	pla
	sta \1h
	pla
	sta \1l
	.endm

MLoadR .macro
	;load a value into a Zero Page register
	lda #<\2
	sta \1l
	lda #>\2
	sta \1h
	.endm

MP .macro
	;load the Target Value of a Pointer stored in a zero page register into the same register
	lda (\1)
	tax
	ldy #1
	lda (\1), y
	sta \1h
	txa
	sta \1l
	.endm