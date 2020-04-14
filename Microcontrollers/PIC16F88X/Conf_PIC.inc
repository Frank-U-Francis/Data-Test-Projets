;*******************************************************************************
;                                                                              *
;    Filename:         Conf_PIC.INC                                             *
;    Date:             02/04/2020                                              *
;    File Version:     2.1.3                                                   *
;    Author:           MOJF & GMMF                                             *
;    Company:	       NONE                                                    *
;    Description:     Control 3 leds with TMRS                                 *
;                                                                              *
;*******************************************************************************
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0x20F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3EFF
 __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF

;*******************************************************************************