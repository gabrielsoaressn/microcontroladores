;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÃ‡Ã•ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2024                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David JosÃ© de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÃ‡Ã•ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃƒO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÃ‡ÃƒO DE MEMÃ“RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÃ‡ÃƒO DE COMANDOS DE USUÃRIO PARA ALTERAÃ‡ÃƒO DA PÃGINA DE MEMÃ“RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÃ“RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÃ“RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÃVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DOS NOMES E ENDEREÃ‡OS DE TODAS AS VARIÃVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÃ‡O INICIAL DA MEMÃ“RIA DE
					;USUÃRIO
		W_TEMP		;REGISTRADORES TEMPORÃRIOS PARA USO
		STATUS_TEMP	;JUNTO Ã€S INTERRUPÃ‡Ã•ES3
		COUNT	;CONTADOR PARA DEFINIR QUANTAS VEZES ELE VAI ENTRAR NA INTERRUPÇÃO ATÉ QUE DÊ OS 500 ms
		
		;COLOQUE AQUI SUAS NOVAS VARIÃVEIS
		;NÃƒO ESQUEÃ‡A COMENTÃRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÃ‡ÃƒO DE VARIÃVEIS



	ORG	0x00			;ENDEREÃ‡O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÃCIO DA INTERRUPÃ‡ÃƒO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÃ‡O DE DESVIO DAS INTERRUPÃ‡Ã•ES. A PRIMEIRA TAREFA Ã‰ SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÃ‡ÃƒO FUTURA

	ORG	0x04			;ENDEREÃ‡O INICIAL DA INTERRUPÃ‡ÃƒO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÃ‡ÃƒO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃƒO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÃ‡Ã•ES'

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÃDA DA INTERRUPÃ‡ÃƒO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÃ‡ÃƒO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÃ‡ÃƒO DE FUNCIONAMENTO
; E UM NOME COERENTE Ã€S SUAS FUNÃ‡Ã•ES.

SUBROTINA1
	RETURN

DELAY_500MS:
    MOVLW D'61'   ; Contagem para aproximadamente 500ms
    MOVWF COUNT

DELAY_LOOP:
    CLRF TMR0      ; Zera o Timer0

WAIT_TMR0:
    BTFSS INTCON, T0IF ; Espera Timer0 transbordar
    GOTO WAIT_TMR0
    BCF INTCON, T0IF   ; Limpa a flag do Timer0

    DECFSZ COUNT, F   ; Decrementa contador
    GOTO DELAY_LOOP    ; Repete até zerar

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÃDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÃ‡Ã•ES DE OPERAÃ‡ÃƒO
	MOVLW	B'00100000'	;habilito interrupções globais e interrupções overflow do tmr0
	MOVWF	INTCON		;DEFINE OPÃ‡Ã•ES DE INTERRUPÃ‡Ã•ES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÃ‡ÃƒO DO COMPARADOR ANALÃ“GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÃ‡ÃƒO DAS VARIÃVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOVLW D'0'
MOVWF COUNT
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN	
	CALL DELAY_500MS
	BTFSS GPIO, 5 
	GOTO  _0TESTA_B4
	GOTO  _100TESTA_B1
	
	_0TESTA_B4:
	BTFSS GPIO, GP4
	GOTO _00TESTA_B2
	GOTO _01TESTA_B2
	
	_00TESTA_B2:
	BTFSS GPIO, GP2
	GOTO _000TESTA_B1
	GOTO _001TESTA_B1
	
	_01TESTA_B2:
	BTFSS GPIO, GP2
	GOTO _010TESTA_B1
	GOTO _011TESTA_B1
	
	_000TESTA_B1:
	BTFSS GPIO, GP1
	GOTO R0000
	GOTO R0001
	
	_001TESTA_B1:
	BTFSS GPIO, GP1
	GOTO R0010
	GOTO R0011
	
	_010TESTA_B1:
	BTFSS GPIO, GP1
	GOTO R0100
	GOTO R0101
	
	_011TESTA_B1:
	BTFSS GPIO, GP1
	GOTO R0110
	GOTO R0111
	
	_100TESTA_B1:
	BTFSS GPIO, GP1
	GOTO R1000
	GOTO R1001
		
	R0000:
	BSF GPIO, GP1
	BSF GPIO, GP2
	BSF GPIO, GP4
	BSF GPIO, GP5
	BTFSS GPIO, GP0
	GOTO GO_HIGH
	GOTO GO_LOW
	
	GO_HIGH:
	BSF GPIO, GP0
	GOTO MAIN

	GO_LOW:
	BCF GPIO, GP0
	GOTO MAIN
	
	R0001:
	BCF GPIO, GP1
	GOTO MAIN
	
	R0010:
	BSF GPIO, GP1
	BCF GPIO, GP2
	GOTO MAIN

	R0011:
	BCF GPIO, GP1
	GOTO MAIN
	
	R0100:
	BSF GPIO, GP1
	BSF GPIO, GP2
	BCF GPIO, GP4
	GOTO MAIN
	
	R0101:
	BCF GPIO, GP1
	GOTO MAIN
	
	R0110:
    	BSF GPIO, GP1
	BCF GPIO, GP2
	GOTO MAIN
	
	R0111:
	BCF GPIO, GP1
	GOTO MAIN
	
	R1000:
	BSF GPIO, GP1
	BSF GPIO, GP2
	BSF GPIO, GP4
	BCF GPIO, GP5
	GOTO MAIN
	
	R1001:
	BCF GPIO, GP1
	
	GOTO MAIN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END