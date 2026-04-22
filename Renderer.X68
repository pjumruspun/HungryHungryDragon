*-----------------------------------------------------------
* Title      : Renderer
* Written by : Pon Jumruspun
* Date       : 5/31/2024
* Description: Rendering subroutines
*-----------------------------------------------------------

initializeRenderer:
* Initialize anything graphics-related
    jsr     drawPlayer
    jsr     initializePlayerAnim
    jsr     initializeFuelGauge
    jsr     initFloatingText
    jsr     spawnDifficultyFloatingText
    jsr     swapBuffers
    rts

renderCycle:
    jsr     clearPlayableScreen
    
* Objects
    jsr     drawFloatingText
    jsr     drawStars
    jsr     drawPowerUps
    jsr     drawEnemyProjectiles
    jsr		drawEnemies
    jsr     drawPlayerProjectiles
    jsr     drawPlayer
    
* UI
    jsr     drawFuelGauge
    jsr     drawFuelText
    jsr     drawLivesText
    jsr     drawPlayerLivesCount
    jsr     drawPowerUpUI
    jsr     swapBuffers
    
* For the next frame
    jsr     drawEnemyProjectilesBGTrail
    rts

initializePlayerAnim:
* Set up the memory for player's animation system
* Registers used: D1
    move.b  #0, CurrentPlayerFrame
    jsr     getTimeSinceMidnight
    move.l  d1, TimeSinceLastPlayerFrame
    rts
    
initializeFuelGauge:
* Draw fuel gauge proportionally to the max fuel gauge
* Registers used: D0-D5
    jsr     getFuelGaugeWidth                               ; D5 has fuel gauge width in pixels
    move.l  d5, CurrentFuelGaugeWidth
    jsr     drawFuelGaugeRectangle                          ; Uses D5 to draw
    move.l  #FUEL_GAUGE_WIDTH, LastFuelGaugeWidth           ; Set LastFuelGauge for drawing depleted part
    jsr     drawDepletedFuelGauge
    rts
    
drawPowerUpUI:
    jsr     drawMoveSpeedPowerUpUI
    jsr     drawAtkSpeedPowerUpUI
    jsr     drawSpreadPowerUpUI
    rts
    
drawMoveSpeedPowerUpUI:
    move.l  #0, PowerUpYOffsetParam
    move.l  PowerUpMoveSpeedLevel, d5
    move.l  #POWERUP_MAX_MOVE_SPEED_LEVEL, d6
    move.l  #POWERUP_TYPE_MOVE_SPEED, d7
    jsr     drawPowerUpGauge
    rts
    
drawAtkSpeedPowerUpUI:
    move.l  #POWERUP_UI_GAP_Y, PowerUpYOffsetParam
    move.l  PowerUpAtkSpeedLevel, d5
    move.l  #POWERUP_MAX_ATK_SPEED_LEVEL, d6
    move.l  #POWERUP_TYPE_ATK_SPEED, d7
    jsr     drawPowerUpGauge
    rts
    
drawSpreadPowerUpUI:
    move.l  #2*POWERUP_UI_GAP_Y, PowerUpYOffsetParam
    move.l  PowerUpSpreadLevel, d5
    move.l  #POWERUP_MAX_SPREAD_LEVEL, d6
    move.l  #POWERUP_TYPE_SPREAD, d7
    jsr     drawPowerUpGauge
    rts
    
drawPowerUpGauge
* Parameters:
* PowerUpYOffsetParam: Offset Y from the power-up UI origin
* D5: Current power-up level
* D6: Max power-up level
* D7: Power-up enum type

* Draw the icon
    move.l  #POWERUP_UI_X, d1
    move.l  #POWERUP_UI_Y, d2
    move.l  PowerUpYOffsetParam, d3
    add.l   d3, d2
    jsr     renderPowerUp
    
* Set gauge width
    move.l  #POWERUP_UI_GAUGE_THICKNESS, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set the gauge background color
    move.l  #POWERUP_UI_GAUGE_BG_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15

* Draw the background gauge
    move.l  #POWERUP_UI_X+POWERUP_SIZE+POWERUP_UI_GAP_X, d1
    
    move.l  #POWERUP_UI_Y, d2
    add.l   #POWERUP_SIZE>>1, d2
    move.l  PowerUpYOffsetParam, d3
    add.l   d3, d2
    
    move.l  d1, d3
    add.l   #POWERUP_UI_GAUGE_WIDTH, d3
    move.l  d2, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15

* Set the gauge foreground color
    lea     PowerUpColors, a1
    move.l  (a1, d7), d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15

* Draw the foreground gauge
    move.l  #POWERUP_UI_X+POWERUP_SIZE+POWERUP_UI_GAP_X, d1
    
    move.l  #POWERUP_UI_Y, d2
    add.l   #POWERUP_SIZE>>1, d2
    move.l  PowerUpYOffsetParam, d3
    add.l   d3, d2
    
    move.l  d1, d3
    
* Calculate the ratio needed to render
* D5 contains current power-up level
    
    cmp.l   #0, d5
    ble     skipDrawingPowerUpGauge         ; We don't draw if lv0
    
    lsl.l   #FRACTIONAL_BITS, d5
    divu    d6, d5                          ; D6 contains max power-up level
    swap    d5
    move.w  #0, d5
    swap    d5                              ; D5 contains ratio from 0~1
    
    mulu    #POWERUP_UI_GAUGE_WIDTH, d5
    lsr.l   #FRACTIONAL_BITS, d5            ; To integer
    
    move.l  d1, d3
    add.l   d5, d3                          ; D5 is the amount to render
    move.l  d2, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
