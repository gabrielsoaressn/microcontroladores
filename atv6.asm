;epecificações:
; Uma conversão A/D deve ser efetuada a cada 100ms, em modo cíclico;
; A interrupção gerada pelo conversor A/D deve ser utilizada; pra que?
; Utilize o TIMER 1 para a contagem do período de amostragem (100ms);
; A interrupção gerada pelo TIMER 1 deve ser utilizada;
; O valor da conversão A/D, de 0V a 5V, deve ser transformado para uma escala de 0 a 9, em valores
;inteiros. Veja a escala na tabela abaixo;
; O valor da escala a ser mostrado, de 0 a 9, deve ser representado na codificação BCD para ser
;conectado a um display de 7 segmentos. Para que todos tenham a mesma conectividade, siga a
;seguinte configuração:
; GP0 ? b0 (MENOS significativo) do BCD
; GP1 ? b1 do BCD
; GP4 ? b2 do BCD
; GP5 ? b3 (MAIS significativo) do BCD
; A conversão A/D deve ser feita pela porta GP2;

; ativar interrupção por timer1 e por adcon0
; não pode usar comparador porque ele usa as portas gp0 e gp1

	
;*                     ARQUIVOS DE DEFINIÇÕES                      *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;*                         VARIÁVEIS                               *

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

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
	BTFSS	PIE1, 0		;PULA SE A INTERRUPÇÃO VEIO PELO OVERFLOW DO TMR1?
	GOTO	TESTA_ADCON		
	GOTO	DELAY_100T1	;USA O T1 PRA FAZER O DELAY E COMEÇAR A ADCON
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *

SAI_INT
	BCF	PIE1, 0
	BCF	PIE1, 6
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;*	            	 ROTINAS E SUBROTINAS                      *

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

TESTA_ADCON:
    BTFSS   PIR1, 6	    ;SE A INTERRUPÇÃO TIVER OCORRIDO PELO ADC 
    GOTO  SAI_INT
    GOTO  ADCONV
DELAY_100T1:
    MOVLW 0xCF                  ; Valor alto para TMR1H
    MOVWF TMR1H
    MOVLW 0x18                  ; Valor baixo para TMR1L
    MOVWF TMR1L
    
    ESPERA_OVERFLOW:
    BTFSS PIR1, 0          ; Verifica se o Timer 1 estourou (TMR1IF = 1)
    GOTO ESPERA_OVERFLOW             ; Se não estourou, fica esperando
    GOTO ADCONV
   
    GOTO SAI_INT

ADCONV:
    BSF ADCON0, GO
    ESPERA_ADC:
    BTFSS ADCON0, GO
    GOTO ESPERA_ADC
    GOTO SAI_INT	;NÃO DEVE VIR PRA CA, POIS DEVE HAVER UMA OUTRA INTERURPÇÃO
    
;*                     INICIO DO PROGRAMA                          *
;para configurar as interrupções, vou modificar os registradores
;pie1, intcon, option?(acho que não),adcon0 
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'01000001'
	MOVWF	PIE1		;ATIVEI A INTERRUPÇÃO POR TMR1 OVERFLOW
				; E POR CONVERSÃO AD

	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000001'
	MOVWF	T1CON

;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN

	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

	END