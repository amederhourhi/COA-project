// ============================================================
// Module      : register
// Description : Generic parallel-load register with 
//               increment and asynchronous reset.
// ============================================================

module register #(
    parameter WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  load,
    input  wire                  inc,
    input  wire                  clear,
    input  wire [WIDTH-1:0]      d_in,
    output reg  [WIDTH-1:0]      q_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q_out <= {WIDTH{1'b0}};
        else if (clear)
            q_out <= {WIDTH{1'b0}};
        else if (load)
            q_out <= d_in;
        else if (inc)
            q_out <= q_out + 1'b1;
    end

endmodule