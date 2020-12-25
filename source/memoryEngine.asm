;memory manager

mmStart = $2000
mmEnd 	= $9EFF

mmStartAddress: .word mmStart
mmEndAddress:	.word mmEnd

MMNode .struct pNext, used, length
	pNext	.word \pNext
	used	.byte \used
	length 	.word \length
	end
	.ends

MMPrintNodeInfo:
	jsr PrintImmediate
	.text "Node ", 0
	jsr PrintImmediate
	.text " Address: ", 0
	lda Bl
	sta Al
	lda Bh
	sta Ah
	jsr PrintLongInt
	
	jsr PrintImmediate
	.text 13, "   pNext : ", 0
	ldy #MMNode.pNext
	lda (B), y
	sta Al
	iny
	lda (B), y
	sta Ah
	jsr PrintLongInt

	jsr PrintImmediate
	.text 13, "   used : ", 0
	ldy #MMNode.used
	lda (B), y
	sta Al
	jsr PrintShortInt

	jsr PrintImmediate
	.text 13, "   length : ", 0
	ldy #MMNode.length
	lda (B), y
	sta Al
	iny
	lda (B), y
	sta Ah
	jsr PrintLongInt
	jsr EndLine
	rts

MMPrintInfo:
	lda #<FirstNode
	sta Bl
	lda #>FirstNode
	sta Bh
	ldx #0
	PrintMemoryInfoLoop:
		jsr MMPrintNodeInfo

		;next Node
		ldy #MMNode.pNext
		lda (B), y
		sta Al
		iny
		lda (B), y
		sta Ah
		lda Al
		sta Bl
		lda Ah
		sta Bh

		;back at the start ? then retun.
		lda Bh
		cmp #>FirstNode
		bne +
			lda Bl
			cmp #<FirstNode
		+
		bne +
		jsr EndLine
		rts
		+

		jsr EndLine
		inx
		jmp PrintMemoryInfoLoop
	rts

MMGetNode:
	;A = requested size
	;B = return Address
	;c flag = 0 = sucess, 1 = fail
	lda Al
	sta _requestedSize
	lda Ah
	sta _requestedSize + 1

	lda #<FirstNode
	sta Bl
	lda #>FirstNode
	sta Bh
	_loop:
		;lda #"."
		;jsr PrintCharAccu

		;check used flag
		ldy #MMNode.used
		lda (B), y
		bne _next						;not 0, next node

		;check length
		ldy #MMNode.length + 1
		lda (B), y
		cmp _requestedSize + 1
		bne +
			dey
			lda (B), y
			cmp _requestedSize 
		+
		bmi _next						;node too small. next node
			;jsr PrintImmediate
			;.text "Node found:", 13, 0
			;jsr MMPrintNodeInfo
			clc 						;clear carry for success
			rts
		_next

		;next node
		ldy #MMNode.pNext
		lda (B), y
		sta Al
		iny
		lda (B), y
		sta Bh
		lda Al
		sta Bl

		;back at the start ? return fail
		lda Bh
		cmp #>FirstNode
		bne +
			lda Bl
			cmp #<FirstNode
			bne +
				jsr PrintImmediate
				.text "Memory Error: no node found", 13, 0
				sec 					;set carry for fail
				rts
		+

		jmp _loop
	_requestedSize .word 0

MMAlloc:
	;A = requested size
	;B = return Address
	;c flag = 0 = sucess, 1 = fail

	lda #0
	sta _error

	clc
	lda Al
	sta _requestedSize
	adc #MMNode.end
	sta _totalSize
	lda Ah
	sta _requestedSize + 1
	adc #0
	sta _totalSize + 1

	-

	;get free node
	lda _totalSize
	sta Al
	lda _totalSize + 1
	sta Ah
	jsr MMGetNode
	bcc +			;error ?
		lda _error
		bne _totalFail
			;0
			jsr MMDefrag
			lda #1
			sta _error
			jmp -
		_totalFail
		sec
		rts 			;then return
	+

	;decrease length of old node
	ldy #MMNode.length
	sec
	lda (B), y
	sbc _totalSize
	sta (B), y
	iny
	lda (B), y
	sbc _totalSize + 1
	sta (B), y

	;calculate new node address and save in C
	ldy #MMNode.length
	clc
	lda Bl
	adc (B), y
	sta Cl
	iny
	lda Bh
	adc (B), y
	sta Ch

	;set newNode.pNext to oldNode.pNext
	ldy #MMNode.pNext
	lda (B), y
	sta (C), y
	iny
	lda (B), y
	sta (C), y

	;set oldNode.pNext to newNode
	ldy #MMNode.pNext
	lda Cl
	sta (B), y
	iny
	lda Ch
	sta (B), y

	;set newNode length
	ldy #MMNode.length
	lda _requestedSize
	sta (C), y
	iny
	lda _requestedSize + 1
	sta (C), y

	;set newNode used flags
	ldy #MMNode.used
	lda #1
	sta (C), y

	;jsr PrintImmediate
	;.text "MMAlloc result:", 13, 0
	;jsr PrintImmediate
	;.text "old node:", 13, 0
	;jsr MMPrintNodeInfo
	lda Cl
	sta Bl
	lda Ch
	sta Bh
	;jsr PrintImmediate
	;.text "new node:", 13, 0
	;jsr MMPrintNodeInfo

	clc
	rts

	_totalSize		.word 0
	_requestedSize 	.word 0
	_error			.byte 0

