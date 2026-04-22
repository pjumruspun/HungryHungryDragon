*-----------------------------------------------------------
* Title      : Fuel
* Written by : Pon Jumruspun
* Date       : 6/10/2024
* Description: Manager for fuel mechanics
*-----------------------------------------------------------

initializeFuel:
    move.l  #STARTING_FUEL, CurrentFuel
    rts

fuelUpdate:
* Fuel depletion
    jsr     fuelDepletionTick
    jsr     checkFuelDepleted
    rts
    
fuelDepletionTick:
* Registers used: D0, D1
    move.l  DeltaTime, d0
    lsl.l	#FRACTIONAL_BITS, d0
    move.l	FuelDepletionRate, d1
    mulu    d1, d0
    lsr.l	#FRACTIONAL_BITS, d0
    lsr.l	#FRACTIONAL_BITS, d0
    sub.l   d0, CurrentFuel
    rts
    
checkFuelDepleted:
* Check whether fuel is all depleted, if it is, then we'll kill the player
    cmp.l   #0, CurrentFuel
    bgt     skipKillingPlayerFuelDepleted
    
* Kill the player here
    jsr     gameOver
    
skipKillingPlayerFuelDepleted:
    rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
