;init

.cpu "65c02"

;Zero Page Variables
	r0 = $02
	r0l = r0
	r0h = r0l + 1

	r1 = r0 +2
	r1l = r1
	r1h = r1l + 1

	r2 = r1 +2
	r2l = r2
	r2h = r2l + 1

	r3 = r2 +2
	r3l = r3
	r3h = r3l + 1

	r4 = r3 +2
	r4l = r4
	r4h = r4l + 1

	r5 = r4 +2
	r5l = r5
	r5h = r5l + 1

	r6 = r5 +2
	r6l = r6
	r6h = r6l + 1

	r7 = r6 +2
	r7l = r7
	r7h = r7l + 1

	r8 = r7 + 2
	r8l = r8
	r8h = r8l + 1

	r9 = r8 +2
	r9l = r9
	r9h = r9l + 1

	r10 = r9 +2
	r10l = r10
	r10h = r10l + 1

	r11 = r10 +2
	r11l = r11
	r11h = r11l + 1

	r12 = r11 +2
	r12l = r12
	r12h = r12l + 1

	r13 = r12 +2
	r13l = r13
	r13h = r13l + 1

	r14 = r14l = r13 +2
	r14l = r14
	r14h = r14l + 1

	r15 = r15l = r14 +2
	r15l = r15
	r15h = r15l + 1

	A = $22
	Al = A
	Ah = A + 1

	B = A + 2
	Bl = B
	Bh = B + 1

	C = B + 2
	Cl = C
	Ch = C + 1

	D = C + 2
	Dl = D
	Dh = D + 1

	E = D + 2
	El = E
	Eh = E + 1

	F = E + 2
	Fl = F
	Fh = F + 1

	G = F + 2
	Gl = G
	Gh = G + 1

	H = G + 2
	Hl = H
	Hh = H + 1

	I = G + 2
	Il = I
	Ih = I + 1

	J = I + 2
	Jl = J
	Jh = J + 1


Startup:
	; Start of BASIC program
	*=$0801

	; BASIC "run" line
	.byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00

	; Start of actual program
	*=$0810

jmp Start