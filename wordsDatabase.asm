#include p18f87k22.inc
	
    global	random
    extern	LCD_Write_Message
    extern	chosenWord, wordsList
    extern	counter2, counter	


int_hi	code	0x0008 ; high vector, no low vector
    btfss   INTCON,RBIF ; check that this is RBIF interrupt
    retfie  FAST ; if not then return
    incf    LATD ; increment PORTD
    ;code to be called on interupt
    ;call    writeword  
    ;---
    bcf	    INTCON,TMR0IF ; clear interrupt flag
    retfie  FAST ; fast return from interrupt

    
wdata	code
words	data	"ABCDEF"
	constant words_l = .6
	;constant counter2 = .2 ;word_l minus 1

cwords	code

fit	lfsr	FSR0, wordsList	; Load FSR0 with address in RAM	
	movlw	upper(words)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(words)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(words)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	words_l	; bytes to read
	movwf 	counter		; our counter register
loop2 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop2		; keep going until finished
random
	bsf INTCON,RBIE ; Enable RBIE interrupt
	movlw	.2
	movwf	counter2
randomloop
	DECFSZ	counter2, 1 ;decreases counter by 1 and skips next instruction if zero
	goto randomloop	
	
	;----checks if button is pressed, breaks loops if it is
	;movlw	0xFF
	;movwf	TRISC, ACCESS ; makes all pins on C inputs
	;nop
	;nop
	;BTFSS	PORTC, 1 ;skips next instruction if button pressed
	;goto	randomloop
	;----	
setcounter ;sets counter to 2
	movlw	.2
	movwf	counter2
 	goto	randomloop
	
;writeword
;	movf    counter2, w
;	mullw   2 ; multiplies counter in w by 2
;	movwf   counter2 ; moves new counter (double) back to counter
;	movlw   words_l+counter2
;	lfsr    FSR2, chosenWord
;	movlw   .2
;	call    LCD_Write_Message
;	return
	
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
	
	
	

