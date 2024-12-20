//====================================================================
// simpleEthernet
// eth_rx.v
// Ethernet RMII receive module
// 12/10/24
//====================================================================

module eth_rx (
  input wire        Clk,
  input wire        Rst,
  input wire [1:0]  Rxd,
  output wire       Rx_Req, // placeholder, output required
  output wire       Crc_Valid
);

  //==========================================
  // Constants
  //==========================================

  // number of parallel data lines to PHY
  localparam pMII_WIDTH = 2;

  //==========================================
  // Wires/Registers
  //==========================================

  // byte formation
  wire            wRx_Req;
  wire            wByte_Rdy;
  wire [7:0]      wByte_Rx;
  reg  [7:0]      rByte_Rx;
  reg  [1:0]      rBit_Cnt;

  // formed bytes
  reg             rByte_Rdy;
  reg             rByte_Rdy_d1;
  reg  [7:0]      rByte;
  reg  [7:0]      rByte_d1;

  // crc
  wire            wCrc_En;
  wire            wCrc_Req;
  wire [31:0]     wCrc;
  reg  [31:0]     rCrc_Recv;

  //==========================================
  // eth_rx_ctrl
  //==========================================

  assign Rx_Req = wRx_Req;
  eth_rx_ctrl eth_rx_ctrl_inst (
    .Clk            (Clk),
    .Rst            (Rst),
    .Rxd            (Rxd),
    .Byte_Rdy       (rByte_Rdy),
    .Byte           (rByte),
    .Crc_Recv       (rCrc_Recv),
    .Rx_En          (wRx_Req),
    .Crc_En         (wCrc_Req),
    .Crc_Valid      (Crc_Valid)
  );

  //==========================================
  // byte_rx
  //==========================================
  // big-endian BYTE order, BITS enter with LSB first

  // form bytes when past PREAMBLE
  assign wByte_Rx = {Rxd, rByte_Rx[5:0]};
  always @(posedge Clk)
  begin
    if (wRx_Req)
      rByte_Rx <= wByte_Rx >> pMII_WIDTH;
  end

  // indicate when formed byte is valid
  assign wByte_Rdy = rBit_Cnt[1] & rBit_Cnt[0];
  always @(posedge Clk)
  begin
    if (wRx_Req)
      rBit_Cnt <= rBit_Cnt + 1;
    else
      rBit_Cnt <= 0;
  end

  // rx output register
  always @(posedge Clk)
  begin
    rByte_Rdy <= wByte_Rdy;
    if (wByte_Rdy & wRx_Req)
      rByte <= wByte_Rx;
  end

  //==========================================
  // crc
  //==========================================

  // pipeline data for crc
  always @(posedge Clk)
  begin
    rByte_Rdy_d1 <= rByte_Rdy;
    rByte_d1 <= rByte;
  end

  assign wCrc_En = rByte_Rdy_d1 & wCrc_Req; // only update when a byte is ready
  eth_crc_gen2 eth_crc_gen2_inst (
    .Clk      (Clk),
    .Rst      (Rst),
    .Crc_En   (wCrc_En),
    .Data     (rByte_d1),
    .Crc_Out  (wCrc)
  );

  always @(posedge Clk)
  begin
    if (wCrc_En) begin
      rCrc_Recv <= wCrc;
    end
  end

endmodule
