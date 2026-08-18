// ============================================================
// Module      : clk_divider
// Description : Divides the Basys 3's 100 MHz input clock down
//               to a slow, human-visible clock (a few Hz) so
//               that CAR/AC/PC changes are actually observable
//               on the board's LEDs during a live demo.
//
//               Implemented as a free-running counter: the output
//               clock toggles every time the counter reaches
//               DIVIDER_MAX, giving an output frequency of
//               100_000_000 / (2 * (DIVIDER_MAX + 1)) Hz.
//
//               Default DIVIDER_MAX = 24_999_999 gives a 2 Hz
//               output clock -- fast enough to keep a demo moving,
//               slow enough to read the LEDs by eye.
// ============================================================

module clk_divider #(
    parameter integer DIVIDER_MAX = 24_999_999   // Tune this to change demo speed
)(
    input  wire clk_in,     // 100 MHz board clock
    input  wire rst,        // Synchronous reset
    output reg  clk_out     // Slow output clock for the CPU
);

    reg [24:0] count;       // Wide enough to count up to DIVIDER_MAX

    always @(posedge clk_in) begin
        if (rst) begin
            count   <= 0;
            clk_out <= 1'b0;
        end else if (count == DIVIDER_MAX) begin
            count   <= 0;
            clk_out <= ~clk_out;   // Toggle -> creates the slow clock edge
        end else begin
            count   <= count + 1'b1;
        end
    end

endmodule