skipDrawingPowerUpGauge:
    rts
    
drawBackgroundAsync:
* Pops the loading screen while drawing background in the other buffer
    jsr     drawLoadingImage
    jsr     swapBuffers
    jsr     drawBackgroundImage
    jsr     swapBuffers

    rts
    
drawFloatingText:
* Draw all currently active floating texts
* Registers used: D0-D4, A1-A3

* Loop through IsFloatingTextActive, if it is, then draw it
    lea     IsFloatingTextActive, a2
    move.l  #MAX_FLOATING_TEXT-1, d3
    
drawFloatingTextLoop:
    cmp.b   #FLOATING_TEXT_STATUS_ACTIVE, (a2)+
    bne     continueDrawFloatingTextLoop

* Found an active one, draw
    move.l  d3, d4
    sub.l   #MAX_FLOATING_TEXT-1, d4
    neg.l   d4
    lsl.l   #2, d4                              ; Long offset

* Set font color and properties
    lea     FloatingTextColors, a3
    move.l  (a3, d4), d1
    lea     FloatingTextProps, a3
    move.l  (a3, d4), d2
    move.l  #TASK_SET_FONT, d0
    trap    #15

* Set the background color
    move.l  #BACKGROUND_COLOR, d1
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Get the address of the null-terminated string
    lea     FloatingTextStrAddr, a3
    move.l  (a3, d4), a1
    
* Get the position
    lea     FFloatingTextX, a3
    move.l  (a3, d4), d1
    lsr.l   #FRACTIONAL_BITS, d1                ; To integer
    
    lea     FFloatingTextY, a3
    move.l  (a3, d4), d2
    lsr.l   #FRACTIONAL_BITS, d2                ; To integer
    
    move.l  #TASK_DRAW_TEXT, d0
    trap    #15

continueDrawFloatingTextLoop:
    dbra    d3, drawFloatingTextLoop
    rts
    
setDefaultFont:
    move.l  #FONT_COLOR_DEFAULT, d1
    move.l  #FONT_PROPS_DEFAULT, d2
    move.l  #TASK_SET_FONT, d0
    trap    #15
    rts
    
setBackgroundColorAsFill:
    move.l  #BACKGROUND_COLOR, d1
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    rts

drawLivesText:
* Draw the word "Lives" underneath the player lives count
* Registers used: D0-D2, A1
    jsr     setDefaultFont
    jsr     setBackgroundColorAsFill
    
* Draw the text
    lea     StrLives, a1
    move.l  #LIVES_TEXT_X, d1
    move.l  #LIVES_TEXT_Y, d2
    
    move.l  #TASK_DRAW_TEXT, d0
    trap    #15
    rts

drawFuelText:
* Draw the word "Fuel" at the fuel gauge
* Registers used: D0-D2, A1
    jsr     setDefaultFont
    jsr     setBackgroundColorAsFill
    
* Draw the text
    lea     StrFuel, a1
    move.l  #FUEL_TEXT_X, d1
    move.l  #FUEL_TEXT_Y, d2
    
    move.l  #TASK_DRAW_TEXT, d0
    trap    #15
    rts
    
drawFuelGaugeRectangle:
* Draw the fuel gauge rectangle according to the given parameters. Doesn't draw background.
* Parameters:
* D5: Fuel gauge width

* Other registers used: D1-D4
    
* Reset pen width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #DEFAULT_PEN_WIDTH, d1
    trap    #15
    
    
* Calculate fuel gauge depending on the fuel amount left
    move.l  CurrentFuel, d0
    lsl.l   #FRACTIONAL_BITS, d0
    divu    #MAX_FUEL, d0
    swap    d0
    move.w  #0, d0
    swap    d0                                              ; D0 is FCurrentFuel
    
    clr.l   d1
    
    move.l  #FUEL_GAUGE_GREEN_AMOUNT, d2
    mulu    d0, d2
    lsr.l   #FRACTIONAL_BITS, d2
    move.b  d2, d1                                          ; Set green color
    
    lsl.l   #8, d1                                          ; Shift to red
    
    sub.l   #1<<FRACTIONAL_BITS, d0
    neg.l   d0                                              ; d0 = 1-d0
    
    move.l  #FUEL_GAUGE_RED_AMOUNT, d2
    mulu    d0, d2
    lsr.l   #FRACTIONAL_BITS, d2
    move.b  d2, d1                                          ; Set red

* Set fuel gauge color
* D1 here should be a mix between green and red depending on the fuel percentage left
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    
* Set rectangle parameters and draw
    move.l  #FUEL_GAUGE_X, d1                               ; LeftX
    move.l  #FUEL_GAUGE_Y, d2                               ; UpperY
    move.l  d1, d3
    add.l   d5, d3                                          ; RightX
    move.l  #FUEL_GAUGE_Y+FUEL_GAUGE_HEIGHT, d4             ; LowerY
    
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15

    rts

drawDepletedFuelGauge:
* Registers used: D0-D4
* Reset pen width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #DEFAULT_PEN_WIDTH, d1
    trap    #15

