import sys
import argparse
from typing import TextIO

# Dicionários de registradores e operações
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
    'WAIT': '1110'  # Adicionado o código para WAIT
}

label_dict = {}

def is_binary(string: str):
    return all(char in '01' for char in string)

def print_error(line_words: list, line_number: int):
    print(f'Erro! linha {line_number}: {" ".join(line_words)}')

def mif_init(output_file: TextIO):
    output_file.write('DEPTH = 256;\n')
    output_file.write('WIDTH = 8;\n')
    output_file.write('ADDRESS_RADIX = HEX;\n')
    output_file.write('DATA_RADIX = BIN;\n')
    output_file.write('CONTENT\nBEGIN\n\n')

def instruction_to_hex(instruction: str):
    return hex(int(instruction, 2))[2:].zfill(2).upper()

def write_hex_instruction(hex_file : TextIO, instruction : str):
    hex_file.write(f'{instruction_to_hex(instruction)}\n')

def write_mif_instruction(mif_file: TextIO, program_position : int, instruction : str):
    mif_file.write(f'{hex(program_position).removeprefix('0x').upper()} : {instruction};\n')

def pre_process(line: str) -> list[str]:
    comment_removed = line.split(';')[0].strip()
    return [word.strip(',') for word in comment_removed.split()]

def put_all_labels(line : str, program_position : int, line_number : int):
    words = pre_process(line)
    #Se não tiver nada na linha pula
    if len(words) == 0:
        return True, program_position
    #Erros dados pela quantidade de palavras nas linhas
    elif len(words) == 1 and (not words[0].endswith(':') and words[0] != 'WAIT'):
        print('ERRO::quantidade de palavras muito pequena para se exucutar algo')
        print_error(words, line_number)
        return False, program_position
    elif len(words) > 3:
        print('ERRO::quantidade muito grande para uma instrução')
        print_error(words, line_number)
        return False, program_position

    if words[0] in op_dict:
        #Caso especial para o wait que recebe nenhum argumento
        if words[0] == 'WAIT':
            if len(words) != 1:
                print('ERRO::A instrução WAIT nao deve receber nenhum argumento')
                print_error(words, line_number)
                return False, program_position

            program_position += 0
            
        #São os comando que recebem apenas um argumento
        elif words[0] in ('NOT', 'JMP', 'JEQ', 'JGR', 'IN', 'OUT'):
            if len(words) > 2:
                print(f'ERRO::A instrução {words[0]} não recebe mais de um argumento')
                print_error(words, line_number)
                return False, program_position
            
            #Pode receber apenas uma registradora
            if words[0] in ('NOT', 'IN', 'OUT'):
                program_position += 0
            #Instruções JMP JEQ JGR
            else:
                program_position += 1
        #São todos os comandos que recebem dois argumentos
        else:
            if words[0] in ('MOV', 'ADD', 'CMP', 'SUB', 'AND', 'OR'):
                if words[2].isdecimal():
                    program_position += 1                    
                else:
                    program_position += 0
            #Load e store
            else:
                
                program_position += 1

        return True, program_position
    
    elif words[0].endswith(':'):
        label = words[0].removesuffix(':')

        if label.isdecimal():
            print('Uma label não pode ter como nome um número')
            print_error(line, line_number)
        
        if label == 'A' or label == 'B' or label == 'R':
            print('As letras A B e R são reservadas para as registras, labels dessa forma são ilegais')
            print_error(line, line_number)
        
        label_dict.update({words[0].removesuffix(':') : (program_position)})
        #Remove 1 na posição do programa pois a label n é suposta estar em nenhum lugar, como lógo após ele sair dessa função ele vai 
        #Adicionar 1 no a posição do programa não muda
        program_position -= 1
        return True, program_position

