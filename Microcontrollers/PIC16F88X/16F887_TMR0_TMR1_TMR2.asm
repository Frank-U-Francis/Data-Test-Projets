;*******************************************************************************
;                                                                              *
;    Microchip licenses this software to you solely for use with Microchip     *
;    products. The software is owned by Microchip and/or its licensors, and is *
;    protected under applicable copyright laws.  All rights reserved.          *
;                                                                              *
;    This software and any accompanying information is for suggestion only.    *
;    It shall not be deemed to modify Microchip?s standard warranty for its    *
;    products.  It is your responsibility to ensure that this software meets   *
;    your requirements.                                                        *
;                                                                              *
;    SOFTWARE IS PROVIDED "AS IS".  MICROCHIP AND ITS LICENSORS EXPRESSLY      *
;    DISCLAIM ANY WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING  *
;    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS    *
;    FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL          *
;    MICROCHIP OR ITS LICENSORS BE LIABLE FOR ANY INCIDENTAL, SPECIAL,         *
;    INDIRECT OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, HARM TO     *
;    YOUR EQUIPMENT, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR    *
;    SERVICES, ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY   *
;    DEFENSE THEREOF), ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER      *
;    SIMILAR COSTS.                                                            *
;                                                                              *
;    To the fullest extend allowed by law, Microchip and its licensors         *
;    liability shall not exceed the amount of fee, if any, that you have paid  *
;    directly to Microchip to use this software.                               *
;                                                                              *
;    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF    *
;    THESE TERMS.                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Filename:         MAIM.ASM                                                *
;    Date:             02/04/2020                                              *
;    File Version:     2.1.3                                                   *
;    Author:           MOJF & GMMF                                             *
;    Company:	       NONE                                                    *
;    Description:      Control 3 leds with TMRS                                *
;                                                                              *
;*******************************************************************************
;********************************Libraries**************************************
    
#include   "Conf_PIC.INC"
    
;*******************************************************************************    
CTIMER0 EQU 0X20
CTIMER1 EQU 0X21
CTIMER2	EQU 0X22
RETARDO EQU 0X23	
    ORG 0
	GOTO INICIO
    ORG 4
	GOTO TMR_INT
;***********************Conf uController****************************************	
INICIO
	;Conf
	
	BSF	STATUS,RP0	    ;BANK1
	
	MOVLW	B'01001000'	    ;E: Pull up, int-falling edge, internal 
				    ;instructions, low, WDT,PRESCALER
	MOVWF	OPTION_REG	    ;TMR0 Conf
	CLRF	TRISD		    ;TRISC AS OUTPUT
	
	BSF OSCCON,6
	BSF OSCCON,5
	BSF OSCCON,4		    ;FREQ PIC 31KHz
	
	MOVLW	B'00000011'
	MOVWF	PIE1
	CLRF	PIE2		    ;PERIPHERICLA INTERRUPTS  
	
	BSF	STATUS,RP1	    ;BANK3
	CLRF	ANSEL	
	CLRF	ANSELH		    ;AD_INPUT_DISLABLE
	
	BCF	STATUS,RP0	    ;BANK2
	
	BCF	STATUS,RP1	    ;BANK0
	
	BSF	T1CON,0	;Enable TMR1
	BCF	T1CON,1	; INTERNAL OR EXTERNAL CLOCK
	BSF	T1CON,2	;NO SYC 
	BCF	T1CON,3 ;LP OSC CONTROL
	BCF	T1CON,4
	BCF	T1CON,5 ;PRESCALER 1:1
	BCF	T1CON,6 ;TMR1 ALWAYS COUNT-NO GATE
	BCF	T1CON,7 ;GATE LOGIC- NO USDE
	
	MOVLW	B'00000100'	    ;E= TMR2
	MOVWF	T2CON		    ;TMR2 Conf
	
	CLRF	PORTD
	CLRF	TMR0
	CLRF	TMR1
	CLRF	TMR2		
				    ;CLEAN TIMERS & PORTC
	MOVLW	0X7F
	MOVWF	CTIMER0
	MOVWF	CTIMER1
	MOVWF	CTIMER2
	MOVWF	TMR0
	MOVWF	TMR1L
	MOVWF	TMR2
	MOVLW	0XFF
	MOVWF	TMR1H
	MOVLW	B'11100000'
	MOVWF	INTCON		    ;INTERRUPT CONF
	
				    ;SET TIMRS
