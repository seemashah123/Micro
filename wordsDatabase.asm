#include p18f87k22.inc
	
	global	random
	extern	LCD_Write_Message


pdata	code	
words	data	"IN", "AT", "BE"
	constant words_l = .3	
	constant counter = .2 ;word_l minus 1
pad	code

main	code
	
random	
	;----checks if button is pressed, breaks loops if it is
	bsf	PORTC, 1
	nop
	BTFSC	PORTC, 1 ;skips next instruction if pin 1 is '0'
	break
	;----
	decfsz	couter ;decreases counter by 1 and skips next instruction if zero
	bra	setcounter
	
	movf	words+counter, w
	movwf	FSR2L
	movlw	0x00
	movwf	FSR2H
	movlw	.2
	call	LCD_Write_Message
		
	movlw	.2
	
	return
setcounter ;sets counter to 2
	movlw	.2
	movwf	counter
	goto	random
	
	
	
;words
	;banksel .2
	;lfsr	FSR0, 0x000, BANKED
	;movlw	"I"
	;clrf	POSTINC0, f
	;movlw	"N"
	;clrf	POSTINC0, f
	
	;lfsr	FSR0, 0x010, BANKED
	;movlw	"A"
	;clrf	POSTINC0, f
	;movlw	"T"
	;clrf	POSTINC0, f
	
	;lfsr	FSR0, 0x020, BANKED
	;movlw	"B"
	;clrf	POSTINC0, f
	;movlw	"E"
	;clrf	POSTINC0, f
;
	
	
	
	

