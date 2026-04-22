*-----------------------------------------------------------
* Title      : Collision
* Written by : Pon Jumruspun
* Date       : 6/3/2024
* Description: Collision Detection Subroutines
*-----------------------------------------------------------

enemyCollisionUpdate:
* Collision between enemy and player's projectiles
* Will have to compare every pair of enemy and projectile's positions
* This will be O(ProjectileCount * EnemyCount) and will be called each frame

* Registers used: D0-D2, D3 (in drawScore), D4-D7, A1-A3 (A3 being used in get position)

* First, loop through the enemy and get their positions
    move.l  #MAX_ENEMY_ALLOWED-1, d0
    move.l  #MAX_PLAYER_PROJECTILE-1, d1
    
    lea     IsEnemyAlive, a1
    lea     IsProjectileActive, a2
    
enemyCollisionLoop:
    cmp.b   #ENEMY_STATUS_ALIVE, (a1)+
    bne     continueEnemyCollisionLoop              ; If not alive, just continue to the next enemy
    
    lea     IsProjectileActive, a2
    move.l  #MAX_PLAYER_PROJECTILE-1, d1
    
playerProjectileCollisionLoop:
    cmp.b   #PLAYER_PROJ_STATUS_ACTIVE, (a2)+
    bne     continuePlayerProjCollisionLoop         ; If projectile not active, continue
    
* By this point, enemy at a1 should be alive and the projectile should also be active
    move.l  d0, d2
    sub.l   #MAX_ENEMY_ALLOWED-1, d2                
    neg.l   d2                                      ; D2 should contain enemy's index
    
    jsr     getEnemyPosition                        ; D6, D7 should contain enemy's position
    
    move.l  d1, d2
    sub.l   #MAX_PLAYER_PROJECTILE-1, d2            
    neg.l   d2                                      ; D2 should contain projectile index
    
    jsr     getProjectilePosition                   ; D4, D5 should contain projectile's position
    
* Compare enemy's hitbox and player's projectile here
* To properly collide we need all conditions to be true:
* (1) ProjectileY (D5)  >=  EnemyY (D7)
* (2) ProjectileY (D5)  <=  EmemyY (D7) + EnemySizeY
* (3) ProjectileX (D4)  >=  EnemyX (D6) - ProjectileSizeX
* (4) ProjectileX (D4)  <=  EnemyX (D6) + EnemySizeX

* Check (1)
    cmp.l   d7, d5
    blt     continuePlayerProjCollisionLoop
* Check (2)
    add.l   #ENEMY_SIZE_Y<<FRACTIONAL_BITS, d7
    cmp.l   d7, d5
    bgt     continuePlayerProjCollisionLoop
* Check (3)
    sub.l   #PLAYER_PROJECTILE_SIZE_X<<FRACTIONAL_BITS, d6
    cmp.l   d6, d4
    blt     continuePlayerProjCollisionLoop
* Check (4)
    add.l   #PLAYER_PROJECTILE_SIZE_X<<FRACTIONAL_BITS, d6  ; Add back from check (3)
    add.l   #ENEMY_SIZE_X<<FRACTIONAL_BITS, d6
    cmp.l   d6, d4
    bgt     continuePlayerProjCollisionLoop
    
* All checks passed if we reach here, which mean we need to handle the collision

    cmp.b   #ENEMY_STATUS_ALIVE, -1(a1)                 ; This enemy might've been killed by another proj
    bne     continuePlayerProjCollisionLoop             ; So we have to recheck here
    
    jsr     onEnemyHit                                  ; Uses A1, A2 from the loop

continuePlayerProjCollisionLoop:
    dbra    d1, playerProjectileCollisionLoop
    
continueEnemyCollisionLoop:
    dbra    d0, enemyCollisionLoop
    
    rts

playerCollisionUpdate:
* Collision between player and enemy's projectiles + enemies itself
* This will be O(EnemyProjectileCount + EnemyCount) and will be called each frame
    
* Registers used: D0-D4, D6-D7, A1-A2

    move.l  #MAX_ENEMY_PROJECTILE-1, d0
    lea     IsEnemyProjectileActive, a1

enemyProjCollisionLoop:
    cmp.b   #ENEMY_PROJ_STATUS_ACTIVE, (a1)+
    bne     continueEnemyProjCollisionLoop
    
* The projectile is active, check positions
* Collision happens if
* (1) ProjectileX >= PlayerX
* (2) ProjectileX <= PlayerX + PlayerSizeX
* (3) ProjectileY >= PlayerY
* (4) ProjectileY <= PlayerY + PlayerSizeY

    move.l  d0, d1
    sub.l   #MAX_ENEMY_PROJECTILE-1, d1
    neg.l   d1                                          ; D1 has true projectile index
    lsl.l   #2, d1                                      ; Long offset
    
    lea     FEnemyProjectileX, a2
    move.l  (a2, d1), d2                                ; FProjectileX
    move.l  FPlayerX, d3
    
* Check (1)
    cmp.l   d3, d2
    blt     continueEnemyProjCollisionLoop
    
* Check (2)
    add.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d3
    cmp.l   d3, d2
    bgt     continueEnemyProjCollisionLoop
    
    lea     FEnemyProjectileY, a2
    move.l  (a2, d1), d2                                ; FProjectileY
    move.l  FPlayerY, d3
    
* Check (3)
    cmp.l   d3, d2
    blt     continueEnemyProjCollisionLoop
    
* Check (4)
    add.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS, d3
    cmp.l   d3, d2
    bgt     continueEnemyProjCollisionLoop
    
