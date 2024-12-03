# Projeto-Final-SD
Esse projeto é o consiste na implementação de um CPU de acordo com as [expecificações propostas](TrabalhoFinalPráticaSistemasDigitais-2.pdf) para o trabalho final na disciplina de Prática em Sistemas Digitais (SSC108) ministrada pelo docente Vanderlei Bonato.

# Resumo 
Desenvolvemos através do uso de VHDL um processador digital simples com base nas especificações requeridas, com o objetivo de aplicar todos os conceitos estudados em sala de aula em um único projeto

# ISA (Instruction Set Architecture)
A implementação do processador seguiu as especificações propostas em grande parte do projeto, no entanto, por simplicidade, em alguns pontos ocorreram divergências:
## Tipos de dados Tratados
Mantemos as especificações do projeto trabalhando apenas com números positivos em complemento de dois
## Registradores
Os registradores utilizados foram de acordo com as especificações propostas
- reg1 e reg2 (8 bits): Registradores de propósito geral usados como operandos para operações aritméticas e lógicas.
- rs (R, 8 bits): Registrador dedicado para armazenar os resultados das operações realizadas pela ULA.
- pcounter (Program Counter, 8 bits): Controla o fluxo do programa apontando para o endereço da próxima instrução.
- q (Intruction Register (IR), 8 bits): Armazena a instrução atual a ser decodificada e executada.
- Flags (1 bit cada):
    - Zero(z): Indica se o resultado da operação foi igual a zero.
    - Sinal(s): Representa o sinal do resultado (positivo ou negativo).
    - Carry(c): Indica o ultimo carry out em operações de soma ou subtração.
    - Overflow(o): Detecta overflow em operações aritméticas.

## Operações
Na arquitetura que definimos todas as operações podem ocupar de um a dois endereços na memória, uma vez que utilizamos uma RAM de 8 bits apenas, desse modo, os **primeiros quatro bits (operation) indicam a operação que sera realizada**, os **dois bits seguintes (operator1) se referem a origem do primeiro operador **, e os **ultimos dois bits (operator2) se referem a origem do segundo operador**. Assim, o valor contido nos ultimos 4 bits do vetor determinam de dois a dois de onde serão proveninentes os valores utilizados nas operações sendo:
1. "00" : Registrador 1 (r1)
3. "01" : Registrador 2 (r2)
4. "10" : Registrador R (rs)
5. "11" : Imediato (proximo endereço na memória)
-  ADD, SUB, AND, OR, CMP, MOV
    - Utilizam os dois operadores para realizar a operação 
- NOT, JMP, JEQ, JGR, LOAD, STORE, IN, OUT
    - primeiro operador é utilizado apenas para definir se o imediato deve ser lido
    - segundo operador indica origem da informação necessária para realizar a intrução
- WAIT
    - Não utiliza o espaço da memória reservada para os operadores

## Barramentos
De maneira levemente diferente do que foi porposto utilizamos apenas os seguintes barramentos:
- Barramentos de Controle
    - Write Enable : wen
    - Enable Flag : eflag
    - Enable "rs" (registrador R): ers
    - Flags: zero, sinal, carry, over
- Barramento de  Dados
    - Transferência dos dados: data
- Barramento de Endereço
    - Endereço da memória: address



#  Assembler
O assembler tem a responsabilidade de traduzir um programa da linguagem estabelecida para um formato binário que pode ser utilizado pela CPU. Ele gera dois arquivos de saída: um arquivo MIF (Memory Initialization File), utilizado para inicializar a memória do processador, e um arquivo HEX, que contém as instruções no formato hexadecimal.
- Processa instruções: converte instruções com 1, 2 ou 3 argumentos
- Utiliza rótulos: permite o uso de labels para instruções de salto como JMP e JEQ, tornando endereços de memória mais legiveis 


# RAM (Random Acess Memory)
# ULA (Unidade de Lógia e Aritmética)
# UC (Unidade de Controle)

## FETCH
## DECODE
## IMMEDIATE
## LOAD_MEM
## EXECUTE
## LOAD_ANS
