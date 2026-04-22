*-----------------------------------------------------------
* Title      : Player
* Written by : Pon Jumruspun
* Date       : 6/11/2024
* Description: Player character logic. Originally in GameLogic.
*-----------------------------------------------------------

initializePlayer:
* Initialize anything player-related, should be called when starting the game loop
    jsr     initializePlayerPosition
    jsr     initIsPlayerProjectileActive
    jsr     initPlayerAttackSpeed
    jsr     initPlayerLives
    jsr     initPlayerInvulTime
    jsr     initPlayerBlinkTime
    rts

initPlayerLives:
    move.l  #PLAYER_STARTING_LIVES, PlayerLives
    rts
    
initPlayerInvulTime:
    move.l  #0, PlayerInvulTime
    rts
    
initPlayerBlinkTime:
    move.l  #0, PlayerBlinkTime
    rts
    
initPlayerSpriteActive:
    move.b  #TRUE, PlayerSpriteActive
    rts

initPlayerAttackSpeed:
* Might be redundant since we already set the value in the initializePowerUpLevels function
    move.l  PowerUpAtkCdValues, PlayerAttackCooldown
    rts
    
initializePlayerPosition:
    move.l  #FPLAYER_START_X, FPlayerX
    move.l  #FPLAYER_START_Y, FPlayerY
    rts
    
initIsPlayerProjectileActive:
* Set everything to inactive initially
* Registers used: D0, A1
    move.l  #MAX_PLAYER_PROJECTILE-1, d0
    lea     IsProjectileActive, a1
    
initIsPlayerProjectileActiveLoop:
    move.b  #PLAYER_PROJ_STATUS_INACTIVE, (a1)+
    dbra    d0, initIsPlayerProjectileActiveLoop
    
    rts

playerUpdate:
    jsr     updatePlayerPosition    ; Need D7 from input cycle's return as its parameter 
    jsr     attemptSpawningPlayerProjectile
    jsr     updatePlayerProjectilePositions
    jsr     updatePlayerInvulTime
    rts

updatePlayerInvulTime:
* If invul time >= 0, then we decrease it by DeltaTime
* Otherwise don't do anything

* Registers used: D0

    cmp.l   #0, PlayerInvulTime
    ble     invulTimeReturn
    
* Player is invul right now, decrease the timer here
    move.l  DeltaTime, d0
    sub.l   d0, PlayerInvulTime
    
* Check whether we decrease it too much or not
    cmp.l   #0, PlayerInvulTime
    bgt     invulTimeReturn
    
* Zero or negative amount, set it 0 and reset the blinking time
    move.l  #0, PlayerInvulTime
    move.l  #0, PlayerBlinkTime
    move.b  #TRUE, PlayerSpriteActive
    
invulTimeReturn:
    rts

updatePlayerPosition:
* Save player's last position for drawing background chunk
* Note: Perhaps can check if the player move and only redraw if they do to optimize further

* Parameters:
* D7: Direction enum from input

* Other registers used: D1-D3, A0

* Handle player X position
    lsl.l   #2, d7                      ; Longword lookup table = 4 bytes
    lea     FDirectionMapX, a0
    move.l  (a0, d7), d1                ; D1 contains FDeltaX to be added to player's position X
    
    lsr.l   #HALF_FRACTIONAL_BITS, d1
    move.l  DeltaTime, d2               ; Scale by DeltaTime
    lsl.l   #HALF_FRACTIONAL_BITS, d2
    muls.w  d2, d1

    lsr.l   #HALF_FRACTIONAL_BITS, d1
    move.l  FPlayerSpeed, d2
    lsr.l   #HALF_FRACTIONAL_BITS, d2
    muls.w  d2, d1
    add.l   d1, FPlayerX
    
* Clamp LeftX value
    cmp.l   #FPLAYER_SCREEN_OFFSET_LEFT, FPlayerX
    bge     skipClampingLeftX
    
    move.l  #FPLAYER_SCREEN_OFFSET_LEFT, FPlayerX
    
