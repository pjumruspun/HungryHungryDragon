*-----------------------------------------------------------
* Title      : Sin Table
* Written by : Pon Jumruspun
* Date       : 6/10/2024
* Description: Sin table to calculate enemy's positions in sin wave pattern
*-----------------------------------------------------------

SinRadian:
* Sin function but in radian
* Parameters: Angle in radian (Passes through heap)
* Returns: Sin value (D6)
    
* Convert radian to degree by multiplying by 180 and dividing by pi
* Multiply
    move.l  FSinRadianParam, d7
    muls    #FULL_CIRCLE_ANGLE>>1, d7

* Divide
    divs    #FPI, d7
    swap    d7
    move.w  #0, d7
    swap    d7                          ; Get the quotient only
    ext.l   d7                          ; Extend in case of negative
    
    move.l  d7, SinDegreeParam
    jsr     SinDegree
    rts

SinDegree:
* Parameters: Angle in degree (Passes through heap)
* Returns: Sin value (D6)

* Registers used: D7, A6

*** NOTE: ***
* Right now, simply round down and return the lower sin value

* More precise implementation idea if there's time:

* We divide the angle with the interval to get two things
* Index to look up in the table     : Quotient
* Linear proportion to step         : Remainder


* Get the modded value
    move.l  SinDegreeParam, d7
    divs    #FULL_CIRCLE_ANGLE, d7
    move.w  #0, d7
    swap    d7
    ext.l   d7
    
* Add and remod the full circle degree to handle negative angle values
    add.l   #FULL_CIRCLE_ANGLE, d7
    divs    #FULL_CIRCLE_ANGLE, d7
    move.w  #0, d7
    swap    d7
    
* Get the index of the lookup table
    divs    #SIN_ANGLE_INTERVAL, d7
    
* Clear the remainder
    swap    d7
    move.w  #0, d7
    swap    d7
    
* Look up the sin value
    lsl.l   #2, d7          ; Long offset
    lea     SinTable, a6
    move.l  (a6, d7), d6
    
    rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
