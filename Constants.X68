*-----------------------------------------------------------
* Title      : Constants
* Written by : Pon Jumruspun
* Date       : 6/6/2024
* Description: All the equates used in the project. 
* Note:        Some variables may have "F" in front of their names to incicate they're fixed point.
*-----------------------------------------------------------

* Fixed Point
FRACTIONAL_BITS             equ 8
HALF_FRACTIONAL_BITS        equ FRACTIONAL_BITS>>1

* Hardcoded sizes of assets (Bad practice, but helps optimizing for now)
* Shouldn't be too bad as long as we don't change assets often
* Can optimize by getting the sizes of the assets on initializing the game
PLAYER_SIZE_X               equ 20
PLAYER_SIZE_Y               equ 40
ENEMY_SIZE_X                equ 24
ENEMY_SIZE_Y                equ 32
BACKGROUND_HEIGHT           equ 68

* Graphics
BYTES_PER_PIXEL             equ 4               ; Bitmap's 32 byte per pixel
DEFAULT_PEN_WIDTH           equ 1
COLOR_BLACK                 equ 0
COLOR_YELLOW                equ $FFFF
COLOR_RED                   equ $FF
COLOR_WHITE                 equ $FFFFFF
COLOR_GREEN                 equ $DD00
COLOR_SLIGHTLY_DARK_GREEN   equ $AA00
COLOR_MAGENTA               equ $FF00FF
COLOR_CYAN                  equ $FFFF00
COLOR_PINK                  equ $AA64E0
COLOR_DARK_GRAY             equ $222222
COLOR_TAWNY                 equ $1C487B
COLOR_ORANGE                equ $0088FF
COLOR_CREAM                 equ 176<<16+228<<8+239
COLOR_MEAT                  equ 82<<8+191
BACKGROUND_COLOR            equ COLOR_BLACK
PLAYER_PROJ_COLOR_INNER     equ COLOR_YELLOW
PLAYER_PROJ_COLOR_OUTER     equ COLOR_RED
PLAYER_PROJ_THICKNESS       equ 5
PLAYER_PROJ_YELLOW_OFFSET   equ 3
SEVEN_SEGMENT_COLOR         equ COLOR_RED
SEVEN_SEGMENT_LENGTH        equ 20
SEVEN_SEGMENT_PEN_WIDTH     equ 5

* Fonts
FONT_FIXEDSYS               equ 1
FONT_COURIER                equ 2
FONT_COURIER_NEW            equ 3
FONT_LUCIDA_CONSOLE         equ 4
FONT_LUCIDA_SANS            equ 5
FONT_CONSOLAS               equ 6
FONT_TERMINAL               equ 7

FONT_PROP_BOLD              equ 1
FONT_PROP_ITALIC            equ 1<<1
FONT_PROP_UNDERLINE         equ 1<<2
FONT_PROP_STRIKEOUT         equ 1<<3

FONT_COLOR_DEFAULT          equ COLOR_WHITE
FONT_SIZE_DEFAULT           equ 9
FONT_DEFAULT                equ FONT_FIXEDSYS
FONT_PROPS_DEFAULT          equ FONT_DEFAULT<<24+FONT_SIZE_DEFAULT<<16

* Window size
WINDOW_WIDTH                equ 640
WINDOW_HEIGHT               equ 480
HALF_WINDOW_WIDTH           equ WINDOW_WIDTH>>1
HALF_WINDOW_HEIGHT          equ WINDOW_HEIGHT>>1

BACKGROUND_ORIGIN           equ WINDOW_HEIGHT-BACKGROUND_HEIGHT

* Physics
FGRAVITY_ACCELERATION       equ 1<<FRACTIONAL_BITS>>4

* Constants for maths
FONE                        equ 1<<FRACTIONAL_BITS
FNEG_ONE                    equ -1<<FRACTIONAL_BITS
FONE_OVER_SQRT_2            equ $B5

* Animations
PLAYER_FRAME_COUNT          equ 3
PLAYER_FRAME_DELAY          equ 20          ; In hundredth second

* Boolean
TRUE                        equ 1
FALSE                       equ 0

