*************************************************************************************
*														*
*	Pseudo random number generator for the EASy68k simulator	2006/01/10		*
*														*
*	This code is an attempt to gauge the effectiveness of variations on the		*
*	shift register type of pseudo random number generator. The PRNG code is		*
*	similar to that used in the RND() function in EhBASIC68.				*
*														*
*	More 68000 and other projects can be found on my website at ..			*
*														*
*	 http://mycorner.no-ip.org/index.html							*
*														*
*	mail : leeedavison@googlemail.com								*
*														*
*************************************************************************************

*************************************************************************************
* This is the code that generates the pseudo random sequence. A seed word located in
* PRNlword(a3) is loaded into a register before being operated on to generate the
* next number in the sequence. This number is then saved as the seed for the next
* time it's called.
*
* This code is adapted from the 32 bit version of RND(n) used in EhBASIC68. Taking
* the 19th next number is slower but helps to hide the shift and add nature of this
* generator as can be seen from analysing the output.

LAB_RND
    sub.l   #LONG_OFFSET*3, sp
    movem.l d0-d2, (sp)         ; Save context
    
	MOVE.l	PRNlword(a3),d0		* get current seed longword
	MOVEQ		#$AF-$100,d1		* set EOR value
	MOVEQ		#18,d2			* do this 19 times
Ninc0
	ADD.l		d0,d0				* shift left 1 bit
	BCC.s		Ninc1				* if bit not set skip feedback

	EOR.b		d1,d0				* do Galois LFSR feedback
Ninc1
	DBF		d2,Ninc0			* loop

	MOVE.l	d0,PRNlword(a3)		* save back to seed longword

    movem.l (sp), d0-d2
    add.l   #LONG_OFFSET*3, sp  ; Load context
	RTS

randomRange:
* Author:       Pon Jumruspun
* Date:         6/6/2024
* Description:  Custom function to random a number between [0, d6) using DIVU

* Parameters:
* D6: Upper limit (exclusive) of the number

* Returns:
* D7: Randomized unsigned number

* Other registers used: A3

    jsr     LAB_RND
    clr.l   d7
    move.w  PRNlword(a3), d7        ; Random long in D7
    
    divu    d6, d7
    move.w  #0, d7                  ; Clear the quotient
    swap    d7                      ; Get the remainder, which is the random number in the range
        
    rts
	
* variables used

PRNlword	ds.l	1				* PRNG seed long word





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
