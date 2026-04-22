*-----------------------------------------------------------
* Title      : Variables
* Written by : Pon Jumruspun
* Date       : 6/6/2024
* Description: Heap variables
*-----------------------------------------------------------

HomeScreenImage		INCBIN	"title_screen.bmp"
TutorialScreenImage INCBIN  "tutorial_screen.bmp"
BackgroundImage     INCBIN  "space.bmp"
LoadingImage        INCBIN  "loading.bmp"
GameOverImage       INCBIN  "gameover.bmp"
EnemyImage          INCBIN  "enemy.bmp"

PlayerFrame_1               INCBIN  "player_1.bmp"
PlayerFrame_2               INCBIN  "player_2.bmp"
PlayerFrame_3               INCBIN  "player_3.bmp"
PlayerSprites               dc.l    PlayerFrame_1, PlayerFrame_2, PlayerFrame_3
CurrentPlayerFrame          dc.b    0
TimeSinceLastPlayerFrame    dc.l    0

LastUpdateTime      dc.l    0
DeltaTime           dc.l    1

IsPlayerAttacking   ds.b    1

PlayerScore             ds.l    1
LastPlayerScoreDec      ds.l    1
FPlayerX                ds.l    1
FPlayerY                ds.l    1
FPlayerSpeed            ds.l    1
PlayerAttackCooldown    ds.l    1

PlayerLives             dc.l    0
PlayerInvulTime         dc.l    0
PlayerSpriteActive      dc.b    TRUE
PlayerBlinkTime         dc.l    0

CurrentFuel             ds.l    1
LastFuelGaugeWidth      ds.l    1
CurrentFuelGaugeWidth   ds.l    1

TimeSinceLastEnemySpawned   dc.l    0
IsEnemyAlive                ds.b    MAX_ENEMY_ALLOWED
EnemyTypes                  ds.b    MAX_ENEMY_ALLOWED
FEnemyPosX                  ds.l    MAX_ENEMY_ALLOWED
FEnemyPosY                  ds.l    MAX_ENEMY_ALLOWED
FEnemyStartPosY             ds.l    MAX_ENEMY_ALLOWED

LastEnemyShootingTime       ds.l    MAX_ENEMY_ALLOWED

IsEnemyProjectileActive     ds.b    MAX_ENEMY_PROJECTILE
FEnemyProjectileX           ds.l    MAX_ENEMY_PROJECTILE
FEnemyProjectileY           ds.l    MAX_ENEMY_PROJECTILE
FEnemyProjectileVY          ds.l    MAX_ENEMY_PROJECTILE

EnemyColors                 dc.l    COLOR_ENEMY_NORMAL
                            dc.l    COLOR_ENEMY_NIMBLE
                            dc.l    COLOR_ENEMY_FIERCE
                            dc.l    COLOR_ENEMY_SPECIAL
                            
EnemyScoreBounty            dc.l    50  ; Normal
                            dc.l    100 ; Nimble
                            dc.l    100 ; Fierce
                            dc.l    150 ; Special
                            
* If enough time, should create a regToString function instead of hardcopy like this
StrEnemyScoreBountyArr      dc.l    StrEnemyScoreBounty_1, StrEnemyScoreBounty_2, StrEnemyScoreBounty_3, StrEnemyScoreBounty_4
StrEnemyScoreBounty_1       dc.b    '50', 0
StrEnemyScoreBounty_2       dc.b    '100', 0
StrEnemyScoreBounty_3       dc.b    '100', 0
StrEnemyScoreBounty_4       dc.b    '150', 0
                            
EnemyColorArg               ds.l    1
EnemyLeftXArg               ds.l    1
EnemyUpperYArg              ds.l    1

EnemySpawnedThisGroup       ds.l    1
EnemyMaxThisGroup           ds.l    1
FEnemyGroupRandomY          ds.l    1

EnemySpawnRateArray         dc.l    ENEMY_SPAWNRATE_NIMBLE, ENEMY_SPAWNRATE_FIERCE, ENEMY_SPAWNRATE_SPECIAL

