*-----------------------------------------------------------
* Title      : Main file of the assembly game project (Title TBD)
* Written by : Pon Jumruspun
* Date       : 5/30/2024
* Description: This x68 is to be called to launch the game.
* Note       : FVAR means the variable is in fixed point format.
*              Turn it into integer by shifting right.
*-----------------------------------------------------------

    INCLUDE Constants.x68

    ORG     $1000
    
    INCLUDE BitmapDisplay.x68
    INCLUDE Inputs.x68
    INCLUDE Renderer.x68
    INCLUDE GameLogic.x68
    INCLUDE Player.x68
    INCLUDE Enemy.x68
    INCLUDE Difficulty.x68
    INCLUDE Time.x68
    INCLUDE Collision.x68
    INCLUDE SevenSegment.x68
    INCLUDE Score.x68
    INCLUDE MovingStars.x68
    INCLUDE Powerups.x68
    INCLUDE Fuel.x68
    INCLUDE Physics.x68
    INCLUDE FloatingText.x68
    INCLUDE SinTable.x68
    INCLUDE Sound.x68
    INCLUDE random.x68
    
    ORG     $4000
START:
    jsr     initialize
    jsr     initializeGameloop
    jsr     gameloop
	
    SIMHALT

gameloop:
    jsr     inputCycle              ; D7 has input enum for updateCycle
    jsr     updateCycle
    jsr     renderCycle
    bra     gameloop
    
* Put variables and constants here

    INCLUDE Variables.x68

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
