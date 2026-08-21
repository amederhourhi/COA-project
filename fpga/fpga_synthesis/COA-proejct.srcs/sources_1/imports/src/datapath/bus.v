// ============================================================
// Module      : bus
// Description : 8-to-1 16-bit multiplexer (Common Bus)
//               When selecting IR, only the address field
//               (IR[11:0]) is placed on the bus.
// ============================================================

module bus (
    input  wire [2:0]  select,       // S2 S1 S0

    input  wire [15:0] ar_in,
    input  wire [15:0] pc_in,
    input  wire [15:0] dr_in,
    input  wire [15:0] ac_in,
    input  wire [15:0] ir_in,
    input  wire [15:0] tr_in,
    input  wire [15:0] mem_in,

    output reg  [15:0] bus_out
);

    always @(*) begin
        case (select)
            3'b001: bus_out = ar_in;                      // AR
            3'b010: bus_out = pc_in;                      // PC
            3'b011: bus_out = dr_in;                      // DR
            3'b100: bus_out = ac_in;                      // AC
            3'b101: bus_out = {4'b0000, ir_in[11:0]};     // IR → address only
            3'b110: bus_out = tr_in;                      // TR
            3'b111: bus_out = mem_in;                     // Memory
            default: bus_out = 16'b0;
        endcase
    end

endmodule