* Set fuel gauge color
    move.l  #FUEL_GAUGE_DEPLETED_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Set rectangle parameters
    move.l  CurrentFuelGaugeWidth, d1
    add.l   #FUEL_GAUGE_X, d1
    
    move.l  #FUEL_GAUGE_Y, d2
    
    move.l  #FUEL_GAUGE_X+FUEL_GAUGE_WIDTH, d3
    
    move.l  #FUEL_GAUGE_Y+FUEL_GAUGE_HEIGHT, d4
    
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15
    
skipDrawingDepleted:
    rts
    
drawFuelGauge:
* Fuel gauge function to call in the renderCycle loop.
* Registers used: D0-D5
    move.l  CurrentFuelGaugeWidth, LastFuelGaugeWidth
    jsr     getFuelGaugeWidth                               ; D5 has fuel gauge width in pixels
    move.l  d5, CurrentFuelGaugeWidth
    jsr     drawFuelGaugeRectangle                          ; Uses D5 to draw
    jsr     drawDepletedFuelGauge                      
    rts

getFuelGaugeWidth:
* Calculate how many pixels of fuel gauge should be drawn. Doesn't really draw anything.
* Returns:
* D7: Fuel gauge width in pixels
    move.l  CurrentFuel, d5
    lsl.l   #FRACTIONAL_BITS, d5
    divu    #MAX_FUEL, d5
    swap    d5
    move.w  #0, d5
    swap    d5                                              ; D5 contains proportion of fuel in fixed point
    
* Calculate how much to draw
    mulu    #FUEL_GAUGE_WIDTH, d5       ; Calculate width
    lsr.l   #FRACTIONAL_BITS, d5        ; To integer
    rts

setDoubleBuffering:
* Registers used: D0, D1

    move.l  #TASK_SET_DRAWING_MODE, d0
    move.l  #DOUBLE_BUFFERING, d1
    trap    #15
    rts

setScreenResolution:
* Registers used: D0, D1

    move.l	#WINDOW_WIDTH, d1
    swap    d1
    move.w  #WINDOW_HEIGHT, d1
	move.l	#TASK_GET_SET_OUTPUT_WIN, d0
	trap	#15
	rts

drawHomeScreenImage:
* Registers used: A1
    jsr     clearScreen
	lea		HomeScreenImage, a1

	sub.l	#THREE_ARGS_FUNC, sp					; Argument stack incremental
	
	move.l	a1, BMP_ADDR(sp)
	move.l	#HALF_WINDOW_WIDTH, X_SCREEN(sp)
	move.l	#HALF_WINDOW_HEIGHT, Y_SCREEN(sp)
	
	jsr		displayBitmapCenter
	add.l	#THREE_ARGS_FUNC, sp					; Fix stack
	rts

drawTutorialScreenImage:
* Registers used: A1
    jsr     clearScreen
	lea		TutorialScreenImage, a1

	sub.l	#THREE_ARGS_FUNC, sp					; Argument stack incremental
	
	move.l	a1, BMP_ADDR(sp)
	move.l	#HALF_WINDOW_WIDTH, X_SCREEN(sp)
	move.l	#HALF_WINDOW_HEIGHT, Y_SCREEN(sp)
	
	jsr		displayBitmapCenter
	add.l	#THREE_ARGS_FUNC, sp					; Fix stack
	rts
	
drawLoadingImage:
* Registers used: A1

    jsr     clearScreen
    lea     LoadingImage, a1
    
    sub.l   #THREE_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    move.l  #HALF_WINDOW_WIDTH, X_SCREEN(sp)
    move.l  #HALF_WINDOW_HEIGHT, Y_SCREEN(sp)
    
    jsr     displayBitmapCenter
    add.l   #THREE_ARGS_FUNC, sp
    rts
    
drawGameOverImage:
* Registers used: A1
    jsr     clearScreen
    lea     GameOverImage, a1
    
    sub.l   #THREE_ARGS_FUNC, sp
    
    move.l  a1, BMP_ADDR(sp)
    move.l  #HALF_WINDOW_WIDTH, X_SCREEN(sp)
    move.l  #HALF_WINDOW_HEIGHT, Y_SCREEN(sp)
    
    jsr     displayBitmapCenter
    add.l   #THREE_ARGS_FUNC, sp
    rts

drawPlayer:
* Registers used: D0, D1, A1
* Could optimized further: If the player didn't move, we don't redraw
* Check if the player is invul
    cmp.l   #0, PlayerInvulTime
    ble     drawPlayerSpriteActive

* Here, the player is invul, see if the blink timer is >= 0 or not.
* If it is, then decrease the timer
* If it isn't, then switch player sprite's visibility and reset the blinking time
    cmp.l   #0, PlayerBlinkTime
    ble     switchPlayerSpriteVisibility

* Decrease the blink timer normally here
    move.l  DeltaTime, d0
    sub.l   d0, PlayerBlinkTime
    bra     checkPlayerSpriteVisibility

switchPlayerSpriteVisibility:
* -1 then neg is a way to switch from true to false and vise versa
    move.b  PlayerSpriteActive, d0
    sub.b   #1, d0
    neg.b   d0
    move.b  d0, PlayerSpriteActive

* Reset blinking time
    move.l  #PLAYER_BLINK_TIME, PlayerBlinkTime
    
checkPlayerSpriteVisibility:
    cmp.b   #TRUE, PlayerSpriteActive
    bne     skipDrawingPlayer
 
drawPlayerSpriteActive:
    lea     PlayerSprites, a1
    
    clr.l   d0
    move.b  CurrentPlayerFrame, d0  ; Get the frame index (long offset)
    
    sub.l   #THREE_ARGS_FUNC, sp
    move.l  (a1, d0), BMP_ADDR(sp)  ; Load the correct image by frame index
    
