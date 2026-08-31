// ------------------------------------------------------------------
// Module: mano_pipeline
// Description: Top-level 3-stage pipeline with Loops (ISZ)
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

    reg [11:0] pc;
    reg [15:0] ac;
    reg        e;  // "Extend" / carry-out flip-flop, used by CIR/CIL/CME/CLE

    assign inst_addr = pc;

    // ========================================================
    // PIPELINE REGISTERS
    // ========================================================
    reg [15:0] if_id_ir;
    reg [11:0] if_id_pc;

    reg [15:0] id_ex_ac;
    reg        id_ex_e;   // Forwarded E value, mirrors id_ex_ac's forwarding role
    reg [3:0]  id_ex_op;
    reg [11:0] id_ex_addr;
    reg [11:0] id_ex_pc;

    // ========================================================
    // REGISTER-REFERENCE INSTRUCTION BIT MAP (opcode = 3'b111)
    // ========================================================
    // Register-reference instructions don't address memory, so the low
    // 12 bits of the instruction word (which normally hold an address)
    // instead act as one-hot "which micro-op" flags. id_ex_addr already
    // carries those 12 bits into the execute stage for every opcode, so
    // we reuse it here for free instead of adding a new pipeline register.
    localparam RR_CLA = 11; // AC <- 0
    localparam RR_CLE = 10; // E  <- 0
    localparam RR_CMA = 9;  // AC <- AC' (one's complement)
    localparam RR_CME = 8;  // E  <- E'
    localparam RR_CIR = 7;  // Circular shift AC right through E
    localparam RR_CIL = 6;  // Circular shift AC left through E
    localparam RR_INC = 5;  // AC <- AC + 1
    localparam RR_SPA = 4;  // Skip next instr if AC positive    (subphase 1.3)
    localparam RR_SNA = 3;  // Skip next instr if AC negative    (subphase 1.3)
    localparam RR_SZA = 2;  // Skip next instr if AC is zero     (subphase 1.3)
    localparam RR_SZE = 1;  // Skip next instr if E is zero      (subphase 1.3)
    localparam RR_HLT = 0;  // Halt the machine                  (subphase 1.4)

    // ========================================================
    // HAZARD UNIT & ALU COMBINATORIAL LOGIC
    // ========================================================
    reg [15:0] next_ac;
    reg        next_e;
    reg        branch_taken;
    reg [11:0] branch_target;

    // Wire to calculate the ISZ increment immediately
    wire [15:0] isz_incremented = data_in + 16'b1;

    always @(*) begin
        branch_taken  = 1'b0;
        branch_target = 12'b0;
        next_ac       = ac; // Default to not changing AC
        next_e        = e;  // Default to not changing E

        case (id_ex_op)
            4'b0000: next_ac = id_ex_ac & data_in; // AND
            4'b0001: next_ac = id_ex_ac + data_in; // ADD
            4'b0010: next_ac = data_in;            // LDA

            4'b0111: begin                          // Register-reference group
                next_ac = id_ex_ac;                  // Default: hold AC unless a flag fires
                next_e  = id_ex_e;                    // Default: hold E unless a flag fires
                if (id_ex_addr[RR_CLA]) next_ac = 16'b0;            // CLA: clear AC
                if (id_ex_addr[RR_CMA]) next_ac = ~id_ex_ac;        // CMA: complement AC
                if (id_ex_addr[RR_INC]) next_ac = id_ex_ac + 16'b1; // INC: increment AC
                if (id_ex_addr[RR_CLE]) next_e  = 1'b0;             // CLE: clear E
                if (id_ex_addr[RR_CME]) next_e  = ~id_ex_e;         // CME: complement E
                if (id_ex_addr[RR_CIR]) begin
                    // CIR: rotate AC+E right one bit as a single 17-bit ring.
                    // Old E becomes the new top bit of AC; old AC[0] becomes the new E.
                    next_ac = {id_ex_e, id_ex_ac[15:1]};
                    next_e  = id_ex_ac[0];
                end
                if (id_ex_addr[RR_CIL]) begin
                    // CIL: rotate AC+E left one bit (mirror image of CIR).
                    // Old AC[15] becomes the new E; old E becomes the new bottom bit of AC.
                    next_ac = {id_ex_ac[14:0], id_ex_e};
                    next_e  = id_ex_ac[15];
                end
                // RR_SPA / RR_SNA / RR_SZA / RR_SZE handled in subphase 1.3 (control hazard)
                // RR_HLT                            handled in subphase 1.4 (halt state)
            end

            4'b0100: begin                         // BUN
                branch_taken  = 1'b1;
                branch_target = id_ex_addr;
            end
            4'b0101: begin                         // BSA
                branch_taken  = 1'b1;
                branch_target = id_ex_addr + 1'b1;
            end
            4'b0110: begin                         // ISZ (Increment and Skip if Zero)
                if (isz_incremented == 16'b0) begin
                    branch_taken  = 1'b1;
                    // Skip the NEXT instruction by jumping 2 spaces ahead of ISZ
                    branch_target = id_ex_pc + 12'd2;
                end
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
            e             <= 1'b0;
            if_id_ir      <= 16'b0;
            if_id_pc      <= 12'b0;
            id_ex_ac      <= 16'b0;
            id_ex_e       <= 1'b0;
            id_ex_op      <= 4'b0;
            id_ex_addr    <= 12'b0;
            id_ex_pc      <= 12'b0;
            data_addr     <= 12'b0;
            data_read_en  <= 1'b0;
            data_write_en <= 1'b0;
        end else if (branch_taken) begin
            // PIPELINE FLUSH for BUN, BSA, and ISZ skips
            pc            <= branch_target;
            if_id_ir      <= 16'b0;
            id_ex_op      <= 4'b0;
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
            id_ex_ac     <= next_ac;
            id_ex_e      <= next_e;
            id_ex_pc     <= if_id_pc;
            id_ex_op     <= if_id_ir[15:12]; // Note: Bit 15 is the I-bit. We isolate 14:12 in a full build.
            id_ex_addr   <= if_id_ir[11:0];
            data_addr    <= if_id_ir[11:0]; // Set up the READ address for whatever's just entering decode.
            data_read_en <= 1'b1;

            // ------------------------------------------------
            // STAGE 3: EXECUTE
            // ------------------------------------------------
            ac            <= next_ac;
            e             <= next_e;
            data_write_en <= 1'b0;

            // Handle Memory Writes (STA, BSA, ISZ)
            //
            // data_addr is re-driven here with id_ex_addr (this instruction's own
            // operand address) to override the read-setup assignment above (Stage 2
            // just pointed data_addr at the NEXT instruction). Without this, the
            // write would land at the wrong address since data_write_en/data_out
            // and this data_addr update all become visible on the same next cycle.
            if (id_ex_op == 4'b0011) begin      // STA
                data_addr     <= id_ex_addr;
                data_out      <= id_ex_ac;
                data_write_en <= 1'b1;
            end
            else if (id_ex_op == 4'b0101) begin // BSA
                data_addr     <= id_ex_addr;
                data_out      <= {4'b0000, id_ex_pc + 12'b1};
                data_write_en <= 1'b1;
            end
            else if (id_ex_op == 4'b0110) begin // ISZ
                // Write the incremented value back to memory regardless of whether we skip or not
                data_addr     <= id_ex_addr;
                data_out      <= isz_incremented;
                data_write_en <= 1'b1;
            end
        end
    end

endmodule