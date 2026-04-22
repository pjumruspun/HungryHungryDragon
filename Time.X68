*-----------------------------------------------------------
* Title      : Time
* Written by : Pon Jumruspun
* Date       : 5/31/2024
* Description: Time utility subroutines
*-----------------------------------------------------------

updateTime:
* Call this after updateDeltaTime
* Registers used: D1
    move.l  DeltaTime, d1
    add.l   d1, TimeSinceStartGame
    rts

updateDeltaTime:
* Registers used: D1

    jsr     getTimeSinceMidnight    ; D1 contains time since midnight
    sub.l   LastUpdateTime, d1      ; D1 contains duration since last update aka DeltaTime
    move.l  d1, DeltaTime
    
    jsr     getTimeSinceMidnight    ; D1 contains time since midnight
    move.l  d1, LastUpdateTime
    rts

getTimeSinceMidnight:
* Returns time since midnight in hundreds of a second

* Parameters:
* D0: Trap code 

* Returns:
* D1: Hundredths seconds since last midnight

    move.l  d0, -(sp)                           ; Save context

    move.l  #TASK_GET_TIME_SINCE_MIDNIGHT, d0
    trap    #15
    
    move.l  (sp)+, d0                           ; Load context
    rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
