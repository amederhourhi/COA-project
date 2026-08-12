# Microprogram for Mano Computer (Complete Version – v1)

**Control Memory size:** 256 × 32-bit  
**Addressing:** 8-bit (0x00 – 0xFF)

---

## 1. Common Fetch Cycle

| Address | Control Signals (key ones)            | Cond    | Seq  | Next | Description                     |
|---------|---------------------------------------|---------|------|------|---------------------------------|
| 0x00    | AR ← PC                               | ALWAYS  | CONT | -    | AR ← PC                         |
| 0x01    | IR ← M[AR], PC ← PC + 1               | ALWAYS  | CONT | -    | Fetch instruction               |
| 0x02    | AR ← IR(11–0)                         | ALWAYS  | CONT | -    | AR ← address part of instruction|
| 0x03    |                                     | ALWAYS  | MAP  | -    | Map according to opcode         |

---

## 2. Indirect Cycle (inserted when I = 1 and memory-reference)

| Address | Action                                | Seq  | Next | Description                     |
|---------|---------------------------------------|------|------|---------------------------------|
| 0x08    | DR ← M[AR]                            | CONT | -    |                                 |
| 0x09    | AR ← DR(11–0)                         | JUMP | 0x03 | Return to MAP after indirect    |

> Note: After fetch we will check the I bit and jump to 0x08 if indirect is needed.

---

## 3. Opcode Mapping (after MAP)

| Opcode | Instruction | Start Address |
|--------|-------------|---------------|
| 000    | AND         | 0x10          |
| 001    | ADD         | 0x18          |
| 010    | LDA         | 0x20          |
| 011    | STA         | 0x28          |
| 100    | BUN         | 0x30          |
| 101    | BSA         | 0x38          |
| 110    | ISZ         | 0x40          |
| 111    | Register / I/O | 0x48       |

---

## 4. Memory-Reference Execute Routines

### AND – 0x10
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x10 | DR ← M[AR]                    | CONT | -    |
| 0x11 | AC ← AC ∧ DR, SC ← 0          | JUMP | 0x00 |

### ADD – 0x18
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x18 | DR ← M[AR]                    | CONT | -    |
| 0x19 | AC ← AC + DR, SC ← 0          | JUMP | 0x00 |

### LDA – 0x20
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x20 | DR ← M[AR]                    | CONT | -    |
| 0x21 | AC ← DR, SC ← 0               | JUMP | 0x00 |

### STA – 0x28
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x28 | M[AR] ← AC, SC ← 0            | JUMP | 0x00 |

### BUN – 0x30
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x30 | PC ← AR, SC ← 0               | JUMP | 0x00 |

### BSA – 0x38
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x38 | M[AR] ← PC, AR ← AR + 1       | CONT | -    |
| 0x39 | PC ← AR, SC ← 0               | JUMP | 0x00 |

### ISZ – 0x40
| Addr | Action                        | Seq  | Next |
|------|-------------------------------|------|------|
| 0x40 | DR ← M[AR]                    | CONT | -    |
| 0x41 | DR ← DR + 1                   | CONT | -    |
| 0x42 | M[AR] ← DR                    | CONT | -    |
| 0x43 | if DR == 0 → PC ← PC + 1      | JMPIF| 0x00 |
| 0x44 | SC ← 0                        | JUMP | 0x00 |

---

## 5. Register-Reference Instructions (start at 0x48)

These are decoded using the lower bits of IR (bits 11–0).

| Addr | Instruction | Action                              | Seq  | Next |
|------|-------------|-------------------------------------|------|------|
| 0x48 | CLA         | AC ← 0                              | JUMP | 0x00 |
| 0x49 | CLE         | E ← 0                               | JUMP | 0x00 |
| 0x4A | CMA         | AC ← AC'                            | JUMP | 0x00 |
| 0x4B | CME         | E ← E'                              | JUMP | 0x00 |
| 0x4C | CIR         | AC ← shr(AC), E ← AC[0]             | JUMP | 0x00 |
| 0x4D | CIL         | AC ← shl(AC), E ← AC[15]            | JUMP | 0x00 |
| 0x4E | INC         | AC ← AC + 1                         | JUMP | 0x00 |
| 0x4F | SPA         | if AC[15] == 0 → PC ← PC + 1        | JUMP | 0x00 |
| 0x50 | SNA         | if AC[15] == 1 → PC ← PC + 1        | JUMP | 0x00 |
| 0x51 | SZA         | if AC == 0 → PC ← PC + 1            | JUMP | 0x00 |
| 0x52 | SZE         | if E == 0 → PC ← PC + 1             | JUMP | 0x00 |
| 0x53 | HLT         | S ← 0 (stop)                        | JUMP | 0x00 |

> In the real microprogram we will use a small decoder or multiple conditional jumps based on IR bits. For clarity we show them as separate entries here.

---

## 6. I/O Instructions (also under opcode 111)

| Addr | Instruction | Action                              | Seq  | Next |
|------|-------------|-------------------------------------|------|------|
| 0x58 | INP         | AC ← INPR, FGI ← 0                  | JUMP | 0x00 |
| 0x59 | OUT         | OUTR ← AC, FGO ← 0                  | JUMP | 0x00 |
| 0x5A | SKI         | if FGI == 1 → PC ← PC + 1           | JUMP | 0x00 |
| 0x5B | SKO         | if FGO == 1 → PC ← PC + 1           | JUMP | 0x00 |
| 0x5C | ION         | IEN ← 1                             | JUMP | 0x00 |
| 0x5D | IOF         | IEN ← 0                             | JUMP | 0x00 |

---

## 7. Current Status

- [x] Fetch cycle
- [x] Indirect cycle
- [x] All 7 memory-reference instructions
- [x] Register-reference instructions (skeleton)
- [x] I/O instructions (skeleton)
- [ ] Final exact bit encoding of every microinstruction
- [ ] Interrupt cycle (optional for first version)
