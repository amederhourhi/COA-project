// ============================================================
// Module      : next_address_logic
// Description : Calculates the next address for CAR according
//               to the Sequencing field of the microinstruction.
// ============================================================

module next_address_logic (
    input  wire [3:0]  seq,              // Sequencing field (bits 11-8)
    input  wire [3:0]  cond_field,       // Condition select (bits 15-12)
    input  wire [7:0]  address_field,    // Address field (bits 7-0)
    input  wire [7:0]  car_current,      // Current CAR value
    input  wire [7:0]  map_address,      // From mapping logic

    // Status flags from datapath
    input  wire        AC_zero,
    input  wire        E,
    input  wire        AC_sign,

    output reg  [7:0]  next_car
);

    // Evaluate condition
    reg condition_met;

    always @(*) begin
        case (cond_field)
            4'b0000: condition_met = 1'b1;           // ALWAYS
            4'b0001: condition_met = AC_zero;        // AC == 0
            4'b0010: condition_met = E;              // E == 1
            4'b0011: condition_met = AC_sign;        // AC < 0 (example)
            default: condition_met = 1'b0;
        endcase
    end

    // Decide next address
    always @(*) begin
        case (seq)
            4'b0000: next_car = car_current + 8'd1;          // CONT  (Continue)
            4'b0001: next_car = address_field;               // JUMP
            4'b0010: next_car = condition_met ? address_field : (car_current + 8'd1); // JMPIF
            4'b0011: next_car = map_address;                 // MAP
            default: next_car = car_current + 8'd1;
        endcase
    end

endmodule