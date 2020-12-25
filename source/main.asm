;main.asm
;by sebastian gurlin

.include "init.asm"
.include "misc.asm"
.include "textEngine.asm"

Start:
	jsr SetAnsi
	
	.MLoadR A, str1
	.MLoadR B, char1
	.MLoadR C, short2
	.MLoadR D, str2
	jsr PrintF

	.MEndlessLoop

str1 	.text "this is a string %c hihi %x und ciao and %s", 0
str2 	.text "this is another string", 0
char1	.byte "#"
char2	.byte "+"
short1	.byte 123
short2	.byte $AB
short3	.byte %10101100
short4	.byte -$23
long1	.word 12345
long2	.word $ABCD
long3	.word %1111111100001000
long4 	.word -$1234
str3 	.text "                                        ", 0