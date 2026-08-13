// ============================================================
// Module      : control_unit
// Description : Complete Microprogrammed Control Unit
//               for the Mano Computer.
// ============================================================

module control_unit (
    input  wire        clk,
    input  wire        rst,

    // From Datapath
    input  wire [15:0] IR,                 // Instruction Register
    input  wire        AC_zero,
    input  wire        E,
    input  wire        AC_sign,

    // ========== Control Signals to Datapath ==========
    // Registers
    output wire        AR_Load, AR_Inc, AR_Clear,
    output wire        PC_Load, PC_Inc, PC_Clear,
    output wire        DR_Load, DR_Inc, DR_Clear,
    output wire        AC_Load, AC_Inc, AC_Clear,
    output wire        IR_Load,
    output wire        TR_Load,

    // Memory
    output wire        Mem_Write,

    // Bus
    output wire [2:0]  Bus_Select,

    // ALU
    output wire        ALU_Add,
    output wire        ALU_And,
    output wire        ALU_DR,
    output wire        ALU_Comp,
    output wire        ALU_Shr,
    output wire        ALU_Shl,

    // E
    output wire        E_Load,
    output wire        E_Clear,
    output wire        E_Comp,

    // Debug
    output wire [7:0]  car_out,
    output wire [31:0] microinstruction_out
);

    // Internal signals
    wire [7:0]  car_current;
    wire [7:0]  next_car;
    wire [31:0] microinstruction;
    wire [7:0]  map_address;

    // Split microinstruction fields
    wire [15:0] ctrl_signals = microinstruction[31:16];
    wire [3:0]  cond_field   = microinstruction[15:12];
    wire [3:0]  seq_field    = microinstruction[11:8];
    wire [7:0]  addr_field   = microinstruction[7:0];

    // ---------------------- CAR ----------------------
    car car_reg (
        .clk(clk),
        .rst(rst),
        .load(1'b1),               // Always load next address
        .d_in(next_car),
        .q_out(car_current)
    );

    // ---------------------- Control Memory -----------
    control_memory cm (
        .address(car_current),
        .microinstruction(microinstruction)
    );

    // ---------------------- Mapping Logic ------------
    mapping_logic mapper (
        .opcode(IR[14:12]),
        .micro_address(map_address)
    );

    // ---------------------- Next Address Logic -------
    next_address_logic next_logic (
        .seq(seq_field),
        .cond_field(cond_field),
        .address_field(addr_field),
        .car_current(car_current),
        .map_address(map_address),
        .AC_zero(AC_zero),
        .E(E),
        .AC_sign(AC_sign),
        .next_car(next_car)
    );

    // ---------------------- Assign Control Signals ---
    // These bit positions must match the encoding we defined earlier.
    // For now we use a clean temporary mapping. We will finalize
    // the exact bit encoding when we fill the full microprogram.

    assign AR_Load   = ctrl_signals[15];
    assign AR_Inc    = ctrl_signals[14];
    assign AR_Clear  = ctrl_signals[13];
    assign PC_Load   = ctrl_signals[12];
    assign PC_Inc    = ctrl_signals[11];
    assign PC_Clear  = ctrl_signals[10];
    assign DR_Load   = ctrl_signals[9];
    assign DR_Inc    = ctrl_signals[8];
    assign AC_Load   = ctrl_signals[7];
    assign AC_Inc    = ctrl_signals[6];
    assign IR_Load   = ctrl_signals[5];
    assign Mem_Write = ctrl_signals[4];
    assign ALU_Add   = ctrl_signals[3];
    assign ALU_And   = ctrl_signals[2];
    assign ALU_DR    = ctrl_signals[1];
    assign E_Load    = ctrl_signals[0];

    // Temporary defaults for signals not yet fully encoded
    assign DR_Clear  = 1'b0;
    assign AC_Clear  = 1'b0;
    assign TR_Load   = 1'b0;
    assign ALU_Comp  = 1'b0;
    assign ALU_Shr   = 1'b0;
    assign ALU_Shl   = 1'b0;
    assign E_Clear   = 1'b0;
    assign E_Comp    = 1'b0;
    assign Bus_Select = 3'b000;   // Will be driven properly later

    // Debug outputs
    assign car_out = car_current;
    assign microinstruction_out = microinstruction;

endmodule