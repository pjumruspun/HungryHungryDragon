*-----------------------------------------------------------
* Title      : Enemy AI
* Written by : Pon Jumruspun
* Date       : 5/31/2024
* Description: Code related to enemy spawning or movement
*-----------------------------------------------------------

initializeEnemies:
    jsr     initializeEnemySpawnMechanics
    jsr     initializeEnemyProjMechanics
    jsr     initializeEnemyGroup
    rts

initializeEnemyGroup:
* Just need to set EnemySpawnedThisGroup to equal EnemyMaxThisGroup
* To trigger the next group spawn when we start the game
    move.l  #ENEMY_GROUP_SIZE_MAX, EnemyMaxThisGroup
    move.l  #ENEMY_GROUP_SIZE_MAX, EnemySpawnedThisGroup

    rts

initializeEnemyProjMechanics:
* Call this initially to tell the game that no projectile is active
* Registers used: D0, A1
    lea     IsEnemyProjectileActive, a1
    move.l  #MAX_ENEMY_PROJECTILE-1, d0
    
initEnemyProjLoop:
    move.b  #ENEMY_PROJ_STATUS_INACTIVE, (a1)+
    dbra    d0, initEnemyProjLoop
    rts

initializeEnemySpawnMechanics:
    jsr     initializeIsEnemyAlive
    jsr     initializeEnemySpawnTime
    rts

initializeIsEnemyAlive:
* Set everything to dead initially
* Registers used: D0, D1, A1
    move.l  #MAX_ENEMY_ALLOWED-1, d0
    lea     IsEnemyAlive, a1
    
initIsEnemyAliveLoop:
    move.b  #ENEMY_STATUS_DEAD, (a1)+
    dbra    d0, initIsEnemyAliveLoop
    rts

initializeEnemySpawnTime:
* Call this at the begin of the main game loop to set the time that enemy should spawn
* Registers used: D1
    jsr     getTimeSinceMidnight        ; D1 contains time since midnight
    move.l  d1, TimeSinceLastEnemySpawned
    rts
    
initializeEnemyProjTimeCounter:
* Should call this when enemy spawns
* Set time since enemy last shooting
* Parameters:
* D0: Offset index of the enemy (****Already scaled by long offset****)

* Other registers used: D1, A2
    jsr     getTimeSinceMidnight                ; D1 contains time since midnight
    lea     LastEnemyShootingTime, a2
    move.l  d1, (a2, d0)                        ; Set the D0'th enemy's last shooting time to now
    rts
    
enemyUpdate:
    jsr     attemptToSpawnEnemy
    jsr		enemyMovementUpdate
    jsr     enemyShootingUpdate
    jsr     enemyProjectilePositionUpdate
    rts
    
attemptToSpawnEnemy:
* Check whether it's been X hundredth seconds since last spawned yet
* Registers used:   D0-D5, A1, A2 (initializeEnemyProjTimeCounter), 
*                   D6-D7, A3 (random function)

* Check if we need to create a new group
    move.l  EnemySpawnedThisGroup, d0
    move.l  EnemyMaxThisGroup, d1
    cmp.l   d1, d0
    blt     skipNewGroup
    
* Need to spawn a new group here
    move.l  #ENEMY_GROUP_SIZE_MAX-ENEMY_GROUP_SIZE_MIN+1, d6
    jsr     randomRange
    add.l   #ENEMY_GROUP_SIZE_MIN, d7       ; D7 contains a random number from [ENEMY_GROUP_SIZE_MIN, ENEMY_GROUP_SIZE_MAX]

    move.l  d7, EnemyMaxThisGroup           ; Set this group's size
    move.l  #0, EnemySpawnedThisGroup       ; Reset the enemy count
    
* Enemies in the same group spawns at the same random Y location
    move.l  #ENEMY_MAX_SPAWN_Y, d6                  ; Random from [0, d6)
    jsr     randomRange                             ; D7 contains random int in the range
    add.l   #ENEMY_MIN_SPAWN_Y, d7
    lsl.l   #FRACTIONAL_BITS, d7                    ; To fixed point
    move.l  d7, FEnemyGroupRandomY                  ; Save for later

