;input Engine

;this module is for interrupt driven input

;joystick:

joystick_scan	=	$FF53
joystick_get	=	$FF56

JoyUp:
	lda #0
	jsr joystick_get
	and #%00001000
	bne +
	sec
	rts
	+
	clc
	rts

JoyDown:
	lda #0
	jsr joystick_get
	and #%00000100
	bne +
	sec
	rts
	+
	clc
	rts

JoyLeft:
	lda #0
	jsr joystick_get
	and #%00000010
	bne +
	sec
	rts
	+
	clc
	rts

JoyRight:
	lda #0
	jsr joystick_get
	and #%00000001
	bne +
	sec
	rts
	+
	clc
	rts

JoyA: 		;CTRL
	lda #0
	jsr joystick_get
	and #%10000000
	bne +
	sec
	rts
	+
	clc
	rts

JoyB: 		;ALT
	lda #0
	jsr joystick_get
	and #%01000000
	bne +
	sec
	rts
	+
	clc
	rts

JoySelect: 	;SPACE
	lda #0
	jsr joystick_get
	and #%00100000
	bne +
	sec
	rts
	+
	clc
	rts

JoyStart: 	;Enter
	lda #0
	jsr joystick_get
	and #%00010000
	bne +
	sec
	rts
	+
	clc
	rts

;mouse

mouse_config	=	$FF68
mouse_scan		=	$FF71
mouse_get		=	$FF6B

MouseInit:
	lda #1
	jsr mouse_config
	rts

MouseGetPos:
	ldx #B
	jsr mouse_get
	rts

MouseLeft:
	ldx #B
	jsr mouse_get
	and #%00000001
	beq +
	sec
	rts
	+
	clc
	rts

MouseRight:
	ldx #B
	jsr mouse_get
	and #%00000010
	beq +
	sec
	rts
	+
	clc
	rts


;keyboard:

BASIN	=	$FFCF

KeyDown:
	sta _key
	jsr BASIN
	cmp _key
	beq +
	sec
	rts
	+
	clc
	rts
	_key .byte 0