skipClampingLeftX:
* Clamp RightX value
    cmp.l   #FPLAYER_SCREEN_OFFSET_RIGHT, FPlayerX
    ble     skipClampingRightX
    
    move.l  #FPLAYER_SCREEN_OFFSET_RIGHT, FPlayerX

skipClampingRightX:    
* Handle player Y position
    lea     FDirectionMapY, a0
    move.l  (a0, d7), d1                ; D1 contains FDeltaY to be added to player's position Y
    
    lsr.l   #HALF_FRACTIONAL_BITS, d1
    move.l  DeltaTime, d2               ; Scale by DeltaTime
    lsl.l   #HALF_FRACTIONAL_BITS, d2
    muls.w  d2, d1
    
    lsr.l   #HALF_FRACTIONAL_BITS, d1
    move.l  FPlayerSpeed, d2
    lsr.l   #HALF_FRACTIONAL_BITS, d2
    muls.w  d2, d1
    add.l   d1, FPlayerY

* Clamp UpperY value
    cmp.l   #FPLAYER_SCREEN_OFFSET_UPPER, FPlayerY
    bge     skipClampingUpperY
    
    move.l  #FPLAYER_SCREEN_OFFSET_UPPER, FPlayerY
    
skipClampingUpperY:
    cmp.l   #FPLAYER_SCREEN_OFFSET_LOWER, FPlayerY
    ble     skipClampingLowerY
    
    move.l  #FPLAYER_SCREEN_OFFSET_LOWER, FPlayerY
    
skipClampingLowerY:
    lsr.l   #2, d7                      ; Shift back so the variable isn't changed (might be unnecessary)
    rts
    
attemptSpawningPlayerProjectile:
* Check if the player is pressing the attack button
* If they are, check whether it's been enough time since last player has shot
* If it is, then create a new projectile

* Registers used: D0-D6, A1-A2

* Check if the attack button is being pressed
    cmp.b   #FALSE, IsPlayerAttacking
    beq     skipPlayerProjectileSpawning
    
* Check the time
    jsr     getTimeSinceMidnight
    sub.l   LastPlayerShootingTime, d1  ; D1 = Time between right now and last shooting
    cmp.l   PlayerAttackCooldown, d1
    blt     skipPlayerProjectileSpawning

* Spawn the projectile here
* Firstly, loop to find first SpreadLevel+1 inactive projectiles
    move.l  #-1, d0
    lea     IsProjectileActive, a1
    
    move.l  PowerUpSpreadLevel, PlayerProjToSpawn
    
playerProjectileSpawningLoop:
    add.l   #1, d0
    
    cmp.l   #MAX_PLAYER_PROJECTILE, d0
    bge     skipPlayerProjectileSpawning    ; There's more than max projectile allowed on the screen
   
    cmp.b   #PLAYER_PROJ_STATUS_INACTIVE, (a1, d0)
    beq     spawnPlayerProjectile           ; If it's inactive, then spawn
    
    bra     playerProjectileSpawningLoop
    
spawnPlayerProjectile:
    move.b  #PLAYER_PROJ_STATUS_ACTIVE, (a1, d0)    ; Flag as active
    move.l  d0, d3
    lsl.l   #2, d3                                  ; Long offset
    
* Set positions
* To spawn in the middle, we need parameters to be:
* ProjectileX = PlayerX + PlayerSizeX
    lea     FProjectilePosX, a2
    move.l  FPlayerX, d1
    add.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d1
    move.l  d1, (a2, d3)

