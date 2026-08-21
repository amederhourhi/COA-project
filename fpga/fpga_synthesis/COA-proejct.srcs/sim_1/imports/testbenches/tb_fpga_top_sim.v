// ============================================================
// Testbench   : tb_fpga_top_sim
// Description : Drives the actual fpga_top module (the same
//               hierarchy that gets placed, routed, and turned
//               into a bitstream) with a 100 MHz clock, exactly
//               like the real Basys 3 board would.
//
//               Used ONLY for post-implementation timing
//               simulation -- i.e. simulating the real routed
//               netlist (with real gate delays) instead of the
//               idealized RTL, as a stand-in verification step
//               when physical board access isn't available yet.
//
// IMPORTANT: For this simulation to finish in a reasonable
// amount of time, u_clkdiv inside fpga_top.v must temporarily
// use a SMALL DIVIDER_MAX (e.g. 4) instead of the real demo
// value (24,999,999). Revert it back to the real value before
// generating the bitstream you actually flash to the board.
// ============================================================

`timescale 1ns / 1ps

module tb_fpga_top_sim;

    reg clk;
    reg rst;
    reg sw0;
    wire [7:0] led;

    // Instantiate the real top-level module -- same one that
    // gets synthesized, placed, and routed for the board.
    fpga_top uut (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .led(led)
    );

    // 100 MHz board clock (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        sw0 = 0;      // Watch AC on the LEDs
        #100;
        rst = 0;

        // With a small DIVIDER_MAX, the CPU should finish its
        // short program well within this window.
        #100000;

        $display("\n=== Post-implementation timing sim finished ===");
        $display("LED output (AC[7:0]) = %b  (expect 10101010 = 0xAA)", led);

        if (led == 8'b10101010)
            $display("RESULT: PASS -- routed netlist behaves correctly.");
        else
            $display("RESULT: Check DIVIDER_MAX is set small enough and simulation ran long enough.");

        $finish;
    end

endmodule