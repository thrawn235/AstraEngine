!to "main.o", cbm

;Zero Page Variables
A  = 20
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


!source "textEngine.asm"

lda <str
sta Al
lda >str
sta Ah 
jsr PrintString

; zero-terminated string containing a newline at the end (char# 13)
str	!pet	"hello, world!!",13,0