LastPlayerShootingTime  ds.l    1
IsProjectileActive      ds.b    MAX_PLAYER_PROJECTILE
FProjectilePosX         ds.l    MAX_PLAYER_PROJECTILE
FProjectilePosY         ds.l    MAX_PLAYER_PROJECTILE
PlayerProjToSpawn       dc.l    0                           ; For spread power-up

* Difficulty
MaxEnemy                    dc.l    0
TimeToSpawnEnemy            dc.l    0
EnemyShootingTime           dc.l    0
FuelDepletionRate			dc.l	0
DifficultyLevel             dc.l    0
TimeSinceStartGame          dc.l    0

TimeToChangeDifficulty      dc.l    1000
                            dc.l    1800
                            dc.l    2600
                            dc.l    3400
                            dc.l    4200
                            dc.l    5000
                            dc.l    5800
                            dc.l    6600

MaxEnemyByLevel             dc.l    10
                            dc.l    10
                            dc.l    12
                            dc.l    14
                            dc.l    16
                            dc.l    18
                            dc.l    20
                            dc.l    22
                            dc.l    24

TimeToSpawnEnemyByLevel     dc.l    50
                            dc.l    45
                            dc.l    41
                            dc.l    38
                            dc.l    36
                            dc.l    33
                            dc.l    28
                            dc.l    25
                            dc.l    22
                            
EnemyShootingTimeByLevel    dc.l    250
                            dc.l    220
                            dc.l    190
                            dc.l    175
                            dc.l    160
                            dc.l    150
                            dc.l    140
                            dc.l    131
                            dc.l    122
                            
FuelDepletionByLevel		dc.l	10<<FRACTIONAL_BITS>>1
							dc.l	11<<FRACTIONAL_BITS>>1
							dc.l	12<<FRACTIONAL_BITS>>1
							dc.l	13<<FRACTIONAL_BITS>>1
							dc.l	14<<FRACTIONAL_BITS>>1
							dc.l	15<<FRACTIONAL_BITS>>1
							dc.l	16<<FRACTIONAL_BITS>>1
							dc.l	17<<FRACTIONAL_BITS>>1
							dc.l	18<<FRACTIONAL_BITS>>1

StrDifficultyArr            dc.l    StrDifficulty_1
                            dc.l    StrDifficulty_2
                            dc.l    StrDifficulty_3
                            dc.l    StrDifficulty_4
                            dc.l    StrDifficulty_5
                            dc.l    StrDifficulty_6
                            dc.l    StrDifficulty_7
                            dc.l    StrDifficulty_8
                            dc.l    StrDifficulty_9

* Keycode responses associated with TASK_KEY_INPUT
KeycodeResponses
*           $WWAASSDD
    dc.l    $00000000
    dc.l    $FF000000
    dc.l    $FF0000FF
    dc.l    $000000FF
    dc.l    $0000FFFF
    dc.l    $0000FF00
    dc.l    $00FFFF00
    dc.l    $00FF0000
    dc.l    $FFFF0000

* Map direction enums to FDeltaX and FDeltaY
FDirectionMapX       
    dc.l    0
    dc.l    0
    dc.l    FONE_OVER_SQRT_2
    dc.l    FONE
    dc.l    FONE_OVER_SQRT_2
    dc.l    0
    dc.l    -FONE_OVER_SQRT_2
    dc.l    FNEG_ONE
    dc.l    -FONE_OVER_SQRT_2
    
FDirectionMapY       
    dc.l    0
    dc.l    FNEG_ONE
    dc.l    -FONE_OVER_SQRT_2
    dc.l    0
    dc.l    FONE_OVER_SQRT_2
    dc.l    FONE
    dc.l    FONE_OVER_SQRT_2
    dc.l    0
    dc.l    -FONE_OVER_SQRT_2
    
SevenSegmentDigitCode   dc.b    $7E, $30, $6D, $79, $33, $5B, $5F, $70, $FF, $7B
    
SevenSegStartOffsetX    dc.b    0, 1, 1, 0, 0, 0, 0
SevenSegStartOffsetY    dc.b    0, 0, 1, 2, 1, 0, 1
SevenSegEndOffsetX      dc.b    1, 1, 1, 1, 0, 0, 1
SevenSegEndOffsetY      dc.b    0, 1, 2, 2, 2, 1, 1

