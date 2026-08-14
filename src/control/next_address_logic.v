// ============================================================
// Module      : next_address_logic
// Description : Next address calculation (compatible with µIR)
// ============================================================

module next_address_logic (
    input  wire [3:0]  seq,
    input  wire [3:0]  cond_field,
    input  wire [7:0]  address_field,
    input  wire [7:0]  car_current,
    input  wire [7:0]  map_address,

    input  wire        AC_zero,
    input  wire        E,
    input  wire        AC_sign,

    output reg  [7:0]  next_car
);

    reg condition_met;

    always @(*) begin
        case (cond_field)
            4'b0000: condition_met = 1'b1;          // ALWAYS
            4'b0001: condition_met = AC_zero;
            4'b0010: condition_met = E;
            4'b0011: condition_met = AC_sign;
            default: condition_met = 1'b0;
        endcase
    end

    always @(*) begin
        case (seq)
            4'b0000: next_car = car_current + 8'd1;                 // CONT
            4'b0001: next_car = address_field;                      // JUMP
            4'b0010: next_car = condition_met ? address_field 
                                              : (car_current + 8'd1); // JMPIF
            4'b0011: next_car = map_address;                        // MAP
            default: next_car = 8'h00;                              // safe default → Fetch
        endcase
    end

endmodule