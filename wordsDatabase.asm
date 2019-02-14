#include p18f87k22.inc
	
    global	random
    extern	LCD_Write_Message
    extern	chosenWord

 
wdata	code	
words	data	"IN", "AT", "BE"
	constant words_l = .3	
	constant counter2 = .2 ;word_l minus 1


cwords	code
	
random	
	
	
	
	
	dcfsnz	counter2 ;decreases counter by 1 and skips next instruction if zero
	goto	setcounter	
	
	; alt method
	movlw	0x02 ;sets columns as inputs
	movwf	TRISC, ACCESS
	nop
	nop
	nop
	nop
	movlw	0x02
	movwf	PORTC
	
	;----checks if button is pressed, breaks loops if it is
	;bsf	PORTC, 1
	;nop
	;nop
	BTFSC	PORTC, 1 ;skips next instruction if pin 1 is '0'
	goto	random
	;----
	
	
	; write word to LCD
	movf	counter2, w
	mullw	2 ; multiplies counter in w by 2
	movwf	counter2 ; moves new counter (double) back to counter
	
	movlw	words_l+counter2
	lfsr	FSR2, chosenWord
	movlw	.2
	call	LCD_Write_Message
	return
setcounter ;sets counter to 2
	movlw	.2
	movwf	counter2
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
	end
	
	
	

