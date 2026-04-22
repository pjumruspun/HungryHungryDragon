*-----------------------------------------------------------
* Title      : Difficulty
* Written by : Pon Jumruspun
* Date       : 6/11/2024
* Description: Scaling difficulty with time
*-----------------------------------------------------------

initializeDifficulty:
    move.l  MaxEnemyByLevel, MaxEnemy
    move.l  TimeToSpawnEnemyByLevel, TimeToSpawnEnemy
    move.l  EnemyShootingTimeByLevel, EnemyShootingTime
    move.l	FuelDepletionByLevel, FuelDepletionRate
    move.l  #0, DifficultyLevel
    rts
    
difficultyUpdate:
* Check to see if we need to increase the difficulty
* Registers used: D0-D1, A1
    lea     TimeToChangeDifficulty, a1
    move.l  DifficultyLevel, d0
    lsl.l   #2, d0
    move.l  TimeSinceStartGame, d1
    move.l  (a1, d0), d0
    cmp.l   d1, d0
    bgt     skipIncreaseDifficulty
    jsr     increaseDifficulty
    
skipIncreaseDifficulty:
    jsr     updateDifficultyValues
    rts
    
increaseDifficulty:
* Increase the difficulty level by 1, doesn't increase if already at max
* Registers used: D0-D2, A1 (Spawn floating text)
    move.l  DifficultyLevel, d0
    cmp.l   #MAX_DIFFICULTY_LEVEL, d0
    bge     isAtMaxDifficulty

* Actually increase difficulty here
    add.l   #1, DifficultyLevel
    jsr     spawnDifficultyFloatingText
isAtMaxDifficulty:
    rts
    
updateDifficultyValues:
* Change parameters that affects the difficulty of the game
* Registers used: D0, A1

* Get the long offset index
    move.l  DifficultyLevel, d0
    lsl.l   #2, d0
    
* Set max enemy
    lea     MaxEnemyByLevel, a1
    move.l  (a1, d0), MaxEnemy
    
* Set enemy spawn rate
    lea     TimeToSpawnEnemyByLevel, a1
    move.l  (a1, d0), TimeToSpawnEnemy
    
* Set enemy shooting rate
    lea     EnemyShootingTimeByLevel, a1
    move.l  (a1, d0), EnemyShootingTime
    
* Set fuel depletion rate
	lea		FuelDepletionByLevel, a1
	move.l	(a1, d0), FuelDepletionRate
    
    rts
    
spawnDifficultyFloatingText:
* Spawn the difficulty text on the screen depending on the current difficulty
* Registers used: D0-D2, A1
* Set font
    move.l  #DIFFICULTY_FONT_COLOR, FloatingTextColorArg
    move.l  #DIFFICULTY_FONT_PROPS, FLoatingTextPropsArg

* Spawn the floating text
    lea     StrDifficultyArr, a1
    move.l  DifficultyLevel, d0
    lsl.l   #2, d0                              ; Long offset
    move.l  (a1, d0), a1
    move.l  #DIFFICULTY_TEXT_TTL, d0
    move.l  #FDIFFICULTY_TEXT_X, d1
    move.l  #FDIFFICULTY_TEXT_Y, d2
    jsr     spawnFloatingText
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
