*-----------------------------------------------------------
* Title      : Moving Stars
* Written by : Pon Jumruspun
* Date       : 6/6/2024
* Description: Moving star background. Pure visual.
*-----------------------------------------------------------

initializeMovingStars:
    jsr     initLastStarSpawnTime
    jsr     initRandomStars
    rts
    
initLastStarSpawnTime:
* Registers used: D1
    jsr     getTimeSinceMidnight        ; D1 contains time since midnight
    move.l  d1, LastStarSpawnTime
    rts

initRandomStars:
* Set all stars to be active and assign its random initial positions, size, color, and speed
* Registers used: D0-D1, D6-D7, A1-A3
    move.l  #STAR_LIMIT-1, d0
    lea     IsStarActive, a1
    
initRandomStarsLoop:
    move.b  #STAR_STATUS_ACTIVE, (a1)+
    
    move.l  d0, d1
    sub.l   #STAR_LIMIT-1, d1
    neg.l   d1
    lsl.l   #2, d1                      ; D1 contains long offset star index

* Set random X to be between [0, WINDOW_WIDTH)
    move.l  #WINDOW_WIDTH, d6
    jsr     randomRange                 ; D7 contains the random number
    lsl.l   #FRACTIONAL_BITS, d7        ; To fixed point
    
    lea     FStarPosX, a2
    move.l  d7, (a2, d1)                ; Save the random position to the memory
    
* Set random Y to be between [0, WINDOW_HEIGHT-BACKGROUND_HEIGHT-MAX_STAR_SIZE)
    move.l  #WINDOW_HEIGHT-BACKGROUND_HEIGHT-MAX_STAR_SIZE, d6
    jsr     randomRange
    lsl.l   #FRACTIONAL_BITS, d7
    lea     FStarPosY, a2
    move.l  d7, (a2, d1)

* Set size
    move.l  #MAX_STAR_SIZE-MIN_STAR_SIZE+1, d6
    jsr     randomRange
    add.l   #MIN_STAR_SIZE, d7
    
    lea     StarSizes, a2
    move.l  d7, (a2, d1)
    
* Set color
    lea     StarColors, a2
    move.l  #STAR_COLOR, (a2, d1)
    
* Set speed
    move.l  #FSTAR_MAX_SPEED-FSTAR_MIN_SPEED+1, d6
    jsr     randomRange
    add.l   #FSTAR_MIN_SPEED, d7
    
    lea     FStarSpeed, a2
    move.l  d7, (a2, d1)
    
    dbra    d0, initRandomStarsLoop
    
    rts
    
starUpdate:
    jsr     attemptToSpawnStar
    jsr     updateStarsPosition
    rts
    
attemptToSpawnStar:
* (1) Check whether it's been enough time since last star spawned.
* (2) If it is, loop through the IsStarActive array and set the first inactive star to active.
* (3) Then set the star color, initial star position, and sizes.
* (4) Also reset the last star spawn time.

* Registers used: D0-D2, D6, A1, A3

    jsr     getTimeSinceMidnight        ; D1 contains time since midnight (now)
    move.l  LastStarSpawnTime, d0
    sub.l   d0, d1                      ; D1 contains duration between now and last spawn
    cmp.l   #HUNDREDTH_SECONDS_TO_SPAWN_STAR, d1
    blt     skipSpawnStar
    
* Enough time has passed, we loop through the array to find the first inactive star
    move.l  #STAR_LIMIT-1, d0
    lea     IsStarActive, a1
    
starSpawnLoop:
    cmp.b   #STAR_STATUS_INACTIVE, (a1)+
    beq     spawnStar
    dbra    d0, starSpawnloop
    bra     skipSpawnStar               ; Star limit reached, we skip spawning
    
