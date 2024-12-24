//====================================================================
// simpleEthernet
// eth_tx_ctrl.v
// Ethernet RMII transmit module control
// 12/23/24
//====================================================================

// https://v2kparse.sourceforge.net/includes.pdf
`include "eth_tx_pkg.vh"

module eth_tx_ctrl (
  input wire        Clk,
  input wire        Rst,
  output reg [3:0]  Tx_Ctrl_FSM_State,
  output reg        Tx_En,
  output reg        Crc_En
);

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg  [9:0]  rTx_Ctrl_Cnt;
  reg         rCtrl_Done;
  reg  [9:0]  rDat_Cnt; // count of how many data bytes were read out of FIFO
  reg  [2:0]  rPad_Delay;

  //==========================================
  // eth_tx_ctrl_fsm
  //==========================================
  // control read-out of bits to PHY

  assign Tx_En = Tx_En;

  always @(posedge Clk)
  begin
    if (Rst) begin
      Tx_Ctrl_FSM_State <= `IDLE;
      Tx_En <= 0;
      Crc_En <= 0;
    end 
    else begin

      case(Tx_Ctrl_FSM_State)

      //================
      // IDLE (0)
      //================
        `IDLE:
        begin
          Tx_En <= 0;
          Crc_En <= 0;
          rTx_Ctrl_Cnt <= 0;
          rCtrl_Done <= 0;
          rDat_Cnt <= 0;
          rPad_Delay <= 0;
          if (rEth_En) begin
            Tx_En <= 1;
            Tx_Ctrl_FSM_State <= `PREAMBLE;
          end
        end

      //================
      // PREAMBLE (1)
      //================
        `PREAMBLE:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == `pPreamble_Cnt-1) begin
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `SFD;
          end
        end

      //================
      // SFD (2)
      //================
        `SFD:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == pSFD_Cnt-1) begin
            Crc_En <= 1;
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `DEST_ADDR;
          end 
        end

      //================
      // DEST_ADDR (3)
      //================
        `DEST_ADDR:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == pDest_Addr_Cnt-1) begin
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `SRC_ADDR;
          end
        end

      //================
      // SRC_ADDR (4)
      //================
        `SRC_ADDR:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == pSrc_Addr_Cnt-1) begin
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `LEN_TYPE;
          end
        end

      //================
      // LEN_TYPE (5)
      //================
        `LEN_TYPE:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == pLen_Type_Cnt-3) begin
            rFifo_Rd <= 1;
          end
          if (rTx_Ctrl_Cnt == pLen_Type_Cnt-2)
            rFifo_Rd <= 0;
          else if (rTx_Ctrl_Cnt == pLen_Type_Cnt-1) begin
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `DATA;
          end
        end

      //================
      // DATA (6)
      //================
        `DATA:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;

          // increment data count
          if (rFifo_Rd_d1)
            rDat_Cnt <= rDat_Cnt + 1;

          // fifo read
          if (rTx_Ctrl_Cnt[1:0] == 2'b01 & ~wFifo_Empty) begin
            rFifo_Rd <= 1;
          end
          else
            rFifo_Rd <= 0;

          // transition to pad when fifo is empty
          if (wFifo_Empty) begin
            rFifo_Empty <= {rFifo_Empty[2:0], wFifo_Empty};
            if (rFifo_Empty[3]) begin
              rDat_Cnt <= rDat_Cnt + 1;
              rTx_Ctrl_Cnt <= 0;
              Tx_Ctrl_FSM_State <= `PAD;
            end
          end
        end

      //================
      // PAD (7)
      //================
        `PAD:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt[1:0] == 2'b11 & rDat_Cnt < pPayload_Bytes-1)
            rDat_Cnt <= rDat_Cnt + 1;

          if (rDat_Cnt == pPayload_Bytes-1) begin
            rPad_Delay <= {rPad_Delay[1:0], 1'b1};
            if (rPad_Delay[1] & ~rPad_Delay[2])
              Crc_En <= 0;
            else if (rPad_Delay[2]) begin
              rDat_Cnt <= 0;
              rTx_Ctrl_Cnt <= 0;
              Tx_Ctrl_FSM_State <= `FCS;
            end
          end 
        end

      //================
      // FCS (8)
      //================
        `FCS:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == pFCS_Cnt-2)
            rCtrl_Done <= 1;
          else if (rTx_Ctrl_Cnt == pFCS_Cnt-1) begin
            rCtrl_Done <= 0;
            rTx_Ctrl_Cnt <= 0;
            Tx_Ctrl_FSM_State <= `IDLE;
          end
        end

        default:
          Tx_Ctrl_FSM_State <= `IDLE;

      endcase
    end
  end

endmodule
