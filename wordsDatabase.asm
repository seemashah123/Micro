#include p18f87k22.inc
	
    global	random, fit
    extern	LCD_Write_Message
    extern	wordsList
    extern	counter2, counter	


int_hi	code	0x0008 ; high vector, no low vector ;joe
    btfss   INTCON,RBIE ; check that this is RBIF interrupt
    retfie  FAST ; if not then return
    ;incf    LATD ; increment PORTD
    ;add code here to add one to counter and double it
    bcf	    INTCON,RBIF ; clear interrupt flag
    retfie  FAST ; fast return from interrupt
    return

    
wdata	code
words	data	"ABCDEF"
	constant words_l = .6

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
	return
random
	bsf INTCON,RBIE ; Enable RBIE interrupt
	movlw	.2
	movwf	counter2
randomloop
	DECFSZ	counter2, 1 ;decreases counter by 1 and skips next instruction if zero
	goto randomloop	
	
setcounter ;sets counter to 2
	movlw	.2
	movwf	counter2
 	goto	randomloop
	
	end	
	
	
	
	;----checks if button is pressed, breaks loops if it is
	;movlw	0xFF
	;movwf	TRISC, ACCESS ; makes all pins on C inputs
	;nop
	;nop
	;BTFSS	PORTC, 1 ;skips next instruction if button pressed
	;goto	randomloop
	;----		
	
	
	
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

	
	
	

