// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline with Hazard Management
// ------------------------------------------------------------------
module mano_pipeline (
    input  wire        clk,
    input  wire        reset,

    // --- Instruction Memory Interface ---
    output wire [11:0] inst_addr,
    input  wire [15:0] inst_data,

    // --- Data Memory Interface ---
    output reg  [11:0] data_addr,
    output reg         data_read_en,
    output reg         data_write_en,
    input  wire [15:0] data_in,
    output reg  [15:0] data_out
);

    // Global Architectural State
    reg [11:0] pc;
    reg [15:0] ac;
    reg        e; 

    assign inst_addr = pc;

    // ========================================================
    // PIPELINE REGISTERS
    // ========================================================
    // IF/ID (Fetch -> Decode)
    reg [15:0] if_id_ir;
    reg [11:0] if_id_pc;
    reg        if_id_valid; 

    // ID/EX (Decode -> Execute)
    reg [3:0]  id_ex_op;
    reg [11:0] id_ex_addr;
    reg [11:0] id_ex_pc;
    reg        id_ex_valid;

    // ========================================================
    // HAZARD UNIT INTEGRATION
    // ========================================================
    wire stall;
    wire flush;
    
    hazard_unit hu (
        .if_id_op(if_id_ir[15:12]),
        .id_ex_op(id_ex_op),
        .branch_taken(branch_taken),
        .stall(stall),
        .flush(flush)
    );

    // ========================================================
    // REGISTER-REFERENCE BIT MAP
    // ========================================================
    localparam RR_CLA = 11, RR_CLE = 10, RR_CMA = 9, RR_CME = 8, 
               RR_CIR = 7,  RR_CIL = 6,  RR_INC = 5, RR_SPA = 4, 
               RR_SNA = 3,  RR_SZA = 2,  RR_SZE = 1, RR_HLT = 0;

    // ========================================================
    // EXECUTE STAGE: ALU & BRANCH LOGIC (Combinational)
    // ========================================================
    reg [15:0] next_ac;
    reg        next_e;
    reg        branch_taken;
    reg [11:0] branch_target;

    wire [15:0] isz_incremented = data_in + 16'b1;

    always @(*) begin
        branch_taken  = 1'b0;
        branch_target = 12'b0;
        next_ac       = ac; 
        next_e        = e;  

        if (id_ex_valid) begin
            case (id_ex_op)
                4'b0000: next_ac = ac & data_in; // AND
                4'b0001: next_ac = ac + data_in; // ADD
                4'b0010: next_ac = data_in;      // LDA

                4'b0111: begin                   // Register-reference
                    if (id_ex_addr[RR_CLA]) next_ac = 16'b0;            
                    if (id_ex_addr[RR_CMA]) next_ac = ~ac;        
                    if (id_ex_addr[RR_INC]) next_ac = ac + 16'b1; 
                    if (id_ex_addr[RR_CLE]) next_e  = 1'b0;             
                    if (id_ex_addr[RR_CME]) next_e  = ~e;         
                    if (id_ex_addr[RR_CIR]) begin
                        next_ac = {e, ac[15:1]};
                        next_e  = ac[0];
                    end
                    if (id_ex_addr[RR_CIL]) begin
                        next_ac = {ac[14:0], e};
                        next_e  = ac[15];
                    end
                    // Conditional Skips
                    if (id_ex_addr[RR_SPA] && ac[15] == 1'b0) begin branch_taken = 1'b1; branch_target = id_ex_pc + 12'd2; end
                    if (id_ex_addr[RR_SNA] && ac[15] == 1'b1) begin branch_taken = 1'b1; branch_target = id_ex_pc + 12'd2; end
                    if (id_ex_addr[RR_SZA] && ac == 16'b0)    begin branch_taken = 1'b1; branch_target = id_ex_pc + 12'd2; end
                    if (id_ex_addr[RR_SZE] && e == 1'b0)      begin branch_taken = 1'b1; branch_target = id_ex_pc + 12'd2; end
                end

                4'b0100: begin branch_taken = 1'b1; branch_target = id_ex_addr; end         // BUN
                4'b0101: begin branch_taken = 1'b1; branch_target = id_ex_addr + 1'b1; end  // BSA
                4'b0110: begin // ISZ
                    if (isz_incremented == 16'b0) begin
                        branch_taken  = 1'b1;
                        branch_target = id_ex_pc + 12'd2;
                    end
                end
            endcase
        end
    end

    // ========================================================
    // PIPELINE SEQUENTIAL LOGIC
    // ========================================================
    always @(posedge clk) begin
        if (reset) begin
            pc            <= 12'b0;
            ac            <= 16'b0;
            e             <= 1'b0;
            if_id_valid   <= 1'b0;
            id_ex_valid   <= 1'b0;
            id_ex_op      <= 4'b0;
            data_read_en  <= 1'b0;
            data_write_en <= 1'b0;
        end else begin
            // Default: drop memory enables unless specifically requested
            data_write_en <= 1'b0;
            data_read_en  <= 1'b0;

            // --- STAGE 3: EXECUTE (Always completes to prevent lockups) ---
            if (id_ex_valid) begin
                ac <= next_ac;
                e  <= next_e;
                
                // Memory Writes control the port here
                if (id_ex_op == 4'b0011) begin      // STA
                    data_addr     <= id_ex_addr;
                    data_out      <= next_ac;
                    data_write_en <= 1'b1;
                end else if (id_ex_op == 4'b0101) begin // BSA
                    data_addr     <= id_ex_addr;
                    data_out      <= {4'b0000, id_ex_pc + 12'b1};
                    data_write_en <= 1'b1;
                end else if (id_ex_op == 4'b0110) begin // ISZ
                    data_addr     <= id_ex_addr;
                    data_out      <= isz_incremented;
                    data_write_en <= 1'b1;
                end
            end

            // --- STAGE 1 & 2: FETCH & DECODE ---
            if (flush) begin
                // Flush clears fetched/decoded instructions and jumps PC
                if_id_valid <= 1'b0;
                id_ex_valid <= 1'b0;
                pc          <= branch_target;
            end 
            else if (stall) begin
                // Stall freezes PC and IF/ID, injects bubble into EX
                id_ex_valid <= 1'b0; 
                id_ex_op    <= 4'b0000;
            end 
            else begin
                // Normal progression: ID -> EX
                id_ex_op    <= if_id_ir[15:12];
                id_ex_addr  <= if_id_ir[11:0];
                id_ex_pc    <= if_id_pc;
                id_ex_valid <= if_id_valid;

                // Decode requests Memory Read for the NEXT cycle's Execute stage
                if (if_id_valid && (if_id_ir[15:12] == 4'b0000 || // AND
                                    if_id_ir[15:12] == 4'b0001 || // ADD
                                    if_id_ir[15:12] == 4'b0010 || // LDA
                                    if_id_ir[15:12] == 4'b0110)) begin // ISZ
                    data_addr    <= if_id_ir[11:0];
                    data_read_en <= 1'b1;
                end

                // Normal progression: IF -> ID
                if_id_ir    <= inst_data;
                if_id_pc    <= pc;
                if_id_valid <= 1'b1;
                pc          <= pc + 1;
            end
        end
    end

endmodule