* ProjectileY = PlayerY + PlayerSizeY/2 
*               - ProjectileSizeY 
*               + (PlayerProjToSpawn - (1/2) * SpreadLevel) 
*               * (Gap / (SpreadLevel + 1))

    lea     FProjectilePosY, a2
    move.l  FPlayerY, d1
    add.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS>>1, d1
    sub.l   #PLAYER_PROJECTILE_SIZE_Y<<FRACTIONAL_BITS>>1, d1   ; PlayerY + PlayerSizeY/2 
    
    move.l  PowerUpSpreadLevel, d2
    lsl.l   #FRACTIONAL_BITS>>1, d2                     ; To fixed point, mult by 1/2
    move.l  PlayerProjToSpawn, d4
    lsl.l   #FRACTIONAL_BITS, d4
    sub.l   d2, d4                                      ; PlayerProjToSpawn - (1/2) * SpreadLevel
    
    move.l  #FPLAYER_PROJ_SPREAD_GAP, d5
    move.l  PowerUpSpreadLevel, d6
    add.l   #1, d6
    divs    d6, d5
    swap    d5
    move.w  #0, d5
    swap    d5                                          ; Gap / (SpreadLevel - 1)
    
    lsr.l   #HALF_FRACTIONAL_BITS, d5
    lsr.l   #HALF_FRACTIONAL_BITS, d4                   ; Preshift
    
    muls    d5, d4
    add.l   d4, d1
    move.l  d1, (a2, d3)
    
* Loop back for spread mechanic
    sub.l   #1, PlayerProjToSpawn
    bpl     playerProjectileSpawningLoop
    
* Finish spawning
    jsr     getTimeSinceMidnight
    move.l  d1, LastPlayerShootingTime
    
    jsr     playPlayerShootingSound
    
skipPlayerProjectileSpawning:
    rts

updatePlayerProjectilePositions:
* Registers used: D0-D3, A1, A2
    move.l  #-1, d0
    lea     IsProjectileActive, a1
    
playerProjectilePositionLoop:
    add.l   #1, d0
    
    cmp.l   #MAX_PLAYER_PROJECTILE, d0
    bge     skipProjectilePositionUpdate
    
    cmp.b   #PLAYER_PROJ_STATUS_ACTIVE, (a1, d0)
    beq     moveProjectile
    
    bra     playerProjectilePositionLoop
    
moveProjectile:
* Move from left to right
    move.l  d0, d1
    lsl.l   #2, d1                          ; Long offset
    
    lea     FProjectilePosX, a2
    
    move.l  #FPLAYER_PROJECTILE_SPEED>>HALF_FRACTIONAL_BITS, d2     ; Preshifting for multiplication
    move.l  DeltaTime, d3
    lsl.l   #HALF_FRACTIONAL_BITS, d3       ; To fixed point and preshifting
    muls.w  d2, d3
    
    add.l   d3, (a2, d1)                    ; Move the D1th projectile to the right
    
* Check whether we have to kill the projectiles that are offscreen
    cmp.l   #WINDOW_WIDTH<<FRACTIONAL_BITS, (a2, d1)
    blt     skipKillingOffscreenProjectile
    
* Kill it here
    move.b  #PLAYER_PROJ_STATUS_INACTIVE, (a1, d0)
    
skipKillingOffscreenProjectile:
    bra     playerProjectilePositionLoop
    
skipProjectilePositionUpdate:
    rts
    
getProjectilePosition:
* Parameters:
* D2: Index of the projectile (make sure that it's active)

* Returns:
* D4: FPositionX of the projectile
* D5: FPositionY of the projectile

* Other registers used: A3
    lsl.l   #2, d2                          ; Long offset
    
    lea     FProjectilePosX, a3
    move.l  (a3, d2), d4
    
    lea     FProjectilePosY, a3
    move.l  (a3, d2), d5
    
    rts

onPlayerHit:
* Call this when the player is hit
* Check if they're invulnerable or not
    cmp.l   #0, PlayerInvulTime
    bgt     skipReducePlayerLives

* Reduces player's life by 1, if they hit negative, show gameover screen
    sub.l   #1, PlayerLives
    bmi     gameOver
    
* The player's not dead, set invul frame and initial blinking time
    move.l  #PLAYER_INVUL_TIME_AFTER_HIT, PlayerInvulTime
    move.l  #PLAYER_BLINK_TIME, PlayerBlinkTime
    
* Update the lives UI
    jsr     drawPlayerLivesCount
    
* Play hurt sound
    jsr     playPlayerHurtSound

skipReducePlayerLives:
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
