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