* Sounds Effects
SoundPathPlayerShooting     dc.b    'player_shooting.wav', 0
SoundPathPlayerDeath        dc.b    'player_death.wav', 0
SoundPathEnemyDeath         dc.b    'enemy_death.wav', 0
SoundPathPowerUpCollected   dc.b    'powerup_collected.wav', 0
SoundPathPlayerHurt         dc.b    'player_hurt.wav', 0
SoundPathEnemyShooting      dc.b    'enemy_shooting.wav', 0
SoundPathSlurp              dc.b    'slurp.wav',0 


* Music
MusicPathMainMenu           dc.b    'main_menu_music.wav', 0
MusicPathGameLoop           dc.b    'gameloop_music.wav', 0
MusicPathGameOver           dc.b    'gameover_music.wav', 0

MusicArrayIndex             dc.b    MUSIC_MAIN_MENU
                            dc.b    MUSIC_GAMELOOP
                            dc.b    MUSIC_GAMEOVER

* Moving star background
LastStarSpawnTime       dc.l    0
IsStarActive            ds.b    STAR_LIMIT
FStarPosX               ds.l    STAR_LIMIT
FStarPosY               ds.l    STAR_LIMIT
StarSizes               ds.l    STAR_LIMIT
StarColors              ds.l    STAR_LIMIT
FStarSpeed              ds.l    STAR_LIMIT

* Powerups

FLastEnemyDeadX         ds.l    1       ; Arguments for power-up spawning
FLastEnemyDeadY         ds.l    1
PowerUpTypeToSpawn      ds.b    1

IsPowerUpActive         ds.b    MAX_POWERUPS_ON_SCREEN
PowerUpType             ds.b    MAX_POWERUPS_ON_SCREEN
FPowerUpPosX            ds.l    MAX_POWERUPS_ON_SCREEN
FPowerUpPosY            ds.l    MAX_POWERUPS_ON_SCREEN

* Powerup UI parameter
PowerUpYOffsetParam     ds.l    1

* Powerup levels
PowerUpMoveSpeedLevel   dc.l    0
PowerUpAtkSpeedLevel    dc.l    0
PowerUpSpreadLevel      dc.l    0

* Powerup values
* Must be in sync with POWERUP_MAX_MOVE_SPEED_LEVEL
FPowerUpMoveSpeedValues dc.l    8*(FPLAYER_INITIAL_SPEED>>3)
                        dc.l    9*(FPLAYER_INITIAL_SPEED>>3)        ; Lv1
                        dc.l    10*(FPLAYER_INITIAL_SPEED>>3)       ; Lv2
                        dc.l    11*(FPLAYER_INITIAL_SPEED>>3)       ; Lv3
                        dc.l    12*(FPLAYER_INITIAL_SPEED>>3)       ; Lv4
                        dc.l    13*(FPLAYER_INITIAL_SPEED>>3)       ; Lv5
                        dc.l    14*(FPLAYER_INITIAL_SPEED>>3)       ; Lv6
                        dc.l    15*(FPLAYER_INITIAL_SPEED>>3)       ; Lv7
                        dc.l    16*(FPLAYER_INITIAL_SPEED>>3)       ; Lv8
                        dc.l    17*(FPLAYER_INITIAL_SPEED>>3)       ; Lv9
                        dc.l    18*(FPLAYER_INITIAL_SPEED>>3)       ; Lv10

* Must be in sync with POWERUP_MAX_ATK_SPEED_LEVEL
* These values are in hundredth seconds                        
PowerUpAtkCdValues      dc.l    50
                        dc.l    46    ; Lv1
                        dc.l    42    ; Lv2
                        dc.l    38    ; Lv3
                        dc.l    35    ; Lv4
                        dc.l    33    ; Lv5
                        dc.l    31    ; Lv6
                        dc.l    29    ; Lv7
                        dc.l    27    ; Lv8
                        dc.l    25    ; Lv9
                        dc.l    23    ; Lv10

