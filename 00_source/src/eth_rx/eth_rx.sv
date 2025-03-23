//--------------------------------------------------------------------
// simpleEthernet
// eth_rx.sv
// Ethernet RMII receive module
// 12/10/24
//--------------------------------------------------------------------

module eth_rx (
  input  logic       Clk,
  input  logic       Rst,
  input  logic       Crs_Dv,
  input  logic [1:0] Rxd,
  output logic [7:0] Recv_Byte,
  output logic       Recv_Byte_Rdy,
  output logic       Crc_Valid,
  output logic       EtherType_Valid
);

  //------------------------------------------
  // Constants
  //------------------------------------------

  // number of parallel data lines to PHY
  localparam pMII_WIDTH = 2;

  //------------------------------------------
  // Logic
  //------------------------------------------

  // byte formation
  logic       wRx_Req;
  logic       wByte_Rdy;
  logic [7:0] wByte_Rx;
  logic [7:0] rByte_Rx;
  logic [1:0] rBit_Cnt;

  // formed bytes
  logic       rByte_Rdy;
  logic       rByte_Rdy_d1;
  logic [7:0] rByte;
  logic [7:0] rByte_d1;

  // output bytes
  logic [7:0]  rRecv_Byte;
  logic [7:0]  rRecv_Byte_d1;
  logic [7:0]  rRecv_Byte_d2;
  logic [7:0]  rRecv_Byte_d3;
  logic [7:0]  rRecv_Byte_d4;
  logic [16:0] rRecv_Byte_Rdy;

  // crc
  logic        wCrc_En;
  logic        wCrc_Req;
  logic [31:0] wCrc_Out;
  logic [31:0] rCrc_Computed;
  logic [31:0] rCrc_Computed_d1;
  logic [31:0] rCrc_Computed_d2;
  logic [31:0] rCrc_Computed_d3;

  //------------------------------------------
  // eth_rx_ctrl
  //------------------------------------------
  eth_rx_ctrl eth_rx_ctrl_inst (
    .Clk             (Clk),
    .Rst             (Rst),
    .Crs_Dv          (Crs_Dv),
    .Rxd             (Rxd),
    .Byte_Rdy        (rByte_Rdy),
    .Byte            (rByte),
    .Crc_Computed    (rCrc_Computed_d3),
    .Rx_En           (wRx_Req),
    .Crc_En          (wCrc_Req),
    .Crc_Valid       (Crc_Valid),
    .EtherType_Valid (EtherType_Valid)
  );

  //------------------------------------------
  // byte_rx
  //------------------------------------------
  // big-endian byte order, bits enter with LSB first

  // form bytes when past PREAMBLE
  assign wByte_Rx = {Rxd, rByte_Rx[5:0]};
  always @(posedge Clk)
  begin
    if (wRx_Req & Crs_Dv)
      rByte_Rx <= wByte_Rx >> pMII_WIDTH;
  end

  // indicate when formed byte is valid
  assign wByte_Rdy = rBit_Cnt[1] & rBit_Cnt[0];
  always @(posedge Clk)
  begin
    if (wRx_Req & Crs_Dv)
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

  //------------------------------------------
  // crc
  //------------------------------------------

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

  //------------------------------------------
  // data output
  //------------------------------------------
  
  // pipeline the data for output
  always @(posedge Clk)
  begin
    if (rByte_Rdy) begin
      rRecv_Byte <= rByte;
      rRecv_Byte_d1 <= rRecv_Byte;
      rRecv_Byte_d2 <= rRecv_Byte_d1;
      rRecv_Byte_d3 <= rRecv_Byte_d2;
      rRecv_Byte_d4 <= rRecv_Byte_d3;
    end
  end

  // pipeline the byte ready signal
  always @(posedge Clk)
  begin
    if (rByte_Rdy)
      rRecv_Byte_Rdy <= {rRecv_Byte_Rdy[15:0], rByte_Rdy};
    else
      rRecv_Byte_Rdy <= {rRecv_Byte_Rdy[15:0], 1'b0};
  end

  assign Recv_Byte = rRecv_Byte_d4;
  assign Recv_Byte_Rdy = rRecv_Byte_Rdy[16] & rRecv_Byte_Rdy[0];

endmodule
