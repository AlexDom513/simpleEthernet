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
// RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.

// crc polynomial coefficients: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
//                              0xEDB88320 (hex)
// crc width:                   32 bits
// crc shift direction:         right (little endian)
// Input word width:            8 bits

module eth_crc_gen (
  input         Clk,
  input         Rst,
  input         Crc_Req,
  input         Byte_Rdy,
  input [7:0]   Byte,
  output [31:0] Crc_Out
);

  wire [31:0] Lfsr_C; // combinational output
  reg [31:0]  Lfsr_Q; // previously combinational output

  always @(posedge Clk)
  begin
    if (Rst)
      Lfsr_Q <= 32'hFFFFFFFF;
    else begin
      if (Crc_Req) begin
        if (Byte_Rdy)
          Lfsr_Q <= Lfsr_C;
      end
      else
        Lfsr_Q <= 32'hFFFFFFFF;
    end
  end

  // post complement
  assign Crc_Out = Lfsr_C ^ 32'hFFFFFFFF;

  assign Lfsr_C[0] = Lfsr_Q[2] ^ Lfsr_Q[8] ^ Byte[2];
  assign Lfsr_C[1] = Lfsr_Q[0] ^ Lfsr_Q[3] ^ Lfsr_Q[9] ^ Byte[0] ^ Byte[3];
  assign Lfsr_C[2] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[4] ^ Lfsr_Q[10] ^ Byte[0] ^ Byte[1] ^ Byte[4];
  assign Lfsr_C[3] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[5] ^ Lfsr_Q[11] ^ Byte[1] ^ Byte[2] ^ Byte[5];
  assign Lfsr_C[4] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[6] ^ Lfsr_Q[12] ^ Byte[0] ^ Byte[2] ^ Byte[3] ^ Byte[6];
  assign Lfsr_C[5] = Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[7] ^ Lfsr_Q[13] ^ Byte[1] ^ Byte[3] ^ Byte[4] ^ Byte[7];
  assign Lfsr_C[6] = Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[14] ^ Byte[4] ^ Byte[5];
  assign Lfsr_C[7] = Lfsr_Q[0] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[15] ^ Byte[0] ^ Byte[5] ^ Byte[6];
  assign Lfsr_C[8] = Lfsr_Q[1] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[16] ^ Byte[1] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[9] = Lfsr_Q[7] ^ Lfsr_Q[17] ^ Byte[7];
  assign Lfsr_C[10] = Lfsr_Q[2] ^ Lfsr_Q[18] ^ Byte[2];
  assign Lfsr_C[11] = Lfsr_Q[3] ^ Lfsr_Q[19] ^ Byte[3];
  assign Lfsr_C[12] = Lfsr_Q[0] ^ Lfsr_Q[4] ^ Lfsr_Q[20] ^ Byte[0] ^ Byte[4];
  assign Lfsr_C[13] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[5] ^ Lfsr_Q[21] ^ Byte[0] ^ Byte[1] ^ Byte[5];
  assign Lfsr_C[14] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[6] ^ Lfsr_Q[22] ^ Byte[1] ^ Byte[2] ^ Byte[6];
  assign Lfsr_C[15] = Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[7] ^ Lfsr_Q[23] ^ Byte[2] ^ Byte[3] ^ Byte[7];
  assign Lfsr_C[16] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[24] ^ Byte[0] ^ Byte[2] ^ Byte[3] ^ Byte[4];
  assign Lfsr_C[17] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[25] ^ Byte[0] ^ Byte[1] ^ Byte[3] ^ Byte[4] ^ Byte[5];
  assign Lfsr_C[18] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[26] ^ Byte[0] ^ Byte[1] ^ Byte[2] ^ Byte[4] ^ Byte[5] ^ Byte[6];
  assign Lfsr_C[19] = Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[27] ^ Byte[1] ^ Byte[2] ^ Byte[3] ^ Byte[5] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[20] = Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[28] ^ Byte[3] ^ Byte[4] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[21] = Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Lfsr_Q[29] ^ Byte[2] ^ Byte[4] ^ Byte[5] ^ Byte[7];
  assign Lfsr_C[22] = Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[30] ^ Byte[2] ^ Byte[3] ^ Byte[5] ^ Byte[6];
  assign Lfsr_C[23] = Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Lfsr_Q[31] ^ Byte[3] ^ Byte[4] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[24] = Lfsr_Q[0] ^ Lfsr_Q[2] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Byte[0] ^ Byte[2] ^ Byte[4] ^ Byte[5] ^ Byte[7];
  assign Lfsr_C[25] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Byte[0] ^ Byte[1] ^ Byte[2] ^ Byte[3] ^ Byte[5] ^ Byte[6];
  assign Lfsr_C[26] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[2] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Byte[0] ^ Byte[1] ^ Byte[2] ^ Byte[3] ^ Byte[4] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[27] = Lfsr_Q[1] ^ Lfsr_Q[3] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[7] ^ Byte[1] ^ Byte[3] ^ Byte[4] ^ Byte[5] ^ Byte[7];
  assign Lfsr_C[28] = Lfsr_Q[0] ^ Lfsr_Q[4] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Byte[0] ^ Byte[4] ^ Byte[5] ^ Byte[6];
  assign Lfsr_C[29] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[5] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Byte[0] ^ Byte[1] ^ Byte[5] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[30] = Lfsr_Q[0] ^ Lfsr_Q[1] ^ Lfsr_Q[6] ^ Lfsr_Q[7] ^ Byte[0] ^ Byte[1] ^ Byte[6] ^ Byte[7];
  assign Lfsr_C[31] = Lfsr_Q[1] ^ Lfsr_Q[7] ^ Byte[1] ^ Byte[7];

endmodule
