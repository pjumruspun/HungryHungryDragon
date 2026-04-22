*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Written by : Pon Jumruspun
* Date       : 5/30/2024
* Description: Reading pixels from bitmaps to display. Most cycles will be running here.
*              Note that subroutines' parameters here are passed in stack, not registers.
*-----------------------------------------------------------

GREEN_SCREEN_COLOR      equ $FF00
    
displayBitmap:
* Fully display a bitmap at X_SCREEN, Y_SCREEN coordinates
* Benchmark: 356 cycles pre-draw

* 	ARGUMENTS:

* 	BMP_ADDR								Pointer to .bmp file
* 	X_SCREEN, Y_SCREEN						(x, y) top left corner of the output screen to display

* Registers used: A1, D0-D2, D5-D7

* Move pass the return address
	add.l	#4, sp

* Load the bmp pointer argument
	move.l	BMP_ADDR(sp), a1

* Assume BM header with 40 bytes DIB header (BITMAPINFOHEADER)
* Extract width
	move.l	BMP_WIDTH_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_WIDTH(sp)
	
* Extract height
	move.l	BMP_HEIGHT_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_HEIGHT(sp)

* Move to the starting pixel storage
	move.l	BMP_START_ADDR(a1), d0 
	ror.w	#8, d0
	swap	d0
	ror.w	#8, d0		; Convert little to big endian
	
	add.l	d0, a1		; Move
	
* Can start reading the pixels here
* Should read from bottom left, to right, then up
* Init drawing positions, d6=x, d7=y
	move.l	X_SCREEN(sp), d6			; X starts from X_SCREEN
	move.l	Y_SCREEN(sp), d7
	add.l	VAR_IMAGE_HEIGHT(sp), d7
	sub.l	#1, d7						; Y starts from LowerY = Y_SCREEN + ImageHeight - 1

	move.l	X_SCREEN(sp), d5
	add.l	VAR_IMAGE_WIDTH(sp), d5
	sub.l	#1, d5						; RightX = X_SCREEN + ImageWidth - 1

verticalLoop:
	move.l	X_SCREEN(sp), d6			; Reset	current X
	
horizontalLoop:
* Set the pen color for 32 bits
	clr.l	d1
	move.l	(a1)+, d1	; BBGGRR00
	lsr.l	#8, d1

* By this line the pen color should be set in D1 from 24/32-bit color reading above
	move.l	#TASK_SET_PEN_COLOR, d0
	trap	#15

* Draw the pixel here
	move.w	d6, d1		; X
	move.w	d7, d2		; Y
	move.l	#TASK_DRAW_PIXEL, d0
	trap	#15
	
	add.l	#1, d6		; Move pen right
	
* Go to the upper row when X > RightX
	cmp.l	d5, d6
	ble		horizontalLoop
	
* New row here
	sub.l	#1, d7			; Move pen up
	
	cmp.l	Y_SCREEN(sp), d7
	bge		verticalLoop	; Ends when Y < Y_SCREEN = UpperY

* Move back to the return address
	sub.l	#4, sp
	rts
	
displayBitmapCenter:
* Fully display a bitmap at X_SCREEN, Y_SCREEN coordinates with those coordinates being the center of the image

* 	ARGUMENTS:

* 	BMP_ADDR								Pointer to .bmp file
* 	X_SCREEN, Y_SCREEN					(x, y) center of the output screen to display

* Registers used: A1, D0-D2, D4-D7

* Move pass the return address
	add.l	#4, sp

* Load the bmp pointer argument
	move.l	BMP_ADDR(sp), a1

* Assume BM header with 40 bytes DIB header (BITMAPINFOHEADER)
* Extract width
	move.l	BMP_WIDTH_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_WIDTH(sp)
	
* Extract height (offset = 22)
	move.l	BMP_HEIGHT_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_HEIGHT(sp)

* Move to the starting pixel storage
* The starting offset value is stored at byte 0x0A (10 in dec) of the file
	move.l	BMP_START_ADDR(a1), d0 
	ror.w	#8, d0
	swap	d0
	ror.w	#8, d0		; Convert little to big endian
	
	add.l	d0, a1		; Move
	
* Can start reading the pixels here
* Should read from bottom left, to right, then up
* Init drawing positions, d6=x, d7=y
	move.l	X_SCREEN(sp), d6			
	move.l  VAR_IMAGE_WIDTH(sp), d0
	lsr.l   #1, d0
    sub.l   d0, d6                      ; X starts from LeftX = X_SCREEN - ImageWidth/2
    
	move.l	Y_SCREEN(sp), d7
	move.l  VAR_IMAGE_HEIGHT(sp), d0
	lsr.l   #1, d0
	add.l	d0, d7
	sub.l	#1, d7					    ; Y starts from LowerY = Y_SCREEN + ImageHeight/2 - 1

	move.l	d6, d5
	move.l  VAR_IMAGE_WIDTH(sp), d0
	add.l   d0, d5     
    sub.l   #1, d5                      ; RightX = LeftX + ImageWidth - 1
	
	move.l	d7, d4                      
    sub.l   VAR_IMAGE_HEIGHT(sp), d4    
    add.l   #1, d4                      ; UpperY = LowerY - ImageHeight + 1