spawnStar:
* We found the first inactive star
    move.l  d0, d1
    sub.l   #STAR_LIMIT-1, d1
    neg.l   d1                          ; D1 contains true star index

    move.b  #STAR_STATUS_ACTIVE, -1(a1) ; Set the star to active
    
    move.l  d1, d2
    lsl.l   #2, d2                      ; D2 has long offset index
    
* Set the star color
    lea     StarColors, a1
    move.l  #STAR_COLOR, (a1, d2)

* Set the star position
    lea     FStarPosX, a1
    move.l  #WINDOW_WIDTH<<FRACTIONAL_BITS, (a1, d2)    ; Set the star's x to the right side of the screen 

    move.l  #WINDOW_HEIGHT-BACKGROUND_HEIGHT-MAX_STAR_SIZE, d6
    jsr     randomRange                 ; D7 contains random number between [0, d6)
    
    lea     FStarPosY, a1
    lsl.l   #FRACTIONAL_BITS, d7        ; Shift to fixed point
    move.l  d7, (a1, d2)                ; Set the star's y to be random between [0, WINDOW_HEIGHT)
    
* Set the star size
    move.l  #MAX_STAR_SIZE-MIN_STAR_SIZE+1, d6
    jsr     randomRange
    add.l   #MIN_STAR_SIZE, d7          ; D7 contains random number between [MIN_STAR_SIZE, MAX_STAR_SIZE]    

    lea     StarSizes, a1
    move.l  d7, (a1, d2)
    
* Set the star speed
    move.l  #FSTAR_MAX_SPEED-FSTAR_MIN_SPEED+1, d6
    jsr     randomRange
    add.l   #FSTAR_MIN_SPEED, d7
    
    lea     FStarSpeed, a1
    move.l  d7, (a1, d2)

* Reset the spawn timer to say that we just spawn a star
    jsr     getTimeSinceMidnight        ; D1 contains time since midnight
    move.l  d1, LastStarSpawnTime

skipSpawnStar:
* Not enough time has passed, or star limit reached so we don't spawn a star
    rts
    
updateStarsPosition:
* Loop through the IsStarActive array, if it is, then move it to the left by StarSpeed * DeltaTime

* Registers used: D0-D4, A1-A2

    move.l  #STAR_LIMIT-1, d0
    lea     IsStarActive, a1

updateStarsPosLoop:
    cmp.b   #STAR_STATUS_ACTIVE, (a1)+
    beq     updateStarPosition

continueUpdateStarsPosLoop:
    dbra    d0, updateStarsPosLoop
    
* Array out of range, return    
    rts
    
updateStarPosition:
    move.l  d0, d1
    sub.l   #STAR_LIMIT-1, d1
    neg.l   d1
    lsl.l   #2, d1                      ; D1 contains long offset index of the star to move
    
* Get the star's speed
    lea     FStarSpeed, a2
    move.l  (a2, d1), d3                ; D3 contains Fixed point star speed
    
* Add bonus speed depends on the difficulty level
    move.l  DifficultyLevel, d4
    muls    #FSTAR_DIFF_SPEED_MULT, d4
    add.l   #1<<FRACTIONAL_BITS, d4
    muls    d4, d3
    lsr.l   #FRACTIONAL_BITS, d3
    
* FNewX = FOldX - FSpeed * DeltaTime
    lsr.l   #HALF_FRACTIONAL_BITS, d3   ; Preshift
    move.l  DeltaTime, d4
    lsl.l   #HALF_FRACTIONAL_BITS, d4   ; Preshift
    muls.w  d4, d3                      ; FSpeed * DeltaTime
    
    lea     FStarPosX, a2
    sub.l   d3, (a2, d1)                ; FNewX = FOldX - FSpeed * DeltaTime
    
* Check if the star is offscreen
    cmp.l   #0, (a2, d1)
    bgt     skipKillingStar

* If it is, then kill it
    move.b  #STAR_STATUS_INACTIVE, -1(a1)

* Loop back
skipKillingStar:
    bra     continueUpdateStarsPosLoop
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