skipNewGroup:
    move.l  TimeSinceLastEnemySpawned, d2
    jsr     getTimeSinceMidnight            ; D1 contains time since midnight
    sub.l   d2, d1                          ; D1 contains hundredth seconds since last spawn
    move.l  TimeToSpawnEnemy, d4
    
    cmp.l   #0, EnemySpawnedThisGroup       ; If new fresh group, delay the first spawn time
    bgt     skipMultiplyTimeBetweenGroup
    
* Delay spawn time
    mulu    #ENEMY_TIME_MULT_BETWEEN_GROUP, d4
    
skipMultiplyTimeBetweenGroup:
    cmp.l   d4, d1
    bge     checkAliveArraySpawnEnemy
    rts
    
checkAliveArraySpawnEnemy:
* Increment enemy current group size counter
    add.l   #1, EnemySpawnedThisGroup
    
* Loop through the alive array to see if it's okay to spawn
    move.l  #-1, d0                         ; Offset
    lea     IsEnemyAlive, a1
    
checkAliveArraySpawnEnemyLoop:
* Should not ever loop back here after spawning an enemy
    add.l   #1, d0
    
    move.l  MaxEnemy, d4
    cmp.l	d4, d0			; If no slot to spawn, skip spawning
    bge		skipSpawn
    
    cmp.b   #ENEMY_STATUS_DEAD, (a1, d0)    
    beq     spawnEnemy                      ; If found an empty slot to spawn, then spawn
    
	bra		checkAliveArraySpawnEnemyLoop
    
spawnEnemy:
    move.b  #ENEMY_STATUS_ALIVE, (a1, d0)   ; Flag that this enemy is becoming alive
    
* Set enemy type
    move.l  #100, d6                        ; Random from hundred percent, 
    jsr     randomRange                     ; D7 contains a random number from 0-99
    
    lea     EnemySpawnRateArray, a1
    move.l  #ENEMY_TYPE_TOTAL-2, d5         ; -2 because we don't count normal enemy
    
    move.l  #100, d4                        ; We will subtract from D4 to see if it's the right type of enemy to spawn
    
setEnemyTypeLoop:
    move.l  d5, d6
    lsl.l   #2, d6                          ; Long offset
    sub.l   (a1, d6), d4                    ; Subtract spawn rate percentage
    cmp.l   d4, d7                          ; See if value is within range
    bge     setEnemyType
    dbra    d5, setEnemyTypeLoop
    
setEnemyType:
* Right after this D5 should contain EnemyTypeEnum-1
    add.l   #1, d5                          ; Add 1 back

    lea     EnemyTypes, a1
    move.b  d5, (a1, d0)                    ; Set enemy's type
    
    lsl.l   #2, d0                          ; Long offset
    jsr     initializeEnemyProjTimeCounter  ; Init some projectile mechanics
    
* Set position
    lea     FEnemyPosX, a1
    move.l  #FDEFAULT_ENEMY_POS_X, (a1, d0) ; Set enemy's X position

    lea     FEnemyPosY, a1
    move.l  FEnemyGroupRandomY, (a1, d0)    ; Set enemy's Y position
    
    lea     FEnemyStartPosY, a1
    move.l  FEnemyGroupRandomY, (a1, d0)    ; Set enemy's initial Y position for sin wave movement


skipSpawn:
    jsr     getTimeSinceMidnight            ; D1 contains time since midnight
    move.l  d1, TimeSinceLastEnemySpawned   ; Reset timer
    
    rts
    
enemyMovementUpdate:
* Loop through the alive array to see if it needs to be moved
* Registers used: D0-D4, D6-D7 (Sin function), A1-A3
    move.l  #-1, d0                         ; Offset
    lea     IsEnemyAlive, a1

checkAliveArrayEnemyMovementLoop:
	add.l	#1, d0
	
	cmp.l	#MAX_ENEMY_ALLOWED, d0			; If is at the end of the array, return
	bge		skipMovement
	
	cmp.b	#ENEMY_STATUS_ALIVE, (a1, d0)	; Check to see if we need to move an alive enemy
	beq		moveEnemy
	
	bra		checkAliveArrayEnemyMovementLoop
	