verticalCenterLoop:
	move.l	X_SCREEN(sp), d6			
	move.l  VAR_IMAGE_WIDTH(sp), d0
	lsr.l   #1, d0
    sub.l   d0, d6		; Reset	current X
	
horizontalCenterLoop:
* Set the pen color for 32 bits
	clr.l	d1
	move.l	(a1)+, d1	; BBGGRR00
	lsr.l	#8, d1

* By this line the pen color should be set in D1 from 24/32-bit color reading above
	move.l	#TASK_SET_PEN_COLOR, d0
	trap	#15

* Draw the pixel here
	move.w	d6, d1		; X
	move.w	d7, d2		; Y
	move.l	#TASK_DRAW_PIXEL, d0
	trap	#15
	
	add.l	#1, d6		; Move pen right
	
* Go to the upper row when X > RightX
	cmp.l	d5, d6
	ble		horizontalCenterLoop
	
* New row here
	sub.l	#1, d7			; Move pen up
	
	cmp.l	d4, d7
	bge		verticalCenterLoop	; Ends when Y < UpperY

* Move back to the return address
	sub.l	#4, sp
	rts


displayTransparentBitmap:
* Fully display a green screened bitmap at X_SCREEN, Y_SCREEN coordinates
* 	ARGUMENTS:

* 	BMP_ADDR								Pointer to .bmp file
* 	X_SCREEN, Y_SCREEN						(x, y) top left corner of the output screen to display

* Registers used: A1, D0-D2, D5-D7

* Move pass the return address
	add.l	#4, sp

* Load the bmp pointer argument
	move.l	BMP_ADDR(sp), a1

* Assume BM header with 40 bytes DIB header (BITMAPINFOHEADER)
* Extract width
	move.l	BMP_WIDTH_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_WIDTH(sp)
	
* Extract height (offset = 22)
	move.l	BMP_HEIGHT_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_HEIGHT(sp)

* Move to the starting pixel storage
* The starting offset value is stored at byte 0x0A (10 in dec) of the file
	move.l	BMP_START_ADDR(a1), d0 
	ror.w	#8, d0
	swap	d0
	ror.w	#8, d0		; Convert little to big endian
	
	add.l	d0, a1		; Move
	
* Can start reading the pixels here
* Should read from bottom left, to right, then up
* Init drawing positions, d6=x, d7=y
	move.l	X_SCREEN(sp), d6			; X starts from X_SCREEN
	move.l	Y_SCREEN(sp), d7
	add.l	VAR_IMAGE_HEIGHT(sp), d7
	sub.l	#1, d7						; Y starts from LowerY = Y_SCREEN + ImageHeight - 1

	move.l	X_SCREEN(sp), d5
	add.l	VAR_IMAGE_WIDTH(sp), d5
	sub.l	#1, d5						; RightX = X_SCREEN + ImageWidth - 1

verticalTransparentLoop:
	move.l	X_SCREEN(sp), d6			; Reset	current X
	
horizontalTransparentLoop:
* Optimizing this would result in huge performance increase
* As this is the function that gets called the most in the code
* During rendering the player and enemies
* Cycles are attached for ease of optimizing

* Set the pen color for 32 bits

* Note: Offseting by a byte backward to avoid shifting wouldn't work 
*       Since EASy68k is word-aligned for long operations

	move.l	(a1)+, d1	; BBGGRR00      12 cycles
	lsr.l	#8, d1      ;               24 cycles

* If the color is pure green, don't draw
	cmp.l   #GREEN_SCREEN_COLOR, d1 ;   14 cycles
	beq     skipDrawing             ;   12 cycles

* By this line the pen color should be set in D1 from 24/32-bit color reading above
	move.l	#TASK_SET_PEN_COLOR, d0 ;   4 cycles
	trap	#15

* Draw the pixel here
	move.w	d6, d1		; X             4 cycles
	move.w	d7, d2		; Y             4 cycles
	move.l	#TASK_DRAW_PIXEL, d0    ;   4 cycles
	trap	#15

skipDrawing:
	add.l	#1, d6	; Move pen right    8 cycles
	
* Go to the upper row when X > RightX
	cmp.l	d5, d6      ;               6 cycles
	ble		horizontalTransparentLoop ; 10 cycles
	
* New row here
	sub.l	#1, d7			; Move pen up
	
	cmp.l	Y_SCREEN(sp), d7
	bge		verticalTransparentLoop	; Ends when Y < Y_SCREEN = UpperY

* Move back to the return address
	sub.l	#4, sp
	rts


displayBitmapChunk:
* Pre-draw
* Unoptimized: 846 cycles
* No argument correcting/bit extraction: 744 cycles

* Cycles per pixel
* Unoptimized: 116 cycles 
* 32bit-only: 82 cycles

