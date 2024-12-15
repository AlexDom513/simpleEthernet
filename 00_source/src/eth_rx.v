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
  localparam pDest_Addr_Bytes   = 8'h6;
  localparam pSrc_Addr_Bytes    = 8'h6;
  localparam pLen_Type_Bytes    = 8'h2;
  localparam pPayload_Len_Bytes = 8'h4;
  localparam pFCS_Len_Bytes     = 8'h4;

  // bit counts
  localparam pDest_Addr_Bits    = pDest_Addr_Bytes << pBytes_To_Bits;
  localparam pSrc_Addr_Bits     = pSrc_Addr_Bytes << pBytes_To_Bits;
  localparam pLen_Type_Bits     = pLen_Type_Bytes << pBytes_To_Bits;
  localparam pPayload_Len_Bits  = pPayload_Len_Bytes << pBytes_To_Bits;
  localparam pFCS_Len_Bits      = pFCS_Len_Bytes << pBytes_To_Bits;

  // serial counts 
  // # iterations to process incoming data given some MII width
  localparam pDest_Addr_Cnt     = pDest_Addr_Bits >> (pMII_WIDTH >> 1);
  localparam pSrc_Addr_Cnt      = pSrc_Addr_Bits >> (pMII_WIDTH >> 1);
  localparam pLen_Type_Cnt      = pLen_Type_Bits >> (pMII_WIDTH >> 1);
  localparam pPayload_Len_Cnt   = pPayload_Len_Bits >> (pMII_WIDTH >> 1);
  localparam pFCS_Len_Cnt       = pFCS_Len_Bits >> (pMII_WIDTH >> 1);

  // eth_rx_fsm
  localparam IDLE               = 3'h0;
  localparam PREAMBLE           = 3'h1;
  localparam DEST_ADDR          = 3'h2;
  localparam SRC_ADDR           = 3'h3;
  localparam LEN_TYPE           = 3'h4;
  localparam PAYLOAD_LEN        = 3'h5;
  localparam PAYLOAD            = 3'h6;
  localparam FCS                = 3'h7;

  // header parameters
  localparam IP_LEN_TYPE      = 16'h0800;

  //==========================================
  // Wires/Registers
  //==========================================

  // eth_rx_fsm
  reg [2:0]     rCurr_State;
  reg [7:0]     rCtrl_Cnt;
  reg [15:0]    rLen_Type;
  reg [7:0]     rIP_Prev_Byte;
  reg [15:0]    rIP_Curr_Payload_Bytes;
  reg [15:0]    rIP_Tot_Payload_Bytes;

  // byte_packer
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
      rIP_Curr_Payload_Bytes <= 0;
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
        rIP_Curr_Payload_Bytes <= 0;
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
      // LEN_TYPE (4)
      //================
      LEN_TYPE:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;

        // form 16-bit word indicating LEN_TYPE
        if (wByte_Rdy)
          rLen_Type <= {rLen_Type[7:0], wByte_Rx};

        if (rCtrl_Cnt == pLen_Type_Cnt-1) begin
          rCtrl_Cnt <= 0;
          rCurr_State <= PAYLOAD_LEN;
        end
      end

      //================
      // PAYLOAD_LEN (5)
      //================
      PAYLOAD_LEN:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;

        // only operate on IP packets
        if (rLen_Type == IP_LEN_TYPE) begin

          // form 16-bit word indicating # bytes in IP header + payload
          if (wByte_Rdy) begin
            rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;
            rIP_Prev_Byte <= wByte_Rx;
          end

          if (rCtrl_Cnt == pPayload_Len_Cnt-1) begin
            rIP_Tot_Payload_Bytes <= {rIP_Prev_Byte, wByte_Rx};
            rCtrl_Cnt <= 0;
            rCurr_State <= PAYLOAD;
          end
        end

        // LEN_TYPE is not IP, return to IDLE
        else
          rCurr_State <= IDLE;
      end

      //================
      // PAYLOAD (6)
      //================
      PAYLOAD:
      begin
        if (wByte_Rdy)
          rIP_Curr_Payload_Bytes <= rIP_Curr_Payload_Bytes + 1;

        if (rIP_Curr_Payload_Bytes == rIP_Tot_Payload_Bytes)
          rCurr_State <= FCS;
      end

      //================
      // FCS (7)
      //================
      FCS:
      begin
        rCtrl_Cnt <= rCtrl_Cnt + 1;
        if (rCtrl_Cnt == pFCS_Len_Cnt-1) begin
          rCtrl_Cnt <= 0;
          rCurr_State <= IDLE;
        end
      end

      //================
      // Default
      //================
      default:
        rCurr_State <= IDLE;

      endcase
    end
  end

  //==========================================
  // byte_rx
  //==========================================
  // big-endian BYTE order
  // bits enter with LSB first

  // form bytes when past PREAMBLE
  assign wByte_Rx = {Rxd, rByte_Rx[5:0]};
  always @(posedge Clk)
  begin
    if (rCurr_State > PREAMBLE & rCurr_State < FCS)
      rByte_Rx <= wByte_Rx >> pMII_WIDTH;
  end

  // indicate when formed byte is valid
  always @(posedge Clk)
  begin
    if (rCurr_State > PREAMBLE & rCurr_State < FCS)
      rBit_Cnt <= rBit_Cnt + 1;
    else
      rBit_Cnt <= 0;
  end
  assign wByte_Rdy = rBit_Cnt[1] & rBit_Cnt[0];


endmodule
