// ============================================================
// Module      : memory
// Description : 4096 x 16-bit asynchronous read, synchronous
//               write memory (Mano computer main memory)
// ============================================================

module memory (
    input  wire        clk,
    input  wire        write_enable,     // Mem_Write
    input  wire [11:0] address,          // Usually comes from AR[11:0]
    input  wire [15:0] data_in,
    output reg  [15:0] data_out
);

    // 4K memory
    reg [15:0] mem [0:4095];

    // Asynchronous read (common in educational designs)
    always @(*) begin
        data_out = mem[address];
    end

    // Synchronous write
    always @(posedge clk) begin
        if (write_enable) begin
            mem[address] <= data_in;
        end
    end

endmodule