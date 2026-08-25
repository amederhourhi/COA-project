// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline (Fetch, Decode, Execute) 
//              for the Mano Computer architecture.
// ------------------------------------------------------------------
module mano_pipeline (
    input wire clk,      // Main system clock
    input wire reset     // Synchronous reset (active high) to flush pipeline
);

    // ========================================================
    // PIPELINE REGISTERS
    // These act as synchronous buffers between our three stages.
    // ========================================================
    
    // 1. IF/ID (Instruction Fetch -> Instruction Decode) Buffer
    reg [15:0] if_id_ir; // Holds the currently fetched instruction
    reg [11:0] if_id_pc; // Holds the Program Counter for that specific instruction
    
    // 2. ID/EX (Instruction Decode -> Execute) Buffer
    reg [15:0] id_ex_a;  // Snapshot of Accumulator (AC) data
    reg [15:0] id_ex_dr; // Snapshot of Data Register (DR) data
    reg [3:0]  id_ex_op; // Decoded 4-bit Opcode to tell the ALU what to do
    
    // ========================================================
    // PIPELINE STAGE LOGIC (Synchronous)
    // ========================================================
    
    always @(posedge clk) begin
        if (reset) begin
            // Flush pipeline on reset to prevent garbage execution
            if_id_ir <= 16'b0;
            if_id_pc <= 12'b0;
            id_ex_a  <= 16'b0;
            id_ex_dr <= 16'b0;
            id_ex_op <= 4'b0;
        end else begin
            // ------------------------------------------------
            // STAGE 1: FETCH
            // (Subphase 1.2: Pull instruction from block RAM)
            // ------------------------------------------------
            
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