* Player
FPLAYER_INITIAL_SPEED       equ 2<<FRACTIONAL_BITS
FPLAYER_START_X             equ WINDOW_WIDTH<<FRACTIONAL_BITS>>2
FPLAYER_START_Y             equ WINDOW_HEIGHT<<FRACTIONAL_BITS>>1
PLAYER_SCREEN_OFFSET        equ 20
PLAYER_SCREEN_OFFSET_TOP    equ 40
FPLAYER_SCREEN_OFFSET_LEFT  equ PLAYER_SCREEN_OFFSET<<FRACTIONAL_BITS
FPLAYER_SCREEN_OFFSET_RIGHT equ (WINDOW_WIDTH-PLAYER_SIZE_X-PLAYER_SCREEN_OFFSET)<<FRACTIONAL_BITS
FPLAYER_SCREEN_OFFSET_UPPER equ PLAYER_SCREEN_OFFSET_TOP<<FRACTIONAL_BITS
FPLAYER_SCREEN_OFFSET_LOWER equ (WINDOW_HEIGHT-PLAYER_SIZE_X-BACKGROUND_HEIGHT-PLAYER_SCREEN_OFFSET)<<FRACTIONAL_BITS
PLAYER_STARTING_LIVES       equ 2
PLAYER_INVUL_TIME_AFTER_HIT equ 150
PLAYER_BLINK_TIME           equ 10

* Player projectile mechanics
MAX_PLAYER_PROJECTILE               equ 50
PLAYER_INIT_PROJECTILE_COOLDOWN     equ 50   ; In hundredth second
PLAYER_PROJECTILE_SIZE_X            equ 15
PLAYER_PROJECTILE_SIZE_Y            equ 6
PLAYER_PROJ_STATUS_INACTIVE         equ 0
PLAYER_PROJ_STATUS_ACTIVE           equ 1
FPLAYER_PROJECTILE_SPEED            equ 5<<FRACTIONAL_BITS
FPLAYER_PROJ_SPREAD_GAP             equ 25<<FRACTIONAL_BITS

* Score
INITIAL_SCORE_VALUE         equ 0
SEVEN_SEGMENT_LOOP_LIMIT    equ 7       ; 7 because we have 7 segments, duh
BASE_TEN_DIVIDER            equ 10
SCORE_MASK                  equ $F      ; Used for masking each digit
SCORE_POSITION_X            equ 610     ; LeftX position of the least significant digit
SCORE_POSITION_Y            equ 425     ; UpperY position of the least significant digit
SCORE_DIGIT_SPACE_X         equ 30      ; Space in x-axis between each digit


* Score floating text
SCORE_FLOATING_TEXT_TTL     equ 200
SCORE_FLOATING_TEXT_COLOR   equ COLOR_SLIGHTLY_DARK_GREEN
SCORE_FLOATING_TEXT_SIZE    equ 9
SCORE_FLOATING_TEXT_FONT    equ FONT_FIXEDSYS
SCORE_FLOATING_TEXT_PROPS   equ SCORE_FLOATING_TEXT_FONT<<24+SCORE_FLOATING_TEXT_SIZE<<16+FONT_PROP_BOLD

* Lives UI
PLAYER_LIVES_OFFSET         equ WINDOW_WIDTH-SCORE_POSITION_X
PLAYER_LIVES_X              equ WINDOW_WIDTH-PLAYER_LIVES_OFFSET
PLAYER_LIVES_Y              equ 10
LIVES_TEXT_X                equ PLAYER_LIVES_X-10
LIVES_TEXT_Y                equ PLAYER_LIVES_Y+2*SEVEN_SEGMENT_LENGTH+5

* Difficulty
MAX_DIFFICULTY_LEVEL        equ 8       : Starting is 0
DIFFICULTY_TEXT_TTL         equ 300
FDIFFICULTY_TEXT_X          equ (WINDOW_WIDTH>>1-200)<<FRACTIONAL_BITS
FDIFFICULTY_TEXT_Y          equ (WINDOW_HEIGHT>>1-20)<<FRACTIONAL_BITS
DIFFICULTY_FONT_COLOR       equ COLOR_RED
DIFFICULTY_FONT_SIZE        equ 18
DIFFICULTY_FONT             equ FONT_COURIER_NEW
DIFFICULTY_FONT_PROPS       equ DIFFICULTY_FONT<<24+DIFFICULTY_FONT_SIZE<<16+FONT_PROP_BOLD

* Enemy
MAX_ENEMY_ALLOWED                       equ 20     ; Absolute maximum, enemy array size
ENEMY_STATUS_DEAD                       equ 0
ENEMY_STATUS_ALIVE                      equ 1

* Enemy group spawning
ENEMY_GROUP_SIZE_MIN                    equ 1 
ENEMY_GROUP_SIZE_MAX                    equ 5
ENEMY_TIME_MULT_BETWEEN_GROUP           equ 6

