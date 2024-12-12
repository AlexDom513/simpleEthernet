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
  input wire        Crs_DV
);

  //==========================================
  // Constants
  //==========================================

  // number of parallel data lines to PHY
  localparam pMII_WIDTH = 2;

  // shift to convert bytes to bits
  localparam pBytes_To_Bits = 3;

  // byte counts
  localparam pDest_Addr_Bytes  = 8'h6;
  localparam pSrc_Addr_Bytes   = 8'h6;
  localparam pLen_Type_Bytes   = 8'h2;

  // bit counts
  localparam pDest_Addr_Bits  = pDest_Addr_Bytes << pBytes_To_Bits;
  localparam pSrc_Addr_Bits   = pSrc_Addr_Bytes << pBytes_To_Bits;
  localparam pLen_Type_Bits   = pLen_Type_Bytes << pBytes_To_Bits;

  // serial counts 
  // # iterations to process incoming data given some MII width
  localparam pDest_Addr_Cnt    = pDest_Addr_Bits >> (pMII_WIDTH >> 1);
  localparam pSrc_Addr_Cnt     = pSrc_Addr_Bits >> (pMII_WIDTH >> 1);
  localparam pLen_Type_Cnt     = pLen_Type_Bits >> (pMII_WIDTH >> 1);

  // eth_rx_fsm
  localparam  IDLE              = 3'h0;
  localparam  PREAMBLE          = 3'h1;
  localparam  DEST_ADDR         = 3'h2;
  localparam  SRC_ADDR          = 3'h3;
  localparam  LEN_TYPE          = 3'h4;
  // localparam  DATA              = 4'h6;
  // localparam  PAD               = 4'h7;
  // localparam  FCS               = 4'h8;

  //==========================================
  // Wires/Registers
  //==========================================

  // eth_rx_fsm
  reg [2:0]     rCurr_State;
  reg [7:0]     rCtrl_Cnt;

  // byte_packer
  //reg [1:0]     rRxd;
  reg [1:0]     rBit_Cnt;
  wire          wByte_Rdy;
  reg [7:0]     rByte_Rx;
  wire [7:0]    wByte_Rx;

  //==========================================
  // eth_rx_fsm
  //==========================================
  always @(posedge Clk)
  begin
    if (Rst) begin
      rCtrl_Cnt <= 0;
      rCurr_State <= IDLE;
    end
    else begin

      case(rCurr_State)

      //================
      // IDLE (0)
      //================
      IDLE:
      begin
        rCtrl_Cnt <= 0;
        if (Rxd == 2'b01)
          rCurr_State <= PREAMBLE;
      end

      //================
      // PREAMBLE (1)
      //================
      PREAMBLE:
      begin
        if (Rxd == 2'b11)
          rCurr_State <= DEST_ADDR;
      end

      //================
      // DEST_ADDR (2)
      //================
      DEST_ADDR:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;
        if (rCtrl_Cnt == pDest_Addr_Cnt-1) begin
          rCtrl_Cnt <= 0;
          rCurr_State <= SRC_ADDR;
        end
      end

      //================
      // SRC_ADDR (3)
      //================
      SRC_ADDR:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;
        if (rCtrl_Cnt == pSrc_Addr_Cnt-1) begin
          rCtrl_Cnt <= 0;
          rCurr_State <= LEN_TYPE;
        end
      end

      //================
      // LEN_TYPE (5)
      //================
      LEN_TYPE:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;
        if (rCtrl_Cnt == pLen_Type_Cnt-1) begin
          rCtrl_Cnt <= 0;
          rCurr_State <= IDLE;
        end
      end

      default:
        rCurr_State <= IDLE;

      endcase
    end
  end

  //==========================================
  // byte_rx
  //==========================================

  // // pipeline input
  // always @(posedge Clk)
  // begin
  //   rRxd <= Rxd;
  // end

  // form bytes when past PREAMBLE
  always @(posedge Clk)
  begin
    if (Rst)
      rByte_Rx <= 0;
    else begin
      if (rCurr_State > PREAMBLE) begin
        rByte_Rx <= wByte_Rx >> pMII_WIDTH;
      end
    end
  end
  //assign wByte_Rx = {rByte_Rx[7:2], Rxd};
  assign wByte_Rx = {Rxd, rByte_Rx[5:0]};

  // indicate when formed byte is valid
  always @(posedge Clk)
  begin
    if (rCurr_State > PREAMBLE)
      rBit_Cnt <= rBit_Cnt + 1;
  end
  assign wByte_Rdy = rBit_Cnt[1] & rBit_Cnt[0];


endmodule
