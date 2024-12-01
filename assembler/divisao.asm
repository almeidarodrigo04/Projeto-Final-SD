IN A ; L ^e as entradas em A
IN B ; L ^e as entradas em B
MOV R 0 ; Armazena 0 em R
STORE R 255 ; Armazena R no endere ¸c o 255
MOV R A ; Armazena o valor de A em R ( R = A )
LOOP_START:
    SUB R B ; R =R - B
    MOV A R ; A = R
    LOAD R 255 ; R = ADDR (255)
    ADD R 1 ; R = R +1
    STORE R 255 ; ADDR (255) = R
    MOV R A ; R = A
    CMP R B ;
    JGR LOOP_START ; R > B? Vai para LOOP_START
LOAD R 255 ; R = ADDR (255)
OUT R ; Coloca na sa ´ı da o valor de R
WAIT