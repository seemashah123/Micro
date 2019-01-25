	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	
	movlw 0x00 ;make E,F,H tristates
	movwf TRISE, ACCESS
	movlw 0x00
	movwf TRISF, ACCESS
	movlw 0x00
	movwf TRISH, ACCESS
	movlw 0x00
	movwf TRISJ, ACCESS
	
	movlw 0x02 ;OE 1
	movwf PORTF, ACCESS
	
	movlw 0xAA ;data bus
	movwf PORTE, ACCESS
	nop
	nop
	nop
	nop
	
	movlw 0x06 ;clock and CP 1
	movwf PORTF, ACCESS
	nop
	nop
	nop
	movlw 0xFF
	movwf TRISE, ACCESS
	
	
	movff PORTE, PORTH

	
	movlw 0x8 ;OE2 to 1
	movwf PORTF, ACCESS
	
	movlw 0xAB ;data bus
	movwf PORTE, ACCESS
	nop
	nop
	nop
	nop
	
	movlw 0x18 ;clock2 and CP2 1
	movwf PORTF, ACCESS
	nop
	nop
	nop
	movlw 0xFF
	movwf TRISE, ACCESS
	movlw 0x00
	movwf PORTF, ACCESS
	
	
	movff PORTE, PORTJ
	
loop	goto loop
	end
