*-----------------------------------------------------------
* Title      : Powerups
* Written by : Pon Jumruspun
* Date       : 6/7/2024
* Description: Occasionally spawn powerups when enemies are killed.
*-----------------------------------------------------------

* Powerup ideas
* - Piercing projectiles
* - Player movement speed increase
* - Player attack speed increase

initializePowerUpSystem:
    jsr     initializePowerUpLevels
    jsr     initializeIsPowerUpActive
    rts

initializePowerUpLevels:
* Set every power-up level to 0, and update the values accordingly
    move.l  #0, PowerUpMoveSpeedLevel
    move.l  #0, PowerUpAtkSpeedLevel
    move.l  #0, PowerUpSpreadLevel
    jsr     updatePowerUpValues
    rts

initializeIsPowerUpActive:
* Loop through the IsPowerUpActive array and set them to inactive
* Registers used: D0, A1
    lea     IsPowerUpActive, a1
    move.l  #MAX_POWERUPS_ON_SCREEN-1, d0
    
initIsPowerUpActiveLoop:
    move.b  #POWERUP_STATUS_INACTIVE, (a1)+
    dbra    d0, initIsPowerUpActiveLoop
    
    rts
    
onPowerUpCollected:
    jsr     spawnPowerUpFloatingText        ; Needs D1 as true power-up index to look-up string
    rts
    
onPowerUpMoveSpeedCollected:
    jsr     onPowerUpCollected
    jsr     playPowerUpCollectedSound
    jsr     increasePowerUpMoveSpeedLevel
    rts
    
onPowerUpAtkSpeedCollected:
    jsr     onPowerUpCollected
    jsr     playPowerUpCollectedSound
    jsr     increasePowerUpAtkSpeedLevel
    rts
    
onPowerUpFuelCollected:
    jsr     onPowerUpCollected
    jsr     playSlurpSound
    jsr     increasePowerUpFuel
    rts
    
onPowerUpSpreadCollected:
    jsr     onPowerUpCollected
    jsr     playPowerUpCollectedSound
    jsr     increasePowerUpSpreadLevel
    rts

increasePowerUpMoveSpeedLevel:
* Increase the move speed power-up level by 1, doesn't do anything if is at max
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)

    cmp.l   #POWERUP_MAX_MOVE_SPEED_LEVEL, PowerUpMoveSpeedLevel
    bge     skipIncreaseMoveSpdLevel
    
    add.l   #1, PowerUpMoveSpeedLevel
    jsr     updatePowerUpValues
    
skipIncreaseMoveSpdLevel:
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp
    rts
    
increasePowerUpAtkSpeedLevel:
* Increase the attack speed power-up level by 1, doesn't do anything if is at max
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)

    cmp.l   #POWERUP_MAX_ATK_SPEED_LEVEL, PowerUpAtkSpeedLevel
    bge     skipIncreaseAtkSpdLevel
    
    add.l   #1, PowerUpAtkSpeedLevel
    jsr     updatePowerUpValues
    
skipIncreaseAtkSpdLevel:
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp
    rts 
    
increasePowerUpFuel:
* Increase fuel by collecting the power-up
* As the current fuel gets closer to 0, the more it increases
* Doesn't increase more than max
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)  
    
* Determine the amount
    move.l  CurrentFuel, d0
    lsl.l   #FRACTIONAL_BITS, d0
    divs    #MAX_FUEL, d0                   ; D0 contains FRatio of the fuel
    sub.l   #1<<FRACTIONAL_BITS, d0
    neg.l   d0                              ; Reverse it so it gives more if the ratio is low
    
    move.l  #POWERUP_MAX_FUEL_AMOUNT-POWERUP_MIN_FUEL_AMOUNT, d1
    muls    d0, d1
    lsr.l   #FRACTIONAL_BITS, d1
    add.l   #POWERUP_MIN_FUEL_AMOUNT, d1    ; D1 contains amount to increase

* Increases it
    add.l   d1, CurrentFuel
    cmp.l   #MAX_FUEL, CurrentFuel
    ble     skipAdjustFuelToMax
    
* Adjust fuel back to max
    move.l  #MAX_FUEL, CurrentFuel

skipAdjustFuelToMax:
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp
    rts

increasePowerUpSpreadLevel:
* Increase the spread power-up level by 1, doesn't do anything if is at max
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)

    cmp.l   #POWERUP_MAX_SPREAD_LEVEL, PowerUpSpreadLevel
    bge     skipIncreaseSpreadLevel
    
    add.l   #1, PowerUpSpreadLevel
    
skipIncreaseSpreadLevel:
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp
    rts 

spawnPowerUpFloatingText:
* Set string
* Relies on D3 earlier (power-up enum long offset)
* This is a bad design, consider improve if there's time
    lea     PowerUpStrings, a2
    movea.l (a2, d3), a1
    
* Set font properties
    move.l  #POWERUP_FONT_COLOR, FloatingTextColorArg
    move.l  #POWERUP_FONT_PROPS, FloatingTextPropsArg

* Set position
* Relies on the D1 earlier (power-up index)
* This is a bad design, consider improve if there's time
    lsl.l   #2, d1
    lea     FPowerUpPosY, a2
    move.l  (a2, d1), d2
    lea     FPowerUpPosX, a2
    move.l  (a2, d1), d1
    
