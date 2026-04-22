*-----------------------------------------------------------
* Title      : Physics
* Written by : Pon Jumruspun
* Date       : 6/5/2024
* Description: Basic phyics engine built initially for enemy's projectiles
*-----------------------------------------------------------

calculateNextVelocity:
* Calculate next velocity given current velocity and acceleration

* Parameters:
* D5: FCurrentVelocity
* D6: FAcceleration

* Returns:
* D5: NextVelocity

* Other registers used: D7

* NextVelocity = CurrentVelocity + Acceleration * DeltaTime
    move.l  DeltaTime, d7
    lsl.l   #HALF_FRACTIONAL_BITS, d7               ; FDeltaTime in hundredth seconds, preshifted
    lsr.l   #HALF_FRACTIONAL_BITS, d6               ; Preshift acceleration
    muls.w  d6, d7
    add.l   d7, d5
    rts

calculateNextPosition:
* Calculate next position given current position, current velocity, and acceleration

* Parameters:
* D4: FCurrentPosition
* D5: FCurrentVelocity
* D6: FAcceleration

* Returns:
* D4: FNextPosition

* Other registers used: D7

* NextPos = CurrentPos + CurrentVelocity * DeltaTime + 1/2 * Acceleration * DeltaTime * DeltaTime
    move.l  DeltaTime, d7
    lsl.l   #HALF_FRACTIONAL_BITS, d7               ; FDeltaTime in hundredth seconds, preshifted
    lsr.l   #HALF_FRACTIONAL_BITS, d5               ; Preshift
    muls.w  d7, d5
    add.l   d5, d4                                  ; + CurrentVelocity * DeltaTime
    
    lsr.l   #HALF_FRACTIONAL_BITS, d6               ; Preshift
    muls.w  d7, d6
    lsr.l   #HALF_FRACTIONAL_BITS, d6
    muls.w  d7, d6
    lsr.l   #1, d6                                  
    add.l   d6, d4                                  ; + 1/2 * Acceleration * DeltaTime * DeltaTime
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
