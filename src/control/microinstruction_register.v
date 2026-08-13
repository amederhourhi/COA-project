// ============================================================
// Module      : microinstruction_register
// Description : Holds the current 32-bit microinstruction
//               coming from Control Memory.
// ============================================================

module microinstruction_register (
    input  wire        clk,
    input  wire        rst,
    input  wire        load,                 // Usually always enabled
    input  wire [31:0] d_in,
    output reg  [31:0] q_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q_out <= 32'b0;
        else if (load)
            q_out <= d_in;
    end

endmodule