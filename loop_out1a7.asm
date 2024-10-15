;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     JULHO DE 2024                               *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16F628a                                      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
;*                     ARQUIVOS DE DEFINIÇÕES                      *

#include "p16f628a.inc"

; CONFIG
; __config 0xFFFF
 __CONFIG _FOSC_EXTRCCLK & _WDTE_ON & _PWRTE_OFF & _MCLRE_ON & _BOREN_ON & _LVP_ON & _CPD_OFF & _CP_OFF

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;*                         VARIÁVEIS                               *

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		; REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	; JUNTO ÀS INTERRUPÇÕES
		RB_QUE_ACENDE	; VARIÁVEL QUE ARMAZENA A INFORMAÇÃO DE QUAL RB EU VOU MANDAR


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
    BSF	    PORTB, RB0
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
	BANK1			; ALTERA PARA O BANCO 1  
	MOVLW	B'00000001'
	MOVWF	TRISA
	MOVLW	B'00000000'	; CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISB		; COMO SAÍDAS, AQUI USAMOS TRISB PARA PORTB
	MOVLW	B'00000100'	; CONFIGURAÇÃO PARA OPTION_REG
	MOVWF	OPTION_REG	; DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		; DESABILITA AS INTERRUPÇÕES
	
	BANK0				
	MOVLW	B'00000010'
	MOVWF	CMCON
	MOVLW	B'00000000'
	MOVWF	PORTB
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN		
	GOTO	MAIN
	END