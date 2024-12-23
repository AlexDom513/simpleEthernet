//====================================================================
// simpleEthernet
// eth_tx_ctrl.v
// Ethernet RMII transmit module control
// 12/23/24
//====================================================================

module eth_tx_ctrl (
  input wire      Clk,
  input wire      Rst,
  output wire     Tx_Ctrl_FSM_State      
);

  // import constants
  `include "eth_tx_pkg.vh"

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg [3:0]       rTx_Ctrl_FSM_State;

  //==========================================
  // eth_tx_ctrl_fsm
  //==========================================
  // control read-out of bits to PHY

  assign Tx_Ctrl_FSM_State = rTx_Ctrl_FSM_State;

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
