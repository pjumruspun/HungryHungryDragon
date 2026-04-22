*-----------------------------------------------------------
* Title      : Score
* Written by : Pon Jumruspun
* Date       : 6/4/2024
* Description: Display score in the game. 
*              Also includes functions to convert hex to decimal.
*-----------------------------------------------------------

resetScore:
* Same registers used as in drawScore
    move.l  #INITIAL_SCORE_VALUE, PlayerScore
    move.l  #INITIAL_SCORE_VALUE, LastPlayerScoreDec
    jsr     drawScore
    rts
    
drawScore:
* Draw the score equals to PlayerScore on the respective location set in the constants
* Registers used: D0-D7, A1
    move.l  #SCORE_POSITION_X, d2
    move.l  #SCORE_POSITION_Y, d3
    move.l  PlayerScore, d0
    
    cmp.l   #0, d0 
    beq     drawZeroScore
    
    jsr     hexToDecimal
    move.l  d7, d4
    
    move.l  LastPlayerScoreDec, d5
    
drawScoreLoop:
    move.l  d4, d1
    
    and.l   #SCORE_MASK, d1     ; Single digit in D5
    cmp.l   #0, d4              ; Run of out digits if the score is 0
    beq     stopDrawingScore
    
    move.l  d5, d6
    and.l   #SCORE_MASK, d6
    cmp.l   d4, d6              ; If the digit is the same, we don't need to redraw it
    beq     continueDrawScoreLoop
    
* Draw each seven segment here
    sub.l   #LONG_OFFSET*6, sp  
    movem.l d1-d6, (sp)         ; Save context
    
    jsr     drawSevenSegment
    
    movem.l (sp), d1-d6
    add.l   #LONG_OFFSET*6, sp          ; Load context
    
continueDrawScoreLoop:
    lsr.l   #4, d5                      ; Shift by 1 hex digit
    lsr.l   #4, d4                      ; Shift by 1 hex digit
    sub.l   #SCORE_DIGIT_SPACE_X ,d2    ; Move the drawing origin to the left
    
    bra     drawScoreLoop
    
stopDrawingScore:
* Update last player score for comparing next time we update the score
    move.l  PlayerScore, d0
    move.l  d7, LastPlayerScoreDec
    rts 
    
drawZeroScore:
* Special case where we draw a single digit of 0
* The general subroutine cannot handle this since it checks whether the digit is 0 or not
* And if it is, it stops drawing. So if the first digit is zero it just draws nothing.
    move.l  d0, d1
    jsr     drawSevenSegment
    
    rts

hexToDecimal:
* Converts hex to decimal e.g. 0xFFFF will turn into 65535
* Parameters:
* D0: Unsigned hexadecimal number (Up to 0xFFFF times 10 due to DIVU limitations)

* Returns:
* D7: Unsigned decimal number

* Other registers used: D1

    clr.l   d7
    move.b  #-4, d1                  ; D1 is the rotate counter
    
hexToDecimalLoop:
    ror.l   #4, d7                  ; Rotate the digit
    add.b   #4, d1
    
    divu    #BASE_TEN_DIVIDER, d0
    swap    d0
    add.b   d0, d7                  ; Move the remainder
    
    move.w  #0, d0                  ; Clear the remainder
    swap    d0                      ; Swap the quotient back to divide in the next iteration
    
    bne     hexToDecimalLoop

    rol.l   d1, d7                  ; Rotate back
    
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