moveEnemy:
* For horizontal movement, we simply move from right to left
* For vertical movement, we move to its sin value corresponded to the horizontal position

* Horizontal movement
	move.l	d0, d1
	lsl.l	#2, d1							; Long offset
	
	move.l  #FENEMY_SPEED, d3
	
* Multiply by difficulty speed modifier
    move.l  DifficultyLevel, d4
    muls    #FENEMY_SPEED_DIFF_MULT, d4
    add.l   #1<<FRACTIONAL_BITS, d4
    muls    d4, d3
    lsr.l   #FRACTIONAL_BITS, d3
	
* Add enemy speed if nimble
    lea     EnemyTypes, a2
    cmp.b   #ENEMY_TYPE_NIMBLE, (a2, d0)
    bne     skipAddingNimbleEnemySpeed
    
* Is nimble enemy, add speed here
    add.l   #FENEMY_NIMBLE_SPEED_BONUS, d3
    
skipAddingNimbleEnemySpeed:
	lsr.l   #HALF_FRACTIONAL_BITS, d3
    move.l  DeltaTime, d2                   ; Scale by DeltaTime
    lsl.l   #HALF_FRACTIONAL_BITS, d2
    muls.w  d2, d3
	
	lea		FEnemyPosX, a2
	sub.l	d3, (a2, d1)			        ; Move the D1'th enemy to the left
	
* Vertical movement
* We have sin equation offset: y = Amplitude * Sin (x/period) + yShift
* x = FEnemyPosX - FScreenWidth
* yShift = FEnemyStartPosY

* Calculate x for the sin function
    move.l  (a2, d1), d3                    ; D3 contains FEnemyPosX
    sub.l   #WINDOW_WIDTH<<FRACTIONAL_BITS, d3
    neg.l   d3
    
    divs    #ENEMY_SIN_PERIOD, d3
    swap    d3
    move.w  #0, d3
    swap    d3                              ; Divide by period
    ext.l   d3                              ; Extend in case of negative    

* Call sin function
    move.l  d3, FSinRadianParam
	jsr     SinRadian                       ; D6 contains sin value of the given D3 in radian
	
	muls    #ENEMY_SIN_AMP, d6              ; Multiply by amplitude to get the offset

* Add the initial shift to get the actual Y position
    lea     FEnemyStartPosY, a2
    move.l  (a2, d1), d2
    add.l   d2, d6
    
* Set the Y position
    lea     FEnemyPosY, a2
    move.l  d6, (a2, d1)
	
* Check if the enemy is offscreen
    lea		FEnemyPosX, a2
    cmp.l   #-ENEMY_SIZE_X<<FRACTIONAL_BITS, (a2, d1)
    bge     skipKillingOffscreenEnemy
    
* Kill offscreen enemies
    move.b  #ENEMY_STATUS_DEAD, (a1, d0)
 
skipKillingOffscreenEnemy:	
* Branch back to see if there's any other enemies that needs to be moved
	bra		checkAliveArrayEnemyMovementLoop

skipMovement:
	rts

enemyShootingUpdate:
* Loop through enemies, if they're alive, check if it's been enough time since they last shot
* If it is, then set an enemy projectile to active

* NOTE: This function uses multiple contexts as it has unusual nested loops
* Becareful when using registers and make sure it has the right value for its context

* Registers used: EVERY REGISTER

    lea     IsEnemyAlive, a1
    move.l  #MAX_ENEMY_ALLOWED-1, d0
    
enemyAttemptShootingLoop:
    move.l  d0, d2
    sub.l   #MAX_ENEMY_ALLOWED-1, d2
    neg.l   d2                              ; D2 is the true index
    
    cmp.b   #ENEMY_STATUS_ALIVE, (a1)+
    bne     skipSetEnemyProjectileActive
    