* Check if it's the time to switch the sprite
    jsr     getTimeSinceMidnight            ; D1 contains time now
    move.l  d1, d2
    sub.l   TimeSinceLastPlayerFrame, d2
    cmp.l   #PLAYER_FRAME_DELAY, d2
    blt     skipPlayerFrame

    add.b   #LONG_OFFSET, d0                ; Move to the next frame
    
    move.l  d1, TimeSinceLastPlayerFrame    ; Mark that we just switch frame
    
skipPlayerFrame:
    divu    #PLAYER_FRAME_COUNT*LONG_OFFSET, d0
    swap    d0                      ; Get the remainder, modulo operator basically
    move.b  d0, CurrentPlayerFrame  ; Save the frame index back
    
    move.l  FPlayerX, d0
    lsr.l   #FRACTIONAL_BITS, d0
    move.l  d0, X_SCREEN(sp)        ; Turn into integer
        
    move.l  FPlayerY, d0
    lsr.l   #FRACTIONAL_BITS, d0
    move.l  d0, Y_SCREEN(sp)
    
    jsr     displayTransparentBitmap
    add.l   #THREE_ARGS_FUNC, sp
    
skipDrawingPlayer:
    rts

drawEnemies:
* Registers used: D0-D6, A1-A3
* Loop through the alive array to see if the enemy needs to be drawn
	move.l	#-1, d5
	lea		IsEnemyAlive, a2

checkAliveEnemyDrawEnemiesLoop:
	add.l	#1, d5
	
	cmp.l	#MAX_ENEMY_ALLOWED, d5
	bge		skipEnemyDrawing
	
	cmp.b	#ENEMY_STATUS_ALIVE, (a2, d5)
	beq		drawEnemy
	
	bra		checkAliveEnemyDrawEnemiesLoop
	
drawEnemy:
	move.l	d5, d6
	lsl.l	#2, d6						; Long offset
	
* Actually draw enemy here
* Pen width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #DEFAULT_PEN_WIDTH, d1
    trap    #15
    
* Color depends on type
    lea     EnemyTypes, a3
    clr.l   d4
    move.b  (a3, d5), d4                ; D4 contains enemy type
    lsl.l   #2, d4                      ; Long offset
    
    lea     EnemyColors, a3
    move.l  (a3, d4), EnemyColorArg     ; Lookup for corresponding color

* Position
    lea		FEnemyPosX, a3
	move.l	(a3, d6), d1
	lsr.l	#FRACTIONAL_BITS, d1
	move.l  d1, EnemyLeftXArg

    lea		FEnemyPosY, a3
	move.l	(a3, d6), d2
	lsr.l	#FRACTIONAL_BITS, d2
	move.l  d2, EnemyUpperYArg

    jsr     renderEnemy
	
	bra		checkAliveEnemyDrawEnemiesLoop	; Branch back to see if there's any more to draw
	
skipEnemyDrawing:
	rts
	
renderEnemy:
* This is where enemy's shapes take place
    sub.l   #LONG_OFFSET*7, sp
	movem.l d0-d6, (sp)

* Set color
    move.l  EnemyColorArg, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Draw the head
* Head is made of 3 overlapping rectangles to construct an artificial curve
* Draw flattest rectangle
    move.l  EnemyLeftXArg, d1
    move.l  EnemyUpperYArg, d2
    add.l   #2*ENEMY_HEAD_STEP, d2
    move.l  d1, d3
    add.l   #ENEMY_SIZE_X, d3
    move.l  d2, d4
    add.l   #ENEMY_HEAD_HEIGHT-2*ENEMY_HEAD_STEP, d4
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15
    
* Draw the middle rectangle
    move.l  EnemyLeftXArg, d1
    add.l   #ENEMY_HEAD_STEP, d1
    move.l  EnemyUpperYArg, d2
    add.l   #ENEMY_HEAD_STEP, d2
    move.l  d1, d3
    add.l   #ENEMY_SIZE_X-2*ENEMY_HEAD_STEP, d3
    move.l  d2, d4
    add.l   #ENEMY_HEAD_HEIGHT-ENEMY_HEAD_STEP, d4
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15

* Draw tallest rectangle
    move.l  EnemyLeftXArg, d1
    add.l   #2*ENEMY_HEAD_STEP, d1
    move.l  EnemyUpperYArg, d2
    move.l  d1, d3
    add.l   #ENEMY_SIZE_X-4*ENEMY_HEAD_STEP, d3
    move.l  d2, d4
    add.l   #ENEMY_HEAD_HEIGHT, d4
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15
    
* Draw the tentacle
    move.l  #ENEMY_TENTACLE_COUNT-1, d5
    
renderEnemyTentacle:
    move.l  EnemyLeftXArg, d1
    move.l  d5, d6
    muls    #ENEMY_TENTACLE_WIDTH+ENEMY_TENTACLE_GAP, d6
    add.l   d6, d1
    move.l  EnemyUpperYArg, d2
    add.l   #ENEMY_HEAD_HEIGHT, d2
    move.l  d1, d3
    add.l   #ENEMY_TENTACLE_WIDTH, d3
    move.l  d2, d4
    add.l   #ENEMY_TENTACLE_HEIGHT, d4
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15
    
    dbra    d5, renderEnemyTentacle
    
* Draw the left eye
* Set color
    move.l  #ENEMY_EYE_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    
