// ------------------------------------------------------------------
// Module: tb_mano_pipeline
// Description: Simulation testbench to verify pipeline stages executing
//              the 16-bit floating point addition algorithm.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module tb_mano_pipeline();

    // --------------------------------------------------------
    // TESTBENCH SIGNALS
    // --------------------------------------------------------
    reg clk;
    reg reset;

    wire [11:0] inst_addr;
    wire [15:0] inst_data;

    wire [11:0] data_addr;
    wire        data_read_en;
    wire        data_write_en;
    wire [15:0] data_in;
    wire [15:0] data_out;

    // --------------------------------------------------------
    // UNIT UNDER TEST (UUT)
    // --------------------------------------------------------
    mano_pipeline uut (
        .clk(clk),
        .reset(reset),
        .inst_addr(inst_addr),
        .inst_data(inst_data),
        .data_addr(data_addr),
        .data_read_en(data_read_en),
        .data_write_en(data_write_en),
        .data_in(data_in),
        .data_out(data_out)
    );

    // --------------------------------------------------------
    // CLOCK GENERATION (100MHz / 10ns period)
    // --------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // UNIFIED MEMORY (RAM)
    // --------------------------------------------------------
    // Stores both instructions and data for the FP algorithm
    reg [15:0] ram [0:4095];
    integer i;

    // Instruction Fetch (Combinational read)
    assign inst_data = ram[inst_addr];

    // Data Read (Combinational read)
    assign data_in = (data_read_en) ? ram[data_addr] : 16'h0000;

    // Data Write (Synchronous write)
    always @(posedge clk) begin
        if (data_write_en) begin
            ram[data_addr] <= data_out;
        end
    end

    // --------------------------------------------------------
    // SIMULATION SEQUENCE & RAM INITIALIZATION
    // --------------------------------------------------------
    initial begin
        // 1. Clear Memory to prevent X values
        for (i = 0; i < 4096; i = i + 1) begin
            ram[i] = 16'h0000;
        end

        // 2. Load the Floating Point Assembly Program
        ram[12'h000] = 16'h2042; // LDA NUM1
        ram[12'h001] = 16'h0044; // AND MSK_MAN
        ram[12'h002] = 16'h1046; // ADD HID_BIT
        ram[12'h003] = 16'h3048; // STA MAN1
        ram[12'h004] = 16'h2043; // LDA NUM2
        ram[12'h005] = 16'h0044; // AND MSK_MAN
        ram[12'h006] = 16'h1046; // ADD HID_BIT
        ram[12'h007] = 16'h3049; // STA MAN2
        ram[12'h008] = 16'h2042; // LDA NUM1
        ram[12'h009] = 16'h0045; // AND MSK_EXP
        ram[12'h00a] = 16'h304a; // STA EXP1
        ram[12'h00b] = 16'h2043; // LDA NUM2
        ram[12'h00c] = 16'h0045; // AND MSK_EXP
        ram[12'h00d] = 16'h304b; // STA EXP2
        ram[12'h00e] = 16'h204b; // LDA EXP2
        ram[12'h00f] = 16'h7200; // CMA
        ram[12'h010] = 16'h7020; // INC
        ram[12'h011] = 16'h104a; // ADD EXP1
        ram[12'h012] = 16'h7008; // SNA
        ram[12'h013] = 16'h402b; // BUN E1_BIG
        ram[12'h014] = 16'h304c; // STA DIFF
        ram[12'h015] = 16'h204c; // LDA DIFF
        ram[12'h016] = 16'h7200; // CMA
        ram[12'h017] = 16'h7020; // INC
        ram[12'h018] = 16'h304c; // STA DIFF
        ram[12'h019] = 16'h204b; // LDA EXP2
        ram[12'h01a] = 16'h304d; // STA RES_EXP
        ram[12'h01b] = 16'h204c; // LDA DIFF
        ram[12'h01c] = 16'h7004; // SZA
        ram[12'h01d] = 16'h401f; // BUN SH1
        ram[12'h01e] = 16'h403e; // BUN DO_ADD
        ram[12'h01f] = 16'h2048; // LDA MAN1
        ram[12'h020] = 16'h7400; // CLE
        ram[12'h021] = 16'h7080; // CIR
        ram[12'h022] = 16'h3048; // STA MAN1
        ram[12'h023] = 16'h204c; // LDA DIFF
        ram[12'h024] = 16'h7200; // CMA
        ram[12'h025] = 16'h7020; // INC
        ram[12'h026] = 16'h1047; // ADD EXP_ONE
        ram[12'h027] = 16'h7200; // CMA
        ram[12'h028] = 16'h7020; // INC
        ram[12'h029] = 16'h304c; // STA DIFF
        ram[12'h02a] = 16'h401b; // BUN ALIGN1
        ram[12'h02b] = 16'h304c; // STA DIFF
        ram[12'h02c] = 16'h204a; // LDA EXP1
        ram[12'h02d] = 16'h304d; // STA RES_EXP
        ram[12'h02e] = 16'h204c; // LDA DIFF
        ram[12'h02f] = 16'h7004; // SZA
        ram[12'h030] = 16'h4032; // BUN SH2
        ram[12'h031] = 16'h403e; // BUN DO_ADD
        ram[12'h032] = 16'h2049; // LDA MAN2
        ram[12'h033] = 16'h7400; // CLE
        ram[12'h034] = 16'h7080; // CIR
        ram[12'h035] = 16'h3049; // STA MAN2
        ram[12'h036] = 16'h204c; // LDA DIFF
        ram[12'h037] = 16'h7200; // CMA
        ram[12'h038] = 16'h7020; // INC
        ram[12'h039] = 16'h1047; // ADD EXP_ONE
        ram[12'h03a] = 16'h7200; // CMA
        ram[12'h03b] = 16'h7020; // INC
        ram[12'h03c] = 16'h304c; // STA DIFF
        ram[12'h03d] = 16'h402e; // BUN ALIGN2
        ram[12'h03e] = 16'h2048; // LDA MAN1
        ram[12'h03f] = 16'h1049; // ADD MAN2
        ram[12'h040] = 16'h304e; // STA RES_MAN
        ram[12'h041] = 16'h7001; // HLT
        ram[12'h042] = 16'h4500; // HEX 4500 (Number 1)
        ram[12'h043] = 16'h4100; // HEX 4100 (Number 2)
        ram[12'h044] = 16'h03ff; // HEX 03FF (Mantissa Mask)
        ram[12'h045] = 16'h7c00; // HEX 7C00 (Exponent Mask)
        ram[12'h046] = 16'h0400; // HEX 0400 (Hidden Bit)
        ram[12'h047] = 16'h0400; // HEX 0400 (Exponent +1 value)
        ram[12'h048] = 16'h0000; // HEX 0000 (MAN1)
        ram[12'h049] = 16'h0000; // HEX 0000 (MAN2)
        ram[12'h04a] = 16'h0000; // HEX 0000 (EXP1)
        ram[12'h04b] = 16'h0000; // HEX 0000 (EXP2)
        ram[12'h04c] = 16'h0000; // HEX 0000 (DIFF)
        ram[12'h04d] = 16'h0000; // HEX 0000 (RES_EXP)
        ram[12'h04e] = 16'h0000; // HEX 0000 (RES_MAN)

        // 3. Apply Reset
        reset = 1;
        #20;
        reset = 0;

        // 4. Live Monitor
        $monitor("t=%0t | PC=%03x | AC=%04x | E=%b | DIFF=%04x", 
                 $time, uut.pc, uut.ac, uut.e, ram[12'h04C]);

        // 5. Fail-safe timeout (In case of infinite loop)
        #10000;
        $display("--- SIMULATION TIMEOUT ---");
        $finish;
    end

    // --------------------------------------------------------
    // AUTO-HALT & RESULT REPORTING
    // --------------------------------------------------------
    always @(posedge clk) begin
        // Detect when the HLT instruction (Opcode 7, Address bit 0) reaches Execute
        if (uut.id_ex_valid && uut.id_ex_op == 4'b0111 && uut.id_ex_addr == 12'h001) begin
            $display("========================================");
            $display("HLT INSTRUCTION REACHED AT t=%0t", $time);
            $display("FINAL EXPONENT (RES_EXP) : %04x", ram[12'h04D]);
            $display("FINAL MANTISSA (RES_MAN) : %04x", ram[12'h04E]);
            $display("========================================");
            $finish;
        end
    end

endmodule