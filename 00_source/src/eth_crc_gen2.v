// vim: ts=4 sw=4 expandtab

// THIS IS GENERATED VERILOG CODE.
// https://bues.ch/h/crcgen
// 
// This code is Public Domain.
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
// RESULTING FROM LOSS OF USE, Data OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.

// crc polynomial coefficients: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
//                              0xEDB88320 (hex)
// crc width:                   32 bits
// crc shift direction:         right (little endian)
// Input word width:            8 bits

module eth_crc_gen2 (
  input         Clk,
  input         Rst,
  input         Crc_En,
  input [7:0]   Data,
  output [31:0] Crc_Out
);

  wire [31:0] Lfsr_C; // combinational output
  reg [31:0]  Lfsr_Q; // previously combinational output

  always @(posedge Clk)
  begin
    if (Rst)
      Lfsr_Q <= 32'hFFFFFFFF;
    else begin
      if (Crc_En)
        Lfsr_Q <= Lfsr_C;
      // else
      //   Lfsr_Q <= 32'hFFFFFFFF;
    end
  end

  // post complement
  assign Crc_Out = Lfsr_C ^ 32'hFFFFFFFF;

  assign Lfsr_C[0] = Lfsr_Q[2] ^ Lfsr_Q[8] ^ Data[2];
  assign Lfsr_C[1] = Lfsr_Q[0] ^ Lfsr_Q[3] ^ Lfsr_Q[9] ^ Data[0] ^ Data[3];
  assign Lfsr_C[2] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[4] ^ Lfsr_Q[10] ^ Data[0] ^ Data[1] ^ Data[4];
  assign Lfsr_C[3] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[5] ^ Lfsr_Q[11] ^ Data[1] ^ Data[2] ^ Data[5];
  assign Lfsr_C[4] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[6] ^ Lfsr_Q[12] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[6];
  assign Lfsr_C[5] = Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[7] ^ Lfsr_Q[13] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[7];
  assign Lfsr_C[6] = Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[14] ^ Data[4] ^ Data[5];
  assign Lfsr_C[7] = Lfsr_Q[0] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[15] ^ Data[0] ^ Data[5] ^ Data[6];
  assign Lfsr_C[8] = Lfsr_Q[1] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[16] ^ Data[1] ^ Data[6] ^ Data[7];
  assign Lfsr_C[9] = Lfsr_Q[7] ^ Lfsr_Q[17] ^ Data[7];
  assign Lfsr_C[10] = Lfsr_Q[2] ^ Lfsr_Q[18] ^ Data[2];
  assign Lfsr_C[11] = Lfsr_Q[3] ^ Lfsr_Q[19] ^ Data[3];
  assign Lfsr_C[12] = Lfsr_Q[0] ^ Lfsr_Q[4] ^ Lfsr_Q[20] ^ Data[0] ^ Data[4];
  assign Lfsr_C[13] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[5] ^ Lfsr_Q[21] ^ Data[0] ^ Data[1] ^ Data[5];
  assign Lfsr_C[14] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[6] ^ Lfsr_Q[22] ^ Data[1] ^ Data[2] ^ Data[6];
  assign Lfsr_C[15] = Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[7] ^ Lfsr_Q[23] ^ Data[2] ^ Data[3] ^ Data[7];
  assign Lfsr_C[16] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[24] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[4];
  assign Lfsr_C[17] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[25] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[5];
  assign Lfsr_C[18] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[26] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6];
  assign Lfsr_C[19] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[27] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6] ^ Data[7];
  assign Lfsr_C[20] = Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[28] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7];
  assign Lfsr_C[21] = Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Lfsr_Q[29] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[7];
  assign Lfsr_C[22] = Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[30] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6];
  assign Lfsr_C[23] = Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[31] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7];
  assign Lfsr_C[24] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Data[0] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[7];
  assign Lfsr_C[25] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6];
  assign Lfsr_C[26] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7];
  assign Lfsr_C[27] = Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[7];
  assign Lfsr_C[28] = Lfsr_Q[0] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Data[0] ^ Data[4] ^ Data[5] ^ Data[6];
  assign Lfsr_C[29] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Data[0] ^ Data[1] ^ Data[5] ^ Data[6] ^ Data[7];
  assign Lfsr_C[30] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Data[0] ^ Data[1] ^ Data[6] ^ Data[7];
  assign Lfsr_C[31] = Lfsr_Q[1] ^ Lfsr_Q[7] ^ Data[1] ^ Data[7];

endmodule