* Enemy movement
FDEFAULT_ENEMY_POS_X                    equ WINDOW_WIDTH<<FRACTIONAL_BITS
FDEFAULT_ENEMY_POS_Y                    equ WINDOW_HEIGHT<<FRACTIONAL_BITS>>1
FENEMY_SPEED                            equ 3<<FRACTIONAL_BITS>>2
ENEMY_SIN_PERIOD                        equ 30
ENEMY_SIN_AMP                           equ 40
ENEMY_SPAWN_OFFSET_Y                    equ ENEMY_SIN_AMP+PLAYER_SCREEN_OFFSET_TOP
ENEMY_MIN_SPAWN_Y                       equ ENEMY_SPAWN_OFFSET_Y
ENEMY_MAX_SPAWN_Y                       equ WINDOW_HEIGHT-BACKGROUND_HEIGHT-ENEMY_SIZE_Y-ENEMY_SPAWN_OFFSET_Y-ENEMY_MIN_SPAWN_Y
FENEMY_SPEED_DIFF_MULT                  equ 1<<FRACTIONAL_BITS>>4   ; Bonus speed by difficulty proportion to its original speed

* Enemy shooting
MAX_ENEMY_PROJECTILE                    equ 40
ENEMY_PROJ_STATUS_INACTIVE              equ 0
ENEMY_PROJ_STATUS_ACTIVE                equ 1
ENEMY_PROJECTILE_COLOR_OUTER            equ COLOR_RED
ENEMY_PROJECTILE_COLOR_INNER            equ COLOR_PINK
ENEMY_PROJECTILE_OUTER_SIZE             equ 5
ENEMY_PROJECTILE_SIZE                   equ 10
FENEMY_PROJECTILE_SPEED_X               equ 2<<FRACTIONAL_BITS
FENEMY_INIT_PROJ_SPEED_Y_MIN      		equ 1<<FRACTIONAL_BITS>>1
FENEMY_INIT_PROJ_SPEED_Y_MAX      		equ 6<<FRACTIONAL_BITS
ENEMY_SHOOTING_TIME_VARIANCE            equ 20

* Enemy types
ENEMY_TYPE_NORMAL                       equ 0
ENEMY_TYPE_NIMBLE                       equ 1
ENEMY_TYPE_FIERCE                       equ 2
ENEMY_TYPE_SPECIAL                      equ 3
ENEMY_TYPE_TOTAL                        equ 4                   ; Whatever above + 1

* Enemy type special parameters
FENEMY_NIMBLE_SPEED_BONUS               equ FENEMY_SPEED>>2     ; 25% speed bonus for nimble enemies
FFIERCE_ENEMY_SHOOTING_RATIO            equ 3<<FRACTIONAL_BITS>>2   ; 75% shooting cooldown

* Enemy colors, should correspond to enemy types
COLOR_ENEMY_NORMAL                      equ COLOR_PINK
COLOR_ENEMY_NIMBLE                      equ COLOR_GREEN
COLOR_ENEMY_FIERCE                      equ COLOR_RED
COLOR_ENEMY_SPECIAL                     equ COLOR_ORANGE

* Enemy spawn rate by type in percentage
* The rest will spawn as a normal enemy
ENEMY_SPAWNRATE_NIMBLE                  equ 15
ENEMY_SPAWNRATE_FIERCE                  equ 15
ENEMY_SPAWNRATE_SPECIAL                 equ 8

* Enemy rendering properties
ENEMY_HEAD_HEIGHT                       equ 20
ENEMY_HEAD_STEP                         equ 3
ENEMY_TENTACLE_HEIGHT                   equ ENEMY_SIZE_Y-ENEMY_HEAD_HEIGHT
ENEMY_TENTACLE_WIDTH                    equ 4
ENEMY_TENTACLE_GAP                      equ 6
ENEMY_TENTACLE_COUNT                    equ 3
ENEMY_EYE_OFFSET_Y                      equ 12
ENEMY_EYE_SIZE                          equ 6
ENEMY_IRIS_SIZE                         equ 4
ENEMY_EYE_GAP                           equ 10
ENEMY_EYE_COLOR                         equ COLOR_WHITE
ENEMY_IRIS_COLOR                        equ COLOR_BLACK

