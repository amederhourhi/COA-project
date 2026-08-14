// ============================================================
// Module      : datapath
// Description : Complete datapath with proper ALU → AC path
// ============================================================

module datapath (
    input  wire        clk,
    input  wire        rst,

    // Control signals from Control Unit
    input  wire        AR_Load, AR_Inc, AR_Clear,
    input  wire        PC_Load, PC_Inc, PC_Clear,
    input  wire        DR_Load, DR_Inc, DR_Clear,
    input  wire        AC_Load, AC_Inc, AC_Clear,
    input  wire        IR_Load,
    input  wire        TR_Load,
    input  wire        Mem_Write,
    input  wire [2:0]  Bus_Select,

    input  wire        ALU_Add,
    input  wire        ALU_And,
    input  wire        ALU_DR,
    input  wire        ALU_Comp,
    input  wire        ALU_Shr,
    input  wire        ALU_Shl,

    input  wire        E_Load,
    input  wire        E_Clear,
    input  wire        E_Comp,

    // Status outputs
    output wire [15:0] IR_out,
    output wire        E_out,
    output wire        AC_zero,
    output wire        AC_sign,

    // Debug outputs
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
    wire [15:0] ac_data_in;

    // ---------- AC input multiplexer ----------
    // When any ALU operation is active → take ALU result
    // Otherwise → take common bus
    assign ac_data_in = (ALU_Add | ALU_And | ALU_DR | ALU_Comp | ALU_Shr | ALU_Shl) 
                        ? alu_result 
                        : bus_out;

    // ---------- Registers ----------
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
        .ac_data_in(ac_data_in),

        .AR_out(AR_out),
        .PC_out(PC_out),
        .DR_out(DR_out),
        .AC_out(AC_out),
        .IR_out(IR_out),
        .TR_out()
    );

    // ---------- Memory ----------
    memory mem (
        .clk(clk),
        .write_enable(Mem_Write),
        .address(AR_out[11:0]),
        .data_in(bus_out),
        .data_out(mem_out)
    );

    // ---------- Common Bus ----------
    bus common_bus (
        .select(Bus_Select),
        .ar_in(AR_out),
        .pc_in(PC_out),
        .dr_in(DR_out),
        .ac_in(AC_out),
        .ir_in(IR_out),
        .tr_in(16'b0),
        .mem_in(mem_out),
        .bus_out(bus_out)
    );

    // ---------- ALU ----------
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

    // ---------- E Flip-Flop ----------
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