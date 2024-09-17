;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; gp0 = Vin
; comparar gp0 com gp1
	; Se gp0 > 
	;    gp5 = 1
	; sen�o
	;    gp5 = 0
;*                     ARQUIVOS DE DEFINI��ES                      *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;*                    PAGINA��O DE MEM�RIA                         *
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA


;*                         VARI�VEIS                               *


	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;*                       VETOR DE RESET                            *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;*                    IN�CIO DA INTERRUP��O                        *

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;*                    ROTINA DE INTERRUP��O                        *

	BTFSS   PIR1, 3 ; Verifica se o bit CMIF(3) est� setado
	GOTO SAI_INT   ;PULA ESSE COMANDO SE A INTERRUP��O TIVER ACONTECIDO PELO COMPARADOR
	;SE A INTERRUP��O TIVER ACONTECIDO POR MEIO DO COMPARADOR
	BTFSC	CMCON, 6    ;COUT(6)
	GOTO ACENDE_LED	    ;SE GP0>GP1 -> ACENDE LED EM GP5
	GOTO APAGA_LED
	

;*                 ROTINA DE SA�DA DA INTERRUP��O                  *

SAI_INT
	BCF PIR1, 3 ;LIMPA FLAG
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	
	RETFIE


SUBROTINA1

	;CORPO DA ROTINA

	RETURN
	
ACENDE_LED
    BSF GPIO, GP5
    GOTO LOOP	;SE N�O VOLTA PRA MAIN

APAGA_LED
    BCF GPIO, GP5
    GOTO LOOP	;SE N�O VOLTA PRA MAIN

	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00000011'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000000'
	MOVWF	PIE1
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000010'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	;MOVLW	B''
	;MOVWF	PIR1

;*                     ROTINA PRINCIPAL                            
MAIN
	BTFSC	CMCON, 6    ;COUT = 1 SE GP1>GP0
			    ;COUT = 0 SE GP1<GP1
	CALL ACENDE_LED
	CALL APAGA_LED
	LOOP
	

	
	GOTO	MAIN


	END