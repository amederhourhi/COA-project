// ============================================================
// Testbench   : tb_mano_computer
// Description : Incremental multi-instruction testbench
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

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Load Instructions into RAM
    initial begin
        #1;

        // ============================================
        // TEST 1: Direct Operations (LDA, AND, ADD, STA, HLT)
        // Memory Addresses:
        // 0x000: LDA 0x006  (AC <- M[6] = 0x000F)
        // 0x001: AND 0x007  (AC <- AC & M[7] = 0x000F & 0x0007 = 0x0007)
        // 0x002: ADD 0x008  (AC <- AC + M[8] = 0x0007 + 0x0002 = 0x0009)
        // 0x003: STA 0x009  (M[9] <- AC = 0x0009)
        // 0x004: HLT        (Jump to self at 0x48)
        // ============================================
        uut.dp.mem.mem[16'h000] = 16'h2006; // LDA 6
        uut.dp.mem.mem[16'h001] = 16'h0007; // AND 7
        uut.dp.mem.mem[16'h002] = 16'h1008; // ADD 8
        uut.dp.mem.mem[16'h003] = 16'h3009; // STA 9
        uut.dp.mem.mem[16'h004] = 16'h7000; // HLT / Reg-ref

        // Data operands
        uut.dp.mem.mem[16'h006] = 16'h000F; // Data 1
        uut.dp.mem.mem[16'h007] = 16'h0007; // Data 2
        uut.dp.mem.mem[16'h008] = 16'h0002; // Data 3
        uut.dp.mem.mem[16'h009] = 16'h0000; // Result destination
    end

    // Execution & Self-Checking Stimulus
    initial begin
        rst = 1;
        #20;
        rst = 0;

        // Allow cycles for execution through HLT loop
        #800;

        $display("\n========================================");
        $display("VERIFICATION RESULT FOR TEST 1");
        $display("----------------------------------------");
        $display("AC Output     : %h (Expected: 0009)", AC);
        $display("Memory[0x009] : %h (Expected: 0009)", uut.dp.mem.mem[16'h009]);
        $display("CAR Value     : %h (Expected: 48)", CAR);
        
        if (AC == 16'h0009 && uut.dp.mem.mem[16'h009] == 16'h0009 && CAR == 8'h48) begin
            $display("STATUS        : >>> PASSED <<<");
        end else begin
            $display("STATUS        : >>> FAILED <<<");
        end
        $display("========================================\n");

        $finish;
    end

endmodule