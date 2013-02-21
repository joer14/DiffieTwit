; CMPE12 - Winter 2012 Tracy Larrabee
; Eric Cao
; Rutherford Le
; Joe Rowley 
; Tyler Smith
; Lab 8
; Section 3 Jay
; Section 4 Daniel
; 3/14/12;
; This file is part of Diffie Hellman encrpytion key exchange system implemented on the HC11.
; You must first upload this code from a lab computer and then connect it to a computer
; running the Alice script. 

#include <v2_18g3.asm>

#define	PACTL	REGBASE+0x26
#define	PACNT	REGBASE+0x27 
#define	TMSK2	REGBASE+0x24
#define	TFLG2	REGBASE+0x25


	.sect .data
start:	.asciz	"Please connect serial to usb\n\n"
debug3:	.asciz	"end.\n"
space:	.asciz	" "
pp:	.asciz	"PP, PI= "
pi:	.asciz	" PI= "
prompt:	.asciz	"Key=switches+ISR"
spaces:	.asciz	"                " 
err:	.asciz	"Key!=0 && < PP-1"
ov:	.asciz	"  Key too big!  "
gotint:	.asciz	"Got key over srl"
compdb:	.asciz	"Private sec ="
gotdb:	.asciz	"Got key = "
gendb: 	.asciz	"Shared sec = "  
msg:	.asciz	"msg: "
raw:	.asciz	"rec byte:    "
arrow:  .asciz	">"

nums:	.space	16


count:		.byte	0
total:		.byte	0
randflag:	.byte 	0
offlag:		.byte	0
pubprime:	.byte	0
divhold:	.byte 	
pubint:	.byte	0
secretkey:	.byte 	0
pow:		.byte	0
pubkey:		.byte	0
//python pete's public key
ppp:		.byte	0
ss:		.byte	0
letter:		.byte	0


	.sect .text
main:
	ldx	#start		// pointer to output message
	jsr	OUTSTRING	// write program name out

	ldx     #BUTTONISR	// interrupt for interrupt button press
	stx     ISR_JUMP15

	ldx     #PA_OVRISR	// interrupt for pulse accumulator overflow
	stx     ISR_JUMP4	// called when PACNT goes from 255 to 0 

	ldaa    #0xf0		// Turn on pulse accumulator
	staa    PACTL
	ldaa    TMSK2		// Turn on overflow interrupts
	oraa	#0x20
	staa    TMSK2

/* Event spin loop */
loop:
	ldab	offlag
	tstb	
	bgt	findprime
	jmp 	loop

findprime:

	ldab	 PACNT
	clra
	stab	pubprime
	ldab	#2
	stab	divhold
	jmp	isPrime


isPrime:

	clra
	ldab	divhold
	xgdx
	clra
	ldab	pubprime
	cmpb	#227
	cmpb	#10		//just for simplicity we don't want a prime number less than 11
	blo	false
	idiv
	cmpx	#1
	beq	true
	tstb
	beq	false		//possible bug
	ldab	divhold
	incb
	stab	divhold
	jmp	isPrime

false:
	jmp	findprime
	
true:	
	jmp 	genkey

genkey:

	ldaa	#0
	staa	offlag
	clra

//	ldab	pubprime
//	ldaa	PACNT
	ldab	PACNT
	//jsr	DUMPREGS

	stab	pubint
	ldaa	pubint
	tsta
	beq	genkey	
	ldab	pubprime
	sba	
	bhs	genkey
	clra
	ldab	pubint
	jmp 	display
		

	

/* Interrupt Service Routine called each time the pulse accumlator
overflows or about every 10 ms. */
PA_OVRISR:	
// if you don't reset these flags (see description in HC11 manual), 
// nasty stuff happens, e.g. Ctrl-X reset can get disabled
	ldaa TFLG2
	oraa #0xc0		// clear PAOVF
	staa TFLG2
	rti

/* ISR called each time the IRQ pin is pulled low (button pushed). Do
as little as possible in this interrupt; LCD functions called here may
crash. Could use this interrupt to save current value of PACNT as a
"random" number. */
BUTTONISR:
    ldab	#1
    stab	offlag
    rti

display:

//FOR THE LOVE OF GOD DON'T FORGET TO REMOVE THIS CODE
//////
//	ldaa	#13
//	staa	pubprime
//	ldaa	#6
//	staa	pubint

