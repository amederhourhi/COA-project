// ============================================================
// Module      : alu
// Description : 16-bit ALU for Mano computer
//               Supports: ADD, AND, transfer DR, complement,
//               shift right, shift left + E handling
// ============================================================

module alu (
    input  wire [15:0] ac_in,        // Current AC value
    input  wire [15:0] dr_in,        // DR value
    input  wire        e_in,         // Current E value

    // Operation selects (from control unit)
    input  wire        op_add,       // AC ← AC + DR
    input  wire        op_and,       // AC ← AC ∧ DR
    input  wire        op_dr,        // AC ← DR
    input  wire        op_comp,      // AC ← ~AC
    input  wire        op_shr,       // Shift right
    input  wire        op_shl,       // Shift left

    output reg  [15:0] result,       // New AC value
    output reg         e_out         // New E value
);

    always @(*) begin
        // Default: hold values
        result = ac_in;
        e_out  = e_in;

        if (op_add) begin
            {e_out, result} = ac_in + dr_in;   // 17-bit addition
        end
        else if (op_and) begin
            result = ac_in & dr_in;
            e_out  = e_in;
        end
        else if (op_dr) begin
            result = dr_in;
            e_out  = e_in;
        end
        else if (op_comp) begin
            result = ~ac_in;
            e_out  = e_in;
        end
        else if (op_shr) begin
            e_out  = ac_in[0];                 // LSB goes to E
            result = {e_in, ac_in[15:1]};      // Shift right through E
        end
        else if (op_shl) begin
            e_out  = ac_in[15];                // MSB goes to E
            result = {ac_in[14:0], e_in};      // Shift left through E
        end
    end

endmodule