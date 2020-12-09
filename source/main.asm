;main.asm
;by sebastian gurlin

.include "init.asm"

jmp Start

Object_PrintStatus:
	jsr PrintImmediate
	.text "I'm an Object!", 13, 0
	rts

Object .struct
	ID 			.word 123
	name 		.text "Object         ", 0
	PrintStatus .word Object_PrintStatus
	end
.ends

ObjectPrototype .dstruct Object

Start:
jsr PrintImmediate
.text "Welcome to X16 Commander", 13, 13, 0

;reserver Memory for Object
lda #<Object.end
sta Al
lda #>Object.end
sta Ah
jsr MMAlloc

;store pointer from MMAlloc in pObject
lda Bl
sta pObject
sta Al
lda Bh
sta pObject + 1
sta Ah

;Initialize the Object (copy Prototype data to Pointer location)
.InitObject ObjectPrototype, pObject, Object

;store Object pointer in B
lda pObject
sta Bl
lda pObject + 1
sta Bh

;call virtual Method Object.PrintStatus
.JumpMethod B, Object.PrintStatus


jsr PrintImmediate
.text "done", 0

endless:
	jmp endless

pObject .word 0

