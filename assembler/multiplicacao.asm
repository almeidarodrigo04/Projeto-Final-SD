
IN A; L ^e o que est ´a no input para Registrador A
IN B; L ^e o que est ´a no input para Registrador B
MOV R, 0 ; Coloca o valor zero no Registrador R
LOOP_START:
    CMP B, 0 ; Compara B com 0
    JEQ END_LOOP ; Se B for igual a 0 , termina o loop
    ADD R, A ; Soma A ao valor acumulado em R ( R = R + A )
    STORE R 255 ; Armazena o valor de R no endere ¸c o 255
    SUB B, 1 ; Decrementa o multiplicador B ( R =B -1)
    MOV B, R ; Armazena o valor de R em B
    LOAD R, 255 ; Carrega o valor do endere ¸c o 255 em R
    JMP LOOP_START ; Repete o loop
END_LOOP:
OUT R
WAIT