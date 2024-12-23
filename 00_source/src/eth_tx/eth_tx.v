//====================================================================
// 02_simple_ethernet
// eth_tx.v
// Ethernet RMII transmit module
// 7/4/24
//====================================================================

module eth_tx (
  input  wire         Clk,
  input  wire         Rst,
  output wire         Dat_Rdy,
  input  wire         Dat_En,
  input  wire  [7:0]  Data,
  input  wire         Data_Last,
  output wire  [1:0]  Tx_Data,
  output wire         Tx_En
);

  //==========================================
  // Constants
  //==========================================

  // number of parallel data lines to PHY
  parameter   pMII_WIDTH = 2;

  // data constants
  // format is little endian
  localparam pPreamble          = 56'h55555555555555; // 0101_0101 ... 7x, read out as 1010_1010 ...
  localparam pSFD               = 8'hD5;              // 1101_0101 ... read out as 1010_1011
  localparam pDest_Addr         = 48'hFFFFFFFFFFFF;   // broadcast address
  localparam pSrc_Addr          = 48'h020000000001;   // locally administered address for testing
  localparam pLen_Type          = 16'h0800;           // indicate IPV4

  //==========================================
  // Wires/Registers
  //==========================================

  reg  [3:0]  rCurr_State;
  reg         rTx_En;
  reg         rCtrl_Cnt_Rst;
  reg  [9:0]  rCtrl_Cnt;
  reg         rCtrl_Done;
  reg  [9:0]  rDat_Cnt; // count of how many data bytes were read out of FIFO
  reg  [2:0]  rPad_Delay;

  reg         rDat_Rdy;
  reg         rEth_En;
  wire [7:0]  wEth_Data_Out;
  reg         rFifo_Rd;
  reg         rFifo_Rd_d1;
  wire        wFifo_Empty;
  reg  [3:0]  rFifo_Empty;
  wire        wFifo_Full;

  reg  [55:0] rPreamble_Buf;
  reg  [7:0]  rSFD_Buf;
  reg  [47:0] rDest_Addr_Buf;
  reg  [47:0] rSrc_Addr_Buf;
  reg  [15:0] rLen_Type_Buf;
  reg  [7:0]  rPayload_Buf;
  reg  [7:0]  rPad_Buf;
  reg  [31:0] rFCS_Buf;

  reg  [1:0]  rTx_Data;

  reg         rCrc_En;
  reg         rCrc_En_d1;
  wire [31:0] wCrc;
  wire [31:0] wCrc_Swap;

  //==========================================
  // eth_data_fifo
  //==========================================
  // FIFO will store 1 byte at a time into an ethernet
  // packet that can store fixed # of data bytes

  sync_reset_fifo eth_data_fifo(
    .Clk      (Clk),
    .Rst      (Rst),
    .Wr_En    (Dat_En),
    .Rd_En    (rFifo_Rd),
    .Data     (Data),
    .q        (wEth_Data_Out),
    .empty    (wFifo_Empty),
    .full     (wFifo_Full)
  );

  // AXI-Stream Handler
  always @(posedge Clk)
  begin
    if (Rst) begin
      rEth_En <= 0;
      rDat_Rdy <= 0;
    end

    else begin

      // only allow new data in when not actively sending a packet
      if (~rEth_En)
        rDat_Rdy <= 1;

      // shut off data when tlast is receieved and enable packet to be sent
      if (Data_Last) begin
        rDat_Rdy <= 0;
        rEth_En <= 1;
      end

      // de-assert rEth_En
      if (rCtrl_Done)
        rEth_En <= 0;
    end
  end
  assign Dat_Rdy = rDat_Rdy;

  //==========================================
  // eth_data_buffer_regs
  //==========================================
  
  // muxes appropriate ethernet data based on FSM and stores
  // in register, shift right by pMII_WIDTH to make
  // LSBs avaliable first for eth_data_mux
  always @(posedge Clk)
  begin

    // update payload buffer
    if (rFifo_Rd_d1 == 1)
      rPayload_Buf <= wEth_Data_Out;
    rFifo_Rd_d1 <= rFifo_Rd;

    // update CRC buffer
    if (rCrc_En == 0 && rCrc_En_d1 == 1)
      rFCS_Buf <= wCrc_Swap;
    rCrc_En_d1 <= rCrc_En;

    case(rCurr_State)

      // prepare data for new packet, perform endianness swap
      // because data will be shifted out to the right

      // KEY:
      // ethernet ransmits data with the most significant byte first;
      // within each octet, however, the least significant bit is
      // transmitted first

      IDLE:
      begin
        rPreamble_Buf   <= {{pPreamble[7:0]},     {pPreamble[15:8]},
                            {pPreamble[23:16]},   {pPreamble[31:24]},
                            {pPreamble[39:32]},   {pPreamble[47:40]},
                            {pPreamble[55:48]}};
        rSFD_Buf        <= pSFD;
        rDest_Addr_Buf  <= {{pDest_Addr[7:0]},    {pDest_Addr[15:8]},
                            {pDest_Addr[23:16]},  {pDest_Addr[31:24]},
                            {pDest_Addr[39:32]},  {pDest_Addr[47:40]}};
        rSrc_Addr_Buf   <= {{pSrc_Addr[7:0]},     {pSrc_Addr[15:8]},
                            {pSrc_Addr[23:16]},   {pSrc_Addr[31:24]},
                            {pSrc_Addr[39:32]},   {pSrc_Addr[47:40]}};
        rLen_Type_Buf   <= {{pLen_Type[7:0]},     {pLen_Type[15:8]}};
        rPad_Buf        <= 0; // unused
      end

      PREAMBLE:
        rPreamble_Buf   <= rPreamble_Buf  >> pMII_WIDTH;
      
      SFD:
      begin
        rSFD_Buf        <= rSFD_Buf       >> pMII_WIDTH;   
      end
      
      DEST_ADDR:
      begin
        rDest_Addr_Buf  <= rDest_Addr_Buf >> pMII_WIDTH;
      end
      
      SRC_ADDR:
      begin
        rSrc_Addr_Buf   <= rSrc_Addr_Buf  >> pMII_WIDTH;
      end
      
      LEN_TYPE:
      begin
        rLen_Type_Buf   <= rLen_Type_Buf  >> pMII_WIDTH;
      end
      
      // read out only 1 byte at a time
      // bits are still shifted, then read next byte
      DATA:
      begin
        if (rFifo_Rd_d1 != 1)
          rPayload_Buf  <= rPayload_Buf   >> pMII_WIDTH;
      end
      
      PAD:
      begin
        rPad_Buf        <= rPad_Buf       >> pMII_WIDTH;
      end
      
      FCS:
      begin
        rFCS_Buf        <= rFCS_Buf       >> pMII_WIDTH;
      end

      default:
      begin
        rPreamble_Buf <= 0;
      end
    endcase
  end

  //==========================================
  // eth_data_mux
  //==========================================
  always @(*)
  begin
    case(rCurr_State)

      IDLE:
      begin
        rTx_Data = 0;
      end

      PREAMBLE:
      begin
        rTx_Data = rPreamble_Buf[pMII_WIDTH-1:0];
      end
      
      SFD:
      begin
        rTx_Data = rSFD_Buf[pMII_WIDTH-1:0]; 
      end
      
      DEST_ADDR:
      begin
        rTx_Data = rDest_Addr_Buf[pMII_WIDTH-1:0]; 
      end
      
      SRC_ADDR:
      begin
        rTx_Data = rSrc_Addr_Buf[pMII_WIDTH-1:0]; 
      end
      
      LEN_TYPE:
      begin
        rTx_Data = rLen_Type_Buf[pMII_WIDTH-1:0]; 
      end
      
      DATA:
      begin
        rTx_Data = rPayload_Buf[pMII_WIDTH-1:0]; 
      end
      
      PAD:
      begin
        rTx_Data = rPad_Buf[pMII_WIDTH-1:0]; 
      end
      
      FCS:
      begin
        rTx_Data = rFCS_Buf[pMII_WIDTH-1:0]; 
      end

      default:
        rTx_Data = 0;
      
    endcase
  end

  // output to top-level
  assign Tx_Data = rTx_Data;
  assign Tx_En   = rTx_En || rCtrl_Cnt_Rst;

  //==========================================
  // CRC Generator
  //==========================================
  crc_gen eth_crc_gen(
    .Clk      (Clk),
    .Rst      (Rst),
    .Crc_En   (rCrc_En),
    .Data     (rTx_Data),
    .Crc_Out  (wCrc)
  );
  assign wCrc_Swap = {{wCrc[7:0]},    {wCrc[15:8]},
                      {wCrc[23:16]},  {wCrc[31:24]}};
endmodule
