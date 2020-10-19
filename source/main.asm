;main.asm
;by sebastian gurlin

;Zero Page Variables
A  = $20
Al = A
Ah = A + 1

B  = A + 2
Bl = B
Bh = B + 1

; Start of BASIC program
*=$0801

; BASIC "run" line
!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00

; Start of actual program
*=$0810

jmp Start

!source "./source/textEngine.asm"

Start:

lda #<str
sta Al
lda #>str
sta Ah
jsr PrintString

loop:
	jmp loop

; zero-terminated string containing a newline at the end (char# 13)
str:	!pet	"Hello, World!!",13,0
