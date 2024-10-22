;*                     ARQUIVOS DE DEFINI��ES                      *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;*                         VARI�VEIS                               *

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		CONTADOR_INTERNO
		CONTADOR_EXTERNO
		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;*                        FLAGS INTERNOS                           *

;*                         CONSTANTES                              *

;*                           ENTRADAS                              *

;*                           SA�DAS                                *

;*                       VETOR DE RESET                            *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;*                    IN�CIO DA INTERRUP��O                        *

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;*                    ROTINA DE INTERRUP��O                        *

;*                 ROTINA DE SA�DA DA INTERRUP��O                  *

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE
;*	            	 ROTINAS E SUBROTINAS                      *
SAIDA_LOW:
    BCF	GPIO, GP4
    GOTO MAIN

TESTEGP1:
    BTFSS   GPIO, GP1
    GOTO    TESTEGP2_GP1LOW
    GOTO    TESTEGP2_GP1HIGH

TESTEGP2_GP1LOW:
    BTFSS   GPIO, GP2
    GOTO    SAIDA262		;001
    GOTO    SAIDA349		;101

TESTEGP2_GP1HIGH:
    BTFSS   GPIO,GP2
    GOTO    SAIDA440		;011
    GOTO    SAIDA523		;111
    
SAIDA262:
    BSF	    GPIO,GP4
    CALL    DELAY1908
    BCF	    GPIO,GP4
    CALL    DELAY1908
    GOTO SAIDA262
    
SAIDA349:
    BSF	    GPIO, GP4
    CALL    DELAY1434
    BCF	    GPIO,GP4
    CALL    DELAY1434
    GOTO    SAIDA349

SAIDA440:
    BSF	    GPIO, GP4
    CALL    DELAY1136
    BCF	    GPIO,GP4
    CALL    DELAY1136
    GOTO    SAIDA440
SAIDA523:
    BSF	    GPIO, GP4
    CALL    DELAY956
    BCF	    GPIO,GP4
    CALL    DELAY956
    GOTO    SAIDA523
    
DELAY1908:
    MOVLW   D'4'
    MOVWF   CONTADOR_EXTERNO
    MOVLW   D'115'
    MOVWF   CONTADOR_INTERNO
    GOTO    DELAY

DELAY1434:
    MOVLW   D'3'
    MOVWF   CONTADOR_EXTERNO
    MOVLW   D'211'
    MOVWF   CONTADOR_INTERNO
    GOTO    DELAY
    
DELAY1136:
    MOVLW   D'3'
    MOVWF   CONTADOR_EXTERNO
    MOVLW   D'116'
    MOVWF   CONTADOR_INTERNO
    GOTO    DELAY
    
DELAY956:
    MOVLW   D'3'
    MOVWF   CONTADOR_EXTERNO
    MOVLW   D'55'
    MOVWF   CONTADOR_INTERNO
    GOTO    DELAY

DELAY:
    DECFSZ  CONTADOR_EXTERNO
    GOTO    DELAY_INTERNO
    RETURN
    DELAY_INTERNO:
    DECFSZ  CONTADOR_INTERNO
    GOTO    DELAY_INTERNO
    GOTO    DELAY
    
    
;*                     INICIO DO PROGRAMA                          *
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;*                     ROTINA PRINCIPAL                            *
MAIN
	NOP
	BTFSS	GPIO, GP0
	GOTO	SAIDA_LOW
	GOTO	TESTEGP1

	GOTO	MAIN

	END