* 	ARGUMENTS:

* 	BMP_ADDR								Pointer to .bmp file
* 	X_BMP, Y_BMP							(x, y) top left corner of the bitmap to start displaying. 
* 	WIDTH_TO_DISPLAY, HEIGHT_TO_DISPLAY		(Width, height) of the bitmap to display.
* 	X_SCREEN, Y_SCREEN						(x, y) top left corner of the output screen to display

* Registers used: A1, D0-D7

* Move pass the return address
	add.l	#4, sp

* Load the bmp pointer argument
	move.l	BMP_ADDR(sp), a1

* Assume BM header with 40 bytes DIB header (BITMAPINFOHEADER)
	move.l	BMP_WIDTH_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_WIDTH(sp)
	
* Extract height (offset = 22)
	move.l	BMP_HEIGHT_OFFSET(a1), d2
	ror.w	#8, d2
	swap	d2
	ror.w	#8, d2		; Convert little to big endian
	move.l	d2, VAR_IMAGE_HEIGHT(sp)

* Move to the starting pixel storage
* The starting offset value is stored at byte 0x0A (10 in dec) of the file
	move.l	BMP_START_ADDR(a1), d0 
	ror.w	#8, d0
	swap	d0
	ror.w	#8, d0		; Convert little to big endian
	
	add.l	d0, a1		; Move
	
* Now move to the pixel we want to start drawing
* The number of bytes to move to the true starting point is by the following formula:
* X_BMP * BytePerPixel + (ImageHeight - HEIGHT_TO_DISPLAY - Y_BMP) * Floor(ImageWidth * BytePerPixel / 4 + 3) * 4
	move.l	X_BMP(sp), d0
	move.l	#BYTES_PER_PIXEL, d1
	mulu.w	d1, d0							; X_BMP * BytePerPixel
	
	move.l	VAR_IMAGE_HEIGHT(sp), d1
	sub.l	HEIGHT_TO_DISPLAY(sp), d1
	sub.l	Y_BMP(sp), d1					; (ImageHeight - HEIGHT_TO_DISPLAY - Y_BMP)
	
	move.l	VAR_IMAGE_WIDTH(sp), d2
	move.l	#BYTES_PER_PIXEL, d3
	mulu.w	d3, d2
	add.l	#3, d2
	lsr.l	#2, d2
	lsl.l	#2, d2							; Floor(ImageWidth * BytePerPixel / 4 + 3) * 4
	
	mulu.w	d2, d1
	add.l	d1, d0
	
	add.l	d0, a1							; Move
	
* When moving to the upper row, the amount of bytes to move is by the following formula:
* Floor(ImageWidth * BytePerPixel / 4 + 3) * 4 - WIDTH_TO_DISPLAY * BytePerPixel
* Do this outside the loop to save cycles
	move.l	WIDTH_TO_DISPLAY(sp), d0
	move.l	#BYTES_PER_PIXEL, d1
	mulu.w	d1, d0
	sub.l	d0, d2							; D2 is from the starting point calculation earlier
	move.l	d2, d4							; Save for using in the loop as D4 is currently unused in this scope
	
* Can start reading the pixels here
* Should read from bottom left, to right, then up
* Init drawing positions, d6=x, d7=y
	move.l	X_SCREEN(sp), d6			; X starts from X_SCREEN
	move.l	Y_SCREEN(sp), d7
	add.l	HEIGHT_TO_DISPLAY(sp), d7
	sub.l	#1, d7						; Y starts from LowerY = Y_SCREEN + HEIGHT_TO_DISPLAY - 1

	move.l	X_SCREEN(sp), d5
	add.l	WIDTH_TO_DISPLAY(sp), d5
	sub.l	#1, d5						; RightX = X_SCREEN + WIDTH_TO_DISPLAY - 1

verticalLoopChunk:
	move.l	X_SCREEN(sp), d6			; Reset	current X
	
horizontalLoopChunk:
* Set the pen color for 32 bits
	clr.l	d1
	move.l	(a1)+, d1	; BBGGRR00
	lsr.l	#8, d1

* By this line the pen color should be set in D1 from 24/32-bit color reading above
	move.l	#TASK_SET_PEN_COLOR, d0
	trap	#15

* Draw the pixel here
	move.w	d6, d1		; X
	move.w	d7, d2		; Y
	move.l	#TASK_DRAW_PIXEL, d0
	trap	#15
	
	add.l	#1, d6		; Move pen right
	
* Go to the upper row when X > RightX
	cmp.l	d5, d6
	ble		horizontalLoopChunk
	
* New row here
	add.l	d4, a1			; Need to skip by D4 bytes, as calculated outside the loop earlier
	sub.l	#1, d7			; Move pen up
	
	cmp.l	Y_SCREEN(sp), d7
	bge		verticalLoopChunk	; Ends when Y < Y_SCREEN = UpperY

* Move back to the return address
	sub.l	#4, sp
	rts















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
