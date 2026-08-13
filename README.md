# COA Project – Mano Computer with Microprogrammed Control

**Course Project 1:** Redesign of the classic Mano Computer Control Unit using **Microprogrammed Control** architecture.

- **Language:** Verilog  
- **Target FPGA:** Digilent Basys 3 (Xilinx Artix-7)  
- **Style:** Horizontal Microprogramming  
- **Repository:** https://github.com/amederhourhi/COA-project  

---

## Project Goal

Replace the original **hardwired** control unit of the Mano Computer with a clean **microprogrammed** control unit, while keeping the datapath compatible. The final system must be simulated and implemented on FPGA.

---

## Project structure 

- `src/datapath/`     → All datapath modules
- `src/control/`      → Microprogrammed Control Unit
- `src/top/`          → Top-level system
- `sim/`              → Testbenches and simulation
- `fpga/`             → Constraints and bitstream
- `docs/`             → Design documents and microprogram
- `reports/`          → Final report and documentation

---

## Current Progress

### Phase 0 – Project Setup & Design Documentation
- [x] Professional repository structure
- [x] Architecture Decision Record (Horizontal microprogramming)
- [x] Complete list of control signals extracted
- [x] Final 32-bit microinstruction format defined
- [x] Complete microprogram written (Fetch, Indirect, Memory-reference, Register-reference, I/O)

### Phase 3 – Datapath Implementation
- [x] Generic register module
- [x] All main registers (AR, PC, DR, AC, IR, TR)
- [x] 4K × 16-bit Memory
- [x] Common Bus (8-to-1 multiplexer)
- [x] ALU + E flip-flop
- [x] Complete Datapath top module

### Phase 4 – Microprogrammed Control Unit
- [ ] Control Memory (ROM)
- [ ] Control Address Register (CAR)
- [ ] Sequencing & Next-Address Logic
- [ ] Microinstruction Register
- [ ] Mapping Logic

### Phase 5 – System Integration
- [ ] Top-level Mano Computer module

### Phase 6 – Simulation & Verification
- [ ] Testbenches
- [ ] Instruction-level verification

### Phase 7 – FPGA Implementation
- [ ] Constraints (XDC)
- [ ] Bitstream + Demo

### Phase 8 – Final Report & Delivery
- [ ] Academic report (Courier New 10pt)
- [ ] Video / Live demo

---


---

## Key Design Decisions

- **Microprogramming style:** Horizontal (for clarity and educational value)
- **Microinstruction width:** 32 bits
  - 16 bits → Control signals
  - 4 bits  → Condition select
  - 4 bits  → Sequencing control
  - 8 bits  → Branch address
- **Control Memory size:** 256 × 32-bit
- **Datapath:** Classic Mano 16-bit architecture kept almost unchanged

---

## How to Follow the Development

All important engineering decisions and the complete microprogram are documented in the `docs/` folder.  
Every meaningful step is committed to Git with clear messages so the full history is traceable.

---

## Next Steps

1. Implement the Microprogrammed Control Unit (`src/control/`)
2. Integrate Datapath + Control Unit
3. Write comprehensive testbenches
4. Implement on Basys 3 FPGA
