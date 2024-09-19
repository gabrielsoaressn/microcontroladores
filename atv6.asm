;epecifica��es:
; Uma convers�o A/D deve ser efetuada a cada 100ms, em modo c�clico;
; A interrup��o gerada pelo conversor A/D deve ser utilizada; pra que?
; Utilize o TIMER 1 para a contagem do per�odo de amostragem (100ms);
; A interrup��o gerada pelo TIMER 1 deve ser utilizada;
; O valor da convers�o A/D, de 0V a 5V, deve ser transformado para uma escala de 0 a 9, em valores
;inteiros. Veja a escala na tabela abaixo;
; O valor da escala a ser mostrado, de 0 a 9, deve ser representado na codifica��o BCD para ser
;conectado a um display de 7 segmentos. Para que todos tenham a mesma conectividade, siga a
;seguinte configura��o:
; GP0 ? b0 (MENOS significativo) do BCD
; GP1 ? b1 do BCD
; GP4 ? b2 do BCD
; GP5 ? b3 (MAIS significativo) do BCD
; A convers�o A/D deve ser feita pela porta GP2;

; ativar interrup��o por timer1 e por adcon0
; n�o pode usar comparador porque ele usa as portas gp0 e gp1

	
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
;		S00
		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;*                        FLAGS INTERNOS                           *

;*                         CONSTANTES                              *
#DEFINE B0 GPIO,GP0
#DEFINE B1 GPIO, GP1
#DEFINE B2 GPIO, GP4
#DEFINE B3 GPIO, GP5
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
	BTFSS	PIR1, 0		;PULA SE A INTERRUP��O VEIO PELO OVERFLOW DO TMR1?
	GOTO	TESTA_ADCON		
	GOTO	DELAY_100T1	;USA O T1 PRA FAZER O DELAY E COME�AR A ADCON
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
TESTA_ADCON:
    BTFSS   PIR1, 6	    ;SE A INTERRUP��O TIVER OCORRIDO PELO ADC 
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
    GOTO ESPERA_OVERFLOW             ; Se n�o estourou, fica esperando
    GOTO ADCONV
   
    GOTO SAI_INT

ADCONV:
    BCF PIR1, 6
    BSF ADCON0, GO
    ESPERA_ADC:
    BTFSS ADCON0, GO
    GOTO ESPERA_ADC
    GOTO SAIDA	    ;N�O DEVE VIR PRA CA, POIS DEVE HAVER UMA OUTRA INTERURP��O
    
SAIDA:
    MOVFW   ADRESH	    ; Move o valor de ADRESH para WREG
    SUBLW   D'51'		     ; Subtrai S00 do valor de WREG
    BTFSS   STATUS, Z	     ;O INPUT FOI IGUAL AO S00(1V)
    GOTO    SAIDA0001
    
SAIDA0000:
    GOTO SAI_INT
SAIDA0001:    
    BSF     B0
    GOTO    SAI_INT
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
;para configurar as interrup��es, vou modificar os registradores
;pie1, intcon, option?(acho que n�o),adcon0 
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00001000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00000100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'01000001'
	MOVWF	PIE1		;ATIVEI A INTERRUP��O POR TMR1 OVERFLOW 
				; E POR CONVERS�O AD

	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00000001'
	MOVWF	T1CON
	MOVLW	B'00001001'
	MOVWF	ADCON0

;*                     INICIALIZA��O DAS VARI�VEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN

	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

	END