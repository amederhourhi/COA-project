# Architecture Decision Record – Microprogrammed Control Unit

## 1. Goal
Replace the classic hardwired control unit of the Mano Computer with a **microprogrammed** control unit while keeping the original datapath compatible.

## 2. Chosen Microprogramming Style

**Decision: Horizontal Microprogramming (mostly)**

### Why Horizontal?
- Each microinstruction contains almost all control signals explicitly.
- Easier to understand and debug for educational purposes.
- Direct mapping from the original Mano control signals.
- Good balance between clarity and size for a 16-bit educational processor.

### Alternatives considered
| Style       | Advantage                      | Disadvantage                     | Decision |
|-------------|--------------------------------|----------------------------------|----------|
| Horizontal  | Simple, clear, easy to debug   | Wider microinstructions          | **Chosen** |
| Vertical    | Narrower microinstructions     | Needs extra decoding logic       | Rejected |
| Hybrid      | Compromise                     | More complex design              | Rejected |

## 3. High-Level Block Diagram of Control Unit
Instruction Register (IR)
          │
          ▼
┌───────────────────┐
│  Mapping Logic    │  (Opcode → starting microaddress)
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  CAR (Control     │◄──── Next Address Logic
│  Address Register)│
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  Control Memory   │  (ROM containing microprogram)
│  (Microprogram)   │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  Microinstruction │
│  Register (µIR)   │
└─────────┬─────────┘
          │
          ▼
Control Signals to Datapath


## 4. Microinstruction Format (Preliminary)

We will use a **horizontal** format. Exact bit widths will be finalized after we list all control signals.

Typical fields:
- Control signals field (most bits)
- Condition select field
- Branch address / next address field
- Sequencing control bits (e.g., jump, map, continue…)

## 5. Next Steps
- List every control signal used in the original Mano computer
- Finalize exact microinstruction width and field encoding
- Design the Control Memory content (microprogram)

## 6. Status
- [x] Style decision made (Horizontal)
- [ ] Full control signal list
- [ ] Final microinstruction format
- [ ] Microprogram written