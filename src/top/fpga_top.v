// ============================================================
// Module      : fpga_top
// Description : Top-level wrapper for Basys 3
// ============================================================

module fpga_top (
    input  wire       clk,       // 100 MHz from Basys 3
    input  wire       rst,       // Center button (active high)
    output wire [7:0] led        // Lower 8 bits of AC
);

    wire rst_sync;
    wire [15:0] AC, PC, IR;
    wire [7:0]  CAR;
    wire [31:0] Microinstruction;

    // Synchronize reset
    reset_sync u_reset (
        .clk(clk),
        .rst_in(rst),
        .rst_out(rst_sync)
    );

    // Instantiate the Mano Computer
    mano_computer u_mano (
        .clk(clk),
        .rst(rst_sync),
        .AC(AC),
        .PC(PC),
        .IR(IR),
        .CAR(CAR),
        .Microinstruction(Microinstruction)
    );

    // Show lower 8 bits of AC on LEDs
    assign led = AC[7:0];

endmodule