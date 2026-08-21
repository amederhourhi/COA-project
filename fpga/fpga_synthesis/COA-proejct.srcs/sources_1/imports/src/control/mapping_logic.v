// ============================================================
// Module      : mapping_logic
// Description : Maps the 3-bit opcode from IR to the starting
//               microaddress of the corresponding execute routine.
// ============================================================

module mapping_logic (
    input  wire [2:0]  opcode,           // IR[14:12]
    output reg  [7:0]  micro_address
);

    always @(*) begin
        case (opcode)
            3'b000: micro_address = 8'h10;   // AND
            3'b001: micro_address = 8'h18;   // ADD
            3'b010: micro_address = 8'h20;   // LDA
            3'b011: micro_address = 8'h28;   // STA
            3'b100: micro_address = 8'h30;   // BUN
            3'b101: micro_address = 8'h38;   // BSA
            3'b110: micro_address = 8'h40;   // ISZ
            3'b111: micro_address = 8'h48;   // Register-ref / I/O
            default: micro_address = 8'h00;
        endcase
    end

endmodule