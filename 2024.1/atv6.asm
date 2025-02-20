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
		CONT1		;DELAY
		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;*                        FLAGS INTERNOS                           *

;*                         CONSTANTES                              *
#DEFINE B0 GPIO,GP0
#DEFINE B1 GPIO, GP1
#DEFINE B2 GPIO, GP4
#DEFINE B3 GPIO, GP5
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
	BTFSS	PIR1, 0		;PULA SE A INTERRUPÇÃO VEIO PELO OVERFLOW DO TMR1?
	GOTO	TESTA_ADCON		
	GOTO	DELAY_100T1	;USA O T1 PRA FAZER O DELAY E COMEÇAR A ADCON
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
TESTA_ADCON:
    BTFSS   PIR1, 6	    ;SE A INTERRUPÇÃO TIVER OCORRIDO PELO ADC 
    GOTO  SAI_INT
    GOTO  ADCONV

DELAY_100T1:
    BCF	PIR1, 0
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
    BCF PIR1, 6
    BSF ADCON0, GO
    ESPERA_ADC:
    BTFSC ADCON0, GO
    GOTO ESPERA_ADC
    GOTO SAIDA	    ;NÃO DEVE VIR PRA CA, POIS DEVE HAVER UMA OUTRA INTERURPÇÃO
    
SAIDA:
    MOVFW   ADRESH	    ; Move o valor de ADRESH para WREG
    SUBLW   D'25'		     ; Subtrai 51 do valor de WREG
    BTFSS   STATUS, C	    ;O INPUT FOI menor que 500mV
    GOTO    UM_OU_MAIOR	    ;SIM -> A SAÍDA VAI SER 1 OU ALGUMA MAIOR
    GOTO    SAIDA0000	    ;NÃ0 -> SAÍDA VAI SER 0000
    
UM_OU_MAIOR:
    MOVFW   ADRESH	    ; Move o valor de ADRESH para WREG
    SUBLW   D'50'		     ; Subtrai 51 do valor de WREG
    BTFSS   STATUS, C	    ;O INPUT FOI menor que 500mV
    GOTO    DOIS_OU_MAIOR	    ;SIM -> A SAÍDA VAI SER 1 OU ALGUMA MAIOR
    GOTO    SAIDA0001	    ;NÃ0 -> SAÍDA VAI SER 0000
 
DOIS_OU_MAIOR:
    MOVFW   ADRESH	    ; Move o valor de ADRESH para WREG
    SUBLW   D'75'		     ; Subtrai 51 do valor de WREG
    BTFSS   STATUS, C	    ;O INPUT FOI menor que 500mV
    GOTO    TRES_OU_MAIOR	    ;SIM -> A SAÍDA VAI SER 1 OU ALGUMA MAIOR
    GOTO    SAIDA0010	    ;NÃ0 -> SAÍDA VAI SER 0000
    RETURN

TRES_OU_MAIOR:
    MOVFW   ADRESH	    ; Move o valor de ADRESH para WREG
    SUBLW   D'100'		     ; Subtrai 51 do valor de WREG
    BTFSS   STATUS, C	    ;O INPUT FOI menor que 500mV
    GOTO    QUATRO_OU_MAIOR ;SIM -> A SAÍDA VAI SER 1 OU ALGUMA MAIOR
    GOTO    SAIDA0011	    ;NÃ0 -> SAÍDA VAI SER 0000
    
QUATRO_OU_MAIOR:
    MOVFW   ADRESH
    SUBLW   D'150'
    BTFSS   STATUS, C
    GOTO    CINCO_OU_MAIOR
    GOTO    SAIDA0100
    
CINCO_OU_MAIOR:
    MOVFW   ADRESH
    SUBLW   D'200'
    BTFSS   STATUS, C
    GOTO    SEIS_OU_MAIOR
    GOTO    SAIDA0101
    
SEIS_OU_MAIOR:
    MOVFW   ADRESH
    SUBLW   D'250'
    BTFSS   STATUS, C
    GOTO    SETE_OU_MAIOR
    GOTO    SAIDA0110

SETE_OU_MAIOR:
    RETURN
SAIDA0000:
    BCF B0
    BCF B1
    BCF B2
    BCF B3
    GOTO SAI_INT

SAIDA0001:
    
    BSF B0
    BCF B1
    BCF B2
    BCF B3
    GOTO    SAI_INT
    
SAIDA0010:
    
    BCF B0
    BSF B1
    BCF B2
    BCF B3
    GOTO    SAI_INT

SAIDA0011:
    BSF	    B0
    BSF	    B1
    BCF	    B2
    BCF	    B3
    GOTO    SAI_INT

SAIDA0100:
    BCF	    B0
    BCF	    B1
    BSF	    B2
    BCF	    B3
    GOTO    SAI_INT

SAIDA0101:
    BSF	    B0
    BCF	    B1
    BSF	    B2
    BCF	    B3
    GOTO    SAI_INT
    
SAIDA0110:
    BCF	    B0
    BSF	    B1
    BSF	    B2
    BCF	    B3
    GOTO    SAI_INT
    
SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;*	            	 ROTINAS E SUBROTINAS                      *

DELAY:
    MOVLW   D'250'      ; Carrega W com 250 (valor para o contador externo)
    MOVWF   CONT1       ; Armazena em CONT1 (contador externo)

DELAY_LOOP:
    NOP                 ; No Operation - cada instrução leva 1 ciclo
    DECFSZ  CONT1,F     ; Decrementa CONT1 e verifica se chegou a 0
    GOTO    DELAY_LOOP  ; Se CONT1 não for zero, repete o loop
    RETURN              ; Re

SUBROTINA1

	;CORPO DA ROTINA

	RETURN


;*                     INICIO DO PROGRAMA                          *
;para configurar as interrupções, vou modificar os registradores
;pie1, intcon, option?(acho que não),adcon0 
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000100' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00000100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
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
	MOVLW	B'00001001'
	MOVWF	ADCON0

;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN

	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

	END