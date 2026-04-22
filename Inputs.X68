*-----------------------------------------------------------
* Title      : Input subroutines
* Written by : Pon Jumruspun
* Date       : 5/31/2024
* Description: Functions to handle inputs
*-----------------------------------------------------------

inputCycle:
    jsr     inputMonitoring         ; D7 contains direction enum after this
    rts

inputMonitoring:
    jsr     attackInputMonitoring
    jsr     movementInputMonitoring
    rts

movementInputMonitoring:
* Monitor movement input and return direction enum in D7

* Returns: 
* D7: Direction enum

* Other registers used: D0, D1, A1

    move.l  #-1, d7                 ; Start from -1 since we use a "do while" logic in the loop below
    move.l  #KEYCODES_WASD, d1
    move.l  #TASK_KEY_INPUT, d0
    trap    #15                     ; Check if WASD is pressed
    
    lea     KeycodeResponses, a1

loopInputCheck:
    add.l   #1, d7
    
    cmp.l   #DIRECTION_ENUM_LIMIT, d7   ; Check if direction out of range
    bgt     correctDirectionEnum
    
    cmp.l   (a1)+, d1                   ; Check if the keypress is recognized
    bne     loopInputCheck

    rts
    
correctDirectionEnum:
    clr.l   d7                      ; Set to no movement for now if the keypress not recognize (happens when 3 or more keys are pressed)
    rts

attackInputMonitoring:
* Monitoring whether player pressed the attack button this frame
* Returns: IsPlayerAttacking (heap memory)
    move.l  #KEYCODE_SPACE, d1
    move.l  #TASK_KEY_INPUT, d0
    trap    #15
    
    cmp.b   #$FF, d1
    beq     setAttackKeyPressed
    
* If we reach here, it means the attack key isn't pressed
    move.b  #FALSE, IsPlayerAttacking
    rts
    
setAttackKeyPressed:
* If we reach here, it means the attack key is pressed
    move.b  #TRUE, IsPlayerAttacking
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
