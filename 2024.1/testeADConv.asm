; PROGRAMA PRA EU TENTAR IMPLEMENTAR UMA CONVERSS�O AD
;	JUSTIFICADO � ESQUERDA
; 	ADC = VIn(em Volts)*204.2
;	TESTEI COM 500mV e o resultado foi 102
;	FICA ARMAZENADO NO ADRESL
;	
;	JUSTIFICADO � DIREITA
;	�ADC = VIn(em Volts)*51
;	TESTEI COM 500mV e o resultado foi 25
;	FICA ARMAZENADO NO ADRESH
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
		ARMAZENA_ADC1
		ARMAZENA_ADC2
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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;*                     INICIO DO PROGRAMA                          *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000001' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00000001'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00000001'
	MOVWF	ADCON0
;*                     INICIALIZA��O DAS VARI�VEIS                 *
CLRF	GPIO
;*                     ROTINA PRINCIPAL                            *
MAIN

	;CORPO DA ROTINA PRINCIPAL
        BSF ADCON0, GO           ; Iniciar a convers�o A/D
	
	WAIT_ADC:
	BTFSC	ADCON0, GO         ; Verifica se a convers�o terminou
	GOTO	WAIT_ADC            ; Continua esperando se ainda n�o terminou
	MOVFW	ADRESH	
	MOVWF	ARMAZENA_ADC1
	
	
	GOTO	MAIN


	END