; PROGRAMA PRA EU TENTAR IMPLEMENTAR UMA CONVERSSÃO AD
;	JUSTIFICADO À ESQUERDA
; 	ADC = VIn(em Volts)*204.2
;	TESTEI COM 500mV e o resultado foi 102
;	FICA ARMAZENADO NO ADRESL
;	
;	JUSTIFICADO À DIREITA
;	ÀADC = VIn(em Volts)*51
;	TESTEI COM 500mV e o resultado foi 25
;	FICA ARMAZENADO NO ADRESH
;*                     ARQUIVOS DE DEFINIÇÕES                      *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;*                    PAGINAÇÃO DE MEMÓRIA                         *

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;*                         VARIÁVEIS                               *

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		ARMAZENA_ADC1
		ARMAZENA_ADC2
		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS
;*                        FLAGS INTERNOS                           *

;*                         CONSTANTES                              *

;*                           ENTRADAS                              *

;*                           SAÍDAS                                *
	
;*                       VETOR DE RESET                            *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;*                    INÍCIO DA INTERRUPÇÃO                        *

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;*                    ROTINA DE INTERRUPÇÃO                        *

;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *

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
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00000001'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000001'
	MOVWF	ADCON0
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
CLRF	GPIO
;*                     ROTINA PRINCIPAL                            *
MAIN

	;CORPO DA ROTINA PRINCIPAL
        BSF ADCON0, GO           ; Iniciar a conversão A/D
	
	WAIT_ADC:
	BTFSC	ADCON0, GO         ; Verifica se a conversão terminou
	GOTO	WAIT_ADC            ; Continua esperando se ainda não terminou
	MOVFW	ADRESH	
	MOVWF	ARMAZENA_ADC1
	
	
	GOTO	MAIN


	END