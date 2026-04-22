*-----------------------------------------------------------
* Title      : Floating Text
* Written by : Pon Jumruspun
* Date       : 6/11/2024
* Description: Floating text for UI purposes
*-----------------------------------------------------------

initFloatingText:
* Set all IsFloatingTextActive to inactive
* Registers used: D0, A1
    move.l  #MAX_FLOATING_TEXT-1, d0
    lea     IsFloatingTextActive, a1
    
initFloatingTextLoop:
    move.b  #FLOATING_TEXT_STATUS_INACTIVE, (a1)+
    dbra    d0, initFloatingTextLoop
    
    rts
    
spawnFloatingText:
* Spawn floating text with null-terminated string at A1 for D0 time unit
* Parameters:
* A1: String Address
* D0: Time to live in hundredth seconds
* D1: FloatingText's FLeftX
* D2: FloatingText's FUpperY

* Other registers used: D1-D4, A2-A3

* Loop through IsFloatingTextActive and find the first inactive one
    move.l  #MAX_FLOATING_TEXT-1, d3
    lea     IsFloatingTextActive, a2
    
spawnFloatingTextLoop:
    cmp.b   #FLOATING_TEXT_STATUS_INACTIVE, (a2)+
    bne     continueSpawnFloatingText

* Found inactive FloatingText, set it to active
    move.b  #FLOATING_TEXT_STATUS_ACTIVE, -1(a2)

* Get the long-offset index
    move.l  d3, d4
    sub.l   #MAX_FLOATING_TEXT-1, d4
    neg.l   d4
    lsl.l   #2, d4
    
* Set the null-terminated string address
    lea     FloatingTextStrAddr, a3
    move.l  a1, (a3, d4)

* Set time to live as well as its age
    lea     FloatingTextDuration, a3
    move.l  d0, (a3, d4)

    lea     FloatingTextAge, a3
    move.l  #0, (a3, d4)
    
* Set position
    lea     FFloatingTextX, a3
    move.l  d1, (a3, d4)
    lea     FFloatingTextY, a3
    move.l  d2, (a3, d4)
    
* Set font color
    lea     FloatingTextColors, a3
    move.l  FloatingTextColorArg, (a3, d4)

* Set font properties
    lea     FloatingTextProps, a3
    move.l  FloatingTextPropsArg, (a3, d4)
    
    rts

continueSpawnFloatingText:
    dbra    d3, spawnFloatingTextLoop
    rts
    
floatingTextUpdate:
* Loop through IsFloatingTextActive to find active ones
* Registers used: D0-D3, A1
    move.l  #MAX_FLOATING_TEXT-1, d0
    lea     IsFloatingTextActive, a1
    
floatingTextUpdateLoop:
    cmp.b   #FLOATING_TEXT_STATUS_ACTIVE, (a1)+
    bne     continueFloatingTextUpdateLoop
    
* Found an active one, get the index
    move.l  d0, d1
    sub.l   #MAX_FLOATING_TEXT-1, d1
    neg.l   d1
    lsl.l   #2, d1                              ; Long offset

* Move it up
    move.l  DeltaTime, d2
    lsl.l   #HALF_FRACTIONAL_BITS, d2           ; Preshift
    mulu    #FFLOATING_TEXT_MOVE_SPEED>>HALF_FRACTIONAL_BITS, d2

    lea     FFloatingTextY, a2
    sub.l   d2, (a2, d1)
    
* Increase its age by DeltaTime
    move.l  DeltaTime, d2
    lea     FloatingTextAge, a2
    add.l   d2, (a2, d1)

* Check if it should be killed
    move.l  (a2, d1), d2                        ; D2 contains age
    lea     FloatingTextDuration, a2
    move.l  (a2, d1), d3
    cmp.l   d2, d3
    bge     continueFloatingTextUpdateLoop      ; If duration >= age, we don't kill

* Kill it here
    move.b  #FLOATING_TEXT_STATUS_INACTIVE, -1(a1)

continueFloatingTextUpdateLoop:
    dbra    d0, floatingTextUpdateLoop
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
