// ============================================================
// Module      : mano_computer
// Description : Top-level module of the Microprogrammed
//               Mano Computer.
//               Connects Datapath + Control Unit.
// ============================================================

module mano_computer #(
    parameter INIT_FILE = ""
)(
    input  wire        clk,
    input  wire        rst,

    // Optional debug / observation ports
    output wire [15:0] AC,
    output wire [15:0] PC,
    output wire [15:0] IR,
    output wire [7:0]  CAR,
    output wire [31:0] Microinstruction
);

    // Internal wires between Control Unit and Datapath
    wire        AR_Load, AR_Inc, AR_Clear;
    wire        PC_Load, PC_Inc, PC_Clear;
    wire        DR_Load, DR_Inc, DR_Clear;
    wire        AC_Load, AC_Inc, AC_Clear;
    wire        IR_Load;
    wire        TR_Load;
    wire        Mem_Write;
    wire [2:0]  Bus_Select;
    wire        ALU_Add, ALU_And, ALU_DR, ALU_Comp, ALU_Shr, ALU_Shl;
    wire        E_Load, E_Clear, E_Comp;

    wire        AC_zero, E, AC_sign;
    wire [15:0] IR_internal;
    wire [15:0] AC_internal, PC_internal, AR_internal, DR_internal;

    // ---------------------- Control Unit ----------------------
    control_unit cu (
        .clk(clk),
        .rst(rst),

        .IR(IR_internal),
        .AC_zero(AC_zero),
        .E(E),
        .AC_sign(AC_sign),

        // Control signals
        .AR_Load(AR_Load), .AR_Inc(AR_Inc), .AR_Clear(AR_Clear),
        .PC_Load(PC_Load), .PC_Inc(PC_Inc), .PC_Clear(PC_Clear),
        .DR_Load(DR_Load), .DR_Inc(DR_Inc), .DR_Clear(DR_Clear),
        .AC_Load(AC_Load), .AC_Inc(AC_Inc), .AC_Clear(AC_Clear),
        .IR_Load(IR_Load),
        .TR_Load(TR_Load),
        .Mem_Write(Mem_Write),
        .Bus_Select(Bus_Select),
        .ALU_Add(ALU_Add),
        .ALU_And(ALU_And),
        .ALU_DR(ALU_DR),
        .ALU_Comp(ALU_Comp),
        .ALU_Shr(ALU_Shr),
        .ALU_Shl(ALU_Shl),
        .E_Load(E_Load),
        .E_Clear(E_Clear),
        .E_Comp(E_Comp),

        // Debug
        .car_out(CAR),
        .microinstruction_out(Microinstruction)
    );

    // ---------------------- Datapath --------------------------
    datapath #(.INIT_FILE(INIT_FILE)) dp (
        .clk(clk),
        .rst(rst),

        .AR_Load(AR_Load), .AR_Inc(AR_Inc), .AR_Clear(AR_Clear),
        .PC_Load(PC_Load), .PC_Inc(PC_Inc), .PC_Clear(PC_Clear),
        .DR_Load(DR_Load), .DR_Inc(DR_Inc), .DR_Clear(DR_Clear),
        .AC_Load(AC_Load), .AC_Inc(AC_Inc), .AC_Clear(AC_Clear),
        .IR_Load(IR_Load),
        .TR_Load(TR_Load),

        .Mem_Write(Mem_Write),
        .Bus_Select(Bus_Select),

        .ALU_Add(ALU_Add),
        .ALU_And(ALU_And),
        .ALU_DR(ALU_DR),
        .ALU_Comp(ALU_Comp),
        .ALU_Shr(ALU_Shr),
        .ALU_Shl(ALU_Shl),

        .E_Load(E_Load),
        .E_Clear(E_Clear),
        .E_Comp(E_Comp),

        .IR_out(IR_internal),
        .E_out(E),
        .AC_zero(AC_zero),
        .AC_sign(AC_sign),

        .AC_out(AC_internal),
        .DR_out(DR_internal),
        .PC_out(PC_internal),
        .AR_out(AR_internal)
    );

    // Output assignments for observation
    assign AC = AC_internal;
    assign PC = PC_internal;
    assign IR = IR_internal;

endmodule