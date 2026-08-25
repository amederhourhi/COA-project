// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline (Fetch, Decode, Execute) 
//              for the Mano Computer architecture.
// ------------------------------------------------------------------
module mano_pipeline (
    input wire clk,
    input wire reset,
    
    // --- Instruction Memory Interface (IF Stage) ---
    output wire [11:0] inst_addr, 
    input wire [15:0]  inst_data,  
    
    // --- Data Memory Interface (ID/EX Stages) ---
    // Added ports to interact with your RAM block for variables
    output reg [11:0] data_addr,     // Address requested for Data RAM
    output reg        data_read_en,  // Signal to read from RAM
    output reg        data_write_en, // Signal to write to RAM
    input wire [15:0] data_in,       // Data retrieved from RAM (Ready in EX stage)
    output reg [15:0] data_out       // Data to be written to RAM
);

    // ========================================================
    // CPU CORE REGISTERS
    // ========================================================
    reg [11:0] pc; // Program Counter
    reg [15:0] ac; // Accumulator (The main register for arithmetic/logic)

    // Wire PC directly to memory so the fetch address is always ready
    assign inst_addr = pc; 

    // ========================================================
    // PIPELINE REGISTERS
    // ========================================================
    // 1. IF/ID (Instruction Fetch -> Instruction Decode) 
    reg [15:0] if_id_ir; 
    reg [11:0] if_id_pc; 
    
    // 2. ID/EX (Instruction Decode -> Execute)
    reg [15:0] id_ex_ac;   // Snapshot of AC passed to the ALU
    reg [3:0]  id_ex_op;   // 4-bit Opcode (combines the I-bit + 3-bit op)
    reg [11:0] id_ex_addr; // The 12-bit memory address/operand
    
    // ========================================================
    // PIPELINE STAGE LOGIC (Synchronous)
    // ========================================================
    always @(posedge clk) begin
        if (reset) begin
            // Flush all registers and memory control signals
            pc            <= 12'b0; 
            ac            <= 16'b0;
            if_id_ir      <= 16'b0;
            if_id_pc      <= 12'b0;
            id_ex_ac      <= 16'b0;
            id_ex_op      <= 4'b0;
            id_ex_addr    <= 12'b0;
            data_addr     <= 12'b0;
            data_read_en  <= 1'b0;
            data_write_en <= 1'b0;
        end else begin
            // ------------------------------------------------
            // STAGE 1: FETCH
            // ------------------------------------------------
            if_id_ir <= inst_data;
            if_id_pc <= pc;
            pc       <= pc + 1;
            
            // ------------------------------------------------
            // STAGE 2: DECODE
            // Action: Parse instruction, setup AC, request data memory
            // ------------------------------------------------
            // 1. Pass the current Accumulator state to the Execute stage
            id_ex_ac <= ac; 
            
            // 2. Extract Opcode: bit 15 ('I' bit) + bits 14:12 (operation)
            id_ex_op <= if_id_ir[15:12]; 
            
            // 3. Extract the 12-bit Address/Operand
            id_ex_addr <= if_id_ir[11:0];
            
            // 4. Pre-fetch Data: We set the RAM address right now so the data 
            // is guaranteed to be available on `data_in` exactly when Execute starts.
            data_addr    <= if_id_ir[11:0];
            data_read_en <= 1'b1; // Default to reading (harmless if Execute ignores it)
            
            // ------------------------------------------------
            // STAGE 3: EXECUTE
            // (Subphase 1.4: Perform ALU ops and write back)
            // ------------------------------------------------
        end
    end

endmodule