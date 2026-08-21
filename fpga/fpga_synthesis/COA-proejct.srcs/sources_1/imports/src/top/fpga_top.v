// ============================================================
// Module      : fpga_top
// Description : Top-level wrapper for the Basys 3 board.
//               Wires together: reset synchronizer, clock
//               divider (for a human-visible demo speed), the
//               Mano computer itself (pre-loaded with a program
//               via INIT_FILE), and LED output.
//
// Demo behavior:
//   - On power-up / reset, memory already contains the program
//     from program.mem (loaded into Block RAM at build time --
//     no manual switch entry needed).
//   - The CPU runs on a slow (~2 Hz) divided clock so LED changes
//     are visible to an audience.
//   - sw0 selects what the LEDs display:
//       sw0 = 0  ->  show AC[7:0]   (the accumulator result)
//       sw0 = 1  ->  show CAR[7:0]  (the microprogram address,
//                                    proves the control unit is
//                                    really stepping through
//                                    microinstructions)
// ============================================================

module fpga_top (
    input  wire       clk,       // 100 MHz from Basys 3
    input  wire       rst,       // Center button (active high)
    input  wire       sw0,       // Slide switch 0: LED display select
    output wire [7:0] led        // AC or CAR, depending on sw0
);

    wire        rst_sync;    // Debounced/synchronized reset
    wire        clk_slow;    // ~2 Hz clock driving the CPU
    wire [15:0] AC, PC, IR;
    wire [7:0]  CAR;
    wire [31:0] Microinstruction;

    // Reset synchronizer -- avoids metastability from the async
    // push-button reaching internal registers directly.
    reset_sync u_reset (
        .clk(clk),
        .rst_in(rst),
        .rst_out(rst_sync)
    );

    // Clock divider -- slows the 100 MHz board clock down to a
    // rate a human can actually watch on the LEDs.
    clk_divider u_clkdiv (
        .clk_in(clk),
        .rst(rst_sync),
        .clk_out(clk_slow)
    );

    // The Mano computer, pre-loaded with program.mem at build
    // time via the INIT_FILE parameter (see memory.v). Runs on
    // the slow divided clock so the demo is watchable.
    mano_computer #(
        .INIT_FILE("program.mem")
    ) u_mano (
        .clk(clk_slow),
        .rst(rst_sync),
        .AC(AC),
        .PC(PC),
        .IR(IR),
        .CAR(CAR),
        .Microinstruction(Microinstruction)
    );

    // LED output mux -- sw0 picks between watching the
    // accumulator result or the control unit's microaddress.
    assign led = sw0 ? CAR : AC[7:0];

endmodule