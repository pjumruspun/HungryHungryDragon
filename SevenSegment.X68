*-----------------------------------------------------------
* Title      : 7-Segment Display
* Written by : Pon Jumruspun
* Date       : 6/4/2024
* Description: 7-Segment Display for displaying score.
*-----------------------------------------------------------

drawSevenSegment:
* Draw a single 7-segment
* Parameters:
* D1: Number to display (Range of 0-9)
* D2, D3: OriginX and OriginY of the digit

* Other registers used: D0, D4-D7, A1

* Check if we need to redraw BG
    cmp.l   #BACKGROUND_ORIGIN, d3
    blt     skipRedrawBackgroundSevenSeg
    
    jsr     redrawSevenSegBackground

skipRedrawBackgroundSevenSeg:
* Clear D4, D6, and D7 because we'll use them in less than long size
    clr.l   d4
    clr.l   d6
    clr.l   d7

* Load the table
    
    lea     SevenSegmentDigitCode, a1
    move.b  (a1, d1), d4    ; D4 contains the table value of the corresponding base-10 digit

* Set pen width to the desired width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #SEVEN_SEGMENT_PEN_WIDTH, d1
    trap    #15
    
* Set pen color
    move.l  #TASK_SET_PEN_COLOR, d0
    move.l  #SEVEN_SEGMENT_COLOR, d1
    trap    #15
    
    move.l  #SEVEN_SEGMENT_LOOP_LIMIT-1, d5     ; Loop counter

drawSevenSegmentLoop:
    move.b  d4, d6
    and.b   #1, d6
    cmp.b   #1, d6      ; Check whether the last digit is 0 or 1
    bne     skipDrawingSegment

* Actually draw the segment corresponding to the reversed index D5
    move.l  d5, d6
    
    sub.l   #LONG_OFFSET*5, sp
    movem.l d0-d4, (sp)                         ; Save context
    
    move.l  #TASK_DRAW_LINE, d0
    
* Set Old D2 = D1 = D3 = OriginX, OldD3 = D2 = D4 = OriginY
    move.w  d2, d1
    move.w  d3, d2
    move.w  d1, d3
    move.w  d2, d4
    
* Add the offset
    lea     SevenSegStartOffsetX, a1
    move.b  (a1, d6), d7                        ; Get the offset
    mulu.w  #SEVEN_SEGMENT_LENGTH, d7           ; Scale by the length
    add.w   d7, d1                              ; Then add to the respective drawing parameter
    
    lea     SevenSegStartOffsetY, a1
    move.b  (a1, d6), d7                        ; Get the offset
    mulu.w  #SEVEN_SEGMENT_LENGTH, d7           ; Scale by the length
    add.w   d7, d2                              ; Then add to the respective drawing parameter
    
    lea     SevenSegEndOffsetX, a1
    move.b  (a1, d6), d7                        ; Get the offset
    mulu.w  #SEVEN_SEGMENT_LENGTH, d7           ; Scale by the length
    add.w   d7, d3                              ; Then add to the respective drawing parameter
    
    lea     SevenSegEndOffsetY, a1
    move.b  (a1, d6), d7                        ; Get the offset
    mulu.w  #SEVEN_SEGMENT_LENGTH, d7           ; Scale by the length
    add.w   d7, d4                              ; Then add to the respective drawing parameter
    
    trap    #15
    
    movem.l (sp), d0-d4
    add.l   #LONG_OFFSET*5, sp                  ; Load context
    
skipDrawingSegment:
    lsr.b   #1, d4      ; Shift to the next digit
    dbra    d5, drawSevenSegmentLoop
    
* Set the pen width back to default
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #DEFAULT_PEN_WIDTH, d1
    trap   #15

    rts

redrawSevenSegBackground:
* Redraw the background lazily for now (draw once big rect for the whole 7-seg digit)
* Redrawing this part:

*   o x x x x
*   o       x
*   o       x
*   o x x x x
*   o       x
*   o       x
*   o x x x x

    sub.l   #LONG_OFFSET*3, sp
    movem.l d1-d3, (sp)             ; Save context

    lea     BackgroundImage, a1
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    
    move.l  d2, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    move.l  d0, X_SCREEN(sp)        ; X_SCREEN = OriginX - PenWidth/2
    move.l  d0, X_BMP(sp)           ; X_BMP = X_SCREEN
        
    move.l  d3, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    sub.l   #1, d0
    move.l  d0, Y_SCREEN(sp)        ; Y_SCREEN = OriginY - PenWidth/2 - 1
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d0
    move.l  d0, Y_BMP(sp)           ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #SEVEN_SEGMENT_PEN_WIDTH, WIDTH_TO_DISPLAY(sp)    ; Length + PenWidth
    move.l  #2*SEVEN_SEGMENT_LENGTH+SEVEN_SEGMENT_PEN_WIDTH+1, HEIGHT_TO_DISPLAY(sp)   ; 2 * (Length * PenWidth)
    
    jsr     displayBitmapChunk
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack
    
    movem.l (sp), d1-d3
    add.l   #LONG_OFFSET*3, sp      ; Load context
    
* Redrawing this part:

*   x x x x o
*   x       o
*   x       o
*   x x x x o
*   x       o
*   x       o
*   x x x x o

    sub.l   #LONG_OFFSET*3, sp
    movem.l d1-d3, (sp)             ; Save context

    lea     BackgroundImage, a1
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    
    move.l  d2, d0
    add.l   #SEVEN_SEGMENT_LENGTH-SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    move.l  d0, X_SCREEN(sp)        ; X_SCREEN = OriginX + SegmentLength - PenWidth/2
    move.l  d0, X_BMP(sp)           ; X_BMP = X_SCREEN
        
    move.l  d3, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    sub.l   #1, d0
    move.l  d0, Y_SCREEN(sp)        ; Y_SCREEN = OriginY - PenWidth/2 - 1
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d0
    move.l  d0, Y_BMP(sp)           ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #SEVEN_SEGMENT_PEN_WIDTH, WIDTH_TO_DISPLAY(sp)    ; Length + PenWidth
    move.l  #2*SEVEN_SEGMENT_LENGTH+SEVEN_SEGMENT_PEN_WIDTH+1, HEIGHT_TO_DISPLAY(sp)   ; 2 * (Length * PenWidth)
    
    jsr     displayBitmapChunk
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack
    
    movem.l (sp), d1-d3
    add.l   #LONG_OFFSET*3, sp      ; Load context
    
* Redrawing this part:

*   x o o o x
*   x       x
*   x       x
*   x x x x x
*   x       x
*   x       x
*   x x x x x

    sub.l   #LONG_OFFSET*3, sp
    movem.l d1-d3, (sp)             ; Save context

    lea     BackgroundImage, a1
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    
    move.l  d2, d0
    add.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    move.l  d0, X_SCREEN(sp)        ; X_SCREEN = OriginX + PenWidth/2
    move.l  d0, X_BMP(sp)           ; X_BMP = X_SCREEN
        
    move.l  d3, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    sub.l   #1, d0
    move.l  d0, Y_SCREEN(sp)        ; Y_SCREEN = OriginY - PenWidth/2 - 1
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d0
    move.l  d0, Y_BMP(sp)           ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #SEVEN_SEGMENT_LENGTH-SEVEN_SEGMENT_PEN_WIDTH>>1, WIDTH_TO_DISPLAY(sp)
    move.l  #SEVEN_SEGMENT_PEN_WIDTH+1, HEIGHT_TO_DISPLAY(sp)
    
    jsr     displayBitmapChunk
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack
    
    movem.l (sp), d1-d3
    add.l   #LONG_OFFSET*3, sp      ; Load context
    
* Redrawing this part:

*   x x x x x
*   x       x
*   x       x
*   x o o o x
*   x       x
*   x       x
*   x x x x x

    sub.l   #LONG_OFFSET*3, sp
    movem.l d1-d3, (sp)             ; Save context

    lea     BackgroundImage, a1
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    
    move.l  d2, d0
    add.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    move.l  d0, X_SCREEN(sp)        ; X_SCREEN = OriginX + PenWidth/2
    move.l  d0, X_BMP(sp)           ; X_BMP = X_SCREEN
        
    move.l  d3, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    sub.l   #1, d0
    add.l   #SEVEN_SEGMENT_LENGTH, d0
    move.l  d0, Y_SCREEN(sp)        ; Y_SCREEN = OriginY - PenWidth/2 - 1 + SegmentLength
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d0
    move.l  d0, Y_BMP(sp)           ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #SEVEN_SEGMENT_LENGTH-SEVEN_SEGMENT_PEN_WIDTH>>1, WIDTH_TO_DISPLAY(sp)
    move.l  #SEVEN_SEGMENT_PEN_WIDTH+1, HEIGHT_TO_DISPLAY(sp)
    
    jsr     displayBitmapChunk
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack
    
    movem.l (sp), d1-d3
    add.l   #LONG_OFFSET*3, sp      ; Load context
    
* Redrawing this part:

*   x x x x x
*   x       x
*   x       x
*   x x x x x
*   x       x
*   x       x
*   x o o o x

    sub.l   #LONG_OFFSET*3, sp
    movem.l d1-d3, (sp)             ; Save context

    lea     BackgroundImage, a1
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    
    move.l  d2, d0
    add.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    move.l  d0, X_SCREEN(sp)        ; X_SCREEN = OriginX + PenWidth/2
    move.l  d0, X_BMP(sp)           ; X_BMP = X_SCREEN
        
    move.l  d3, d0
    sub.l   #SEVEN_SEGMENT_PEN_WIDTH>>1, d0
    sub.l   #1, d0
    add.l   #2*SEVEN_SEGMENT_LENGTH, d0
    move.l  d0, Y_SCREEN(sp)        ; Y_SCREEN = OriginY - PenWidth/2 - 1 + 2*SegmentLength
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d0
    move.l  d0, Y_BMP(sp)           ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #SEVEN_SEGMENT_LENGTH-SEVEN_SEGMENT_PEN_WIDTH>>1, WIDTH_TO_DISPLAY(sp)
    move.l  #SEVEN_SEGMENT_PEN_WIDTH+1, HEIGHT_TO_DISPLAY(sp)
    
    jsr     displayBitmapChunk
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack
    
    movem.l (sp), d1-d3
    add.l   #LONG_OFFSET*3, sp      ; Load context
    
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
