// ============================================================
// Testbench   : tb_mano_computer
// Description : Robust testbench with multiple test programs
// ============================================================

`timescale 1ns / 1ps

module tb_mano_computer;

    reg clk;
    reg rst;

    wire [15:0] AC, PC, IR;
    wire [7:0]  CAR;
    wire [31:0] Microinstruction;

    // Instantiate the computer
    mano_computer uut (
        .clk(clk),
        .rst(rst),
        .AC(AC),
        .PC(PC),
        .IR(IR),
        .CAR(CAR),
        .Microinstruction(Microinstruction)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------- Test Programs ----------
    initial begin
        #1;

        // ============================================
        // Test 1: LDA + ADD + STA + HLT
        // Expected: AC = 000F, mem[7] = 000F
        // ============================================
        uut.dp.mem.mem[0]  = 16'h2005;  // LDA 5
        uut.dp.mem.mem[1]  = 16'h1006;  // ADD 6
        uut.dp.mem.mem[2]  = 16'h3007;  // STA 7
        uut.dp.mem.mem[3]  = 16'h7000;  // HLT
        uut.dp.mem.mem[5]  = 16'h000A;
        uut.dp.mem.mem[6]  = 16'h0005;

        // Clear result location
        uut.dp.mem.mem[7]  = 16'h0000;
    end

    // Stimulus
    initial begin
        rst = 1;
        #20;
        rst = 0;

        // Let the first program run
        #600;

        $display("\n========================================");
        $display("TEST 1: LDA + ADD + STA + HLT");
        $display("Final AC      = %h  (expected 000F)", AC);
        $display("Memory[7]    = %h  (expected 000F)", uut.dp.mem.mem[7]);
        $display("Final IR     = %h  (expected 7000)", IR);
        $display("========================================\n");

        $finish;
    end

    // Optional monitor (comment out if too much output)
    /*
    always @(posedge clk) begin
        if (!rst)
            $display("T=%0t CAR=%h PC=%h IR=%h AC=%h", $time, CAR, PC, IR, AC);
    end
    */

endmodule