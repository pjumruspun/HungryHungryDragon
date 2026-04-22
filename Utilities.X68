*-----------------------------------------------------------
* Title      : Utilities
* Written by : Pon Jumruspun
* Date       : 6/12/2024
* Description: Utility and helper functions
*-----------------------------------------------------------

regToString:
* Convert a number in D1 to null-terminated string at A1
* A1: Target string address
* D0: The number to convert (Max of decimal value of 99999999)
    
* Other registers used: D1, D7

    jsr     hexToDecimal            ; D7 now contains decimal representation of D0

    rts
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
