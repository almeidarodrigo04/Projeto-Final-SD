# Projeto-Final-SD
Esse projeto consiste na implementação de um CPU de acordo com as [expecificações propostas](TrabalhoFinalPráticaSistemasDigitais-2.pdf) para o trabalho final na disciplina de Prática em Sistemas Digitais (SSC108) ministrada pelo docente Vanderlei Bonato.

# Resumo 
Desenvolvemos, através do uso de VHDL um processador digital simples com base nas especificações requeridas, com o objetivo de aplicar todos os conceitos estudados em sala de aula em um único projeto

# ISA (Instruction Set Architecture)
A implementação do processador seguiu as especificações propostas em grande parte do projeto, no entanto, por simplicidade, em alguns pontos ocorreram divergências, como no tratamento do barramento de dados e nos registradores:
## Tipos de dados tratados
Mantemos as especificações do projeto trabalhando apenas com números positivos utilizando complemento de dois quando necessário
## Registradores
Os registradores utilizados foram semelhantes as especificações propostas, no entanto, diluimos o IR (instruction register) em três registradores menores para facilitar o tratamento de dados: operation, operator1, operator2. Vale ressaltar que os registradores foram declarados como "signal" no código, uma vez que os softwares que utilzamos para rodar o projeto interpreta os "signals" de maneira adequada ao proposito.
- reg1 e reg2 (8 bits): Registradores de propósito geral usados como operandos para operações aritméticas e lógicas.
- rs (R, 8 bits): Registrador dedicado para armazenar os resultados das operações realizadas pela ULA.
- pcounter (Program Counter, 8 bits): Controla o fluxo do programa apontando para o endereço da próxima instrução.
- operation, operator1, operator2 ('IR', 8 bits): Armazenam a instrução atual a ser decodificada e executada
- Flags (1 bit cada):
 - Zero(z): Indica se o resultado da operação foi igual a zero.
 - Sinal(s): Representa o sinal do resultado (positivo ou negativo).
 - Carry(c): Indica o último carry out em operações de soma ou subtração.
 - Overflow(o): Detecta overflow em operações aritméticas.

## Operações
Na arquitetura que definimos, todas as operações ocupam um endereço na memória (8 bits) e podem ou não utilizar o valor imediato, totalizando um ou dois endereços (8/16 bits), uma vez que utilizamos uma RAM 256X8, desse modo, os **quatro bits mais significativos (operation) indicam a operação que sera realizada**, os **dois bits seguintes (operator1) se referem a origem do primeiro operador**, e os **ultimos dois bits (operator2) se referem a origem do segundo operador**. Assim, o valor contido nos ultimos 4 bits do vetor determinam de dois a dois de onde serão proveninentes os valores utilizados nas operações sendo:
1. "00" : Registrador 1 (r1)
3. "01" : Registrador 2 (r2)
4. "10" : Registrador R (rs)
5. "11" : Imediato (próximo endereço na memória)
- ADD, SUB, AND, OR, CMP, MOV
 - Qualquer um dos dois operadores pode indicar a leitura do imediato
- NOT, JMP, JEQ, JGR, LOAD, STORE, IN, OUT
 - Apenas um dos operadores pode indicar a leitura do imediato (primeiro ou segundo dependendo da operacao)
 - Algumas dessas operações utilizam apenas um operador
- WAIT
 - Não utiliza o espaço da memória reservado para os operadores

## Barramentos
De maneira divergente do que foi proposto não utilizamos alguns barramentos sugeridos como o de Memory Enable, Read, etc. Assim, juntamente com algus barramentos como o Write Enable (wen) utilizamos uma logica na unidade de controle que permite o manuseio e transferência dessas informacoes dentro dos próprios estados.

# Assembler
O assembler tem a responsabilidade de traduzir um programa da linguagem estabelecida para um formato binário que pode ser utilizado pela CPU. Ele gera dois arquivos de saída: um arquivo MIF (Memory Initialization File), utilizado para inicializar a memória do processador, e um arquivo HEX, que contém as instruções no formato hexadecimal.

Realizamos o codigo em python e ele possui os seguintes dicionários:
```python
reg_dict = {
 'A': '00',
 'B': '01',
 'R': '10'
}

op_dict = {
 'ADD': '0000',
 'SUB': '0001',
 'AND': '0010',
 'OR': '0011',
 'NOT': '0100',
 'CMP': '0101',
 'JMP': '0110',
 'JEQ': '0111',
 'JGR': '1000',
 'LOAD': '1001',
 'STORE': '1010',
 'MOV': '1011',
 'IN': '1100',
 'OUT': '1101',
 'WAIT': '1110' # Adicionado o código para WAIT
}
```


