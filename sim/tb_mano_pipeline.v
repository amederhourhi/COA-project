// ------------------------------------------------------------------
// Module: tb_mano_pipeline
// Description: Simulation testbench to verify pipeline stages, 
//              data forwarding, and control hazard flushing.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module tb_mano_pipeline();

    // --------------------------------------------------------
    // TESTBENCH SIGNALS
    // --------------------------------------------------------
    reg clk;
    reg reset;
    
    // Wires connecting to the Pipeline Module
    wire [11:0] inst_addr;
    reg  [15:0] inst_data;
    
    wire [11:0] data_addr;
    wire        data_read_en;
    wire        data_write_en;
    reg  [15:0] data_in;
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
    // MOCK INSTRUCTION MEMORY (ROM)
    // --------------------------------------------------------
    always @(*) begin
        case (inst_addr)
            // Test 1: RAW Hazard (LDA then ADD immediately)
            12'h000: inst_data = 16'h2100; // LDA 100 (Load mem[100] into AC)
            12'h001: inst_data = 16'h1101; // ADD 101 (Add mem[101] to AC)
            12'h002: inst_data = 16'h3102; // STA 102 (Store AC to mem[102])
            
            // Test 2: Control Hazard (Branching)
            12'h003: inst_data = 16'h4006; // BUN 006 (Branch unconditionally to 006)
            12'h004: inst_data = 16'h0103; // AND 103 (SHOULD BE FLUSHED/SKIPPED!)
            12'h005: inst_data = 16'h0103; // AND 103 (SHOULD BE FLUSHED/SKIPPED!)
            
            // Target of Branch
            12'h006: inst_data = 16'h2102; // LDA 102 (Verify stored data)
            
            default: inst_data = 16'h0000; // NOP
        endcase
    end

    // --------------------------------------------------------
    // MOCK DATA MEMORY (RAM)
    // --------------------------------------------------------
    // FIXED: Increased memory array bounds to the full 4096-word address space 
    // to prevent strict XSim out-of-bounds compilation crashes.
    reg [15:0] ram [0:4095]; 

    // Synchronous Write, Asynchronous Read (matches typical FPGA Block RAM)
    always @(posedge clk) begin
        if (data_write_en) begin
            ram[data_addr] <= data_out;
        end
    end

    always @(*) begin
        if (data_read_en) begin
            data_in = ram[data_addr];
        end else begin
            data_in = 16'h0000;
        end
    end

    // --------------------------------------------------------
    // SIMULATION SEQUENCE
    // --------------------------------------------------------
    initial begin
        // Initialize Test RAM Data
        ram[12'h100] = 16'd10; // Value for LDA
        ram[12'h101] = 16'd25; // Value for ADD (Expected AC result: 35)
        
        // Apply Reset
        reset = 1;
        #20;
        reset = 0;
        
        // Let pipeline run for 15 clock cycles to process the test program
        #150;
        
        // Stop simulation
        $finish;
    end

endmodule