* Set dimension
    move.l  EnemyLeftXArg, d1
    add.l   #ENEMY_SIZE_X>>1-ENEMY_EYE_GAP>>1-ENEMY_EYE_SIZE, d1
    move.l  EnemyUpperYArg, d2
    add.l   #ENEMY_EYE_OFFSET_Y, d2
    move.l  d1, d3
    add.l   #ENEMY_EYE_SIZE, d3
    move.l  d2, d4
    add.l   #ENEMY_EYE_SIZE, d4
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15
    
* Right eye (Changes only d1, d3)
    add.l   #ENEMY_EYE_GAP+ENEMY_EYE_SIZE, d1
    move.l  d1, d3
    add.l   #ENEMY_EYE_SIZE, d3
    trap    #15
    
    movem.l (sp), d0-d6
    add.l   #LONG_OFFSET*7, sp
    
* Left iris
* Set color
    move.l  #ENEMY_IRIS_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
* Set dimension
    move.l  EnemyLeftXArg, d1
    add.l   #ENEMY_SIZE_X>>1-ENEMY_EYE_GAP>>1-ENEMY_EYE_SIZE, d1
    move.l  EnemyUpperYArg, d2
    add.l   #ENEMY_EYE_OFFSET_Y+(ENEMY_EYE_SIZE-ENEMY_IRIS_SIZE)>>1, d2
    move.l  d1, d3
    add.l   #ENEMY_IRIS_SIZE, d3
    move.l  d2, d4
    add.l   #ENEMY_IRIS_SIZE, d4
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15

* Right iris (Changes only d1, d3)
    add.l   #ENEMY_EYE_GAP+ENEMY_EYE_SIZE, d1
    move.l  d1, d3
    add.l   #ENEMY_IRIS_SIZE, d3
    trap    #15
    
    rts
	
drawPlayerProjectiles:
* Registers used: D0-D7, A1-A3
* Loop through the projectile active array to see if there's any projectile to draw
    move.l  #-1, d6
    lea     IsProjectileActive, a1
    
checkActiveDrawProjectileLoop:
    add.l   #1, d6
    
    cmp.l   #MAX_PLAYER_PROJECTILE, d6
    bge     skipPlayerProjectileDrawing ; Exceed the size of the array, return
    
    cmp.b   #PLAYER_PROJ_STATUS_ACTIVE, (a1, d6)
    beq     drawPlayerProjectile
    
    bra     checkActiveDrawProjectileLoop
    
drawPlayerProjectile:
    move.l  d6, d5
    lsl.l   #2, d5                      ; Long offset
    
* Projectile is a fireball
* Pen width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #PLAYER_PROJ_THICKNESS, d1
    trap    #15

    move.l  #TASK_SET_PEN_COLOR, d0
    move.l  #PLAYER_PROJ_COLOR_OUTER, d1
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15                         ; Same color as above

    lea     FProjectilePosX, a2
    lea     FProjectilePosY, a3

    move.l  (a2, d5), d1                ; LeftX
    lsr.l   #FRACTIONAL_BITS, d1        ; Turn to integer
    
    move.l  (a3, d5), d2                ; UpperY
    lsr.l   #FRACTIONAL_BITS, d2        ; Turn to integer
    
* D1 and D2 contains LeftX and UpperY

    jsr     renderPlayerProjectile
    
    bra     checkActiveDrawProjectileLoop
    
skipPlayerProjectileDrawing:
    rts
    
renderPlayerProjectile:
* Parameters:
* D1: LeftX of the projectile
* D2: UpperY of the projectile

* Upper of the fire ball tail
    move.l  d2, d4
    add.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d2
    move.l  d1, d3
    add.l   #PLAYER_PROJECTILE_SIZE_X, d3
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
* Lower fire ball tail
    add.l   #PLAYER_PROJECTILE_SIZE_Y, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
* Middle to cover the gap
    sub.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15  

* Red circle in the middle
    move.l  d3, d1
    move.l  d4, d2
    sub.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d1
    sub.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d2
    add.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d3
    add.l   #PLAYER_PROJECTILE_SIZE_Y>>1, d4
    
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15
    
* Smaller yellow circle
* Set color
    move.l  d1, d7                             ; Save D1 since it will get override
    move.l  #PLAYER_PROJ_COLOR_INNER, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    
* Draw the circle
    move.l  d7, d1                              ; Load the D1 we saved earlier
    add.l   #PLAYER_PROJ_YELLOW_OFFSET, d1
    add.l   #PLAYER_PROJ_YELLOW_OFFSET, d2
    sub.l   #PLAYER_PROJ_YELLOW_OFFSET, d3
    sub.l   #PLAYER_PROJ_YELLOW_OFFSET, d4
    
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15
    rts
    
drawEnemyProjectiles:
* Registers used: D0-D6, A1-A3
* Loop through the enemy projectile active array to see if there's any projectile to draw
    move.l  #-1, d6
    lea     IsEnemyProjectileActive, a1
    
checkEnemyDrawProjectileLoop:
    add.l   #1, d6
    
    cmp.l   #MAX_ENEMY_PROJECTILE, d6
    bge     skipEnemyProjectileDrawing  ; Exceed the size of the array, return
    
    cmp.b   #ENEMY_PROJ_STATUS_ACTIVE, (a1, d6)
    beq     drawEnemyProjectile
    
    bra     checkEnemyDrawProjectileLoop
    
drawEnemyProjectile:
    move.l  d6, d5
    lsl.l   #2, d5                      ; Long offset
    