* Passed all checks, collision happens here
    jsr     onPlayerHit
    
continueEnemyProjCollisionLoop
    dbra    d0, enemyProjCollisionLoop
    
* Here, the player didn't collide with enemy projectiles
* Try checking enemies themselves too
    
    move.l  #MAX_ENEMY_ALLOWED-1, d0
    lea     IsEnemyAlive, a1
    
playerEnemyCollisionLoop:
    cmp.b   #ENEMY_STATUS_ALIVE, (a1)+    
    bne     continuePlayerEnemyColLoop
    
* Enemy is alive, check if it touches the player
    move.l  d0, d2
    sub.l   #MAX_ENEMY_ALLOWED-1, d2                
    neg.l   d2                                      ; D2 should contain enemy's index
    
    jsr     getEnemyPosition                        ; D6, D7 should contain enemy's position
    
* Get player positions
    move.l  FPlayerX, d3
    move.l  FPlayerY, d4

* To properly collide we need all conditions to be true:
* (1) PlayerY (D4)  >=  EnemyY (D7) - PlayerSizeY
* (2) PlayerY (D4)  <=  EmemyY (D7) + EnemySizeY
* (3) PlayerX (D3)  >=  EnemyX (D6) - PlayerSizeX
* (4) PlayerX (D3)  <=  EnemyX (D6) + EnemySizeX
    
* Check (1)
    sub.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS, d7
    cmp.l   d7, d4
    blt     continuePlayerEnemyColLoop

* Check (2)
    add.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS, d7 ; Readd from check (1)
    add.l   #ENEMY_SIZE_Y<<FRACTIONAL_BITS, d7
    cmp.l   d7, d4
    bgt     continuePlayerEnemyColLoop
    
* Check (3)
    sub.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d6
    cmp.l   d6, d3
    blt     continuePlayerEnemyColLoop
    
* Check (4)
    add.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d6 ; Readd from check (3)
    add.l   #ENEMY_SIZE_X<<FRACTIONAL_BITS, d6
    cmp.l   d6, d3
    bgt     continuePlayerEnemyColLoop
    
* Here, the player had collided with the enemy
    jsr     onPlayerHit
    
continuePlayerEnemyColLoop:
    dbra    d0, playerEnemyCollisionLoop
    rts

powerUpCollisionUpdate:
* Loop through the powerUp array, find an active one
* And see if the player and power-up's position overlaps
* Registers used: D0-D4, A1-A2
    move.l  #MAX_POWERUPS_ON_SCREEN-1, d0
    lea     IsPowerUpActive, a1

powerUpCollisionLoop:
    cmp.b   #POWERUP_STATUS_ACTIVE, (a1)+
    bne     continuePowerUpCollisionLoop
    
* Check if the power-up collides with the player
* Collision happens if
* (1) PlayerX (D4) >= PowerUpX (D2) - PlayerSizeX
* (2) PlayerX (D4) <= PowerUpX (D2) + PowerUpSize
* (3) PlayerY (D5) >= PowerUpY (D3) - PlayerSizeY
* (4) PlayerY (D5) <= PowerUpY (D3) + PowerUpSize

* First, get the long-offset index
    move.l  d0, d1
    sub.l   #MAX_POWERUPS_ON_SCREEN-1, d1
    neg.l   d1                                      ; D1 has true power-up index
    lsl.l   #2, d1                                  ; Long offset
    
* Get the power-up's position
    lea     FPowerUpPosX, a2
    move.l  (a2, d1), d2
    
    lea     FPowerUpPosY, a2
    move.l  (a2, d1), d3
    
* Get the player positions
    move.l  FPlayerX, d4
    move.l  FPlayerY, d5

* Check (1)
    sub.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d2
    cmp.l   d2, d4
    blt     continuePowerUpCollisionLoop
    
* Check (2)
    add.l   #PLAYER_SIZE_X<<FRACTIONAL_BITS, d2     ; Add back from check (1)
    add.l   #POWERUP_SIZE<<FRACTIONAL_BITS, d2
    cmp.l   d2, d4
    bgt     continuePowerUpCollisionLoop
    
* Check (3)
    sub.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS, d3
    cmp.l   d3, d5
    blt     continuePowerUpCollisionLoop
    
* Check (4)  
    add.l   #PLAYER_SIZE_Y<<FRACTIONAL_BITS, d3     ; Add back from check (3)
    add.l   #POWERUP_SIZE<<FRACTIONAL_BITS, d3
    cmp.l   d3, d5
    bgt     continuePowerUpCollisionLoop
    
* All checks passed, collision happens here
    move.b  #POWERUP_STATUS_INACTIVE, -1(a1)        ; Set inactive
   
* Apply the corresponding beneficial effect here
    move.l  d0, d1
    sub.l   #MAX_POWERUPS_ON_SCREEN-1, d1
    neg.l   d1                                      ; D1 has true power-up index
    
    lea     PowerUpType, a2
    clr.l   d3
    move.b  (a2, d1), d3                            ; D3 contains power-up type enum
    lsl.l   #2, d3                                  ; Long offset
    
    lea     PowerUpFuncs, a2
    move.l  (a2, d3), a2
    jsr     (a2)                                    ; Jump to the corresponding function of the power-up type
                                                    ; IMPORTANT: D1 and D3 will be used in the spawnPowerUpFloatingText subroutine
    
continuePowerUpCollisionLoop:
    dbra    d0, powerUpCollisionLoop
    rts


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
