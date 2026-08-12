# Classic Mano Computer – Complete Control Signals List

This document lists every control signal used in the original hardwired control unit of the Mano Computer.  
These signals will form the **control field** of our microinstructions.

## 1. Register Control Signals

| Signal     | Description                              | Width |
|------------|------------------------------------------|-------|
| `AR_Load`  | Load Address Register                    | 1     |
| `AR_Inc`   | Increment Address Register               | 1     |
| `AR_Clear` | Clear Address Register                   | 1     |
| `PC_Load`  | Load Program Counter                     | 1     |
| `PC_Inc`   | Increment Program Counter                | 1     |
| `PC_Clear` | Clear Program Counter                    | 1     |
| `DR_Load`  | Load Data Register                       | 1     |
| `DR_Inc`   | Increment Data Register                  | 1     |
| `DR_Clear` | Clear Data Register                      | 1     |
| `AC_Load`  | Load Accumulator                         | 1     |
| `AC_Inc`   | Increment Accumulator                    | 1     |
| `AC_Clear` | Clear Accumulator                        | 1     |
| `IR_Load`  | Load Instruction Register                | 1     |
| `TR_Load`  | Load Temporary Register                  | 1     |
| `OUTR_Load`| Load Output Register                     | 1     |
| `INPR_Load`| Load Input Register (usually external)   | 1     |

## 2. Memory Control Signals

| Signal     | Description                              | Width |
|------------|------------------------------------------|-------|
| `Mem_Read` | Memory Read                              | 1     |
| `Mem_Write`| Memory Write                             | 1     |

## 3. Bus Selection Signals (S2 S1 S0)

| S2 S1 S0 | Source Selected     |
|----------|---------------------|
| 000      | Nothing (or 0)      |
| 001      | AR                  |
| 010      | PC                  |
| 011      | DR                  |
| 100      | AC                  |
| 101      | IR                  |
| 110      | TR                  |
| 111      | Memory              |

→ We will use 3 bits: `Bus_Select[2:0]`

## 4. ALU / Adder Control Signals

| Signal     | Description                              | Width |
|------------|------------------------------------------|-------|
| `ALU_Add`  | AC ← AC + DR                             | 1     |
| `ALU_And`  | AC ← AC ∧ DR                             | 1     |
| `ALU_Dr`   | AC ← DR                                  | 1     |
| `ALU_Comp` | AC ← AC' (complement)                    | 1     |
| `ALU_Shr`  | Shift Right AC                           | 1     |
| `ALU_Shl`  | Shift Left AC                            | 1     |
| `E_Load`   | Load E (carry/overflow flip-flop)        | 1     |
| `E_Clear`  | Clear E                                  | 1     |
| `E_Comp`   | Complement E                             | 1     |

## 5. Sequence Counter / Timing Control

| Signal     | Description                              | Width |
|------------|------------------------------------------|-------|
| `SC_Clear` | Clear Sequence Counter                   | 1     |
| `SC_Inc`   | Increment Sequence Counter               | 1     |

## 6. Other Important Signals

| Signal     | Description                              | Width |
|------------|------------------------------------------|-------|
| `IEN`      | Interrupt Enable                         | 1     |
| `FGI`      | Input Flag                               | 1     |
| `FGO`      | Output Flag                              | 1     |
| `R`        | Interrupt Request / Service              | 1     |
| `S`        | Start / Stop flip-flop                   | 1     |

## 7. Notes

- Some signals above are mutually exclusive (especially ALU operations).
- In the microprogrammed design we will encode them efficiently.
- Exact final list and encoding will be refined in the next document.

## Status
- [x] Initial complete list extracted
- [ ] Final encoding decided
- [ ] Microinstruction format frozen