* Projectile is a double-layered circle
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #ENEMY_PROJECTILE_OUTER_SIZE, d1
    trap    #15

    move.l  #TASK_SET_PEN_COLOR, d0
    move.l  #ENEMY_PROJECTILE_COLOR_OUTER, d1
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    move.l  #ENEMY_PROJECTILE_COLOR_INNER, d1
    trap    #15

    lea     FEnemyProjectileX, a2
    lea     FEnemyProjectileY, a3

    move.l  (a2, d5), d1                ; LeftX
    lsr.l   #FRACTIONAL_BITS, d1        ; Turn to integer
    
    move.l  (a3, d5), d2                ; UpperY
    lsr.l   #FRACTIONAL_BITS, d2        ; Turn to integer
    
    move.l  d1, d3
    add.l   #ENEMY_PROJECTILE_SIZE, d3      ; RightX
    
    move.l  d2, d4
    add.l   #ENEMY_PROJECTILE_SIZE, d4      ; LowerY
    
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15
    
    bra     checkEnemyDrawProjectileLoop
    
skipEnemyProjectileDrawing:
    rts

drawEnemyProjectilesBGTrail:
* Enemy projectiles can fall through the background area
* So we need to check if it is, and redraw them accordingly
* Registers used: D0-D6, A1-A3
* Loop through the enemy projectile active array to see if there's anything needs to be covered
    move.l  #-1, d6
    lea     IsEnemyProjectileActive, a1
    
checkBGEnemyProjectileLoop:
    add.l   #1, d6
    
    cmp.l   #MAX_ENEMY_PROJECTILE, d6
    bge     skipBGEnemyProjectileDrawing  ; Exceed the size of the array, return
    
    cmp.b   #ENEMY_PROJ_STATUS_ACTIVE, (a1, d6)
    beq     drawBGEnemyProjectile
    
    bra     checkBGEnemyProjectileLoop
    
drawBGEnemyProjectile:
    move.l  d6, d5
    lsl.l   #2, d5                      ; Long offset
    
    lea     FEnemyProjectileX, a2
    lea     FEnemyProjectileY, a3

    move.l  (a2, d5), d1                ; LeftX
    lsr.l   #FRACTIONAL_BITS, d1        ; Turn to integer
    sub.l   #ENEMY_PROJECTILE_OUTER_SIZE>>1, d1
    
    move.l  (a3, d5), d2                ; UpperY
    lsr.l   #FRACTIONAL_BITS, d2        ; Turn to integer
    sub.l   #ENEMY_PROJECTILE_OUTER_SIZE>>1, d2
    
* Only draw BG if it's in the BG area
* Aka ProjectileY >= WindowHeight - BackgroundSize - ENEMY_PROJECTILE_RADIUS
    cmp.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-ENEMY_PROJECTILE_SIZE-ENEMY_PROJECTILE_OUTER_SIZE, d2
    blt     loopBackBGEnemyProjectile
    
***** Start draw bitmap chunk context *****
    
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)

    lea     BackgroundImage, a4
    sub.l   #SEVEN_ARGS_FUNC, sp
    
    move.l  a4, BMP_ADDR(sp)
    
    move.l  d1, X_SCREEN(sp)        
    move.l  d1, X_BMP(sp)               ; X_BMP = X_SCREEN
        
    move.l  d2, Y_SCREEN(sp)
    sub.l   #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d2
    move.l  d2, Y_BMP(sp)               ; Y_BMP = Y_SCREEN - (ScreenHeight - BackgroundHeight -1)
    
    move.l  #ENEMY_PROJECTILE_SIZE+ENEMY_PROJECTILE_OUTER_SIZE, WIDTH_TO_DISPLAY(sp)
    move.l  #ENEMY_PROJECTILE_SIZE+ENEMY_PROJECTILE_OUTER_SIZE, HEIGHT_TO_DISPLAY(sp)
    
    jsr     displayBitmapChunk
    
    add.l   #SEVEN_ARGS_FUNC, sp    ; Fix stack

    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp
    
***** End draw bitmap chunk context *****
loopBackBGEnemyProjectile:
    bra     checkBGEnemyProjectileLoop
    
skipBGEnemyProjectileDrawing:
    rts

drawStars:
* Loop through the IsStarActive array, if it is active, then draw the star. Loop through the limit.
* Registers used: D0-D6, A1, A2
    
    move.l  #STAR_LIMIT-1, d6
    lea     IsStarActive, a1
    
drawStarsLoop:
    cmp.b   #STAR_STATUS_ACTIVE, (a1)+
    beq     drawStar
    
continueDrawStarLoop:
    dbra    d6, drawStarsLoop    
    
* Finished looping array here, return
    rts


    
drawStar:
* Found an active star, draw it here
    move.l  d6, d5
    sub.l   #STAR_LIMIT-1, d5
    neg.l   d5
    lsl.l   #2, d5                      ; D5 contains long-offset index
    
* Set pen width
    move.l  #TASK_SET_PEN_WIDTH, d0
    move.l  #DEFAULT_PEN_WIDTH, d1
    trap    #15
    