;***********************Bucle and test PORTB************************************				    
WORKS	
	BTFSS	PORTB,RB0
	CALL	MOD_A_TMR0	    ;ADD SPEED
	BTFSS	PORTB,RB1
	CALL	MOD_S_TMR0	    ;REST SPEDD
	
	BTFSS	PORTB,RB2
	CALL	MOD_A_TMR1
	BTFSS	PORTB,RB3
	CALL	MOD_S_TMR1
	
	BTFSS	PORTB,RB4
	CALL	MOD_A_TMR2
	BTFSS	PORTB,RB5
	CALL	MOD_S_TMR2
	CALL	DELAY
    GOTO WORKS			    
;*******************************************************************************
    
;*********************************Functions*************************************
DELAY
	MOVLW .36
	MOVWF RETARDO
	DECFSZ RETARDO
	GOTO $-1
    RETURN		    ;Delay
    
MOD_A_TMR0
	INCF    CTIMER0	    ;INCREMENT OF TMR0
    RETURN
    
MOD_S_TMR0	
	DECF    CTIMER0	    ;DECREMENT OF TMR0
    RETURN
    
    
MOD_A_TMR1
	INCF    CTIMER1	    ;INCREMENT OF TMR1
    RETURN
    
MOD_S_TMR1	
	DECF    CTIMER1	    ;DECREMENT OF TMR1
    RETURN

    
MOD_A_TMR2
	INCF    CTIMER2	    ;INCREMENT OF TMR2
    RETURN
    
MOD_S_TMR2
	DECF    CTIMER2	    ;DECREMENT OF TMR2		
    RETURN    
;*******************************************************************************   
    
;*******************************INTERRUPT***************************************     
    
TMR_INT
	BCF	INTCON,PEIE
	BCF	INTCON,GIE	    ;DISABLE INTERRUPTS
	CALL	UNLOCK_FLAGS	    ;CLEAN TMR FLAGS & SET PORTC
	CALL	SETTIMERS	    ;SET NEW DATA FOR TIMERS
	BSF	INTCON,PEIE
	BSF	INTCON, GIE	    ;ENABLE INTERRUPTS
    RETFIE
;*******************************************************************************     
    
;***************************INTER_SUBRUTINE*************************************    
UNLOCK_FLAGS
	
	BTFSC INTCON,T0IF   
	GOTO  TMR0_SET
END_TMR0	
	BTFSC PIR1,TMR1IF
	GOTO TMR1_SET
END_TMR1	
	BTFSC PIR1,TMR2IF
	GOTO  TMR2_SET
END_TMR2	
	NOP
    RETURN			;TEST FLAGS
    
;ON-OFF RC0 & RESET FLAG TMR0
TMR0_SET
    
	BTFSS PORTD,RD0
	    GOTO  SETS_RD0 
	GOTO  CLEAN_RD0
    
SETS_RD0
	BSF	 PORTD,RD0
    GOTO TMR0_END
    
CLEAN_RD0
	BCF	 PORTD,RD0
    GOTO TMR0_END    
    
TMR0_END
	BCF   INTCON,T0IF
    GOTO END_TMR0
;ON-OFF RC1 & RESET FLAG TMR1	
    
TMR1_SET
	BTFSS PORTD,RD1
	    GOTO  SETS_RD1 
	GOTO  CLEAN_RD1
    
SETS_RD1
	BSF	 PORTD,RD1
    GOTO TMR1_END
    
CLEAN_RD1
	BCF	 PORTD,RD1
    GOTO TMR1_END    
    
TMR1_END
	BCF   PIR1,TMR1IF
    GOTO END_TMR1
    
;ON-OFF RC2 & RESET FLAG TMR2    
TMR2_SET
	BTFSS PORTD,RD2
	    GOTO  SETS_RD2 
	GOTO  CLEAN_RD2
    
SETS_RD2
	BSF	 PORTD,RD2
    GOTO TMR2_END
    
CLEAN_RD2
	BCF	 PORTD,RD2
    GOTO TMR2_END    
    
TMR2_END
	BCF   PIR1,TMR2IF
    GOTO END_TMR2    
    
; ADD OR QUIT TIME OF INTERRUPT
SETTIMERS
	MOVFW   CTIMER0
	MOVWF   TMR0
	MOVFW   CTIMER2
	MOVWF   TMR2
	MOVFW   CTIMER1
	MOVWF	TMR1L
	MOVLW	0XFF
	MOVWF	TMR1H
    RETURN
;*******************************************************************************     

									    END