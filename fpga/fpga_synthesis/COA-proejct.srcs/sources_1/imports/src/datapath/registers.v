// ============================================================
// File        : registers.v
// Description : All main registers of the Mano computer.
//               AC has a dedicated data input so it can receive
//               either the bus or the ALU result.
// ============================================================

module registers (
    input  wire        clk,
    input  wire        rst,

    // Control signals
    input  wire        AR_Load, AR_Inc, AR_Clear,
    input  wire        PC_Load, PC_Inc, PC_Clear,
    input  wire        DR_Load, DR_Inc, DR_Clear,
    input  wire        AC_Load, AC_Inc, AC_Clear,
    input  wire        IR_Load,
    input  wire        TR_Load,

    // Data inputs
    input  wire [15:0] bus_in,          // For AR, PC, DR, IR, TR
    input  wire [15:0] ac_data_in,      // Dedicated input for AC (bus or ALU)

    // Outputs
    output wire [15:0] AR_out,
    output wire [15:0] PC_out,
    output wire [15:0] DR_out,
    output wire [15:0] AC_out,
    output wire [15:0] IR_out,
    output wire [15:0] TR_out
);

    // Address Register
    register #(.WIDTH(16)) AR (
        .clk(clk), .rst(rst),
        .load(AR_Load), .inc(AR_Inc), .clear(AR_Clear),
        .d_in(bus_in), .q_out(AR_out)
    );

    // Program Counter
    register #(.WIDTH(16)) PC (
        .clk(clk), .rst(rst),
        .load(PC_Load), .inc(PC_Inc), .clear(PC_Clear),
        .d_in(bus_in), .q_out(PC_out)
    );

    // Data Register
    register #(.WIDTH(16)) DR (
        .clk(clk), .rst(rst),
        .load(DR_Load), .inc(DR_Inc), .clear(DR_Clear),
        .d_in(bus_in), .q_out(DR_out)
    );

    // Accumulator – uses dedicated input
    register #(.WIDTH(16)) AC (
        .clk(clk), .rst(rst),
        .load(AC_Load), .inc(AC_Inc), .clear(AC_Clear),
        .d_in(ac_data_in), .q_out(AC_out)
    );

    // Instruction Register
    register #(.WIDTH(16)) IR (
        .clk(clk), .rst(rst),
        .load(IR_Load), .inc(1'b0), .clear(1'b0),
        .d_in(bus_in), .q_out(IR_out)
    );

    // Temporary Register
    register #(.WIDTH(16)) TR (
        .clk(clk), .rst(rst),
        .load(TR_Load), .inc(1'b0), .clear(1'b0),
        .d_in(bus_in), .q_out(TR_out)
    );

endmodule