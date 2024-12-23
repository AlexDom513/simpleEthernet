//====================================================================
// simpleEthernet
// eth_tx_ctrl.v
// Ethernet RMII transmit module control
// 12/23/24
//====================================================================

module eth_tx_ctrl (
  input wire      Clk,
  input wire      Rst
);

  //==========================================
  // Constants
  //==========================================

  // number of parallel data lines to PHY
  localparam pMII_WIDTH = 2;

  // shift to convert bytes to bits
  localparam pBytes_To_Bits = 3;

  // eth_tx_ctrl_fsm
  localparam  IDLE            = 4'h0;
  localparam  PREAMBLE        = 4'h1;
  localparam  SFD             = 4'h2;
  localparam  DEST_ADDR       = 4'h3;
  localparam  SRC_ADDR        = 4'h4;
  localparam  LEN_TYPE        = 4'h5;
  localparam  DATA            = 4'h6;
  localparam  PAD             = 4'h7;
  localparam  FCS             = 4'h8;

  // byte counts
  localparam pPreamble_Bytes  = 10'h7;
  localparam pSFD_Bytes       = 10'h1;
  localparam pMAC_Addr_Bytes  = 10'h6;
  localparam pLen_Type_Bytes  = 10'h2;
  localparam pPayload_Bytes   = 10'h48; // 72 bytes left for payload after all headers
  localparam pFCS_Bytes       = 10'h4;

  // bit counts
  localparam pPreamble_Bits   = pPreamble_Bytes << pBytes_To_Bits;
  localparam pSFD_Bits        = pSFD_Bytes << pBytes_To_Bits;
  localparam pMAC_Addr_Bits   = pMAC_Addr_Bytes << pBytes_To_Bits;
  localparam pLen_Type_Bits   = pLen_Type_Bytes << pBytes_To_Bits;
  localparam pFCS_Bits        = pFCS_Bytes << pBytes_To_Bits;

  // serial counts (# iterations to process data given some MII width)
  localparam pPreamble_Cnt    = pPreamble_Bits >> (pMII_WIDTH >> 1);
  localparam pSFD_Cnt         = pSFD_Bits >> (pMII_WIDTH >> 1);
  localparam pMAC_Addr_Cnt    = pMAC_Addr_Bits >> (pMII_WIDTH >> 1);
  localparam pLen_Type_Cnt    = pLen_Type_Bits >> (pMII_WIDTH >> 1);
  localparam pFCS_Cnt         = pFCS_Bits >> (pMII_WIDTH >> 1);

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg [3:0]       rTx_Ctrl_FSM_State;

  //==========================================
  // eth_tx_ctrl_fsm
  //==========================================
  // control read-out of bits to PHY

  always @(posedge Clk)
  begin
    if (Rst) begin
      rTx_Ctrl_FSM_State <= IDLE;
      rTx_En <= 0;
      rCrc_En <= 0;
    end 
    else begin

      case(rTx_Ctrl_FSM_State)

      //================
      // IDLE (0)
      //================
        IDLE:
        begin
          rTx_En <= 0;
          rCrc_En <= 0;
          rCtrl_Cnt <= 0;
          rCtrl_Done <= 0;
          rDat_Cnt <= 0;
          rPad_Delay <= 0;
          if (rEth_En) begin
            rTx_En <= 1;
            rTx_Ctrl_FSM_State <= PREAMBLE;
          end
        end

      //================
      // PREAMBLE (1)
      //================
        PREAMBLE:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pPreamble_Cnt-1) begin
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= SFD;
          end
        end

      //================
      // SFD (2)
      //================
        SFD:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pSFD_Cnt-1) begin
            rCrc_En <= 1;
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= DEST_ADDR;
          end 
        end

      //================
      // DEST_ADDR (3)
      //================
        DEST_ADDR:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pDest_Addr_Cnt-1) begin
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= SRC_ADDR;
          end
        end

      //================
      // SRC_ADDR (4)
      //================
        SRC_ADDR:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pSrc_Addr_Cnt-1) begin
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= LEN_TYPE;
          end
        end

      //================
      // LEN_TYPE (5)
      //================
        LEN_TYPE:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pLen_Type_Cnt-3) begin
            rFifo_Rd <= 1;
          end
          if (rCtrl_Cnt == pLen_Type_Cnt-2)
            rFifo_Rd <= 0;
          else if (rCtrl_Cnt == pLen_Type_Cnt-1) begin
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= DATA;
          end
        end

      //================
      // DATA (6)
      //================
        DATA:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;

          // increment data count
          if (rFifo_Rd_d1)
            rDat_Cnt <= rDat_Cnt + 1;

          // fifo read
          if (rCtrl_Cnt[1:0] == 2'b01 & ~wFifo_Empty) begin
            rFifo_Rd <= 1;
          end
          else
            rFifo_Rd <= 0;

          // transition to pad when fifo is empty
          if (wFifo_Empty) begin
            rFifo_Empty <= {rFifo_Empty[2:0], wFifo_Empty};
            if (rFifo_Empty[3]) begin
              rDat_Cnt <= rDat_Cnt + 1;
              rCtrl_Cnt <= 0;
              rTx_Ctrl_FSM_State <= PAD;
            end
          end
        end

      //================
      // PAD (7)
      //================
        PAD:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt[1:0] == 2'b11 & rDat_Cnt < pPayload_Bytes-1)
            rDat_Cnt <= rDat_Cnt + 1;

          if (rDat_Cnt == pPayload_Bytes-1) begin
            rPad_Delay <= {rPad_Delay[1:0], 1'b1};
            if (rPad_Delay[1] & ~rPad_Delay[2])
              rCrc_En <= 0;
            else if (rPad_Delay[2]) begin
              rDat_Cnt <= 0;
              rCtrl_Cnt <= 0;
              rTx_Ctrl_FSM_State <= FCS;
            end
          end 
        end

      //================
      // FCS (8)
      //================
        FCS:
        begin
          rCtrl_Cnt <= rCtrl_Cnt + 1;
          if (rCtrl_Cnt == pFCS_Cnt-2)
            rCtrl_Done <= 1;
          else if (rCtrl_Cnt == pFCS_Cnt-1) begin
            rCtrl_Done <= 0;
            rCtrl_Cnt <= 0;
            rTx_Ctrl_FSM_State <= IDLE;
          end
        end

        default:
          rTx_Ctrl_FSM_State <= IDLE;

      endcase
    end
  end

endmodule
