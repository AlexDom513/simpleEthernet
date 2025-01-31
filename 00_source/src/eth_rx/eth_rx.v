//====================================================================
// simpleEthernet
// eth_rx.v
// Ethernet RMII receive module
// 12/10/24
//====================================================================

module eth_rx (
  input wire        Clk,
  input wire        Rst,
  input wire        Crs_Dv,
  input wire [1:0]  Rxd,
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
  wire [31:0]     wCrc_Out;
  reg  [31:0]     rCrc_Computed;
  reg  [31:0]     rCrc_Computed_d1;
  reg  [31:0]     rCrc_Computed_d2;
  reg  [31:0]     rCrc_Computed_d3;

  //==========================================
  // eth_rx_ctrl
  //==========================================
  eth_rx_ctrl eth_rx_ctrl_inst (
    .Clk            (Clk),
    .Rst            (Rst),
    .Crs_Dv         (Crs_Dv),
    .Rxd            (Rxd),
    .Byte_Rdy       (rByte_Rdy),
    .Byte           (rByte),
    .Crc_Computed   (rCrc_Computed_d3),
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

  eth_crc_gen eth_crc_gen_inst (
    .Clk      (Clk),
    .Rst      (Rst),
    .Crc_Req  (wCrc_Req),
    .Byte_Rdy (rByte_Rdy_d1),
    .Byte     (rByte_d1),
    .Crc_Out  (wCrc_Out)
  );

  // only update rCrc_Computed when byte is ready
  assign wCrc_En = rByte_Rdy_d1 & wCrc_Req;
  always @(posedge Clk)
  begin
    if (wCrc_En) begin
      rCrc_Computed <= wCrc_Out;
      rCrc_Computed_d1 <= rCrc_Computed;
      rCrc_Computed_d2 <= rCrc_Computed_d1;
      rCrc_Computed_d3 <= rCrc_Computed_d2;
    end
  end

endmodule
