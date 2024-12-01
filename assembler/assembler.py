import sys
import argparse
from typing import TextIO

reg_dict = {
    'A': '00',
    'B': '01',
    'R': '10'
}
op_dict = {
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
    'WAIT': '1110'
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
    return hex(int(instruction, 2)).removeprefix('0x').zfill(2).upper()

def write_hex_instruction(hex_file: TextIO, instruction: str):
    hex_file.write(f'{instruction_to_hex(instruction)}\n')

def write_mif_instruction(mif_file: TextIO, program_position: int, instruction: str):
    mif_file.write(f'{hex(program_position).removeprefix("0x").upper()} : {instruction.zfill(8)};\n')

def pre_process(line: str) -> list[str]:
    comment_removed = line.split(';')[0]
    return [word.strip(',') for word in comment_removed.split()]

def put_all_labels(line: str, program_position: int, line_number: int):
    words = pre_process(line)
    if not words:
        return True, program_position
    elif len(words) == 1 and not words[0].endswith(':'):
        print_error(words, line_number)
        return False, program_position
    elif words[0].endswith(':'):
        label = words[0].removesuffix(':')
        if label in reg_dict or label.isdecimal():
            print_error(words, line_number)
            return False, program_position
        label_dict[label] = program_position
        return True, program_position - 1
    return True, program_position

def line_to_instruction(line: str, mif_file: TextIO, hex_file: TextIO, program_position: int, line_number: int):
    words = pre_process(line)
    if not words:
        return True, program_position
    if words[0] in op_dict:
        if words[2].startswith("0x"):  # Hexadecimal
            instruction_p1 = f'{op_dict[words[0]]}{reg_dict[words[1]]}11'
            instruction_p2 = f'{int(words[2], 16):08b}'
            write_mif_instruction(mif_file, program_position, instruction_p1)
            write_hex_instruction(hex_file, instruction_p1)
            program_position += 1
            write_mif_instruction(mif_file, program_position, instruction_p2)
            write_hex_instruction(hex_file, instruction_p2)
        elif is_binary(words[2]):  # Binário
            instruction_p1 = f'{op_dict[words[0]]}{reg_dict[words[1]]}11'
            instruction_p2 = f'{words[2].zfill(8)}'
            write_mif_instruction(mif_file, program_position, instruction_p1)
            write_hex_instruction(hex_file, instruction_p1)
            program_position += 1
            write_mif_instruction(mif_file, program_position, instruction_p2)
            write_hex_instruction(hex_file, instruction_p2)
        elif words[2].isdecimal():  # Decimal
            instruction_p1 = f'{op_dict[words[0]]}{reg_dict[words[1]]}11'
            instruction_p2 = f'{int(words[2]):08b}'
            write_mif_instruction(mif_file, program_position, instruction_p1)
            write_hex_instruction(hex_file, instruction_p1)
            program_position += 1
            write_mif_instruction(mif_file, program_position, instruction_p2)
            write_hex_instruction(hex_file, instruction_p2)
        else:
            print_error(words, line_number)
            return False, program_position
        program_position += 1
        return True, program_position
    elif words[0].endswith(':'):
        return True, program_position - 1
    print_error(words, line_number)
    return False, program_position

def assemble_file(input_file: TextIO, mif_file: TextIO, hex_file: TextIO):
    ENDING_NUMBER = 255
    pre_program_pos = 0
    with open(input_file.name, 'r') as probe_file:
        for line in probe_file:
            success, pre_program_pos = put_all_labels(line, pre_program_pos, 0)
            if not success or pre_program_pos > ENDING_NUMBER:
                return
    program_position = 0
    for line_number, line in enumerate(input_file, start=1):
        success, program_position = line_to_instruction(line, mif_file, hex_file, program_position, line_number)
        if not success or program_position > ENDING_NUMBER:
            return
    mif_file.write(f'[{"..".join([hex(program_position).removeprefix("0x").upper(), "FF"])}] : 11110000;\n\nEND;')
    remaining_lines = 256 - program_position
    for i in range(remaining_lines):
        if i < remaining_lines - 1:
            hex_file.write('F0\n')
        else:
            hex_file.write('F0')

def main():
    argparser = argparse.ArgumentParser(prog="Assembler")
    argparser.add_argument('-m', action='store_true', help='Salva o programa diretamente para ./msim')
    argparser.add_argument('asm_file')
    args = argparser.parse_args()
    with open(args.asm_file, 'r') as input_file:
        with open('programa.mif', 'w') as mif_file:
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