/////
	ldaa	#1
	ldx	#spaces
	jsr	LCDLINE
	ldaa	#1
	ldx	#pp
	jsr	LCDLINE
	clra
	ldab	pubprime
	jsr	LCDINT
	ldaa	#44
	jsr	LCD_CHAR
	ldaa	#32
	jsr	LCD_CHAR
	//ldx	#pi
	//jsr	LCDLINE
	clra
	ldab	pubint
	//jsr	DUMPREGS
	jsr	LCDINT
	ldaa	#2
	ldx	#prompt
	jsr	LCDLINE

getsecret:

	ldaa	offlag
	tsta
	beq	getsecret

checksecret:

	ldaa	#0
	staa	offlag
	ldab	pubprime
	decb
	ldaa	SWITCHES
	staa	secretkey
	tsta
	beq	toohigh
	sba
	bhs	toohigh
	
	jmp 	computepublic

	
toohigh:

	ldaa	#2
	ldx	#err
	jsr	LCDLINE
	jmp 	getsecret

computepublic:

	ldaa	#0
	staa	offlag
//AND THIS TOO
//	ldaa	#3
//
//	staa	secretkey

	clra	
	ldab	secretkey
//	jsr	CONSOLEINT
//	jsr	OUTCRLF


	ldaa	pubint
	staa	total
	ldaa	secretkey
	staa	pow
	
power:
	ldaa	pow
	deca	
	beq	powerdone
	staa	pow
	ldaa	total
	ldab	pubint
	mul
	tstb
	beq	inc1
inc1d:	stab	total
	jmp 	power


inc1:	incb
	jmp	inc1d
	//REMEMBER TO HANDLE 0 CASE FOR MOD 255
	//IN FINAL IMPLEMENTATION
powerdone:
	clra
	ldab	pubprime
	xgdx
	clra
	ldab	total
	idiv
	stab	pubkey
//	clra
//	jsr	CONSOLEINT

	ldaa	#2
	ldx	#spaces
	jsr	LCDLINE
	ldx	#compdb
	jsr	LCDLINE
	clra
	ldab	secretkey
	jsr	LCDINT

	ldaa	pubprime
	jsr	OUTCHAR		//this is where 
	ldaa	pubint		//the three keys are transmitted
	jsr	OUTCHAR	
	ldaa	pubkey
	jsr	OUTCHAR
	


	//ldaa	#2
	//ldx	#spaces		//program flow
	//jsr	LCDLINE		//THIS IS WHERE THE TWO BOXES ARE TWEETING BACK 
	//ldx	#gotint		//AND FORTH
	//jsr	LCDLINE
	//ldaa	#0
	//staa	PACTL		//turns off the pulse accumulator


	jsr	GETCHAR		//then it waits for the received tweet key
	staa	ppp

	ldaa	#2
	ldx	#spaces
	jsr	LCDLINE
	ldx	#gotdb
	jsr	LCDLINE
	
	clra
	ldab	ppp
	jsr	LCDINT

	ldaa	ppp
	staa	total
	ldaa	secretkey
	staa	pow
	
power2:
	ldaa	pow
	deca	
	beq	powerdone2
	staa	pow
	ldaa	total
	ldab	ppp
	mul
	tstb
	beq	inc2
inc2d:	stab	total
	jmp 	power2

inc2:	incb
	jmp	inc2d

	//REMEMBER TO HANDLE 0 CASE FOR MOD 255
	//IN FINAL IMPLEMENTATION

powerdone2:

	clra
	ldab	pubprime
	xgdx
	ldab	total
	clra
	idiv
	stab	ss
	ldaa	#1
	ldx	#spaces
	jsr	LCDLINE
	ldx	#gendb
	jsr	LCDLINE

	clra
	ldab	ss
	jsr	LCDINT

	ldaa	#6
	jsr	OUTCHAR		//outputs an acknoweldge

	
//wait for interrupt	

	ldaa	#2
	ldx	#spaces
	jsr	LCDLINE
	ldaa	#1
	ldx	#spaces
	jsr	LCDLINE	
	ldx	#msg
	jsr	LCDLINE
	ldaa	#2
	ldx	#arrow
	jsr	LCDLINE

	//jsr	LCDLINE
	//ldx	#raw
	//jsr	LCDLINE

startreceive:

	ldab	#15
	stab	count
gettrans:


	jsr	GETCHAR		//gets the transmission
	eora	ss
	jsr	LCD_CHAR
	ldab	count
	decb
	tstb
	bne 	gettrans	
	jmp	startreceive
