
#include p18f87k22.inc
	global	pad_setup, pad_read
	extern	lcdlp2, LCD_Write_Message

acs0    udata_acs   ; named variables in access ram
column  res 1 ;location to store column 
row	res 1 ;location to store row
   
pad	code

table
	banksel .2
	movlw	"F"
	movwf	0x11, BANKED
	
	movlw	"E"
	movwf	0x21, BANKED
	return
	
	;keep inputting letters and their addresses into table??
	
pad_setup
	banksel .15 ;found this 15 using the data sheet, to find with 'file register' it is in?
	bsf	PADCFG1,REPU,BANKED
	clrf	LATE
	
	call	table
	return

pad_read
	;FB73
	movlw	0x0F ;sets columns as inputs
	movwf	TRISE, ACCESS
	movlw   .1
	call	lcdlp2
	movlw	0xFF
	movwf	PORTE
	movff	PORTE, column
	
	;CDEF
	movlw	0xF0 ;sets rows as inputs
	movwf	TRISE, ACCESS
	movlw   .1
	call	lcdlp2
	movlw	0xFF
	movwf	PORTE
	movff	PORTE, row 
	
	;movf	column, w
	;andwf	row,w
	;movwf	FSR2L
	;movlw	.2
	;movwf	FSR2H
	
	movf	row, w
	ANDWF	column, 1, 0 ;puts in column location
	nop
	movf	column, w
	
	movwf	FSR2L
	movlw	0x00
	movwf	FSR2H
	;lfsr	2, w
	movlw	.1
	
	call	LCD_Write_Message
	
	
	
	
	;have changed every port H to port E

	
	
	return

    end