MMFree:
	lda Al
	sta _address
	lda Ah
	sta _address + 1

	lda #<FirstNode
	sta Bl
	lda #>FirstNode
	sta Bh
	_loop:
		lda Bh
		cmp _address + 1
		bne +
			lda Bl
			cmp _address
			bne +
				;node found!
				ldy #MMNode.used
				lda #0
				sta (B), y
				clc
				rts
		+

		;next node
		ldy #MMNode.pNext
		lda (B), y
		sta Al
		iny
		lda (B), y
		sta Bh
		lda Al
		sta Bl

		;back at the start ? return fail
		lda Bh
		cmp #>FirstNode
		bne +
			lda Bl
			cmp #<FirstNode
			bne +
				jsr PrintImmediate
				.text "Memory Free Error: no node found", 13, 0
				sec 					;set carry for fail
				rts
		+

		jmp _loop
		_address .word 0

MMCombineNodes
	;combine Node1 (B) with Node2 (C). Node1 will persist
	;currentNode.pNext = nextNode.pNext
	ldy #MMNode.pNext
	lda (C), y
	sta (B), y
	iny
	lda (C), y
	sta (B), y

	;currentNode.length = currentNode.length + newNode.length
	ldy #MMNode.length
	clc
	lda (B), y
	adc (C), y
	sta (B), y
	iny 
	lda (B), y
	adc (C), y
	sta (B), y
	;+ MMNode.size
	ldy #MMNode.length
	clc
	lda (B), y
	adc MMNode.end
	sta (B), y
	iny 
	lda (B), y
	adc #0
	sta (B), y

	rts

MMDefrag:
	lda #<FirstNode
	sta Bl
	lda #>FirstNode
	sta Bh
	lda #1
	sta _complete
	_loop:
		;lda #"."
		;jsr PrintCharAccu

		;check used flag
		ldy #MMNode.used
		lda (B), y
		bne _next						;not 0, next node
			;current Block is Free check next block
			ldy #MMNode.pNext
			lda (B), y
			sta Cl
			iny
			lda (B), y
			sta Ch

			;check next Block used flag
			ldy #MMNode.used
			lda (C), y
			bne _nexttwice						;not 0, next node
				;this Block (B) and next Block (C) are both unused!
				;check wheter pNext is First Node. if so, dont do anything. First node MUST persist!
				ldy #MMNode.pNext
				lda (B), y
				cmp #<FirstNode
				bne +
					iny
					lda (B), y
					cmp #>FirstNode
					bne +
						jmp _next
				+

				lda #0
				sta _complete

				jsr MMCombineNodes

				jmp _next
		
		_nexttwice
		;next node
		ldy #MMNode.pNext
		lda (B), y
		sta Al
		iny
		lda (B), y
		sta Bh
		lda Al
		sta Bl

		_next

		;next node
		ldy #MMNode.pNext
		lda (B), y
		sta Al
		iny
		lda (B), y
		sta Bh
		lda Al
		sta Bl

		;are we at the beginning ?
		lda Bh
		cmp #>FirstNode
		bne +
			lda Bl
			cmp #<FirstNode
			bne ++
				;yes, at the beginning
				;is complete true ?
				lda _complete
				beq +
					rts
				+
				lda #1
				sta _complete
		+

		;emergency exit is tere is just one block left
		lda #MMNode.pNext + 1
		lda Bh
		cmp (B), y
		bne +
			dey
			lda Bl
			cmp (B), y
			bne +
				clc
				rts
		+ 

		jmp _loop
		_complete .byte 0

*=mmStart
FirstNode .dstruct MMNode, FirstNode, 0, mmEnd - FirstNodeEnd
FirstNodeEnd