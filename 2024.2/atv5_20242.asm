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
		VALOR_CONV
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
ESPERA_ESTOURO:
    BTFSS   INTCON,T0IF   ; Verifica se ocorreu estouro do Timer0
    GOTO    ESPERA_ESTOURO
    GOTO    PREPARA_RETURN

PREPARA_RETURN:
    BCF     INTCON,T0IF
    BTFSS GPIO, GP0
    GOTO ACENDE
    GOTO APAGA
ACENDE:
    BSF GPIO, GP0
    RETURN

APAGA:
    BCF GPIO, GP0
    RETURN
SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00010000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00001000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW   B'00001101'
	MOVWF	ADCON0

;*                     INICIALIZA��O DAS VARI�VEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN

	;CORPO DA ROTINA PRINCIPAL
	;VOU SETAR O GP0 PARA 0 A FIM DE QUE SEMPRE QUE HOUVER RESET, O GP0 SEJA 0
	BCF GPIO, GP0
	CONVERSAO:
	BSF ADCON0, 1
	BTFSS	ADCON0, 1
	GOTO COMPARA_100
	GOTO CONVERSAO

	
	COMPARA_100:
	MOVFW	ADRESH
	SUBLW	D'249'
	BTFSS	STATUS, C   ;SE O CARRY FOR ATIVADO significa que  adresH < 249. Nesse caso vamos fazer o teste compara 75
	GOTO	DUTY_100
	GOTO	COMPARA_75
	
	COMPARA_75:
	MOVFW	ADRESH
	SUBLW	D'187'
	BTFSS	STATUS, C   ;SE O CARRY FOR ATIVADO significa que  adresH < 249. Nesse caso vamos fazer o teste compara 75
	GOTO	DUTY_75
	GOTO	COMPARA_50
	
	COMPARA_50:
	MOVFW	ADRESH
	SUBLW	D'125'
	BTFSS	STATUS, C   ;SE O CARRY FOR ATIVADO significa que  adresH < 249. Nesse caso vamos fazer o teste compara 75
	GOTO	DUTY_50
	GOTO	DUTY_25
	
	DUTY_100:
	BSF	GPIO, GP0
	GOTO DUTY_100
	
	DUTY_75:
	;75% DO PER�ODO DE TEMPO O GP4 VAI ESTAR EM 1
	;ESSA L�GICA SE REPETE EM TODOS OS DUTIES
	;PASSO OS VALORES PARA O CONTADOR QUE FAR�O ELE CONTAR 1.5ms E DEPOIS 0.5MS
	BSF GPIO, GP0
	MOVLW D'209'
	MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVLW D'241'
	MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVWF TMR0
	GOTO DUTY_75
    
	DUTY_50:
	;50% DO PER�ODO DE TEMPO O GP4 VAI ESTAR EM 1
	;ESSA L�GICA SE REPETE EM TODOS OS DUTIES
	;PASSO OS VALORES PARA O CONTADOR QUE FAR�O ELE CONTAR 1ms E DEPOIS 1MS
	BSF GPIO, GP0
	MOVLW D'225'
	MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVLW D'225'
        MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVWF TMR0
	GOTO DUTY_50
    
	DUTY_25:
	;25% DO PER�ODO DE TEMPO O GP4 VAI ESTAR EM 1
	;ESSA L�GICA SE REPETE EM TODOS OS DUTIES
	;PASSO OS VALORES PARA O CONTADOR QUE FAR�O ELE CONTAR 1ms E DEPOIS 1MS
	BSF GPIO, GP0
	MOVLW D'241'
	MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVLW D'209'
	MOVWF TMR0
	CALL ESPERA_ESTOURO
	MOVWF TMR0
	GOTO DUTY_25
	
	GOTO	MAIN

	END