* Save context for this function and spawnFloatingText
* Needs D1=LeftX, D2=UpperY
    sub.l   #LONG_OFFSET*8, sp
    movem.l d0-d4/a1-a3, (sp)
    
* Spawn it
    move.l  #FLOATING_TEXT_POWERUP_TTL, d0
    jsr     spawnFloatingText          
    
* Load context
    movem.l (sp), d0-d4/a1-a3
    add.l   #LONG_OFFSET*8, sp
    rts
    
powerUpUpdate:
* Update values anything power-up related for each frame
* Not to be confused with updatePowerUpValues
    jsr     updatePowerUpPositions
    rts
    
updatePowerUpValues:
* Get the power-up levels in the heap and apply the respective value to other memories in the heap

* Registers used: D0, A1

* Movement speed
    move.l  PowerUpMoveSpeedLevel, d0
    lea     FPowerUpMoveSpeedValues, a1
    lsl.l   #2, d0                          ; Long offset
    move.l  (a1, d0), FPlayerSpeed

* Attack speed
    move.l  PowerUpAtkSpeedLevel, d0
    lea     PowerUpAtkCdValues, a1
    lsl.l   #2, d0                          ; Long offset
    move.l  (a1, d0), PlayerAttackCooldown
    
    rts

attemptToSpawnPowerUp:
* Roll a random chance whether to spawn a power-up
* Then loop through the IsPowerUpActive array and check whether if there's an inactive power-up slot
* If there is, then spawn it at the dead enemy's location

* Parameters:
* FLastEnemyDeadX, FLastEnemyDeadY: Position of the last enemy dead which should be set when the enemy dies

* Registers used: D0-D2, D6-D7 (Random), A1-A2, A3 (Random)

* Roll a random chance here
	move.l	#100, d6
	jsr		randomRange						; D7 contains a random number [0, 99]
	
* Set chance for generic power-ups
	move.l	#POWERUP_SPAWN_CHANCE, d6

* Check if it's a fuel
	clr.l	d0
	move.b	PowerUpTypeToSpawn, d0
	cmp.l	#POWERUP_TYPE_FUEL, d0
	bne		skipOverwriteFuelChance
	
* Overwrite if it's fuel
	move.l	#POWERUP_FUEL_SPAWN_CHANCE, d6
	
skipOverwriteFuelChance:
* Return if unlucky
	cmp.l	d6, d7
	bge		skipSpawningPowerUp
    
* Loop trying to find an inactive power-up slot
    lea     IsPowerUpActive, a1
    move.l  #MAX_POWERUPS_ON_SCREEN-1, d0
    
spawnPowerUpLoop:
    cmp.b   #POWERUP_STATUS_INACTIVE, (a1)+
    beq     spawnPowerUp
    
continueSpawnPowerUpLoop:
    dbra    d0, spawnPowerUpLoop

* No power-up slot, just return
    rts
    
spawnPowerUp:
    move.l  d0, d1
    sub.l   #MAX_POWERUPS_ON_SCREEN-1, d1
    neg.l   d1                              ; D1 contains true power-up index
    
* Set active
    move.b  #POWERUP_STATUS_ACTIVE, -1(a1)
    
* Set the power-up's type
    lea     PowerUpType, a2
    move.b  PowerUpTypeToSpawn, (a2, d1)

    lsl.l   #2, d1                          ; D1 contains power-up index long offset 

* Set the power-up's position
    lea     FPowerUpPosX, a2
    move.l  FLastEnemyDeadX, d2
    sub.l   #ENEMY_SIZE_X<<FRACTIONAL_BITS, d2
    move.l  d2, (a2, d1)
    
    lea     FPowerUpPosY, a2
    move.l  FLastEnemyDeadY, d2
    sub.l   #ENEMY_SIZE_Y<<FRACTIONAL_BITS, d2
    move.l  d2, (a2, d1)

skipSpawningPowerUp:
    rts
    
updatePowerUpPositions:
* Loop through the IsPowerUpActive array and find active ones
* Then move them down, and check if they're offscreen

* Registers used: D0-D2, A1-A2
    lea     IsPowerUpActive, a1
    move.l  #MAX_POWERUPS_ON_SCREEN-1, d0

updatePowerUpPositionsLoop:
    cmp.b   #POWERUP_STATUS_ACTIVE, (a1)+
    bne     continuePowerUpPositionLoop
    
* Move the power-up here
    move.l  d0, d1
    sub.l   #MAX_POWERUPS_ON_SCREEN-1, d1
    neg.l   d1
    lsl.l   #2, d1                          ; D1 contains power-up index long offset
    
    move.l  #FPOWERUP_MOVEMENT_SPEED>>HALF_FRACTIONAL_BITS, d3
    move.l  DeltaTime, d2
    lsl.l   #HALF_FRACTIONAL_BITS, d2       ; Preshift
    muls.w  d2, d3
    
    lea     FPowerUpPosY, a2
    add.l   d3, (a2, d1)                    ; Move down
    
* Check offscreen
    cmp.l   #FPOWERUP_OFFSCREEN_Y, (a2, d1)
    ble     continuePowerUpPositionLoop

* Kill the power-up here
    move.b  #POWERUP_STATUS_INACTIVE, -1(a1)
    
continuePowerUpPositionLoop:
    dbra    d0, updatePowerUpPositionsLoop

* No more power-up, return
    rts













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
