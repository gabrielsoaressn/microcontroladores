;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Este programa implementa um dimmer para um LED usando um microcontrolador. 
;A ideia é controlar o brilho do LED variando a largura do pulso (PWM) 
;do sinal enviado para ele. O brilho do LED é proporcional ao 
;duty cycle (a porcentagem do tempo em que o sinal está ligado).
;CALCULEI OS VALORES ABAIXO PARA A TENSÃO DE REFERÊNCIA
	
;0 = HIGH RANGE			1 = LOW RANGE
;
;1,25+C*0,16			C*0,21			

;0 = 1,2			0 = 0
;1 = 1,4			1 = 0,2
;2 = 1,6			2 = 0,4
;3 = 1,7			3 = 0,6
;4 = 1,9			4 = 0,8
;5 = 2				5 = 1
;6 = 2,2			6 = 1,3
;7 = 2,4			7 = 1,5
;8 = 2,5			8 = 1.7
;9 = 2,7			9 = 1,9
;10 = 2,8			10 = 2,1
;11 = 3				11 = 2,3
;12 = 3,2			12 = 2,5
;13 = 3,3			13 = 2,7
;14 = 3,5			14 = 2,9
;15 = 3,6			15 = 3,1

	
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
	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

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
;*                     INICIO DO PROGRAMA                          *	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000010' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVWF	B'00000010'
	MOVLW	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'10001110'	
	MOVWF	VRCON		;DEFINE AS OPÇÕES PARA A TENSÃO DE REFERÊNCIA
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000100'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *

;*                     ROTINA PRINCIPAL                            *
MAIN
	;CMCON == 1? SIM: EXECUTAREI O DUTY_100 NÃO: TESTO UMA TENSÃO MENOR
	;SIGO A MESMA LÓGICA PARA TODOS OS TESTES ATÉ CHEGAR EM 0
	BTFSS	CMCON, COUT
	GOTO	TESTE_3_3V
	GOTO	DUTY_100

DUTY_100:
	BSF	GPIO, GP4
	GOTO	FIM

DUTY_94:
    ;94% DO PERÍDO DE TEMPO O GP4 VAI ESTAR EM 1
    ;ESSA LÓGICA SE REPETE EM TODOS OS DUTIES

DUTY_91:

DUTY_89:

DUTY_86:
    
DUTY_83:
   
DUTY_80:
    
DUTY_77:
    
DUTY_71:
    
DUTY_69:
    
DUTY_66:
    

TESTE_3_3V:
	;ALTERNO O BANCO PARA ALTERAR A TENSÃO DE REFERÊNCIA
	;ESSA LÓGICA SE REPETE EM TODOS OS TESTES
	BANK1
	MOVLW	B'10001101'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_94
	GOTO	TESTE_3_2V

TESTE_3_2V:
	BANK1
	MOVLW	B'10001100'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_91
	GOTO	TESTE_3_1V
	
TESTE_3_1V:
	BANK1
	MOVLW	B'10101111'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_89
	GOTO	TESTE_3V

TESTE_3V:
	BANK1
	MOVLW	B'10001011'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_86
	GOTO	TESTE_2_9V
	
TESTE_2_9V:
	BANK1
	MOVLW	B'10101110'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_83
	GOTO	TESTE_2_8V

TESTE_2_8V:
	BANK1
	MOVLW	B'10001010'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_80
	GOTO	TESTE_2_7V
TESTE_2_7V:
	BANK1
	MOVLW	B'10001001'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_77
	GOTO	TESTE_2_5V

TESTE_2_5V:
	BANK1
	MOVLW	B'10001000'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_71
	GOTO	TESTE_2_4V
	
TESTE_2_4V:
	BANK1
	MOVLW	B'10000111'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_69
	GOTO	TESTE_2_3V
	
TESTE_2_3V:
	BANK1
	MOVLW	B'10101011'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_66
	GOTO	TESTE_2_2V

TESTE_2_1V:
	BANK1
	MOVLW	B'10000110'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_57
	GOTO	TESTE_2V
	
	GOTO	MAIN
FIM
	GOTO	FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
