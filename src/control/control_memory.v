// ============================================================
// Module      : control_memory
// Description : 256 x 32-bit ROM that stores the microprogram.
//               This is the heart of the microprogrammed control.
// ============================================================

module control_memory (
    input  wire [7:0]  address,      // Comes from CAR
    output reg  [31:0] microinstruction
);

    // Microprogram storage
    reg [31:0] rom [0:255];

    // Initialize the ROM with our microprogram
    // (For now we put a few key entries. We will fill the complete
    //  microprogram in the next step)
    initial begin
        // Default: all zeros
        integer i;
        for (i = 0; i < 256; i = i + 1)
            rom[i] = 32'h0000_0000;

        // ========== FETCH CYCLE ==========
        // 0x00 : AR ← PC
        rom[8'h00] = 32'b0010_0000_0000_0000_0000_0000_0000_0000; // temporary encoding

        // 0x01 : IR ← M[AR], PC ← PC+1
        rom[8'h01] = 32'b1000_0100_0100_0000_0000_0000_0000_0000;

        // 0x02 : AR ← IR address part
        rom[8'h02] = 32'b0010_0000_0000_0000_0000_0000_0000_0000;

        // 0x03 : MAP
        rom[8'h03] = 32'b0000_0000_0000_0000_0000_0011_0000_0000; // Seq = MAP

        // We will replace these temporary values with the real
        // encoded microinstructions in the next step.
    end

    // Asynchronous read
    always @(*) begin
        microinstruction = rom[address];
    end

endmodule