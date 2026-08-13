// ============================================================
// Module      : datapath
// Description : Complete datapath of the Mano computer.
//               Instantiates registers, memory, bus, ALU and E.
// ============================================================

module datapath (
    input  wire        clk,
    input  wire        rst,

    // ========== Control signals from Control Unit ==========
    // Register controls
    input  wire        AR_Load, AR_Inc, AR_Clear,
    input  wire        PC_Load, PC_Inc, PC_Clear,
    input  wire        DR_Load, DR_Inc, DR_Clear,
    input  wire        AC_Load, AC_Inc, AC_Clear,
    input  wire        IR_Load,
    input  wire        TR_Load,

    // Memory
    input  wire        Mem_Read,           // (kept for clarity, read is async)
    input  wire        Mem_Write,

    // Bus select
    input  wire [2:0]  Bus_Select,

    // ALU operations
    input  wire        ALU_Add,
    input  wire        ALU_And,
    input  wire        ALU_DR,             // AC ← DR
    input  wire        ALU_Comp,
    input  wire        ALU_Shr,
    input  wire        ALU_Shl,

    // E controls
    input  wire        E_Load,
    input  wire        E_Clear,
    input  wire        E_Comp,

    // ========== Status outputs to Control Unit ==========
    output wire [15:0] IR_out,             // Needed for opcode decoding / mapping
    output wire        E_out,
    output wire        AC_zero,            // AC == 0
    output wire        AC_sign,            // AC[15]

    // Optional debug outputs (very useful later)
    output wire [15:0] AC_out,
    output wire [15:0] DR_out,
    output wire [15:0] PC_out,
    output wire [15:0] AR_out
);

    // Internal wires
    wire [15:0] bus_out;
    wire [15:0] mem_out;
    wire [15:0] alu_result;
    wire        alu_e_out;

    // ---------------------- Registers ----------------------
    registers regs (
        .clk(clk),
        .rst(rst),

        .AR_Load(AR_Load), .AR_Inc(AR_Inc), .AR_Clear(AR_Clear),
        .PC_Load(PC_Load), .PC_Inc(PC_Inc), .PC_Clear(PC_Clear),
        .DR_Load(DR_Load), .DR_Inc(DR_Inc), .DR_Clear(DR_Clear),
        .AC_Load(AC_Load), .AC_Inc(AC_Inc), .AC_Clear(AC_Clear),
        .IR_Load(IR_Load),
        .TR_Load(TR_Load),

        .bus_in(bus_out),

        .AR_out(AR_out),
        .PC_out(PC_out),
        .DR_out(DR_out),
        .AC_out(AC_out),
        .IR_out(IR_out),
        .TR_out()                 // TR not needed outside for now
    );

    // ---------------------- Memory -------------------------
    memory mem (
        .clk(clk),
        .write_enable(Mem_Write),
        .address(AR_out[11:0]),
        .data_in(bus_out),
        .data_out(mem_out)
    );

    // ---------------------- Common Bus ---------------------
    bus common_bus (
        .select(Bus_Select),
        .ar_in(AR_out),
        .pc_in(PC_out),
        .dr_in(DR_out),
        .ac_in(AC_out),
        .ir_in(IR_out),
        .tr_in(16'b0),            // TR not used on bus yet
        .mem_in(mem_out),
        .bus_out(bus_out)
    );

    // ---------------------- ALU ----------------------------
    alu alu_unit (
        .ac_in(AC_out),
        .dr_in(DR_out),
        .e_in(E_out),

        .op_add(ALU_Add),
        .op_and(ALU_And),
        .op_dr(ALU_DR),
        .op_comp(ALU_Comp),
        .op_shr(ALU_Shr),
        .op_shl(ALU_Shl),

        .result(alu_result),
        .e_out(alu_e_out)
    );

    // Note: AC is loaded from ALU result when AC_Load is asserted.
    // We need a small mux for AC input. For cleanliness we currently
    // feed bus_out to registers. We will refine AC source in next iteration
    // if needed (many educational designs load AC from ALU via bus or dedicated path).

    // ---------------------- E Flip-Flop --------------------
    e_ff e_register (
        .clk(clk),
        .rst(rst),
        .load(E_Load),
        .clear(E_Clear),
        .complement(E_Comp),
        .d_in(alu_e_out),
        .q_out(E_out)
    );

    // Status flags
    assign AC_zero = (AC_out == 16'b0);
    assign AC_sign = AC_out[15];

endmodule