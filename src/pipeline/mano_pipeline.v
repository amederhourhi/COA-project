// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline (Fetch, Decode, Execute) 
// ------------------------------------------------------------------
module mano_pipeline (
    input wire clk,
    input wire reset,
    
    // --- Instruction Memory Interface (IF Stage) ---
    output wire [11:0] inst_addr, 
    input wire [15:0]  inst_data,  
    
    // --- Data Memory Interface (ID/EX Stages) ---
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
    // HAZARD UNIT: DATA FORWARDING
    // ========================================================
    reg [15:0] next_ac; // Holds what the AC *will* be after Execute

    // Combinatorial logic to calculate what the Execute stage is about to write
    always @(*) begin
        case (id_ex_op)
            4'b0000: next_ac = id_ex_ac & data_in; // AND
            4'b0001: next_ac = id_ex_ac + data_in; // ADD
            4'b0010: next_ac = data_in;            // LDA
            default: next_ac = ac;                 // No AC write, default to current AC
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
        end else begin
            // ------------------------------------------------
            // STAGE 1: FETCH
            // ------------------------------------------------
            if_id_ir <= inst_data;
            if_id_pc <= pc;
            pc       <= pc + 1;
            
            // ------------------------------------------------
            // STAGE 2: DECODE
            // ------------------------------------------------
            // HAZARD AVOIDANCE: Pass the 'forwarded' AC value to the next stage 
            // instead of the potentially stale 'ac' register.
            id_ex_ac     <= next_ac; 
            
            id_ex_op     <= if_id_ir[15:12]; 
            id_ex_addr   <= if_id_ir[11:0];
            data_addr    <= if_id_ir[11:0];
            data_read_en <= 1'b1; 
            
            // ------------------------------------------------
            // STAGE 3: EXECUTE
            // ------------------------------------------------
            data_write_en <= 1'b0; 
            
            // Actually update the AC register with the calculated value
            ac <= next_ac; 

            // Handle memory writes (STA)
            if (id_ex_op == 4'b0011) begin
                data_out      <= id_ex_ac;
                data_write_en <= 1'b1;
            end
        end
    end

endmodule