* Power-up function array
PowerUpFuncs            dc.l    onPowerUpMoveSpeedCollected, onPowerUpAtkSpeedCollected, onPowerUpFuelCollected, onPowerUpSpreadCollected

* Power-up rendering
PowerUpColors           dc.l    COLOR_GREEN, COLOR_RED, COLOR_TAWNY, COLOR_ORANGE
PowerUpStrings          dc.l    StrMoveSpeedPowerUp, StrAtkSpeedPowerUp, StrFuelPowerUp, StrSpreadPowerUp
PowerUpIconFunc         dc.l    drawMoveSpeedIcon, drawAtkSpeedIcon, drawFoodIcon, drawSpreadIcon

* Floating Text
FloatingTextColorArg    ds.l    1
FloatingTextPropsArg    ds.l    1

IsFloatingTextActive    ds.b    MAX_FLOATING_TEXT
FloatingTextStrAddr     ds.l    MAX_FLOATING_TEXT
FFloatingTextX          ds.l    MAX_FLOATING_TEXT
FFloatingTextY          ds.l    MAX_FLOATING_TEXT
FloatingTextColors      ds.l    MAX_FLOATING_TEXT
FloatingTextProps       ds.l    MAX_FLOATING_TEXT
FloatingTextAge         ds.l    MAX_FLOATING_TEXT       ; In hundredth seconds
FloatingTextDuration    ds.l    MAX_FLOATING_TEXT       ; In hundredth seconds

* Strings
StrFuel                 dc.b    'Hunger', 0
StrLives                dc.b    'Lives', 0

StrMoveSpeedPowerUp     dc.b    'Movement Speed', 0
StrAtkSpeedPowerUp      dc.b    'Attack Speed', 0
StrFuelPowerUp          dc.b    'YUMMY!!', 0
StrSpreadPowerUp        dc.b    'More Fireballs', 0

StrDifficulty_1         dc.b    'Difficulty: Easy', 0
StrDifficulty_2         dc.b    'Difficulty: Normal', 0
StrDifficulty_3         dc.b    'Difficulty: Hard', 0
StrDifficulty_4         dc.b    'Difficulty: Very hard', 0
StrDifficulty_5         dc.b    'Difficulty: Insane', 0
StrDifficulty_6         dc.b    'Difficulty: Impossible', 0
StrDifficulty_7         dc.b    'Difficulty: I SEE YOU', 0
StrDifficulty_8         dc.b    'Difficulty: IM COMING FOR YOU', 0
StrDifficulty_9         dc.b    'Difficulty: HAHAHAHAHAHAHAHAHAHAHAHAHA', 0

* Sin Calculation
SinDegreeParam          ds.l    1
FSinRadianParam         ds.l    1
SinTable       
*           Value   Angle
    dc.l    $0      * 0
    dc.l    $2C     * 10
    dc.l    $58     * 20
    dc.l    $80     * 30
    dc.l    $A5     * 40
    dc.l    $C4     * 50
    dc.l    $DE     * 60
    dc.l    $F1     * 70
    dc.l    $FC     * 80
    dc.l    $100    * 90
    dc.l    $FC     * 100
    dc.l    $F1     * 110
    dc.l    $DE     * 120
    dc.l    $C4     * 130
    dc.l    $A5     * 140
    dc.l    $80     * 150
    dc.l    $58     * 160
    dc.l    $2C     * 170
    dc.l    $0      * 180
    dc.l    -$2C    * 100
    dc.l    -$58    * 200
    dc.l    -$80    * 210
    dc.l    -$A5    * 220
    dc.l    -$C4    * 230
    dc.l    -$DE    * 240
    dc.l    -$F1    * 250
    dc.l    -$FC    * 260
    dc.l    -$100   * 270
    dc.l    -$FC    * 280
    dc.l    -$F1    * 290
    dc.l    -$DE    * 300
    dc.l    -$C4    * 310
    dc.l    -$A5    * 320
    dc.l    -$80    * 330
    dc.l    -$58    * 340
    dc.l    -$2C    * 350
    dc.l    $0      * 360













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