def line_to_instruction(line: str, mif_file: TextIO, hex_file: TextIO, program_position: int, line_number: int):
    words = pre_process(line)
    if not words:
        return True, program_position

    # Instrução com três argumentos
    if len(words) == 3 and words[0] in op_dict:
        if words[2].isdecimal():
            instruction_p1 = f'{op_dict[words[0]]}{reg_dict[words[1]]}11'
            write_mif_instruction(mif_file, program_position, instruction_p1)
            write_hex_instruction(hex_file, instruction_p1)
            program_position += 1
            instruction_p2 = f'{int(words[2]):08b}'
            write_mif_instruction(mif_file, program_position, instruction_p2)
            write_hex_instruction(hex_file, instruction_p2)
            program_position += 0
            return True, program_position
        elif words[2] in reg_dict:
            instruction = f'{op_dict[words[0]]}{reg_dict[words[1]]}{reg_dict[words[2]]}'
            write_mif_instruction(mif_file, program_position, instruction)
            write_hex_instruction(hex_file, instruction)
            program_position += 0
            return True, program_position
        else:
            print_error(words, line_number)
            return False, program_position

    # Instrução com dois argumentos
    if len(words) == 2 and words[0] in op_dict:
        # Tratamento para saltos com rótulo
        if words[0] in {'JMP', 'JEQ', 'JGR'}:
            if words[1].isdecimal():  # Caso com valor imediato
                instruction = f'{op_dict[words[0]]}0011'  # Prefixo do salto (JMP, JEQ, JGR)
                write_mif_instruction(mif_file, program_position, instruction)
                write_hex_instruction(hex_file, instruction)
                program_position += 1
                # Agora, escrevemos o imediato na próxima linha
                immediate = f'{int(words[1]):08b}'  # Imediato em binário
                write_mif_instruction(mif_file, program_position, immediate)
                write_hex_instruction(hex_file, immediate)
                program_position += 0
                return True, program_position

            if words[1] in label_dict:  # Caso salto com rótulo
                # Para saltos com rótulo, pegamos o endereço do rótulo
                address = f'{label_dict[words[1]]:08b}'
                instruction = f'{op_dict[words[0]]}0011'  # Formato base
                write_mif_instruction(mif_file, program_position, instruction)
                write_hex_instruction(hex_file, instruction)
                program_position += 1
                write_mif_instruction(mif_file, program_position, address)
                write_hex_instruction(hex_file, address)
                program_position += 0
                return True, program_position

        elif words[1] in reg_dict:
            instruction = f'{op_dict[words[0]]}{reg_dict[words[1]]}00'
            write_mif_instruction(mif_file, program_position, instruction)
            write_hex_instruction(hex_file, instruction)
            program_position += 0
            return True, program_position

        else:
            print_error(words, line_number)
            return False, program_position

    if len(words) == 1 and words[0] in op_dict:
        if words[0] == 'WAIT':  # Tratamento específico para WAIT
            instruction = '11100000'  # WAIT (sem argumentos)
            write_mif_instruction(mif_file, program_position, instruction)
            write_hex_instruction(hex_file, instruction)
            program_position += 0
            return True, program_position
        else:
            print_error(words, line_number)
            return False, program_position

    # Rótulo (label)
    if words[0].endswith(':'):
        return True, program_position-1

    # Linha inválida
    print_error(words, line_number)
    return False, program_position

def assemble_file(input_file : TextIO, mif_file : TextIO, hex_file : TextIO):
    ENDING_NUMBER = 255

    #Para encontrar as labels
    pre_program_pos = 0
    pre_line_pos = 0

    with open(input_file.name, 'r') as probe_file:
        for line in probe_file:
            error, pre_program_pos = put_all_labels(line, pre_program_pos, pre_line_pos)
        
            pre_line_pos += 1
            pre_program_pos += 1

            if not error:
                return
            
            if pre_program_pos > ENDING_NUMBER + 1:
                print(f'{'\033[0;31m'}ERRO::O programa escrito excede o maximo de memória de programa permitida pelo processador\n\n')
                return

    program_position = 0
    line_number = 1
    error = bool
    for line in input_file:
        error, program_position = line_to_instruction(line, mif_file, hex_file, program_position, line_number)
        line_number += 1
        program_position += 1

        if not error:
            return
        
        if program_position > ENDING_NUMBER + 1:
            print(f'{'\033[0;31m'}ERRO::O programa escrito excede o maximo de memória de programa permitida pelo processador\n\n')
            return
    
    #Marca as posiçoes não inicializada com uma instrução não executavel
    if (ENDING_NUMBER - program_position) == 0:
        mif_file.write(f'{hex(255).removeprefix('0x').upper()} : 11110000;\n')
    elif (ENDING_NUMBER - program_position) == 1:
        mif_file.write(f'{hex(254).removeprefix('0x').upper()} : 11110000;\n')
        mif_file.write(f'{hex(255).removeprefix('0x').upper()} : 11110000;\n')
    elif (program_position < ENDING_NUMBER):
        mif_file.write(f'[{hex(program_position).removeprefix('0x').upper()}..{hex(255).removeprefix('0x').upper()}] : 11110000;\n')
    
    mif_file.write('\nEND;')

    while program_position < 256:
        write_hex_instruction(hex_file, '11110000')
        program_position += 1

def main():
    argparser = argparse.ArgumentParser(prog="Assembler")
    argparser.add_argument('-m', action='store_true', help='Salva o programa diretamente para ./msim')
    argparser.add_argument('asm_file')
    args = argparser.parse_args()
    with open(args.asm_file, 'r') as input_file:
        with open('ram256x8.mif', 'w') as mif_file:
            if args.m:
                with open('programa.hex', 'w') as hex_file:
                    mif_init(mif_file)
                    assemble_file(input_file, mif_file, hex_file)
            else:
                with open('programa.hex', 'w') as hex_file:
                    mif_init(mif_file)
                    assemble_file(input_file, mif_file, hex_file)

if __name__ == "__main__":
    main()