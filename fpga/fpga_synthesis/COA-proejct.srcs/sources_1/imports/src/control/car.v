// ============================================================
// Module      : car
// Description : Control Address Register (8-bit)
//               Holds the address of the current microinstruction
// ============================================================

module car (
    input  wire       clk,
    input  wire       rst,
    input  wire       load,          // Load new address
    input  wire [7:0] d_in,          // Next address
    output reg  [7:0] q_out          // Current microaddress
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q_out <= 8'h00;          // Start from address 0 (Fetch)
        else if (load)
            q_out <= d_in;
    end

endmodule