* If we reach here, then enemy is alive. See if it's been enough time since it last shot.
    move.l  d2, d3
    lsl.l   #2, d3                                  ; Long offset
    lea     LastEnemyShootingTime, a6
    move.l  (a6, d3), d4                            ; D4 contains time since last enemy shot
    jsr     getTimeSinceMidnight                    ; D1 contains time now
    sub.l   d4, d1                                  ; Time between last shot and now

* Get generic enemy shooting time
    move.l  EnemyShootingTime, d4

* Check if it's a fierce enemy which has different attack cooldown
    lea     EnemyTypes, a6
    cmp.b   #ENEMY_TYPE_FIERCE, (a6, d2)
    bne     skipFierceEnemyShooting

* Fierce enemy, multiply by the fierce enemy ratio constant
    mulu    #FFIERCE_ENEMY_SHOOTING_RATIO, d4
    lsr.l   #FRACTIONAL_BITS, d4                    ; To integer

skipFierceEnemyShooting:
* Add some variance here
    move.l  #ENEMY_SHOOTING_TIME_VARIANCE, d6
    jsr     randomRange                             ; D7 contains a random number in range of [0, d6)
    sub.l   #ENEMY_SHOOTING_TIME_VARIANCE>>1, d7
    add.l   d7, d4
    
* Compare here
    cmp.l   d4, d1
    blt     skipSetEnemyProjectileActive            ; Skip if not enough time has passed

* It's been enough time since last time this enemy has shot, so it will shoot again here.
* Play sound
    jsr     playEnemyShootingSound

    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)                           ; Save context

***** START OF THE ENEMY PROJECTILE CONTEXT *****
* Loop to find the first inactive projectile
    move.l  #MAX_ENEMY_PROJECTILE-1, d0
    lea     IsEnemyProjectileActive, a2
    
    move.l  d2, d6                                  ; Enemy index, will use this to get enemy's pos
    
findEnemyInactiveProjLoop:
    cmp.b   #ENEMY_PROJ_STATUS_INACTIVE, (a2)+
    beq     setEnemyProjActive
    
    dbra    d0, findEnemyInactiveProjLoop
    
* Run of out projectile array to spawn

    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp                     ; Load context
    
    bra     skipSetEnemyProjectileActive            ; Exceed the projectile limit
    
setEnemyProjActive:
    move.l  d0, d2
    sub.l   #MAX_ENEMY_PROJECTILE-1, d2
    neg.l   d2                                      ; D2 contains enemy projectile index
    
    move.b  #ENEMY_PROJ_STATUS_ACTIVE, -1(a2)       ; Sets the first inactive projectile to active

* Set the initial position to enemy's position for now
    move.l  d2, d3
    lsl.l   #2, d3                                  ; Long offset * Proj index
    move.l  d6, d2                                  ; Enemy index from earlier
    
    jsr     getEnemyPosition                        ; D2 from above is used and mutated
                                                    ; D6 and D7 contains positions
    
    lea     FEnemyProjectileX, a4                                            
    move.l  d6, (a4, d3)                            ; Set FEnemyProjectileX
    
    lea     FEnemyProjectileY, a4
    move.l  d7, (a4, d3)                            ; Set FEnemyProjectileY
    
* Get a ratio of the enemy position
* If the enemy is at the top of the screen, it should be 0
* If the enemy is at the bottom of the screen, it should be 1

	divu	#BACKGROUND_ORIGIN, d7					; D7 contains a fixed point of range [0, 1]
	swap	d7
	move.w	#0, d7
	swap	d7										; Get the quotient
	move.l	#FENEMY_INIT_PROJ_SPEED_Y_MAX-FENEMY_INIT_PROJ_SPEED_Y_MIN, d6
	mulu	d6, d7
	lsr.l	#8, d7
	add.l	#FENEMY_INIT_PROJ_SPEED_Y_MIN, d7
	neg.l	d7

    lea     FEnemyProjectileVY, a4
    move.l  d7, (a4, d3)  							; Set initial speed
                                                        ; Negative because physics and screen
                                                        ; Y-axis are flipped

***** END OF THE ENEMY PROJECTILE CONTEXT *****  
  
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp                     ; Load context

    jsr     getTimeSinceMidnight
    lea     LastEnemyShootingTime, a6
    move.l  d1, (a6, d3)                            ; Mark the time that this enemy just shot
    