* Moving star background
STAR_LIMIT                          equ 40
STAR_STATUS_ACTIVE                  equ 1
STAR_STATUS_INACTIVE                equ 0
HUNDREDTH_SECONDS_TO_SPAWN_STAR     equ 25
FSTAR_MAX_SPEED                     equ 1<<FRACTIONAL_BITS
FSTAR_MIN_SPEED                     equ 1<<FRACTIONAL_BITS>>2
FSTAR_DIFF_SPEED_MULT               equ 1<<FRACTIONAL_BITS>>1   ; Stars will be this much faster for each difficulty level
STAR_COLOR                          equ COLOR_WHITE             ; Single color for now, random later
MIN_STAR_SIZE                       equ 2
MAX_STAR_SIZE                       equ 5

* Local variables for Bitmap rendering
* Save local vars above the stack pointer
VAR_IMAGE_WIDTH			    equ -12
VAR_IMAGE_HEIGHT		    equ	-8

* Keycodes
KEYCODES_WASD               equ $57415344
KEYCODE_SPACE               equ $20

* Direction
DIRECTION_NONE              equ 0
DIRECTION_ENUM_LIMIT        equ 8

* Arguments
BMP_ADDR				    equ 0
X_SCREEN				    equ 4
Y_SCREEN				    equ 8
X_BMP					    equ 12
Y_BMP					    equ 16
WIDTH_TO_DISPLAY		    equ 20
HEIGHT_TO_DISPLAY		    equ	24

* Offsets for passing params through the stack
THREE_ARGS_FUNC             equ 12
SEVEN_ARGS_FUNC             equ 28

* Task stuff
TASK_GET_TIME_SINCE_MIDNIGHT    equ 8
TASK_SCREEN                     equ 11
TASK_KEY_INPUT                  equ 19
TASK_SET_FONT                   equ 21
TASK_GET_SET_OUTPUT_WIN	        equ	33
TASK_LOAD_SOUND                 equ 74
TASK_CONTROL_SOUND              equ 77
TASK_SET_PEN_COLOR              equ 80
TASK_SET_FILL_COLOR		        equ	81
TASK_DRAW_PIXEL			        equ	82
TASK_DRAW_LINE                  equ 84
TASK_DRAW_FILLED_RECTANGLE      equ 87
TASK_DRAW_FILLED_ELLIPSE        equ 88
TASK_SET_DRAWING_MODE           equ 92
TASK_SET_PEN_WIDTH              equ 93
TASK_REPAINT_SCREEN             equ 94
TASK_DRAW_TEXT                  equ 95

* Sound Index
SFX_PLAYER_SHOOTING         equ 0
SFX_PLAYER_DEATH            equ 1
SFX_ENEMY_DEATH             equ 2
SFX_POWERUP_COLLECTED       equ 3
SFX_PLAYER_HURT             equ 4
SFX_ENEMY_SHOOTING          equ 5
SFX_SLURP                   equ 6

* Music index
MUSIC_MAIN_MENU             equ 100
MUSIC_GAMELOOP              equ 101
MUSIC_GAMEOVER              equ 102
MUSIC_COUNT                 equ 3

* Offsets
LONG_OFFSET                 equ 4
ALL_REG					    REG	d0-d7/a0-a6

* Task argument constants
DOUBLE_BUFFERING            equ 17
CLEAR_SCREEN                equ $FF00

SOUND_PLAY_ONCE             equ 0
SOUND_LOOP                  equ 1
SOUND_STOP                  equ 2
SOUND_STOP_ALL              equ 3

SOUND_ERROR_CODE            equ 0

* Bitmap data offsets
BMP_WIDTH_OFFSET            equ 18
BMP_HEIGHT_OFFSET           equ 22
BMP_START_ADDR              equ 10

* Power-up types
POWERUP_TYPE_MOVE_SPEED         equ 0
POWERUP_MAX_MOVE_SPEED_LEVEL    equ 10

POWERUP_TYPE_ATK_SPEED          equ 1
POWERUP_MAX_ATK_SPEED_LEVEL     equ 10

POWERUP_TYPE_FUEL               equ 2
POWERUP_MIN_FUEL_AMOUNT         equ 800
POWERUP_MAX_FUEL_AMOUNT         equ 2400

POWERUP_TYPE_SPREAD             equ 3
POWERUP_MAX_SPREAD_LEVEL        equ 4

* Power-up enums
POWERUP_STATUS_ACTIVE       equ 1
POWERUP_STATUS_INACTIVE     equ 0

* Power-up floating texts
POWERUP_FONT_COLOR          equ COLOR_WHITE
POWERUP_FONT_SIZE           equ 12
POWERUP_FONT                equ FONT_COURIER_NEW
POWERUP_FONT_PROPS          equ POWERUP_FONT<<24+POWERUP_FONT_SIZE<<16

