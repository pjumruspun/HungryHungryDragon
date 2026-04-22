*-----------------------------------------------------------
* Title      : Sound
* Written by : Pon Jumruspun
* Date       : 6/5/2024
* Description: Sound Effect Manager. Managing both music and other sound effects
*-----------------------------------------------------------

playPlayerShootingSound:
* Play the player shooting sound once
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_PLAYER_SHOOTING, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts
    
playPlayerDeathSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_PLAYER_DEATH, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts

playEnemyDeathSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_ENEMY_DEATH, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts

playPowerUpCollectedSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_POWERUP_COLLECTED, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts

playPlayerHurtSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_PLAYER_HURT, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts

playEnemyShootingSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_ENEMY_SHOOTING, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts
    
playSlurpSound:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SFX_SLURP, d1
    move.l  #SOUND_PLAY_ONCE, d2
    trap    #15
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts
    
playMainMenuMusic:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    jsr     stopAllMusic
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #MUSIC_MAIN_MENU, d1
    move.l  #SOUND_LOOP, d2
    trap    #15
    
    cmp.l   #SOUND_ERROR_CODE, d0
    beq     musicError
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts
    
playGameLoopMusic:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    jsr     stopAllMusic
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #MUSIC_GAMELOOP, d1
    move.l  #SOUND_LOOP, d2
    trap    #15
    
    cmp.l   #SOUND_ERROR_CODE, d0
    beq     musicError
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts
    
playGameOverMusic:
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)
    
    jsr     stopAllMusic
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #MUSIC_GAMEOVER, d1
    move.l  #SOUND_LOOP, d2
    trap    #15
    
    cmp.l   #SOUND_ERROR_CODE, d0
    beq     musicError
    
    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp
    
    rts

stopAllMusic:
    sub.l   #LONG_OFFSET*5, sp
    movem.l d0-d3/a1, (sp)
    
    move.l  #TASK_CONTROL_SOUND, d0
    move.l  #SOUND_STOP_ALL, d2
    move.l  #MUSIC_COUNT-1, d3
    lea     MusicArrayIndex, a1
    clr.l   d1
    
stopAllMusicLoop:
    move.b  (a1)+, d1
    trap    #15
    cmp.l   #SOUND_ERROR_CODE, d0
    beq     musicError
    
    dbra    d3, stopAllMusicLoop
    
    movem.l (sp), d0-d3/a1
    add.l   #LONG_OFFSET*5, sp
    
    rts

loadSound:
* Registers used: D0, D1, A1
    
* Sound effects
* Player shooting
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathPlayerShooting, a1
    move.l  #SFX_PLAYER_SHOOTING, d1
    trap    #15
    
* Player death
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathPlayerDeath, a1
    move.l  #SFX_PLAYER_DEATH, d1
    trap    #15
    
* Enemy death
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathEnemyDeath, a1
    move.l  #SFX_ENEMY_DEATH, d1
    trap    #15
    
* Power-up collected
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathPowerUpCollected, a1
    move.l  #SFX_POWERUP_COLLECTED, d1
    trap    #15
    
* Player hurt
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathPlayerHurt, a1
    move.l  #SFX_PLAYER_HURT, d1
    trap    #15
    
* Enemy shooting
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathEnemyShooting, a1
    move.l  #SFX_ENEMY_SHOOTING, d1
    trap    #15
    
* Slurp
    move.l  #TASK_LOAD_SOUND, d0
    lea     SoundPathSlurp, a1
    move.l  #SFX_SLURP, d1
    trap    #15
    
* Music
* Main menu
    move.l  #TASK_LOAD_SOUND, d0
    lea     MusicPathMainMenu, a1
    move.l  #MUSIC_MAIN_MENU, d1
    trap    #15
    
* Gameloop
    move.l  #TASK_LOAD_SOUND, d0
    lea     MusicPathGameLoop, a1
    move.l  #MUSIC_GAMELOOP, d1
    trap    #15
    
* Gameover
    move.l  #TASK_LOAD_SOUND, d0
    lea     MusicPathGameOver, a1
    move.l  #MUSIC_GAMEOVER, d1
    trap    #15
    
    rts
    
musicError:
    illegal




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
