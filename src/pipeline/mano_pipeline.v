// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline (Fetch, Decode, Execute) 
//              for the Mano Computer architecture.
// ------------------------------------------------------------------
module mano_pipeline (
    input wire clk,      // Main system clock
    input wire reset,    // Synchronous reset (active high) to flush pipeline
    
    // --- Memory Interface (Instruction Fetch) ---
    // We expose these ports so the top-level module can wire this up to your Block ROM
    output wire [11:0] inst_addr, // Address sent to Instruction Memory
    input wire [15:0] inst_data   // 16-bit Instruction Data received from Memory
);

    // ========================================================
    // PROGRAM COUNTER (PC)
    // ========================================================
    reg [11:0] pc; // 12-bit Program Counter for Mano Computer

    // Wire the PC directly to the memory address port.
    // This allows the memory to see the address immediately and prep the data 
    // for the upcoming clock edge.
    assign inst_addr = pc; 

    // ========================================================
    // PIPELINE REGISTERS
    // ========================================================
    // 1. IF/ID (Instruction Fetch -> Instruction Decode) Buffer
    reg [15:0] if_id_ir; // Holds the currently fetched instruction
    reg [11:0] if_id_pc; // Holds the PC of the fetched instruction (useful for branching)
    
    // 2. ID/EX (Instruction Decode -> Execute) Buffer
    reg [15:0] id_ex_a;  // Snapshot of Accumulator (AC) data
    reg [15:0] id_ex_dr; // Snapshot of Data Register (DR) data
    reg [3:0]  id_ex_op; // Decoded 4-bit Opcode to tell the ALU what to do
    
    // ========================================================
    // PIPELINE STAGE LOGIC (Synchronous)
    // ========================================================
    always @(posedge clk) begin
        if (reset) begin
            // Clear everything on reset, including the PC
            pc       <= 12'b0; 
            if_id_ir <= 16'b0;
            if_id_pc <= 12'b0;
            id_ex_a  <= 16'b0;
            id_ex_dr <= 16'b0;
            id_ex_op <= 4'b0;
        end else begin
            // ------------------------------------------------
            // STAGE 1: FETCH
            // Action: Grab the instruction from memory and increment PC.
            // ------------------------------------------------
            if_id_ir <= inst_data; // Lock the incoming memory data into the IF/ID buffer
            if_id_pc <= pc;        // Pass the PC along to the next stage
            pc       <= pc + 1;    // Increment PC so we fetch the next instruction next cycle
            
            // ------------------------------------------------
            // STAGE 2: DECODE
            // (Subphase 1.3: Decode if_id_ir and read registers)
            // ------------------------------------------------
            
            // ------------------------------------------------
            // STAGE 3: EXECUTE
            // (Subphase 1.4: Perform ALU ops and write back)
            // ------------------------------------------------
        end
    end

endmodule