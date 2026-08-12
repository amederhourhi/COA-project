// ============================================================
// Module      : register
// Description : Generic parallel-load register with 
//               increment and asynchronous reset.
//               Used for AR, PC, DR, AC, IR, TR, etc.
// ============================================================

module register #(
    parameter WIDTH = 16                    // Data width (default 16-bit)
)(
    input  wire                  clk,       // Clock
    input  wire                  rst,       // Asynchronous reset (active high)
    input  wire                  load,      // Load enable
    input  wire                  inc,       // Increment enable
    input  wire                  clear,     // Synchronous clear
    input  wire [WIDTH-1:0]      d_in,      // Data input
    output reg  [WIDTH-1:0]      q_out      // Data output
);

    // Sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Asynchronous reset has highest priority
            q_out <= {WIDTH{1'b0}};
        end
        else if (clear) begin
            // Synchronous clear
            q_out <= {WIDTH{1'b0}};
        end
        else if (load) begin
            // Parallel load
            q_out <= d_in;
        end
        else if (inc) begin
            // Increment by 1
            q_out <= q_out + 1'b1;
        end
        // else: hold current value
    end

endmodule