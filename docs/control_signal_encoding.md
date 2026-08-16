# Microinstruction Control Signal Encoding (Final)

**Microinstruction width:** 32 bits
Bits:  31 ---------- 16  15 ---- 12  11 ---- 8  7 ------ 0
| Control Signals |  Cond   |  Seq   |  Address |
text## Control Signals Field (bits 31–16)

| Bit   | Signal       | Meaning                          |
|-----  |------------  |----------------------------------|
| 31    | AR_Load      | Load Address Register            |
| 30    | AR_Inc       | Increment AR                     |
| 29    | PC_Load      | Load Program Counter             |
| 28    | PC_Inc       | Increment PC                     |
| 27    | DR_Load      | Load Data Register               |
| 26    | AC_Load      | Load Accumulator                 |
| 25    | IR_Load      | Load Instruction Register        |
| 24    | Mem_Write    | Memory Write Enable              |
| 23    | ALU_Add      | AC ← AC + DR                     |
| 22    | ALU_And      | AC ← AC ∧ DR                     |
| 21    | ALU_DR       | AC ← DR                          |
| 20–18 | Bus_Select   | 3-bit bus source select          |

### Bus_Select encoding

| Value | Source   |
|-------|----------|
| 001   | AR       |
| 010   | PC       |
| 011   | DR       |
| 100   | AC       |
| 101   | IR (address only) |
| 111   | Memory   |

## Condition Field (bits 15–12)

| Code | Condition   |
|------|-------------|
| 0000 | Always      |
| 0001 | AC == 0     |
| 0010 | E == 1      |
| 0011 | AC sign     |
| 0100 | I bit (Indirect) |

## Sequencing Field (bits 11–8)

| Code | Action                  |
|------|-------------------------|
| 0000 | Continue (CAR + 1)      |
| 0001 | Jump                    |
| 0010 | Jump if condition       |
| 0011 | MAP (opcode mapping)    |
| 0100 | Indirect decision       |

## Address Field (bits 7–0)

8-bit next microaddress (0x00 – 0xFF)