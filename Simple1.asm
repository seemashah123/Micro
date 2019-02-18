	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_clear, LCD_nextline	    ; external LCD subroutines
	extern	pad_setup, pad_read
	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	random				    ; external wordsDatabase 
	extern	column
	global	chosenWord, wordsList, counter
	global	counter2
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
counter2    res 1
delay_count res 1   ; reserve one byte for counter in the delay routine
score	    res 4
player	    res 1
letterPos res 1


tables	    udata 0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray	    res 0x80    ; reserve 128 bytes for message data
wordsList   res 0x80    ; reserve 128 bytes for message data
tables2	    udata 0x500    ; reserve data anywhere in RAM (here at 0x500)
chosenWord  res 0x80

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "__\n"	; message, plus carriage return
	constant    myTable_l=.3	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	;call	ADC_Setup	; setup ADC
	movlw 0
	goto	start
	
	; ******* Main programme ****************************************
start 	movlw	.1
	movwf	player
	lfsr	FSR2, score 
	movlw	.0
	movwf	letterPos
	
	
	;write my table to myArray
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	;----------
	;writes myArray to LCD
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	;--------------
	
	;movlw	myTable_l	; output message to UART
	;lfsr	FSR2, myArray
	;call	UART_Transmit_Message
	
	;call	LCD_clear
	
	;call	LCD_nextline
	;movlw	myTable_l-1	; output message to LCD (leave out "\n")
	;lfsr	FSR2, myArray
	;call	LCD_Write_Message
	
	;call	pad_setup
	;
	;goto	random
loop_pread	
	call	pad_read
	TSTFSZ	column  ;skips next line if no key pressed on keypad
	goto	find_letter
	goto	loop_pread		; goto current line in code


	; a delay subroutine if you need one, times around loop in delay_count
;delay	decfsz	delay_count	; decrement until zero
	;bra delay
	;return

find_letter ;word AB
	movlw	.1
	addwf	letterPos
	lfsr	FSR0, wordsList
	movf	column, w
	movf	PLUSW0, w    
	CPFSEQ	wordsList  ;compares chosen letter with letter in word, skips if it is in word
	goto	find_letter
	goto	found

second_letter ;need to make this a loop later
	movf	column, w
	addlw	.1
	movf	PLUSW0, w
	CPFSEQ	wordsList
	goto	notfound
	goto	found
	;words+counter2
	;words+counter2+1
found ; code if letter isn't in word
	; goto code to add letter to display
	movlw	.1
	addwf	POSTINC2 ; adds 1 to current score
	movlw	.4
	CPFSLT	player ; skips if f < 4
	lfsr	FSR2, score
notfound ;code if letter isn't in word
	;code to sound buzzer 
	;---
	movlw	.0
	addwf	POSTINC2 ; adds 0 to current score
	movlw	.4
	CPFSLT	player ; skips if f < 4
	lfsr	FSR2, score
	 
	end
