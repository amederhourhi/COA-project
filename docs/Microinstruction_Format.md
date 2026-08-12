# Microinstruction Format – Final Version

We use a **horizontal microprogrammed** design optimized for clarity and educational value.

## Total Microinstruction Width: 32 bits
Bits:  31-----------------------------16  15----12  11----8  7------0
|        Control Signals         |  Cond   |  Seq   |  Address |
|            (16 bits)           | (4 bit) | (4 bit)| (8 bits) |
text### Field Breakdown

| Field              | Bits   | Width | Description |
|--------------------|--------|-------|-----------|
| **Control Signals**| 31–16  | 16    | Direct control signals to datapath |
| **Condition**      | 15–12  | 4     | Selects which flag/condition to test |
| **Sequencing**     | 11–8   | 4     | How to calculate next microaddress |
| **Address**        | 7–0    | 8     | Branch address / next address (256 possible microinstructions) |

---

## 1. Control Signals Field (Bits 31–16) – 16 bits

We carefully selected the most important signals and encoded them efficiently:

| Bit | Signal Name    | Meaning                          |
|-----|----------------|----------------------------------|
| 31  | `Mem_Read`     | Memory Read                      |
| 30  | `Mem_Write`    | Memory Write                     |
| 29  | `AR_Load`      | Load AR                          |
| 28  | `PC_Load`      | Load PC                          |
| 27  | `DR_Load`      | Load DR                          |
| 26  | `AC_Load`      | Load AC                          |
| 25  | `IR_Load`      | Load IR                          |
| 24  | `TR_Load`      | Load TR                          |
| 23  | `OUTR_Load`    | Load OUTR                        |
| 22  | `PC_Inc`       | Increment PC                     |
| 21  | `AR_Inc`       | Increment AR                     |
| 20  | `DR_Inc`       | Increment DR                     |
| 19  | `AC_Inc`       | Increment AC                     |
| 18  | `SC_Clear`     | Clear Sequence Counter (end of instruction) |
| 17  | `ALU_Add`      | AC ← AC + DR                     |
| 16  | `ALU_And`      | AC ← AC ∧ DR                     |

> Note: Other operations (Complement, Shift, Clear, etc.) will be added later by expanding or using a small ALU opcode field if needed. For the first version this set is sufficient and clean.

---

## 2. Condition Field (Bits 15–12) – 4 bits

| Code | Condition     | Meaning                     |
|------|---------------|-----------------------------|
| 0000 | Always (Uncond) | Always true               |
| 0001 | AC = 0        | Accumulator is zero         |
| 0010 | E = 1         | Carry / Overflow flag       |
| 0011 | FGI = 1       | Input flag                  |
| 0100 | FGO = 1       | Output flag                 |
| 0101 | R = 1         | Interrupt request           |
| 0110 | S = 1         | Start/Stop flip-flop        |
| 0111–1111 | Reserved   | Future use                  |

---

## 3. Sequencing Field (Bits 11–8) – 4 bits

| Code | Action              | Next CAR value                  |
|------|---------------------|---------------------------------|
| 0000 | Continue (Next)     | CAR + 1                         |
| 0001 | Jump                | Address field                   |
| 0010 | Jump if Condition   | Address if cond true, else CAR+1|
| 0011 | Map (Opcode)        | Mapping logic from IR opcode    |
| 0100 | Call                | Push CAR+1, jump to Address     |
| 0101 | Return              | Pop return address              |
| 0110–1111 | Reserved         | Future use                      |

---

## 4. Address Field (Bits 7–0) – 8 bits

- Used as the target microaddress when sequencing requires a jump.
- Supports up to **256 microinstructions** (more than enough for Mano).

---

## Summary of Design Decisions

- **Width**: 32-bit → clean, easy to store in ROM, easy to read in simulation.
- **Horizontal**: Most control bits are explicit → excellent for learning and debugging.
- **8-bit address**: 256 entries are more than sufficient.
- **Clear separation** between control, condition, sequencing, and address.

## Status
- [x] Microinstruction format frozen
- [ ] Control Memory size decided
- [ ] Microprogram writing starts