// ============================================================
// Testbench   : tb_mano_computer
// Description : Basic testbench to verify Fetch cycle
// ============================================================

`timescale 1ns / 1ps

module tb_mano_computer;

    // Clock and reset
    reg clk;
    reg rst;

    // Outputs from the computer
    wire [15:0] AC, PC, IR;
    wire [7:0]  CAR;
    wire [31:0] Microinstruction;

    // Instantiate the Mano Computer
    mano_computer uut (
        .clk(clk),
        .rst(rst),
        .AC(AC),
        .PC(PC),
        .IR(IR),
        .CAR(CAR),
        .Microinstruction(Microinstruction)
    );

    // Clock generation (10 ns period = 100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize
        rst = 1;
        #20;                    // Hold reset for 20 ns
        rst = 0;

        // Let it run for some cycles
        #200;

        $display("=== Simulation finished ===");
        $display("Final PC  = %h", PC);
        $display("Final CAR = %h", CAR);
        $display("Final IR  = %h", IR);

        $finish;
    end

    // Optional: Monitor important signals every clock
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0t | CAR=%h | PC=%h | IR=%h | Microinstr=%h",
                     $time, CAR, PC, IR, Microinstruction);
        end
    end

endmodule