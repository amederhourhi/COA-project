// ============================================================
// Module      : control_memory
// Description : Corrected microprogram - AC_Load only where needed
// ============================================================

module control_memory (
    input  wire [7:0]  address,
    output reg  [31:0] microinstruction
);

    reg [31:0] rom [0:255];

    // Encoding reminder (bits 31→16):
    // 31 AR_Load | 30 AR_Inc | 29 PC_Load | 28 PC_Inc
    // 27 DR_Load | 26 AC_Load | 25 IR_Load | 24 Mem_Write
    // 23 ALU_Add | 22 ALU_And | 21 ALU_DR
    // 20-18 Bus_Select (111 = Memory, 010 = PC, 101 = IR, 100 = AC, 001 = AR)

    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            rom[i] = 32'h0000_0000;

        // ==================== FETCH ====================
        // 0x00: Bus ← PC, AR ← Bus
        rom[8'h00] = 32'b1000_0000_0000_1000_0000_0000_0000_0000; // AR_Load + Bus=PC

        // 0x01: Bus ← Mem, IR ← Bus, PC++
        rom[8'h01] = 32'b0001_0010_0001_1100_0000_0000_0000_0000; // IR_Load + PC_Inc + Bus=Mem

        // 0x02: Bus ← IR, AR ← Bus
        rom[8'h02] = 32'b1000_0000_0001_0100_0000_0000_0000_0000; // AR_Load + Bus=IR

        // 0x03: MAP
        rom[8'h03] = 32'b0000_0000_0000_0000_0000_0011_0000_0000;

        // ==================== AND ====================
        // 0x10: DR ← M[AR]          (NO AC_Load)
        rom[8'h10] = 32'b0000_1000_0001_1100_0000_0000_0000_0000; // DR_Load + Bus=Mem
        // 0x11: AC ← AC ∧ DR, JUMP 0
        rom[8'h11] = 32'b0000_0100_0100_0000_0000_0001_0000_0000; // AC_Load + ALU_And + JUMP

        // ==================== ADD ====================
        // 0x18: DR ← M[AR]          (NO AC_Load)
        rom[8'h18] = 32'b0000_1000_0001_1100_0000_0000_0000_0000; // DR_Load + Bus=Mem
        // 0x19: AC ← AC + DR, JUMP 0
        rom[8'h19] = 32'b0000_0100_1000_0000_0000_0001_0000_0000; // AC_Load + ALU_Add + JUMP

        // ==================== LDA ====================
        // 0x20: DR ← M[AR]          (NO AC_Load)
        rom[8'h20] = 32'b0000_1000_0001_1100_0000_0000_0000_0000; // DR_Load + Bus=Mem
        // 0x21: AC ← DR, JUMP 0
        rom[8'h21] = 32'b0000_0100_0010_0000_0000_0001_0000_0000; // AC_Load + ALU_DR + JUMP

        // ==================== STA ====================
        // 0x28: Bus ← AC, Mem_Write, JUMP 0
        rom[8'h28] = 32'b0000_0001_0001_0000_0000_0001_0000_0000; // Mem_Write + Bus=AC + JUMP

        // ==================== BUN ====================
        // 0x30: Bus ← AR, PC ← Bus, JUMP 0
        rom[8'h30] = 32'b0010_0000_0000_0100_0000_0001_0000_0000; // PC_Load + Bus=AR + JUMP
    end

    always @(*) begin
        microinstruction = rom[address];
    end

endmodule