# RAM (Random Acess Memory)
A memória RAM da CPU possui 256 posições, cada uma com 8 bits de largura, responsável por armazenar códigos das instruções e dados temporários. Durante a execução, a CPU acessa a RAM no estado FETCH e possivelmente no estado IMMEDIATE para buscar instruções e utiliza as operações LOAD e STORE para manipular valores diretamente na memória. Ela também guarda resultados intermediários.

# ULA (Unidade de Lógica e Aritmética)
A ULA (Unidade de Lógica e Aritmética) é o componente responsável pelas operações aritméticas e lógicas, cada operação está representada pelo seu comando (exemplo comando ADD - 0000). Nesta implementação as entradas são: op (operação - 4 bits), A (operando 1 - 8 bits) e B (operando 2 - 8 bits); as saídas são: R (resultado - 8 bits), Zero (indica se zero - 1 bit), Sinal (sinal do resultado - 1 bit), Carry (carry - 1 bit), Overflow(overflow - 1 bit). Além disso, a fim de performar as operações aritméticas usa-se 8 somadores completos (full adders).

# UC (Unidade de Controle)
A determinações das atividades dos componentes da CPU ocorrem na UC (Unidade de Controle), como as futuras ações da RAM, ULA e registradores. Sua implementação realiza-se por meio de uma FSM (Máquina de Estados Finitos), na qual seus estados controlam o que será feito, os estados são: FETCH, DECODE, IMMEDIATE, LOAD_MEM, EXECUTE, LOAD_ANS. Realizamos uma abordagem que não separa a UC em um código separado, mas suas funcionalidades estão diluidas na "main" do código

## FETCH
Buscar a instrução da memória RAM para ser executada. O endereço da próxima instrução na RAM está na variável pcounter, o PC (Program Counter), após isso a UC incrementa o PC em 1 para dar prosseguimento ao processamento da posterior instrução. Por fim, o estado muda para DECODE.

## DECODE
Interpretar a instrução carregada da memória RAM. A instrução compõe-se da seguinte forma: operation (Bits 7-4 que identificam a operação a ser realizada), operator1 (Bits 3-2 que indicam o primeiro operando, registradores ou valor imediato), operator2 (Bits 1-0 que indicam o segundo operando). Feita a decodificação, a CPU avança para o estado IMMEDIATE.

## IMMEDIATE
Determinar e configurar os operandos da instrução. Verificar se os operandos são valores imediatos. Assim, caso se trate de operandos imediatos, o próximo valor da memória é lido para ser usado como operando, com isso exigindo mais um ciclo de leitura e incremento do PC. De acordo com o tipo de operação, o próximo estado pode ser diferente, veja a condição: Se a operação for relacionada à memória (LOAD ou STORE), a cpu muda para o estado LOAD_MEM; caso contrário, muda para o estado EXECUTE.

## LOAD_MEM
Executar operações de acesso à memória (LOAD e STORE). LOAD configura o endereço (address) para o valor do operando, tal valor carregado no registrador especificado pelo operator1. STORE configura o endereço (address) para onde o dado será armazenado.

## EXECUTE
Realizar a operação especificada, como cálculo aritmético, lógico, ou manipulação de fluxo. As operações estão organizadas desta forma:

Aritméticas/Lógicas - ADD,SUB,ANDD,ORR,NOTT (Realiza as operações com os valores A e B)
Comparação - CMP (Compara os valores A e B)
Movimentação de dados - MOV (Move o valor de um registrador ou memória para outro)
Saltos - JMP,JEQ,JGR (Atualiza o PC com base no operando e, no caso de saltos condicionais, nos valores das flags)
Entrada/Saída - INN,OUTT (Realiza leitura entradas ou envia valores de registradores para saídas)
Espera - WAITT (Pausa a CPU por um ciclo de clock)

## LOAD_ANS
Lidar com o resultado das operações e preparar a CPU para a próxima instrução. Se uma operação Aritmética ou Lógica, o resultado (R) da ULA é armazenado no registrador (rs); os flags são atualizados, necessário; se uma operação de memória, em LOAD o valor carregado da memória (q) é armazenado no registrador especificado e em STORE, o sinal de escrita (wen) é desativado.