* Power-up spawn chances in percentage
POWERUP_SPAWN_CHANCE		equ	50	; Everything except fuel
POWERUP_FUEL_SPAWN_CHANCE	equ	100

* Other power-up constants
MAX_POWERUPS_ON_SCREEN      equ 40
FPOWERUP_SPEED              equ 1<<FRACTIONAL_BITS>>1
POWERUP_SIZE                equ 24
POWERUP_PEN_SIZE            equ 2
FPOWERUP_MOVEMENT_SPEED     equ 1<<FRACTIONAL_BITS>>3
FPOWERUP_OFFSCREEN_Y        equ (BACKGROUND_ORIGIN-POWERUP_SIZE)<<FRACTIONAL_BITS

* Power-up icons
* Move speed icon is literally >>
POWERUP_MOVESPD_ARROW_COLOR equ COLOR_WHITE
POWERUP_MOVESPD_X_OFFSET    equ POWERUP_PEN_SIZE+6
POWERUP_MOVESPD_Y_OFFSET    equ POWERUP_PEN_SIZE+4
POWERUP_MOVESPD_X_TILT      equ 4
POWERUP_MOVESPD_PEN_SIZE    equ 3
POWERUP_MOVESPD_GAP         equ 6

* Atk speed icon is ^^ (but they're vertically aligned)
POWERUP_ATKSPD_ARROW_COLOR  equ COLOR_CREAM
POWERUP_ATKSPD_X_OFFSET     equ POWERUP_PEN_SIZE+4
POWERUP_ATKSPD_Y_OFFSET     equ POWERUP_PEN_SIZE+6
POWERUP_ATKSPD_Y_TILT       equ 4
POWERUP_ATKSPD_PEN_SIZE     equ 3
POWERUP_ATKSPD_GAP          equ 6

* Food icon is meat
POWERUP_FOOD_MEAT_COLOR     equ COLOR_MEAT
POWERUP_FOOD_BONE_COLOR     equ COLOR_WHITE
POWERUP_BONE_EXTENSION_X    equ 2
POWERUP_BONE_THICKNESS      equ 4
POWERUP_MEAT_THICKNESS      equ 18
POWERUP_MEAT_X_OFFSET       equ 10
    
* Spread icon is 3-way spread
POWERUP_SPREAD_COLOR        equ COLOR_CREAM
POWERUP_SPREAD_X_OFFSET     equ POWERUP_PEN_SIZE+4
POWERUP_SPREAD_Y_GAP        equ 6
POWERUP_SPREAD_ARROW_WIDTH  equ 8
POWERUP_SPREAD_EXTRA_WIDTH  equ 3
POWERUP_SPREAD_PEN_SIZE     equ 3

* Power-up UI
POWERUP_UI_X                equ 10
POWERUP_UI_Y                equ 40
POWERUP_UI_GAP_X            equ 10
POWERUP_UI_GAP_Y            equ 25
POWERUP_UI_GAUGE_THICKNESS  equ 10
POWERUP_UI_GAUGE_WIDTH      equ 100
POWERUP_UI_GAUGE_BG_COLOR   equ COLOR_DARK_GRAY

* Fuel mechanics
STARTING_FUEL               equ 16000
MAX_FUEL                    equ 20000

* Fuel UI
FUEL_GAUGE_X                equ 10
FUEL_GAUGE_Y                equ 10
FUEL_GAUGE_WIDTH            equ WINDOW_WIDTH-FUEL_GAUGE_X*2-PLAYER_LIVES_OFFSET
FUEL_GAUGE_HEIGHT           equ 20
FUEL_GAUGE_GREEN_AMOUNT     equ $DD
FUEL_GAUGE_RED_AMOUNT       equ $DD
FUEL_GAUGE_DEPLETED_COLOR   equ COLOR_DARK_GRAY
FUEL_TEXT_X                 equ HALF_WINDOW_WIDTH-35
FUEL_TEXT_Y                 equ FUEL_GAUGE_Y+FUEL_GAUGE_HEIGHT+4

* Floating texts
MAX_FLOATING_TEXT               equ 20
FLOATING_TEXT_STATUS_ACTIVE     equ 1
FLOATING_TEXT_STATUS_INACTIVE   equ 0
FFLOATING_TEXT_MOVE_SPEED       equ 1<<FRACTIONAL_BITS>>3
FLOATING_TEXT_POWERUP_TTL       equ 200         ; In hundredth seconds

* Sin Calculation
SIN_ANGLE_INTERVAL      equ 10
FULL_CIRCLE_ANGLE       equ 360
FPI                     equ $324



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
