//====================================================================
// simpleEthernet
// eth_tx_ctrl.v
// Ethernet RMII transmit module control
// 12/23/24
//====================================================================

`include "eth_tx_pkg.vh"

module eth_tx_ctrl (
  input wire        Clk,
  input wire        Rst,
  input wire        Eth_Pkt_Rdy,
  output reg [3:0]  Tx_Ctrl_FSM_State,
  output reg        Tx_En,
  input wire        Fifo_Empty,
  output reg        Fifo_Rd,
  output reg        Crc_En
);

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg  [9:0]  rTx_Ctrl_Cnt;

  //==========================================
  // eth_tx_ctrl_fsm
  //==========================================
  // control read-out of bits to PHY

  always @(posedge Clk)
  begin
    if (Rst) begin
      Tx_Ctrl_FSM_State <= `IDLE;
      Tx_En             <= 0;
      Crc_En            <= 0;
    end 
    else begin

      case(Tx_Ctrl_FSM_State)

      //================
      // IDLE (0)
      //================
        `IDLE:
        begin
          Tx_En         <= 0;
          Crc_En        <= 0;
          rTx_Ctrl_Cnt  <= 0;
          if (Eth_Pkt_Rdy) begin
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
          if (rTx_Ctrl_Cnt == `pSFD_Cnt-1) begin
            rTx_Ctrl_Cnt <= 0;
            Crc_En <= 1;
            Tx_Ctrl_FSM_State <= `DEST_ADDR;
          end 
        end

      //================
      // DEST_ADDR (3)
      //================
        `DEST_ADDR:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == `pMAC_Addr_Cnt-1) begin
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
          if (rTx_Ctrl_Cnt == `pMAC_Addr_Cnt-1) begin
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
          if (rTx_Ctrl_Cnt == `pLen_Type_Cnt-1) begin
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

          // transition when fifo is empty
          // assume pad is skipped
          if (Fifo_Empty) begin
            rTx_Ctrl_Cnt <= 0;
            if (1) begin
              Crc_En <= 0;
              Tx_Ctrl_FSM_State <= `FCS;
            end
            else
              Tx_Ctrl_FSM_State <= `PAD;
          end
        end

      //================
      // PAD (7)
      //================
        // standard ethernet frame has minimum of 64 bytes total
        `PAD:
        begin
          Tx_Ctrl_FSM_State <= `FCS;
        end

      //================
      // FCS (8)
      //================
        `FCS:
        begin
          rTx_Ctrl_Cnt <= rTx_Ctrl_Cnt + 1;
          if (rTx_Ctrl_Cnt == `pFCS_Cnt-1) begin
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
