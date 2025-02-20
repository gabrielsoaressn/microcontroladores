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
		CONTADOR

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
	BCF	PIR1, 0
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;*	            	 ROTINAS E SUBROTINAS                      *

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000001'
	MOVWF	PIE1
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW   B'00110001'		; Configura Timer1 (prescaler 1:1, timer ligado)
	MOVWF   T1CON		; Escreve no registrador T1CON

;*      INICIALIZA��O DAS VARI�VEIS                 *
	
MOVLW	H'0B'
MOVWF	TMR1H
MOVLW	H'DF'
MOVWF	TMR1L
	
;*                     ROTINA PRINCIPAL                            *

MAIN
	;BTFSS	CONTADOR, 0	;SE O CONTADOR ESTIVER SETADO, VERIFICA
	GOTO	MAIN		;SE TIVER LIMPO SEGUE O FLUXO AT� O ESTOURO
	;GOTO	VERIFICA_TMR1	;SE ESTIVER SETADO, SEGUE VERIFICA��O DE TMR1
		
	
	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

	END