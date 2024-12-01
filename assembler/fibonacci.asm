MOV A, 0          ; A = 0 primeiro valor da sequência
MOV B, 1          ; B = 1 segundo valor da sequência
MOV R, 16       ; Endereço base da memória para armazenar a sequência
STORE A, R        ; Armazena A no endereço R (0x10)
ADD R, 1          ; Incrementa o endereço para o próximo número
STORE B, R        ; Armazena B no próximo endereço
; Define o endereço limite para o cálculo (0x19 para 10 números de Fibonacci)
MOV R, 18       ; Ajusta R para o próximo endereço onde será armazenado o próximo número
LOOP_START:
    ADD A, B          ; Soma A e B, resultado em R (R = A + B)
    STORE R, R        ; Armazena o valor de R no endereço da memória apontado por R
    ; Atualiza valores para o próximo cálculo
    MOV A, B          ; Move B para A (A = B)
    MOV B, R          ; Move o novo valor de R para B (B = R)
    ADD R, 1          ; Incrementa o endereço para o próximo armazenamento
    CMP R, 26       ; Compara o endereço R com o limite 0x1A
    JGR LOOP_START    ; Se R < 0x1A, continua o loop
END_LOOP:
MOV R, 16       ; Redefine R para o endereço base (0x10)
DISPLAY_LOOP:
    LOAD A, R         ; Carrega o valor armazenado no endereço R para A
    OUT A             ; Exibe o valor em A nos LEDs
    ADD R, 1          ; Avança para o próximo endereço
    CMP R, 26       ; Verifica se o endereço ultrapassou o limite 0x1A
    JGR DISPLAY_LOOP  ; Se R < 0x1A, continua exibindo
WAIT              ; Espera por uma ação para resetar
