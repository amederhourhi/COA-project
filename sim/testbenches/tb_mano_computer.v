// ============================================================
// Testbench   : tb_mano_computer
// Description : Testbench with memory initialization
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

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------- Memory Initialization ----------
    // We force some values into the memory inside the datapath
    // for a simple test program.
    initial begin
        // Wait a moment for the design to elaborate
        #1;

        // Simple test program:
        // Address 0: LDA 5     (opcode 010, address 005) → 0x2005
        // Address 1: ADD 6     (opcode 001, address 006) → 0x1006
        // Address 2: STA 7     (opcode 011, address 007) → 0x3007
        // Address 3: HLT       (we will treat later)
        // Data:
        // Address 5: 000A
        // Address 6: 0005
        // Address 7: will receive result

                // Test program for BUN
        // 0: LDA 5
        // 1: BUN 3          ← should jump over address 2
        // 2: LDA 6          ← this should be skipped
        // 3: STA 7
        // 4: HLT

        uut.dp.mem.mem[0] = 16'h2005;   // LDA 5
        uut.dp.mem.mem[1] = 16'h4003;   // BUN 3
        uut.dp.mem.mem[2] = 16'h2006;   // LDA 6  (should be skipped)
        uut.dp.mem.mem[3] = 16'h3007;   // STA 7
        uut.dp.mem.mem[4] = 16'h7000;   // HLT

        uut.dp.mem.mem[5] = 16'h00AA;   // Data
        uut.dp.mem.mem[6] = 16'h00BB;   // Data (should NOT be loaded)
    end

    // Stimulus
    initial begin
        rst = 1;
        #20;
        rst = 0;

                // Run long enough
        #500;

        $display("\n=== Simulation finished ===");
        $display("Final PC  = %h", PC);
        $display("Final AC  = %h", AC);
        $display("Final IR  = %h", IR);
        $display("Final CAR = %h", CAR);
        $display("Memory[7] = %h  (should be 000F if STA worked)", uut.dp.mem.mem[7]);
        $finish;
    end

        always @(posedge clk) begin
        if (!rst) begin
            $display("T=%0t | CAR=%h | PC=%h | IR=%h | AC=%h | Micro=%h | AC_Load=%b ALU_Add=%b ALU_DR=%b",
                     $time, CAR, PC, IR, AC, Microinstruction,
                     uut.cu.AC_Load, uut.cu.ALU_Add, uut.cu.ALU_DR);
        end
    end

endmodule