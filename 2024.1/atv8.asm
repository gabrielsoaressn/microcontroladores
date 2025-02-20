;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     JULHOO DE 2024                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
;   O PIC DEVE RECEBER O UM BYTE DE ENDERE�O E SINALIZAR SUA IDENTIFICA��O
;   A CADA 500ms, o programa vai entrar na interrup��o , verifica se o ENDERECO E IGUAL
;   est� alto. SE FOR, BAIXA O CLOCK E ACECNDE O LED E MANDA O ACK PARA A CHEGADA DO PRIMEIRO BYTE
;   A PARTIR DO SEGUNDO BYTE, NAO MEXE MAIS NO LED E NEM NO CLOCK, MAS MANDA OUTRO ACK.
;
;   DICA PARA AMANH� -> FAZ TUDO FORA DA INTERRUPCAO, QUANDO A INTERRUPCAO CHEGAR, LIMPA TUDO E COMECA NOVAMENTE.
    
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
		BYTE_ENDERECO	;BYTE DE ENDERE�O
		COUNT		;CRIEI ESSA VARI�VEL PARA UTILIZAR O LOOP
		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

    ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;*                        FLAGS INTERNOS                           *

;*                         CONSTANTES                              *
#DEFINE SCL	GPIO, GP0   ;SCL -> CLOCK
#DEFINE SDA	GPIO, GP1   ;SDA -> DADOS
#DEFINE LED	GPIO, GP5 
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
;   LIMPA A FLAG DO TMR1
    BCF    PIR1, TMR1IF
;   COLOCA O CLOCK COMO ENTRADA NOVAMENTE
    BANK1
    BSF	    TRISIO, 0
    BANK0
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
    MOVLW	B'00000011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
    MOVWF	TRISIO		;COMO SA�DAS
    CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
    MOVLW	B'00000100'
    MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
    MOVLW	B'11000000'
    MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
    MOVLW	B'00000001'
    MOVWF	PIE1
    
	BANK0				;RETORNA PARA O BANCO
    MOVLW	B'00000111'
    MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
    MOVLW	B'00110001'	;PRESCALER 1:4
    MOVWF	T1CON

;*                     INICIALIZA��O DAS VARI�VEIS                 *

MOVLW	H'0B'
MOVWF	TMR1H
MOVLW	H'DF'
MOVWF	TMR1L ;CONFIGURA�AO PARA DELAY DE 500ms COM O TMR1
;*                     ROTINA PRINCIPAL                            *

MAIN
    
	;CORPO DA ROTINA PRINCIPAL    
    
    RECEBE_BYTE:
    MOVLW	D'8'
    MOVWF	COUNT ; CONFIG NECESSARIA PARA PERCORRER O LOOP 8 VEZES(TAMANHO DO BYTE)
    
    CLRF    BYTE_ENDERECO
    PROX_BIT:
    RLF	    BYTE_ENDERECO
    BTFSS   SDA			;MEU BIT � 1?			
    GOTO    DECREMENTA_CONTADOR	;COMO MINHA VARI�VEL BYTE ENDERE�O JA ESTA EM 0, VOU PULAR DIRETO PARA O PRX BIT
    BSF	    BYTE_ENDERECO, 0
    
    DECREMENTA_CONTADOR:
    DECFSZ  COUNT	    ; EXECUTA LOOP 7 VEZES
    GOTO    PROX_BIT
    GOTO    ENDERECO_OU_BYTEDADOS   ;TESTA PRA SABER SE O BYTE EH DE ENDERECO OU DADOS
    
    ENDERECO_OU_BYTEDADOS:
    BTFSS   LED	;SE O LED ESTIVER ACESO, � DADOS
    GOTO    CHECK_ENDERECO
    GOTO    ACK
    
    CHECK_ENDERECO:
    ;pela especifica��o da atividade meu endere�o � d'37' ou b'00100101'
    ;portanto, farei essa checagem bit a bit se for correspondente acende
    ; o led e espera o pr�ximo byte
    TESTEB0:
    BTFSS   BYTE_ENDERECO, 0		;B0 DEVERIA SER = 1 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB1

    
    TESTEB1:
    BTFSC   BYTE_ENDERECO, 1		;B0 DEVERIA SER = 0 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB2
    
    TESTEB2:
    BTFSS   BYTE_ENDERECO, 2		;B0 DEVERIA SER = 1 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB3
    
    TESTEB3:
    BTFSC   BYTE_ENDERECO, 3		;B0 DEVERIA SER = 0 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB4
    
    TESTEB4:
    BTFSC   BYTE_ENDERECO, 4		;B0 DEVERIA SER = 0 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB5
    
    TESTEB5:
    BTFSS   BYTE_ENDERECO, 5		;B0 DEVERIA SER = 1 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB6
    
    TESTEB6:
    BTFSC   BYTE_ENDERECO, 6		;B0 DEVERIA SER = 0 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    TESTEB7
    
    TESTEB7:
    BTFSC   BYTE_ENDERECO, 7		;B0 DEVERIA SER = 0 -> SE FOR PULA
    GOTO    MAIN			;ENDERE�O ERRADO, VOLTA A ESPERAR
    GOTO    ACENDE_LED_CLOCK		;ENDERE�O CORRETO, ACENDE O LED E MANDA O CLK
    
    ACENDE_LED_CLOCK:
    BSF	    LED				;LED
    BANK1
    BCF	    TRISIO, 0
    BCF	    SCL				;BAIXA O CLOCK
    BANK0
    GOTO    ACK
    
    ACK:
    BANK1
    BCF		TRISIO, 1
    BSF		SDA
    BSF		TRISIO, 1
    BANK0
    GOTO	RECEBE_BYTE
    
    GOTO	MAIN

	END