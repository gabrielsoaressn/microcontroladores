;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     DEZEMBRO DE 2024                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MEMÓRIA

;*                         VARIÁVEIS                               *

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		X1		;PRIMEIRO OPERANDO
		X2		;SEGUNDO OPERANDO
		R2  ;BYTE MAIS SIGNIFICATIVO
		R1  ;BYTE MENOS SIGNIFICATIVO
		
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
	MOVLW	B'00000011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *

;*                     ROTINA PRINCIPAL                            *

MAIN
    ;INICIALIZA OS XS
    MOVLW	H'0E'
    MOVWF	X1
    MOVLW	H'0A'
    MOVWF	X2

    ;INICALIZA OS RS
    MOVLW   D'0'
    MOVWF   R1
    MOVLW   D'0'
    MOVWF   R2
    
    ;INCREMENTA O X2 PARA O CONTADOR FUNICONAR CORRETAMENTE
    ;A QUANTIDADE DE VEZES QUE O FOR PRECISA ITERAR 
    INCF X2
    
FOR_PARA_MULTIPLICAR:
    ;DECREMENTA O SEGUNDO OPERANDO PARA MULTIPLCAR 
    DECFSZ  X2
    GOTO    MULTIPLICA
    GOTO    LOOP
	
MULTIPLICA:
    ;PASSA O VALOR DE X1 PARA R1 E ADICIONAÉ X1 A X1
    MOVFW   X1
    ADDWF   R1, W
    MOVWF   R1
   ;SE O STATUS FOR 1, QUER DIZER QUE O BYTE ESTOUTOU, PORTANTO
   ;FAZ-SE NECESSARIO SOMAR UM NO BYTE MAIS SGNIFICATIVO
    BTFSC   STATUS,  C
    GOTO    BYTE_MAIS_S
    GOTO    FOR_PARA_MULTIPLICAR

BYTE_MAIS_S:
    ;INCREMENTA O BYTE MAIS SIGNIFICATIVO
    INCF R2
    GOTO FOR_PARA_MULTIPLICAR
LOOP:
    
	GOTO	LOOP

	GOTO	MAIN

    END