	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Write_Message, LCD_clear, LCD_nextline, LCD_delay_ms	    ; external LCD subroutines
	extern	pad_setup, pad_read
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern	random				    ; external wordsDatabase 
	extern	column, fit
	global	wordsList, counter
	global	counter2
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
counter2    res 1   ; gives random number to select word from database of words
delay_count res 1   ; reserve one byte for counter in the delay routine
score	    res 4   ; scores of each of the four players
player	    res 1   ; current player number
letterPos   res 1   ; position in whole word currently at
letter	    res 1   ; current letter in whole word being compared against
word_len    res	1   ; length of the words in the database
high_score  res 1   ; stores highest score any player has 
current_score	res 1 ; stores current score which is being compared to high_score

tables	    udata 0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray	    res 0x80    ; reserve 128 bytes for welcome message data
wordsList   res 0x80    ; reserve 128 bytes for list of words
tables2	    udata 0x500    ; reserve data anywhere in RAM (here at 0x500)
myArray2    res 0x80    ; reserve 128 bytes for hangman display data
;chosenWord  res 0x80	; stores chosen word

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "__\n"	; message, plus carriage return
	constant    myTable_l=.3	; length of data
myTable2 data	    "Press RB5\n"	; message, plus carriage return
	constant    myTable2_l=.10	; length of data	

	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	movlw 0
	goto	start
	
	; ******* Main programme ****************************************
start 	
	movlw	.2
	movwf	word_len
	
	movlw	.10
	movwf	myTable_l
	movlw	.1
	movwf	player
	lfsr	FSR2, score 
		
	; write my table to myArray
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
	
		; write my table2 to myArray2
	lfsr	FSR0, myArray2	; Load FSR0 with address in RAM	
	movlw	upper(myTable2)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable2)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable2)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable2_l	; bytes to read
	movwf 	counter		; our counter register
loop2 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop2		; keep going until finished
	;----------
	;writes myArray to LCD
	call	LCD_clear
	movlw	myTable2_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray2
	call	LCD_Write_Message
	;--------------
		
	;call	LCD_nextline
	call	pad_setup
	call	fit
	call	random
	movf	word_len, w
	mulwf	counter2
	movff	PRODL,	counter2
	nop
	nop
	call	LCD_Setup
	nop
	;call	LCD_clear
	movlw	.1000
	call	LCD_delay_ms
	nop
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	nop
lightLED ;seema
	movlw	0x00
	movwf	TRISF, ACCESS ;port G all outputs
checkLED1 
	movlw	.1
	CPFSEQ 	player   ;check player, skips next line if player 1
	goto	checkLED2
	bsf	PORTF, 1
	goto	loop_pread

checkLED2	
	movlw	.2
	CPFSEQ 	player
	goto	checkLED3 
	bsf	PORTF, 2
	goto	loop_pread
	
checkLED3	
	movlw	.3
	CPFSEQ 	player
	goto	checkLED4 
	bsf	PORTF, 3
	goto	loop_pread
	
checkLED4	
	bsf	PORTF, 4
	
loop_pread ;loops until button on keypad is pressed goes to find_letter when button is pressed	
	call	pad_read
	TSTFSZ	column  ;skips next line if no key pressed on keypad
	goto	find_letter ; letter is in FSR1
	goto	loop_pread  ; goto current line in code


	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

find_letter ; length of word is 2 for now -> need to make this a constant but isn't working
	movlw	.0
	movwf	letterPos
find_letter_loop	
	movlw	.1
	addwf	letterPos ;adds one to letterPos (initially 0)
	movf	word_len, w
	addlw	.1
	CPFSLT	letterPos ;if letter position is less than 3 skips next line
	goto	notfound
	lfsr	FSR0, wordsList ;moves address of wordsList to FSR0
	
	;add counter2 to letterPos and put in w
	movlw	.1
	subwf	letterPos, 0
	addwf	counter2, 0
	;addwf	letterPos-1, 0
	;--
	
 	movff	PLUSW0, letter ;gets the letter at position w in wordsList and puts in letter
	;banksel .2
	movf	INDF1, w;FSR1 is loaded with address of entered letter so moves this to w
	CPFSEQ	letter  ;compares chosen letter with letter in word, skips if it is in word
	goto	find_letter_loop
	goto	found
	

found ; code if letter is in word ;joe
	; goto code to add letter to display
	;need to add letter to myArray at position letterPos
	call	LCD_clear
	lfsr	FSR2, myArray
	movf	letterPos-2, w
	movff	letter, PLUSW2
	movlw	myTable_l-1
	call	LCD_Write_Message
	;--
	movlw	.1
	addwf	POSTINC2 ; adds 1 to current score
	movlw	.4
	CPFSLT	player ; skips if f < 4
	call	reset_to_player1
	
	;check if all letters in word have been found
notfound 
	;code if letter isn't in word ;joe
	;code to sound buzzer 
	;---
	movlw	.0
	movwf	INDF1
	addwf	POSTINC2 ; adds 0 to current score
	movlw	.4
	CPFSLT	player ; skips if f < 4
	goto	reset_to_player1
	movlw	.1
	addwf	player
	goto	lightLED
	;loop to LED lighting part ;seema
reset_to_player1
	lfsr	FSR2, score
	movlw	.1
	movwf	player
	goto	lightLED
endofgame
	movlw	0x00
	movwf	PORTF
	movlw	.4
	movwf	counter
	movlw	.1
	movwf	high_score
	lfsr	FSR2, score
highscore_loop	
	movff	POSTINC2, current_score
	movf	high_score, w
	CPFSLT	current_score
	movff	current_score, high_score
	DECFSZ	counter
	goto	highscore_loop
	
	lfsr	FSR2, score
	movf	high_score, w
	CPFSEQ	POSTINC2 ;skips if is high score
	goto	check_score2
	bsf	PORTF, 1
check_score2
	CPFSEQ	POSTINC2
	goto	check_score3
	bsf	PORTF, 2
check_score3
	CPFSEQ	POSTINC2
	goto	check_score4
	bsf	PORTF, 3
check_score4
	CPFSEQ	POSTINC2
	goto	check_score4
	bsf	PORTF, 4	
	goto	setup
	
	end