* Set the star color
    lea     StarColors, a2
    move.l  (a2, d5), d1                ; D1 contains star's color
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Set the star position
    lea     FStarPosX, a2
    move.l  (a2, d5), d7                ; D7 = Fixed point StarX
    lsr.l   #FRACTIONAL_BITS, d7        ; To integer
    move.l  d7, d1                      ; RightX
    
    lea     FStarPosY, a2
    move.l  (a2, d5), d7                ; D7 = Fixed point StarY
    lsr.l   #FRACTIONAL_BITS, d7        ; To integer
    move.l  d7, d2                      ; UpperY
    
    lea     StarSizes, a2
    move.l  (a2, d5), d3
    move.l  d3, d4                      ; Set LeftX and LowerY to StarSize
    add.l   d1, d3                      ; LeftX = RightX + StarSize
    add.l   d2, d4                      ; LowerY = UpperY + StarSize

* Draw it
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15

    bra     continueDrawStarLoop

drawPowerups:
* Loop through the IsPowerUpActive array and draw them accordingly
* Registers used: D0-D7, A1-A2

    lea     IsPowerUpActive, a1
    move.l  #MAX_POWERUPS_ON_SCREEN-1, d6
    
drawPowerUpsLoop:
    cmp.b   #POWERUP_STATUS_ACTIVE, (a1)+
    beq     drawPowerUp
    
continueDrawPowerUpsLoop:
    dbra    d6, drawPowerUpsLoop
    
* Finished drawing everything, return
    rts
    
drawPowerUp:
* Found an active power-up, so draw it here
    move.l  d6, d5
    sub.l   #MAX_POWERUPS_ON_SCREEN-1, d5
    neg.l   d5                                  ; D5 contains true index
    
* Get the power-up color by its type
    lea     PowerUpType, a2
    clr.l   d7
    move.b  (a2, d5), d7                        ; D7 contains power-up enum
    
    lsl.l   #2, d5                              ; D5 contains long-offset power-up index
    
* LeftX
    lea     FPowerUpPosX, a2
    move.l  (a2, d5), d1
    lsr.l   #FRACTIONAL_BITS, d1                ; To integer
    
* UpperY
    lea     FPowerUpPosY, a2
    move.l  (a2, d5), d2
    lsr.l   #FRACTIONAL_BITS, d2                ; To integer
    
    jsr     renderPowerUp

    bra     continueDrawPowerUpsLoop

renderPowerUp:
* Parameters:
* D1, D2; LeftX and UpperY of the position to draw
* D7: Power-up enum type

* Long offset enum
    lsl.l   #2, d7

* If it's a fuel power-up, we don't draw
* Because it's going to be just a meat icon from now on
    cmp.b   #POWERUP_TYPE_FUEL*4, d7
    beq     skipDrawingPowerUpCircle

* Save context
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)

* Set the color
    lea     PowerUpColors, a2
    move.l  (a2, d7), d1                        ; D1 contains color
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    
* Outline with darker color
    lsr.b   #1, d1                              ; Halve the B
    ror.l   #8, d1
    lsr.b   #1, d1                              ; G
    ror.l   #8, d1
    lsr.b   #1, d1                              ; R
    
    ror.l   #8, d1
    ror.l   #8, d1                              ; Rotate full long-length
    
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    
* Set pen size
    move.l  #POWERUP_PEN_SIZE, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Draw the shape (circle)
* Load context right before applying D1, D2 to LeftX/UpperY
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp

* RightX
    move.l  d1, d3
    add.l   #POWERUP_SIZE, d3

* LowerY
    move.l  d2, d4
    add.l   #POWERUP_SIZE, d4

* Draw
    move.l  #TASK_DRAW_FILLED_ELLIPSE, d0
    trap    #15

skipDrawingPowerUpCircle:
* Draw icon, should retain D1-D2
    sub.l   #LONG_OFFSET*15, sp
    movem.l ALL_REG, (sp)
    
    lea     PowerUpIconFunc, a2
    move.l  (a2, d7), a2                        ; D7 contains long-offset power-up enum
    jsr     (a2)
    
    movem.l (sp), ALL_REG
    add.l   #LONG_OFFSET*15, sp

    rts

drawMoveSpeedIcon:
* Parameters: D1, D2: LeftX and UpperY of the power-up
* Save X coord in D5
    move.l  d1, d5

* Set pen width
    move.l  #POWERUP_MOVESPD_PEN_SIZE, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set pen color
    move.l  #POWERUP_MOVESPD_ARROW_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15

* Load X coord back to D1
* Top part of the left arrow
    move.l  d5, d1
    add.l   #POWERUP_MOVESPD_X_OFFSET, d1
    
    add.l   #POWERUP_MOVESPD_Y_OFFSET, d2
    
    move.l  d1, d3
    add.l   #POWERUP_MOVESPD_X_TILT, d3
    
    sub.l   #POWERUP_SIZE>>1, d4                ; Subtract back to the middle
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
* Bottom part of the left arrow
    move.l  d4, d2
    add.l   #POWERUP_SIZE>>1-POWERUP_MOVESPD_Y_OFFSET, d2
    
    trap    #15
    
* Bottom part of the right arrow
    add.l   #POWERUP_MOVESPD_GAP, d1
    add.l   #POWERUP_MOVESPD_GAP, d3
    
    trap    #15
    
* Top part of the right arrow
    sub.l   #2*(POWERUP_SIZE>>1-POWERUP_MOVESPD_Y_OFFSET), d2
    trap    #15
    
    rts
    
drawAtkSpeedIcon:
* Parameters: D1, D2: LeftX and UpperY of the power-up
* Save X coord in D5
    move.l  d1, d5

* Set pen width
    move.l  #POWERUP_ATKSPD_PEN_SIZE, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set pen color
    move.l  #POWERUP_ATKSPD_ARROW_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15

