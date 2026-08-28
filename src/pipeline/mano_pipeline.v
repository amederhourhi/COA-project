// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline with Control Hazard flushing
// ------------------------------------------------------------------
module mano_pipeline (
    input wire clk,
    input wire reset,
    
    // --- Instruction Memory Interface ---
    output wire [11:0] inst_addr, 
    input wire [15:0]  inst_data,  
    
    // --- Data Memory Interface ---
    output reg [11:0] data_addr,     
    output reg        data_read_en,  
    output reg        data_write_en, 
    input wire [15:0] data_in,       
    output reg [15:0] data_out       
);

    reg [11:0] pc; 
    reg [15:0] ac; 

    assign inst_addr = pc; 

    // Pipeline Registers
    reg [15:0] if_id_ir; 
    reg [11:0] if_id_pc; 
    reg [15:0] id_ex_ac;   
    reg [3:0]  id_ex_op;   
    reg [11:0] id_ex_addr; 

    // ========================================================
    // HAZARD UNIT: DATA FORWARDING & BRANCH DETECTION
    // ========================================================
    reg [15:0] next_ac; 
    reg        branch_taken;
    reg [11:0] branch_target;

    always @(*) begin
        // Default states
        branch_taken  = 1'b0;
        branch_target = 12'b0;
        
        case (id_ex_op)
            4'b0000: next_ac = id_ex_ac & data_in; // AND
            4'b0001: next_ac = id_ex_ac + data_in; // ADD
            4'b0010: next_ac = data_in;            // LDA
            4'b0100: begin                         // BUN (Branch Unconditionally)
                        next_ac       = ac;        // AC doesn't change
                        branch_taken  = 1'b1;
                        branch_target = id_ex_addr;
                     end
            default: next_ac = ac;                 
        endcase
    end

    // ========================================================
    // PIPELINE STAGE LOGIC (Synchronous)
    // ========================================================
    always @(posedge clk) begin
        if (reset) begin
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
        end else if (branch_taken) begin
            // ------------------------------------------------
            // PIPELINE FLUSH (Control Hazard Resolution)
            // ------------------------------------------------
            pc            <= branch_target; // Redirect PC to the branch target
            if_id_ir      <= 16'b0;         // Nullify incorrectly fetched instruction
            id_ex_op      <= 4'b0;          // Nullify incorrectly decoded instruction (NOP)
            data_write_en <= 1'b0;          // Prevent accidental memory writes
        end else begin
            // ------------------------------------------------
            // NORMAL OPERATION (Fetch, Decode, Execute)
            // ------------------------------------------------
            
            // FETCH
            if_id_ir <= inst_data;
            if_id_pc <= pc;
            pc       <= pc + 1;
            
            // DECODE
            id_ex_ac     <= next_ac; // Data Forwarding applied here
            id_ex_op     <= if_id_ir[15:12]; 
            id_ex_addr   <= if_id_ir[11:0];
            data_addr    <= if_id_ir[11:0];
            data_read_en <= 1'b1; 
            
            // EXECUTE
            ac            <= next_ac; 
            data_write_en <= 1'b0; 
            
            if (id_ex_op == 4'b0011) begin // STA (Store Accumulator)
                data_out      <= id_ex_ac;
                data_write_en <= 1'b1;
            end
        end
    end

endmodule