skipSetEnemyProjectileActive:
    dbra    d0, enemyAttemptShootingLoop

    rts

enemyProjectilePositionUpdate:
* Registers used: D0-D7, A1-A2
    move.l  #MAX_ENEMY_PROJECTILE-1, d0
    lea     IsEnemyProjectileActive, a1

    
enemyProjPositionUpdateLoop:
* Check if the projectile is active, if it is, then move it
    cmp.b   #ENEMY_PROJ_STATUS_ACTIVE, (a1)+
    bne     continueMovingEnemyProjLoop
    
* Update FEnemyProjectileX
    move.l  d0, d1
    sub.l   #MAX_ENEMY_PROJECTILE-1, d1
    neg.l   d1                                      ; D1 contains true projectile index
    lsl.l   #2, d1                                  ; Long offset

    lea     FEnemyProjectileX, a2
    
    move.l  #FENEMY_PROJECTILE_SPEED_X>>HALF_FRACTIONAL_BITS, d2  ; Preshifting for mult
    move.l  DeltaTime, d3
    lsl.l   #HALF_FRACTIONAL_BITS, d3               ; To fixed point and preshifting
    muls.w  d2, d3
    
    sub.l   d3, (a2, d1)
    
* Update FEnemyProjectileY
* First, update the position based on current position, velocity, and acceleration
    lea     FEnemyProjectileY, a2
    move.l  (a2, d1), d4                            ; Current Y position
    lea     FEnemyProjectileVY, a2
    move.l  (a2, d1), d5                            ; Current Y velocity
    move.l  #FGRAVITY_ACCELERATION, d6              ; Constant gravity
    
    jsr     calculateNextPosition                   ; D4 contains next Y position
    
    lea     FEnemyProjectileY, a2
    move.l  d4, (a2, d1)                            ; Save the new position

* Then update the velocity
    lea     FEnemyProjectileVY, a2
    move.l  (a2, d1), d5                            ; Current Y velocity
    move.l  #FGRAVITY_ACCELERATION, d6              ; Constant gravity
    
    jsr     calculateNextVelocity                   
    lea     FEnemyProjectileVY, a2
    move.l  d5, (a2, d1)                            ; Save the new velocity
    
* Check whether we have to kill the projectiles that are offscreen
* checkEnemyProjOffscreenX:
    lea     FEnemyProjectileX, a2
    cmp.l   #0, (a2, d1)
    bgt     checkEnemyProjOffscreenY
    
* Kill the projectile here for X offscreen
    move.b  #ENEMY_PROJ_STATUS_INACTIVE, -1(a1)
    
checkEnemyProjOffscreenY:
    lea     FEnemyProjectileY, a2
    cmp.l   #WINDOW_HEIGHT<<FRACTIONAL_BITS, (a2, d1)
    blt     continueMovingEnemyProjLoop
    
* Kill the projectile here for Y offscreen
    move.b  #ENEMY_PROJ_STATUS_INACTIVE, -1(a1)

continueMovingEnemyProjLoop:
    dbra    d0, enemyProjPositionUpdateLoop
    rts
    
onEnemyHit:
* Should call this when enemy is hit with a player's projectile in collision code
* Parameters:
* D0: DBRA enemy loop counter (used for calculating enemy index)
* A1: IsEnemyAlive pointer (after incremented in the collision loop)
* A2: IsProjectileActive pointer (after incremented in the collision loop)

* Other registers used: A3

* Play sound
    jsr     playEnemyDeathSound

* Destroy both enemy and projectile
    move.b  #ENEMY_STATUS_DEAD, -1(a1)                  ; Since we post incremental we need to offset back
    move.b  #PLAYER_PROJ_STATUS_INACTIVE, -1(a2)
    
* Get the enemy type enum
    move.l  d0, d2
    sub.l   #MAX_ENEMY_ALLOWED-1, d2                
    neg.l   d2                                          ; Recalculate enemy's index just to be safe
    
    lea     EnemyTypes, a3
    clr.l   d4
    move.b  (a3, d2), d4                                ; D4 contains enemy type enum
    lsl.l   #2, d4                                      ; Long offset
    
