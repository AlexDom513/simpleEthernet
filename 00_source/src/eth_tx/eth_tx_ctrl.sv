//--------------------------------------------------------------------
// simpleEthernet
// eth_tx_ctrl.sv
// Ethernet RMII transmit module control
// 12/23/24
//--------------------------------------------------------------------

import eth_tx_pkg::*;

module eth_tx_ctrl (
  input  logic               Clk,
  input  logic               Rst,
  input  logic               Eth_Pkt_Rdy,
  input  logic               Fifo_Empty,
  output logic               Tx_En,
  output logic               Fifo_Rd,
  output logic               Crc_En,
  output eth_tx_ctrl_state_t Tx_Ctrl_FSM_State
);

  //------------------------------------------
  // Logic
  //------------------------------------------
  logic [9:0] rTx_Ctrl_Cnt;

  //------------------------------------------
  // eth_tx_ctrl_fsm
  //------------------------------------------
  // control read-out of bits to PHY

  always @(posedge Clk)
  begin
    if (Rst) begin
      Tx_En <= 0;
      Crc_En <= 0;
      Tx_Ctrl_FSM_State <= IDLE;
    end 
    else begin

      case(Tx_Ctrl_FSM_State)

      //----------------
      // IDLE (0)
      //----------------
      IDLE:
      begin
        Tx_En <= 0;
        Crc_En <= 0;
        rTx_Ctrl_Cnt  <= 0;
        if (Eth_Pkt_Rdy) begin
          Tx_En <= 1;
          Tx_Ctrl_FSM_State <= PREAMBLE;
        end
      end

      //----------------
      // PREAMBLE (1)
      //----------------
      PREAMBLE:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pPREAMBLE_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Tx_Ctrl_FSM_State <= SFD;
        end
      end

      //----------------
      // SFD (2)
      //----------------
      SFD:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pSFD_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Crc_En <= 1;
          Tx_Ctrl_FSM_State <= DEST_ADDR;
        end 
      end

      //----------------
      // DEST_ADDR (3)
      //----------------
      DEST_ADDR:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pMAC_ADDR_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Tx_Ctrl_FSM_State <= SRC_ADDR;
        end
      end

      //----------------
      // SRC_ADDR (4)
      //----------------
      SRC_ADDR:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pMAC_ADDR_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Tx_Ctrl_FSM_State <= LEN_TYPE;
        end
      end

      //----------------
      // LEN_TYPE (5)
      //----------------
      LEN_TYPE:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pLen_TYPE_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Tx_Ctrl_FSM_State <= DATA;
        end
      end

      //----------------
      // DATA (6)
      //----------------
      DATA:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        Fifo_Rd <= 0;

        // ready for read
        if (rTx_Ctrl_Cnt == 1)
          Fifo_Rd <= 1;
        else if (rTx_Ctrl_Cnt == 3) begin
          Fifo_Rd <= 0;
          rTx_Ctrl_Cnt <= 0;
        end
        else
          Fifo_Rd <= 0;

        // transition when fifo is empty, assume pad is skipped
        if (Fifo_Empty) begin
          rTx_Ctrl_Cnt <= 0;
          if (1) begin
            Crc_En <= 0;
            Tx_Ctrl_FSM_State <= FCS;
          end
          else
            Tx_Ctrl_FSM_State <= PAD;
        end
      end

      //----------------
      // PAD (7)
      //----------------
      // standard ethernet frame has minimum of 64 bytes total
      PAD:
      begin
        Tx_Ctrl_FSM_State <= FCS;
      end

      //----------------
      // FCS (8)
      //----------------
      FCS:
      begin
        rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
        if (rTx_Ctrl_Cnt == pFCS_CNT-1) begin
          rTx_Ctrl_Cnt <= 0;
          Tx_En <= 0;
          Tx_Ctrl_FSM_State <= IDLE;
        end
      end

      default:
        Tx_Ctrl_FSM_State <= IDLE;

      endcase
    end
  end
endmodule
