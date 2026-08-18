# COA Project – Mano Computer with Microprogrammed Control

**Course Project 1:** Redesign of the classic Mano Computer Control Unit using **Microprogrammed Control** architecture.

- **Language:** Verilog
- **Target FPGA:** Digilent Basys 3 (Xilinx Artix-7, `xc7a35tcpg236-1`)
- **Style:** Horizontal Microprogramming
- **Repository:** https://github.com/amederhourhi/COA-project

---

## Project Goal

Replace the original **hardwired** control unit of the Mano Computer with a clean **microprogrammed** control unit, while keeping the datapath compatible. The system is simulated in software and implemented on real FPGA hardware.

---

## Project Structure

```
src/
├── control/     Microprogrammed Control Unit (CAR, ROM, sequencer, mapping logic)
├── datapath/    Registers, ALU, bus, memory
└── top/         System integration + FPGA-specific wrapper

sim/
├── testbenches/ Simulation testbenches
├── mano_sim/    Compiled simulation output
└── waveforms/   Waveform dumps

fpga/
├── constraints/ Pin mapping for the Basys 3 (.xdc)
├── rom/         Hex program loaded into memory at synthesis time
└── bitstream/   Generated .bit file goes here after Vivado build

docs/            Design documents: architecture decisions, control signal
                 tables, microinstruction format, full microprogram listing
reports/         Final academic report (PDF)
```

---

## Current Progress

### Phase 0 – Project Setup & Design Documentation ✅
- [x] Professional repository structure
- [x] Architecture Decision Record (Horizontal microprogramming)
- [x] Complete list of control signals extracted
- [x] Final 32-bit microinstruction format defined
- [x] Complete microprogram written (Fetch, Indirect, Memory-reference, Register-reference, I/O)

### Phase 3 – Datapath Implementation ✅
- [x] Generic register module
- [x] All main registers (AR, PC, DR, AC, IR, TR)
- [x] 4K × 16-bit memory, with FPGA-ready program loading (see below)
- [x] Common Bus (8-to-1 multiplexer)
- [x] ALU + E flip-flop
- [x] Complete Datapath top module

### Phase 4 – Microprogrammed Control Unit ✅
- [x] Control Memory (256 × 32-bit ROM)
- [x] Control Address Register (CAR)
- [x] Sequencing & Next-Address Logic (CONT / JUMP / JMPIF / MAP)
- [x] Microinstruction Register
- [x] Mapping Logic (opcode → microaddress)

### Phase 5 – System Integration ✅
- [x] Top-level Mano Computer module (`mano_computer.v`)
- [x] FPGA top-level wrapper (`fpga_top.v`) with reset synchronizer and clock divider

### Phase 6 – Simulation & Verification ✅
- [x] `tb_mano_computer.v` — instruction-level testbench (LDA / BUN / STA / HLT), values force-loaded into memory
- [x] `tb_fpga_loading.v` — proves the hardware-style program loading path (`$readmemh`) produces identical, correct results with no manual memory writes
- [x] Both testbenches verified: final `AC = 00AA`, `Memory[7] = 00AA`, control unit halts cleanly

### Phase 7 – FPGA Implementation 🔄 In progress
- [x] Constraints (XDC) matching the actual top-level ports
- [x] Hardware program loading via `fpga/rom/program.mem`, loaded into Block RAM at build time
- [x] Clock divider for a human-visible demo speed (~2 Hz)
- [ ] Vivado project created, synthesized, and implemented
- [ ] Bitstream generated and programmed onto the Basys 3
- [ ] Demo video / live demo recorded

### Phase 8 – Final Report & Delivery
- [ ] Academic report (Courier New, 10pt)
- [ ] Group meeting/communication records
- [ ] Presentation prepared for Week 13

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
- **Program loading on FPGA:** memory is initialized directly from `fpga/rom/program.mem` via a parameterized `INIT_FILE`, so Vivado bakes the program into Block RAM at build time — no manual switch entry needed for the demo
- **Demo clock:** the raw 100 MHz board clock is divided down to ~2 Hz by `clk_divider.v` so control-unit and register activity is visible on the board's LEDs in real time

---

## Running the Simulation

Requires [Icarus Verilog](http://iverilog.icarus.com/).

```bash
iverilog -o sim_run \
  src/top/mano_computer.v \
  src/control/car.v src/control/control_memory.v src/control/control_unit.v \
  src/control/mapping_logic.v src/control/microinstruction_register.v src/control/next_address_logic.v \
  src/datapath/alu.v src/datapath/bus.v src/datapath/datapath.v src/datapath/e_ff.v \
  src/datapath/memory.v src/datapath/register.v src/datapath/registers.v \
  sim/testbenches/tb_mano_computer.v

vvp sim_run
```

Expected output: `Final AC = 00aa`, `Memory[7] = 00aa`, confirming `LDA 5 → BUN 3 → STA 7 → HLT` executed correctly (and that the skipped `LDA 6` at address 2 never ran).

To verify the FPGA-style loading path specifically, swap the last line for `sim/testbenches/tb_fpga_loading.v` — it loads the program purely through `$readmemh`, exactly as Vivado will on the real board.

---

## Building for the Basys 3 (Vivado)

1. Create a new RTL project targeting part `xc7a35tcpg236-1`.
2. Add all files under `src/control/`, `src/datapath/`, and `src/top/` as design sources.
3. Add `fpga/constraints/basys3.xdc` as the constraints file.
4. Set `fpga_top` as the top module.
5. Make sure `fpga/rom/program.mem` is visible to synthesis (add `fpga/rom` to the Verilog include/search paths, or place `program.mem` next to the project file).
6. Run Synthesis → Implementation → Generate Bitstream.
7. Program the board via Hardware Manager.

On the board: leave switch `sw0` down to watch `AC[7:0]` settle on the LEDs as the program runs; flip `sw0` up to instead watch `CAR[7:0]`, showing the control unit stepping through microinstructions. Press the center button to reset and re-run the demo.

---

## How to Follow the Development

All engineering decisions and the complete microprogram are documented in `docs/`. Every meaningful step is committed to Git with clear messages so the full history is traceable.

---

## Next Steps

1. Build the Vivado project and generate a working bitstream
2. Program the Basys 3 and confirm the demo matches simulation
3. Record the demo video / prepare the live demo
4. Write the academic report and finalize team documentation