* Load X coord back to D1
* Left part of the top arrow
    move.l  d5, d1
    add.l   #POWERUP_ATKSPD_X_OFFSET, d1
    
    add.l   #POWERUP_ATKSPD_Y_OFFSET, d2
    
    sub.l   #POWERUP_SIZE>>1, d3
    
    move.l  d2, d4
    sub.l   #POWERUP_ATKSPD_Y_TILT, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15

* Right part of the top arrow
    move.l  d3, d1
    add.l   #POWERUP_SIZE>>1-POWERUP_ATKSPD_X_OFFSET, d1
    
    trap    #15
    
* Right part of the bottom arrow
    add.l   #POWERUP_ATKSPD_GAP, d2
    add.l   #POWERUP_ATKSPD_GAP, d4
    trap    #15
    
* Left part of the bottom arrow
    sub.l   #2*(POWERUP_SIZE>>1-POWERUP_ATKSPD_X_OFFSET), d1
    trap    #15
    
    rts
    
drawFoodIcon:
* Parameters: D1, D2: LeftX and UpperY of the power-up
* Save X coord in D5
    move.l  d1, d5

* Bone
* Set pen width
    move.l  #POWERUP_BONE_THICKNESS, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set pen and fill color
    move.l  #POWERUP_FOOD_BONE_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Load X coord back to D1
    move.l  d5, d1
    sub.l   #POWERUP_BONE_EXTENSION_X, d1
    add.l   #POWERUP_SIZE>>1, d2
    move.l  d1, d3
    add.l   #POWERUP_SIZE+2*POWERUP_BONE_EXTENSION_X, d3
    move.l  d2, d4

    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
* Meat
* Set pen width
    move.l  #POWERUP_MEAT_THICKNESS, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set pen and fill color
    move.l  #POWERUP_FOOD_MEAT_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15

* Load X coord back to D1
    move.l  d5, d1
    add.l   #POWERUP_MEAT_X_OFFSET, d1
    move.l  d1, d3
    add.l   #POWERUP_SIZE-2*POWERUP_MEAT_X_OFFSET, d3

    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
    rts
    
drawSpreadIcon:
* Save X coord in D5
    move.l  d1, d5

* Set pen width
    move.l  #POWERUP_SPREAD_PEN_SIZE, d1
    move.l  #TASK_SET_PEN_WIDTH, d0
    trap    #15
    
* Set pen and fill color
    move.l  #POWERUP_SPREAD_COLOR, d1
    move.l  #TASK_SET_PEN_COLOR, d0
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15
    
* Load X coord back to D1
* Center line
    move.l  d5, d1
    add.l   #POWERUP_SPREAD_X_OFFSET, d1
    
    add.l   #POWERUP_SIZE>>1, d2
    
    move.l  d1, d3
    add.l   #POWERUP_SPREAD_ARROW_WIDTH+POWERUP_SPREAD_EXTRA_WIDTH, d3
    move.l  d2, d4
    
    move.l  #TASK_DRAW_LINE, d0
    trap    #15
    
* Upper line
    sub.l   #POWERUP_SPREAD_EXTRA_WIDTH, d3
    sub.l   #POWERUP_SPREAD_Y_GAP, d4
    
    trap    #15

* Lower line
    add.l   #2*POWERUP_SPREAD_Y_GAP, d4
    trap    #15
    
    rts

drawBackgroundImage:
* Registers used: A1
    lea		BackgroundImage, a1

	sub.l	#THREE_ARGS_FUNC, sp
	
	move.l	a1, BMP_ADDR(sp)
	move.l	#0, X_SCREEN(sp)
	move.l	#WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, Y_SCREEN(sp)
	
	jsr		displayBitmap
	add.l	#THREE_ARGS_FUNC, sp
	rts
	
clearScreen:
* Registers used: D0, D1

    move.w  #CLEAR_SCREEN, d1
    move.l  #TASK_SCREEN, d0
    trap    #15
    rts
    
clearPlayableScreen:
* Draw a huge rectangle over the playable area without affecting the background
* Registers used: D0-D1
    
    move.l  #TASK_SET_PEN_COLOR, d0
    move.l  #BACKGROUND_COLOR, d1
    trap    #15
    
    move.l  #TASK_SET_FILL_COLOR, d0
    trap    #15                         ; Use background color in D1 earlier
    
* Draw rectangle with following params:
* LeftX: 0, UpperY: 0, RightX: WINDOW_WIDTH-1, LowerY: WINDOW_HEIGHT-BACKGROUND_HEIGHT-1
    move.l  #0, d1
    move.l  #0, d2
    move.l  #WINDOW_WIDTH-1, d3
    move.l  #WINDOW_HEIGHT-BACKGROUND_HEIGHT-1, d4
    
    move.l  #TASK_DRAW_FILLED_RECTANGLE, d0
    trap    #15
    rts
    
drawPlayerLivesCount:
* Should only call this when we need the UI to update
* Like when the player took damage
* Registers used: D0-D7
    move.l  PlayerLives, d0
    jsr     hexToDecimal                ; D7 contains decimal number of lives
    
    move.l  d7, d1
    move.l  #PLAYER_LIVES_X, d2
    move.l  #PLAYER_LIVES_Y, d3
    jsr     drawSevenSegment
    
    rts
    
swapBuffers:
* Registers used: D0

    move.l  #TASK_REPAINT_SCREEN, d0
    trap    #15
    rts














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