* Update the score here
    lea     EnemyScoreBounty, a3
    move.l  (a3, d4), d5
    add.l   d5, PlayerScore
    
* Spawn score floating text
    jsr     getEnemyPosition                            ; Takes true enemy index D2, output D6, D7 = FEnemyX, FEnemyY
    
* Set color and properties
    move.l  #SCORE_FLOATING_TEXT_COLOR, FloatingTextColorArg
    move.l  #SCORE_FLOATING_TEXT_PROPS, FloatingTextPropsArg
    
    sub.l   #LONG_OFFSET*8, sp
    movem.l d0-d4/a1-a3, (sp)

* Set String address
* Quick and dirty method for now
    lea     StrEnemyScoreBountyArr, a1
    move.l  (a1, d4), a1
    
* Set position
    move.l  d6, d1
    move.l  d7, d2
    
* Set TTL
    move.l  #SCORE_FLOATING_TEXT_TTL, d0
    
    jsr     spawnFloatingText
    
    movem.l (sp), d0-d4/a1-a3
    add.l   #LONG_OFFSET*8, sp

* D0-D7, A1 is being used in drawScore subroutine
* A2 might be excessive and not needed to be saved
    sub.l   #LONG_OFFSET*11, sp
    movem.l d0-d7/a1-a3, (sp)                           ; Save context
    
    jsr     drawScore
    
    movem.l (sp), d0-d7/a1-a3
    add.l   #LONG_OFFSET*11, sp                         ; Load context

* Set the type of power-up to spawn
* D4 contains enemy type enum
    lsr.l   #2, d4                                      ; Revert long offset

    cmp.b   #ENEMY_TYPE_NIMBLE, d4
    beq     setPowerUpSpawnMoveSpeed
    
    cmp.b   #ENEMY_TYPE_FIERCE, d4
    beq     setPowerUpSpawnAtkSpeed
    
    cmp.b   #ENEMY_TYPE_SPECIAL, d4
    beq     setPowerUpSpawnSpread
    
* Other kinds of enemy died
* Set to spawn fuel power-up for now
    move.b  #POWERUP_TYPE_FUEL, PowerUpTypeToSpawn
    bra     onEnemyDeadSpawnPowerUp
    
setPowerUpSpawnMoveSpeed:
    move.b  #POWERUP_TYPE_MOVE_SPEED, PowerUpTypeToSpawn
    bra     onEnemyDeadSpawnPowerUp
setPowerUpSpawnAtkSpeed:
    move.b  #POWERUP_TYPE_ATK_SPEED, PowerUpTypeToSpawn
    bra     onEnemyDeadSpawnPowerUp
setPowerUpSpawnSpread:
    move.b  #POWERUP_TYPE_SPREAD, PowerUpTypeToSpawn
    bra     onEnemyDeadSpawnPowerUp
    
onEnemyDeadSpawnPowerUp:
* Spawning powerup uses D0-D1, D6-D7, A1-A3, but we'll save all data register for easy-to-read code
    sub.l   #LONG_OFFSET*11, sp
    movem.l d0-d7/a1-a3, (sp)
    
* Passing spawn power-up position parameters in heap
    move.l  d6, FLastEnemyDeadX                         ; From getEnemyPosition jsr above
    move.l  d7, FLastEnemyDeadY
    
    jsr     attemptToSpawnPowerUp
    
    movem.l (sp), d0-d7/a1-a3
    add.l   #LONG_OFFSET*11, sp
    
    rts

getEnemyPosition:
* Parameters:
* D2: Index of the enemy (make sure that it is alive!) 
    
* Returns:
* D6: FPositionX of the enemy
* D7: FPositionY of the enemy

* Other registers used: A3
    lsl.l   #2, d2                          ; Long offset
    
    lea     FEnemyPosX, a3
    move.l  (a3, d2), d6
    
    lea     FEnemyPosY, a3
    move.l  (a3, d2), d7
    
    rts

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
