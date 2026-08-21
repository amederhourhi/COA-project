// ============================================================
// Module      : reset_sync
// Description : Synchronizes external reset to the system clock
//               (active-high reset in, active-high reset out)
// ============================================================

module reset_sync (
    input  wire clk,
    input  wire rst_in,      // asynchronous reset from button
    output reg  rst_out      // synchronized reset
);

    reg rst_meta;

    always @(posedge clk) begin
        rst_meta <= rst_in;
        rst_out  <= rst_meta;
    end

endmodule