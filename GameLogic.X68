*-----------------------------------------------------------
* Title      : GameLogic
* Written by : Pon Jumruspun
* Date       : 5/31/2024
* Description: Initializer and update subroutines.
*-----------------------------------------------------------

initialize:
* To be called at the start of the program only
* Set up some initial params, images, load the main menu screen
    jsr     setScreenResolution
    jsr     setDoubleBuffering  
    jsr     loadSound
    jsr     playMainMenuMusic
    jsr     drawLoadingImage        ; While the title screen is drawing, shows a simple loading message
    jsr     swapBuffers
* Home screen
    jsr     drawHomeScreenImage     ; Draw title screen in background
    jsr     swapBuffers
    jsr     titleScreenUpdate       ; See if the player has pressed a key to proceed into the main gameloop
    
* Tutorial screen
    jsr     drawLoadingImage
    jsr     swapBuffers
    jsr     drawTutorialScreenImage
    jsr     swapBuffers
    jsr     tutorialScreenUpdate
    rts

initializeGameloop:
* To be called after the player proceeds to press start the game
    jsr     drawBackgroundAsync
    jsr     playGameLoopMusic
    jsr     initializeGameLogic
    jsr     initializeRenderer
    rts

updateCycle:
    jsr     updateDeltaTime         ; Should not change D7
    jsr     updateTime              ; Needs to be called after updateDeltaTime
    jsr     playerUpdate            ; Need D7 from input cycle's return as its parameter 
    jsr     playerCollisionUpdate
    jsr     enemyUpdate
    jsr     enemyCollisionUpdate
    jsr     powerUpUpdate
    jsr     powerUpCollisionUpdate
    jsr     starUpdate
    jsr     fuelUpdate
    jsr     floatingTextUpdate
    jsr     difficultyUpdate
    rts

initializeGameLogic:
* Game logic initializer, should be called before the gameloop starts
    jsr     resetScore
    jsr     initializePlayer
    jsr     initializeEnemies
    jsr     initializeFuel
    jsr     initializeTimers
    jsr     initializeMovingStars
    jsr     initializePowerUpSystem
    jsr     initializeDifficulty
    rts

initializeTimers:
* Registers used: D1
    jsr     getTimeSinceMidnight    ; D1 contains time since midnight
    move.l  d1, LastUpdateTime
    move.l  d1, LastPlayerShootingTime
    move.l  #0, TimeSinceStartGame
    rts

titleScreenUpdate:
* Title screen loop to check whether to proceed to the main game loop
    jsr     inputMonitoring         ; D7 contains direction enum after this
    cmp.b   #DIRECTION_NONE, d7     ; If direction changes = WASD is pressed, then start the game
    beq     titleScreenUpdate
    rts

tutorialScreenUpdate:
* Tutorial screen loop to check whether to proceed to the main game loop
    jsr     inputMonitoring         ; D7 contains direction enum after this
    cmp.b   #DIRECTION_NONE, d7     ; If direction changes = WASD is pressed, then start the game
    beq     tutorialScreenUpdate
    rts
    
gameOver:
* The player died, draw gameover and prepare to start the new game if the player press any key
    jsr     stopAllMusic
    jsr     playPlayerDeathSound
    jsr     clearScreen
    jsr     drawLoadingImage
    jsr     swapBuffers
    jsr     playGameOverMusic
    jsr     drawGameOverImage
    jsr     swapBuffers
    
gameOverLoop:
    jsr     inputMonitoring         ; D7 contains direction enum after this
    cmp.b   #DIRECTION_NONE, d7     ; If direction changes = WASD is pressed, then start the game
    bne     initializeGameLoop
    
    cmp.b   #TRUE, IsPlayerAttacking
    beq     start                   ; If the player presses attack, go to main menu
    
    bra     gameOverLoop




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
