# Microprogram for Mano Computer (Horizontal Control)

**Control Memory size:** 256 × 32-bit  
**Addressing:** 8-bit (0x00 – 0xFF)

---

## Legend (quick reference)

**Sequencing codes:**
- `CONT`  = 0000  → CAR + 1
- `JUMP`  = 0001  → Address
- `JMPIF` = 0010  → Address if condition true, else CAR+1
- `MAP`   = 0011  → Map from IR opcode

**Condition codes:**
- `ALWAYS` = 0000
- `ACZERO` = 0001
- `E`      = 0010
- etc.

---

## 1. Common Fetch Cycle

| Address | Control Signals (important ones)      | Cond    | Seq   | Next Addr | Description                  |
|---------|---------------------------------------|---------|-------|-----------|------------------------------|
| 0x00    | `AR_Load`, Bus=PC                     | ALWAYS  | CONT  | -         | AR ← PC                      |
| 0x01    | `Mem_Read`, `IR_Load`, `PC_Inc`       | ALWAYS  | CONT  | -         | IR ← M[AR], PC ← PC + 1      |
| 0x02    | `AR_Load`, Bus=IR (address part)      | ALWAYS  | MAP   | -         | AR ← IR(0–11), then MAP      |

---

## 2. Mapping (Opcode → Execute routine)

After MAP, the CAR will jump to one of these starting addresses according to the opcode:

| Opcode | Instruction | Starting Microaddress |
|--------|-------------|-----------------------|
| 000    | AND         | 0x10                  |
| 001    | ADD         | 0x18                  |
| 010    | LDA         | 0x20                  |
| 011    | STA         | 0x28                  |
| 100    | BUN         | 0x30                  |
| 101    | BSA         | 0x38                  |
| 110    | ISZ         | 0x40                  |
| 111    | Register-Reference / I/O | 0x48        |

> We leave gaps between routines so we can easily add more microinstructions later.

---

## 3. Execute Routines (first version)

### AND (starts at 0x10)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x10 | DR ← M[AR]                          | CONT | -    |
| 0x11 | AC ← AC ∧ DR , SC ← 0               | JUMP | 0x00 |

### ADD (starts at 0x18)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x18 | DR ← M[AR]                          | CONT | -    |
| 0x19 | AC ← AC + DR , SC ← 0               | JUMP | 0x00 |

### LDA (starts at 0x20)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x20 | DR ← M[AR]                          | CONT | -    |
| 0x21 | AC ← DR , SC ← 0                    | JUMP | 0x00 |

### STA (starts at 0x28)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x28 | M[AR] ← AC , SC ← 0                 | JUMP | 0x00 |

### BUN (starts at 0x30)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x30 | PC ← AR , SC ← 0                    | JUMP | 0x00 |

### BSA (starts at 0x38)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x38 | M[AR] ← PC , AR ← AR + 1            | CONT | -    |
| 0x39 | PC ← AR , SC ← 0                    | JUMP | 0x00 |

### ISZ (starts at 0x40)
| Addr | Action                              | Seq  | Next |
|------|-------------------------------------|------|------|
| 0x40 | DR ← M[AR]                          | CONT | -    |
| 0x41 | DR ← DR + 1                         | CONT | -    |
| 0x42 | M[AR] ← DR                          | CONT | -    |
| 0x43 | if (DR == 0) then PC ← PC + 1       | JMPIF| 0x00 |
| 0x44 | SC ← 0                              | JUMP | 0x00 |

---

## 4. Notes & Next Improvements

- Register-reference instructions (CLA, CLE, CMA, CME, CIR, CIL, INC, SPA, SNA, SZA, SZE, HLT) and I/O instructions will be added in the next iteration.
- Indirect addressing (`I` bit) handling will be inserted after the fetch cycle.
- Interrupt cycle will be added later.

## Status
- [x] Fetch cycle defined
- [x] Mapping defined
- [x] Main memory-reference instructions defined
- [ ] Register-reference instructions
- [ ] I/O instructions
- [ ] Indirect cycle
- [ ] Interrupt cycle