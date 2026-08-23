# Mano Computer with Microprogrammed Control Unit

A from-scratch Verilog redesign of M. Morris Mano's classic educational 16-bit CPU, replacing its original **hardwired** control unit with a **horizontally microprogrammed** one — simulated, synthesized, and implemented on a real Xilinx Artix-7 FPGA (Digilent Basys 3).

| | |
|---|---|
| **Course** | Computer Organization and Architecture |
| **Language** | Verilog HDL |
| **Target FPGA** | Digilent Basys 3 — Xilinx Artix-7 (`xc7a35tcpg236-1`) |
| **Control style** | Horizontal microprogramming, 256×32 Control ROM |
| **Toolchain** | Icarus Verilog + GTKWave (simulation), Xilinx Vivado 2022.2 (synthesis/implementation) |

---

## Table of Contents

- [What this project actually does](#what-this-project-actually-does)
- [Why microprogrammed control? (for beginners)](#why-microprogrammed-control-for-beginners)
- [Architecture overview](#architecture-overview)
- [Repository structure](#repository-structure)
- [The microinstruction format](#the-microinstruction-format)
- [How this was built](#how-this-was-built)
- [Verification results](#verification-results)
- [FPGA synthesis results](#fpga-synthesis-results)
- [Running the simulation](#running-the-simulation)
- [Building for the Basys 3](#building-for-the-basys-3)
- [Current status & known limitations](#current-status--known-limitations)
- [Documentation index](#documentation-index)

---

## What this project actually does

This repository contains a complete, working 16-bit CPU based on the Mano computer architecture from *"Computer System Architecture"* (M. Morris Mano). It executes real machine instructions — `LDA`, `ADD`, `AND`, `STA`, `BUN`, `BSA`, `ISZ`, `HLT`, and indirect addressing — and it does this by **stepping through microinstructions stored in ROM**, rather than through a hardwired finite-state machine built from logic gates.

Concretely, this means: instead of writing "when opcode = ADD, wire up these exact gates to produce these exact control signals," we write "when opcode = ADD, jump to address `0x18` in a 256-word Control Memory, and read out a 32-bit microinstruction that tells every register, the ALU, and the bus exactly what to do this cycle." The next microinstruction can advance sequentially, jump, or branch based on a condition — much like a tiny program running the CPU itself.

The design was carried from architecture decision, through Verilog implementation, through full instruction-level simulation, through Vivado synthesis and place-and-route, all the way to a generated FPGA bitstream.

---

## Why microprogrammed control? (for beginners)

If you're new to computer architecture, here's the short version of what "control unit" even means and why this redesign matters:

A CPU's **datapath** — its registers, ALU, and memory — can only do one tiny operation per clock cycle (e.g. "copy the Accumulator onto the bus," or "add the Data Register to the Accumulator"). Something has to decide, cycle by cycle, *which* of these tiny operations happens next, based on which instruction the CPU is currently executing. That "something" is the **control unit**.

There are two classic ways to build one:

- **Hardwired control** — the control unit is a fixed finite-state machine, and every possible signal combination is baked directly into logic gates. It's fast, but every design change means re-wiring gates by hand — painful to modify or extend.
- **Microprogrammed control** — instead of gates, the control signals for every step of every instruction are pre-written as binary words ("microinstructions") and stored in a small ROM (the "Control Memory"). The control unit becomes little more than a tiny sequencer that walks through this ROM, and a small piece of hardware (`car.v`, `next_address_logic.v`) decides which ROM address comes next. Changing what an instruction does becomes an edit to the *contents* of the ROM, not a hardware redesign.

This project keeps the exact same 16-bit Mano datapath (same registers, same ALU, same instruction set) and only swaps in a microprogrammed control unit in its place — which is exactly the redesign this assignment asks for.

---

## Architecture overview

```
                         Instruction Register (IR)
                                   │
                                   ▼
                         ┌───────────────────┐
                         │   Mapping Logic    │  opcode → starting microaddress
                         └─────────┬─────────┘
                                   │
                                   ▼
                         ┌───────────────────┐
        Next-Address     │        CAR         │
        Logic ──────────►│ (Control Address   │
     (CONT/JUMP/MAP/     │    Register)       │
      indirect decision) └─────────┬─────────┘
                                   │
                                   ▼
                         ┌───────────────────┐
                         │  Control Memory    │  256 × 32-bit ROM
                         │   (Microprogram)   │  (the whole microprogram lives here)
                         └─────────┬─────────┘
                                   │
                                   ▼
                         ┌───────────────────┐
                         │  Microinstruction  │
                         │   Register (µIR)   │
                         └─────────┬─────────┘
                                   │
                                   ▼
                     Control signals → Datapath
           (registers, ALU, common bus, memory read/write)
```

**Datapath** (`src/datapath/`) — unchanged from the classical Mano design:
- Six 16-bit registers: `AR`, `PC`, `DR`, `AC`, `IR`, `TR` (all built from one reusable, parameterized `register.v`)
- `bus.v` — an 8-to-1 multiplexer forming the single shared system bus (`AR`, `PC`, `DR`, `AC`, `IR`, `TR`, memory output)
- `alu.v` + `e_ff.v` — arithmetic/logic unit and the carry/overflow flip-flop
- `memory.v` — 4K × 16-bit RAM, synchronous write / combinational read, with FPGA-ready `INIT_FILE` program loading

**Microprogrammed Control Unit** (`src/control/`) — the redesigned part:
- `control_memory.v` — the 256 × 32-bit ROM holding the entire microprogram
- `car.v` — Control Address Register, holds the address of the microinstruction currently executing
- `next_address_logic.v` — decides the *next* CAR value: continue (`CAR+1`), unconditional jump, conditional jump, or trigger a MAP
- `mapping_logic.v` — decodes the instruction's 3-bit opcode into the starting microaddress for that instruction's execute routine
- `microinstruction_register.v` — latches the fetched 32-bit microinstruction so control signals are stable for the full cycle

**System integration** (`src/top/`):
- `mano_computer.v` — wires datapath + control unit together into the complete CPU
- `fpga_top.v` — Basys 3 wrapper: adds a reset synchronizer, a clock divider (100 MHz → ~2 Hz so the demo is watchable by eye), and an LED output mux (`sw0` toggles between watching `AC[7:0]` execute or `CAR[7:0]` step through microinstructions)
- `reset_sync.v`, `clk_divider.v` — supporting infrastructure for the physical board

---

## Repository structure

```
src/
├── control/       Microprogrammed control unit (CAR, ROM, sequencer, mapping logic)
├── datapath/       Registers, ALU, bus, memory
└── top/            System integration + FPGA-specific wrapper

sim/
├── testbenches/    Instruction-level simulation testbenches
└── waveforms/      Waveform dumps (.vcd) for GTKWave inspection

fpga/
├── constraints/    Basys 3 pin mapping (.xdc)
├── rom/            Hex program loaded into memory at synthesis time
├── bitstream/       Generated .bit file (programmed onto the board)
└── fpga_synthesis/  Full Vivado project (synthesis + implementation runs)

reports/
├── COAproject_report1.pdf     Academic report
└── synthesis_proof/            Timing & utilization reports (evidence of synthesis/implementation)

docs/               Design documents: architecture decisions, control signal
                     tables, microinstruction format, full microprogram listing,
                     and a running log of every problem hit and how it was fixed
```

---

## The microinstruction format

Every step of every instruction is one 32-bit word:

| Bits | Field | Purpose |
|---|---|---|
| `[31:24]` | Register control | `AR_Load`, `AR_Inc`, `PC_Load`, `PC_Inc`, `DR_Load`, `AC_Load`, `IR_Load`, `Mem_Write` |
| `[23:21]` | ALU control | `ALU_Add`, `ALU_And`, `ALU_DR` |
| `[20:18]` | Bus select | Picks which register (or memory) drives the common bus |
| `[17:0]`  | Sequencing | Condition select, jump/continue/map control, and the next microaddress |

**Bus_Select encoding** (which source drives the shared 16-bit bus this cycle):

| Value | Source | Value | Source |
|---|---|---|---|
| `001` | AR | `100` | AC |
| `010` | PC | `101` | IR (address bits only) |
| `011` | DR | `111` | Memory |

**Sequencing field** — how the control unit decides the next microaddress:

| Code | Action |
|---|---|
| Continue | `CAR ← CAR + 1` — the default, straight-line case |
| Jump | Unconditional branch to a fixed microaddress |
| Jump-if | Branch only if a condition (AC==0, E==1, AC sign, indirect bit) is true |
| MAP | Decode the current opcode and jump to that instruction's execute routine |

The complete, address-by-address microprogram — covering the fetch cycle, indirect addressing, and every instruction's execute routine — is written out in full in [`docs/Microprogram.md`](docs/Microprogram.md).

---

## How this was built

The project was built incrementally, always keeping something runnable at each step. Roughly, in the order it actually happened:

**1. Design before code.** Before writing any Verilog, the control architecture was decided and documented: horizontal vs. vertical microprogramming was weighed ([`docs/Architecture_Decision.md`](docs/Architecture_Decision.md)), then every control signal the original hardwired Mano computer needs was catalogued ([`docs/Control_Signals.md`](docs/Control_Signals.md)), and only then was the 32-bit microinstruction format finalized ([`docs/control_signal_encoding.md`](docs/control_signal_encoding.md)).

**2. Datapath first.** The register file, ALU, common bus, and memory were built and unit-tested before any control logic existed — so bugs could be isolated to "the wiring" vs. "the sequencing" during later stages.

**3. Control unit, piece by piece.** Control Memory and CAR were added, then the microinstruction register, mapping logic, and next-address logic, then finally the top-level control unit tying them together.

**4. Microprogram written and debugged against real execution.** The fetch cycle went in first, then `LDA`/`ADD`/`STA`/`HLT` as the minimum working loop, verified against a testbench before expanding further. `AND`, `BUN`, `BSA`, `ISZ`, and indirect addressing followed once the core loop was solid.

**5. Hardware-readiness pass.** Once simulation was clean, the design was made FPGA-buildable: a reset synchronizer, a clock divider for a human-visible demo speed, the Basys 3 constraints file, and hardware-style program loading via `$readmemh`.

**6. Synthesis, implementation, and sign-off.** Full Vivado synthesis and implementation were run to completion, producing a routed design with zero timing violations and a final bitstream.

A handful of real bugs were hit and fixed along the way — the accumulator not holding its value after an ALU op, `BUN` accidentally loading the full instruction word instead of just the address bits, the common bus staying hardwired to zero — every one of them is logged with its root cause and fix in [`docs/problems_and_fixes.md`](docs/problems_and_fixes.md). That log is worth reading if you're learning microprogrammed design yourself; these are the exact mistakes that pattern show up.

---

## Verification results

Two testbenches exercise the design:

- **`tb_mano_computer.v`** — behavioral simulation of a full instruction sequence, values force-loaded into memory
- **`tb_fpga_loading.v`** — the same program, but loaded purely through `$readmemh` exactly as Vivado does on the real board, proving the hardware loading path matches the behavioral one

**Verified instruction sequence:**

| Address | Instruction | Effect |
|---|---|---|
| `0x000` | `LDA 0x006` | Loads `M[6] = 0x000F` into `AC` |
| `0x001` | `AND 0x007` | `AC ← AC ∧ M[7]` → `0x000F ∧ 0x0007 = 0x0007` |
| `0x002` | `ADD 0x008` | `AC ← AC + M[8]` → `0x0007 + 0x0002 = 0x0009` |
| `0x003` | `STA 0x009` | Stores `AC` (`0x0009`) into `M[9]` |
| `0x004` | `HLT` | Control unit halts cleanly at microaddress `0x48` |

Both the behavioral simulation and the **post-implementation timing simulation** (run against the actual routed netlist, with real gate delays) produced identical, correct results — `AC` finishing at `0x0009`, `M[9] = 0x0009`, `PC = 0x0005`.

---

## FPGA synthesis results

Full synthesis, place, and route were completed in Vivado 2022.2 targeting the Basys 3's `xc7a35tcpg236-1`. Raw reports are in [`reports/synthesis_proof/`](reports/synthesis_proof/).

**Timing** — every constraint met, comfortable positive slack:

| Metric | Result |
|---|---|
| Worst Negative Slack (WNS) | **+5.118 ns** (positive = met, not violated) |
| Total Negative Slack (TNS) | 0.000 ns |
| Failing endpoints | **0 / 52** |
| Result | ✅ *All user specified timing constraints are met.* |

**Resource utilization** on the Artix-7 (`xc7a35t`) — the design is tiny relative to the chip:

| Resource | Used | Available | Utilization |
|---|---|---|---|
| Slice LUTs | 1,299 | 20,800 | 6.25% |
| — of which, Control ROM (distributed RAM) | 1,024 | — | (this is the 256×32 Control Memory) |
| Slice Registers | 173 | 41,600 | 0.42% |

The 256×32 Control Memory synthesizes as distributed RAM (`RAM256X1S` primitives) rather than consuming Block RAM — a reasonable trade-off at this size that keeps Block RAM free for the main 4K memory.

A generated `fpga_top.bit` bitstream is committed under [`fpga/bitstream/`](fpga/bitstream/).

---

## Running the simulation

Requires [Icarus Verilog](http://iverilog.icarus.com/) and (optionally) [GTKWave](http://gtkwave.sourceforge.net/).

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

Expected output: `Final AC = 00aa`, `Memory[7] = 00aa` — confirming `LDA 5 → BUN 3 → STA 7 → HLT` executed correctly, and that the skipped `LDA 6` at address 2 never ran.

To verify the FPGA-style hardware loading path specifically, swap the last line for `sim/testbenches/tb_fpga_loading.v` instead.

To inspect the waveform:
```bash
gtkwave sim_run.vcd
```

---

## Building for the Basys 3

1. Open Vivado, create a new RTL project targeting part `xc7a35tcpg236-1` (or open the committed project at `fpga/fpga_synthesis/COA-proejct.xpr` directly).
2. Add all files under `src/control/`, `src/datapath/`, and `src/top/` as design sources.
3. Add `fpga/constraints/basys3.xdc` as the constraints file.
4. Set `fpga_top` as the top module.
5. Make sure `fpga/rom/program.mem` is visible to synthesis (add `fpga/rom` to the include/search paths, or place `program.mem` next to the project file).
6. Run **Synthesis → Implementation → Generate Bitstream**.
7. Program the board via Hardware Manager.

**On the board:** leave `sw0` down to watch `AC[7:0]` settle on the LEDs as the program runs; flip `sw0` up to instead watch `CAR[7:0]`, showing the control unit stepping through microinstructions in real time. Press the center button to reset and re-run the demo.

---

## Current status & known limitations

- ✅ Datapath, microprogrammed control unit, and full instruction set implemented and verified in simulation
- ✅ Behavioral **and** post-implementation timing simulation both pass with matching results
- ✅ Synthesis and implementation completed cleanly — zero timing violations, low resource usage
- ✅ Bitstream generated
- ⏳ **Physical board verification is still pending** — the bitstream has not yet been confirmed running on real Basys 3 hardware due to lack of current board access. Post-implementation timing simulation is being used as the interim verification step, since it simulates the actual routed netlist with real gate delays rather than the idealized RTL.

---

## Documentation index

| Document | Contents |
|---|---|
| [`docs/Architecture_Decision.md`](docs/Architecture_Decision.md) | Why horizontal microprogramming was chosen over vertical/hybrid |
| [`docs/Control_Signals.md`](docs/Control_Signals.md) | Every control signal in the original hardwired Mano design |
| [`docs/Microinstruction_Format.md`](docs/Microinstruction_Format.md) | Full field-by-field breakdown of the 32-bit microinstruction |
| [`docs/control_signal_encoding.md`](docs/control_signal_encoding.md) | Final bit-level encoding table |
| [`docs/Microprogram.md`](docs/Microprogram.md) | The complete microprogram — every microaddress, every instruction |
| [`docs/problems_and_fixes.md`](docs/problems_and_fixes.md) | Real bugs hit during development and how each was diagnosed and fixed |
| [`reports/COAproject_report1.pdf`](reports/COAproject_report1.pdf) | Academic report submitted for the course |
| [`reports/synthesis_proof/`](reports/synthesis_proof/) | Raw Vivado timing and utilization reports backing the numbers above |