import sys

def assemble(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()

    # Pass 1: Resolve Labels and Addresses
    labels = {}
    address = 0
    clean_lines = []
    
    for line in lines:
        line = line.split('/')[0].strip() # Strip comments
        if not line: continue
        
        if 'ORG' in line:
            address = int(line.split()[1], 16)
            continue
            
        if ',' in line:
            label, rest = line.split(',')
            labels[label.strip()] = address
            line = rest.strip()
            
        if line:
            clean_lines.append((address, line))
            address += 1

    # Pass 2: Generate Verilog Hex Dump
    opcodes = {"AND": 0x0, "ADD": 0x1, "LDA": 0x2, "STA": 0x3, "BUN": 0x4, "BSA": 0x5, "ISZ": 0x6}
    reg_refs = {
        "CLA": "7800", "CLE": "7400", "CMA": "7200", "CME": "7100", 
        "CIR": "7080", "CIL": "7040", "INC": "7020", "SPA": "7010", 
        "SNA": "7008", "SZA": "7004", "SZE": "7002", "HLT": "7001"
    }

    print("// Paste this into tb_mano_pipeline.v inside the initial begin block:")
    for addr, instruction in clean_lines:
        parts = instruction.split()
        cmd = parts[0]
        
        if cmd == "HEX":
            hex_val = parts[1].lower()
        elif cmd in reg_refs:
            hex_val = reg_refs[cmd]
        elif cmd in opcodes:
            operand = parts[1]
            target_addr = labels.get(operand, int(operand, 16) if operand.isdigit() else 0)
            hex_val = f"{opcodes[cmd]}{target_addr:03x}"
        else:
            hex_val = "0000"
            
        print(f"ram[12'h{addr:03x}] = 16'h{hex_val}; // {instruction}")

if __name__ == '__main__':
    assemble('src/pipeline/fp_add.asm')