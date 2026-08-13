// ============================================================
// Module      : e_ff
// Description : E (Extension / Carry) flip-flop
// ============================================================

module e_ff (
    input  wire clk,
    input  wire rst,
    input  wire load,        // Load new E value from ALU
    input  wire clear,       // Clear E
    input  wire complement,  // Complement E
    input  wire d_in,        // New E value from ALU
    output reg  q_out        // Current E
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q_out <= 1'b0;
        else if (clear)
            q_out <= 1'b0;
        else if (complement)
            q_out <= ~q_out;
        else if (load)
            q_out <= d_in;
    end

endmodule