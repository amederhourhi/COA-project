// ------------------------------------------------------------------
// Module: hazard_unit
// Description: Detects structural and control hazards for Mano pipeline
// ------------------------------------------------------------------
module hazard_unit (
    input  wire [3:0] if_id_op,     // Opcode currently in Decode
    input  wire [3:0] id_ex_op,     // Opcode currently in Execute
    input  wire       branch_taken, // Flag from Execute stage

    output reg        stall,
    output reg        flush
);

    always @(*) begin
        stall = 1'b0;
        flush = 1'b0;

        // 1. Control Hazard (Branching)
        // If Execute takes a branch, we must flush the wrong instructions 
        // that were fetched into the IF and ID stages.
        if (branch_taken) begin
            flush = 1'b1;
        end
        // 2. Structural Hazard (Memory Port Collision)
        // If Execute is writing to memory (STA, BSA, ISZ), it needs the address port.
        // If Decode is trying to read from memory in the same cycle (AND, ADD, LDA, ISZ),
        // Decode must stall for one cycle until Execute releases the port.
        else if ( (id_ex_op == 4'b0011 || id_ex_op == 4'b0101 || id_ex_op == 4'b0110) && 
                  (if_id_op == 4'b0000 || if_id_op == 4'b0001 || if_id_op == 4'b0010 || if_id_op == 4'b0110) ) begin
            stall = 1'b1;
        end
    end

endmodule