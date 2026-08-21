// ============================================================
// Module      : memory
// Description : 4096 x 16-bit main memory for the Mano computer.
//               - Asynchronous read (combinational): whatever
//                 address is on AR[11:0] appears on data_out
//                 immediately, matching the classic Mano design.
//               - Synchronous write: data is written on the
//                 rising clock edge when write_enable is high.
//
// Hardware program loading:
//   INIT_FILE is a parameter (a compile-time string) that points
//   to a plain-text hex file (one 16-bit hex value per line).
//   - In simulation, if you leave INIT_FILE empty (""), memory
//     starts as all zeros and your testbench can force-load
//     values manually, exactly like it does today.
//   - On the FPGA, Vivado reads INIT_FILE at synthesis time and
//     bakes those values directly into the Block RAM, so the
//     program is already sitting in memory the instant the
//     board powers on -- no manual loading hardware required.
// ============================================================

module memory #(
    parameter INIT_FILE = ""          // Path to .mem file, or "" for blank memory
)(
    input  wire        clk,
    input  wire        write_enable,     // Mem_Write
    input  wire [11:0] address,          // Usually comes from AR[11:0]
    input  wire [15:0] data_in,
    output reg  [15:0] data_out
);

    // 4K memory, 16 bits wide
    reg [15:0] mem [0:4095];

    // ---- One-time load at power-up / simulation start ----
    // $readmemh expects a text file where each line is a hex
    // number (e.g. "2005"), loaded in order starting at mem[0].
    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    // ---- Asynchronous read ----
    // Combinational: output tracks the address with no clock delay.
    // (Common in educational CPU designs; keeps the microprogram
    // simple because a memory read doesn't need an extra wait state.)
    always @(*) begin
        data_out = mem[address];
    end

    // ---- Synchronous write ----
    // Only happens on a clock edge when the control unit asserts
    // Mem_Write, e.g. during STA or BSA microinstructions.
    always @(posedge clk) begin
        if (write_enable) begin
            mem[address] <= data_in;
        end
    end

endmodule