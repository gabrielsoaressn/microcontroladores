;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; 100% -> HIGH RANGE 14
; 75% -> HIGH RANGE 9
; 50% -> HIGH RANGE 3
; 25% -> LOW RANGE 4
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

ESPERA_ESTOURO:
    BTFSS   INTCON,T0IF   ; Verifica se ocorreu estouro do Timer0
    GOTO    ESPERA_ESTOURO
    GOTO    PREPARA_RETURN

PREPARA_RETURN:
    BCF     INTCON,T0IF
    BTFSS GPIO, GP4
    GOTO ACENDE
    GOTO APAGA
ACENDE:
    BANK1
    CLRF ANSEL
    BANK0
    BSF GPIO, GP4
    RETURN

APAGA:
    BANK1
    CLRF ANSEL
    BANK0
    BCF GPIO, GP4
    RETURN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000010' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00000010'
	MOVLW	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'10001110'	
	MOVWF	VRCON		;DEFINE AS OPÇÕES PARA A TENSÃO DE REFERÊNCIA
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00010100'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	;UTILIZEI A INVERSÃO PARA MINHA LOGICA FAZER SENTIDOÓ

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	;TENSAO VREF MAIOR QUE 3.5V?
	;CMCON == 1? SIM: EXECUTAREI O DUTY_100 NÃO: TESTO UMA TENSÃO MENOR
	;SIGO A MESMA LÓGICA PARA TODOS OS TESTES ATÉ CHEGAR EM 0
	BTFSS	CMCON, COUT
	GOTO	TESTE_2_5V
	GOTO	DUTY_100

DUTY_100:
	BSF	GPIO, GP4
	GOTO DUTY_100

DUTY_75:
    ;75% DO PERÍODO DE TEMPO O GP4 VAI ESTAR EM 1
    ;ESSA LÓGICA SE REPETE EM TODOS OS DUTIES
    ;PASSO OS VALORES PARA O CONTADOR QUE FARÃO ELE CONTAR 1.5ms E DEPOIS 0.5MS
    BSF GPIO, GP4
    MOVLW D'209'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVLW D'241'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVWF TMR0
    GOTO DUTY_75
    
DUTY_50:
    ;50% DO PERÍODO DE TEMPO O GP4 VAI ESTAR EM 1
    ;ESSA LÓGICA SE REPETE EM TODOS OS DUTIES
    ;PASSO OS VALORES PARA O CONTADOR QUE FARÃO ELE CONTAR 1ms E DEPOIS 1MS
    BSF GPIO, GP4
    MOVLW D'225'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVLW D'225'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVWF TMR0
    GOTO DUTY_50
    
DUTY_25:
;25% DO PERÍODO DE TEMPO O GP4 VAI ESTAR EM 1
    ;ESSA LÓGICA SE REPETE EM TODOS OS DUTIES
    ;PASSO OS VALORES PARA O CONTADOR QUE FARÃO ELE CONTAR 1ms E DEPOIS 1MS
    BSF GPIO, GP4
    MOVLW D'241'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVLW D'209'
    MOVWF TMR0
    CALL ESPERA_ESTOURO
    MOVWF TMR0
    GOTO DUTY_25
    
    
TESTE_2_5V:
	BANK1
	MOVLW	B'10001001'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	TESTE_1_7V
	GOTO	DUTY_75


TESTE_1_7V:
	BANK1
	MOVLW	B'10000011'
	MOVWF	VRCON
	BANK0
	BTFSS	CMCON, COUT
	GOTO	DUTY_25
	GOTO	DUTY_50

	

	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END