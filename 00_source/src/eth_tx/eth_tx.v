//====================================================================
// 02_simple_ethernet
// eth_tx.v
// Ethernet RMII transmit module
// 7/4/24
//====================================================================

`include "eth_tx_pkg.vh"

module eth_tx (
  input  wire         Clk,
  input  wire         Rst,
  input  wire         Eth_En,
  output wire         Dat_Rdy,
  input  wire         Dat_En,
  input  wire  [7:0]  Data,
  input  wire         Data_Last,
  output wire  [1:0]  Tx_Data,
  output wire         Tx_En
);

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg  [3:0]  rTx_Ctrl_FSM_State;
  reg         rTx_En;
  reg         rCtrl_Done;

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
  // eth_tx_ctrl
  //==========================================
  eth_tx_ctrl eth_tx_ctrl_inst (
    .Clk                (Clk),
    .Rst                (Rst),
    .Eth_En             (Eth_En),
    .Tx_Ctrl_FSM_State  (rTx_Ctrl_FSM_State),
    .Tx_En              (rTx_En),
    .Fifo_Rd            (rFifo_Rd),
    .Crc_En             (rCrc_En)
  );

  //==========================================
  // eth_data_fifo
  //==========================================
  // FIFO will store 1 byte at a time into an ethernet
  // packet that can store fixed # of data bytes

  // sync_reset_fifo eth_data_fifo(
  //   .Clk      (Clk),
  //   .Rst      (Rst),
  //   .Wr_En    (Dat_En),
  //   .Rd_En    (rFifo_Rd),
  //   .Data     (Data),
  //   .q        (wEth_Data_Out),
  //   .empty    (wFifo_Empty),
  //   .full     (wFifo_Full)
  //);

  //==========================================
  // eth_data_mux
  //==========================================
  always @(*)
  begin
    
    case(rTx_Ctrl_FSM_State)

      `IDLE:
      begin
        rTx_Data = 0;
      end

      `PREAMBLE:
      begin
        rTx_Data = rPreamble_Buf[`pMII_WIDTH-1:0];
      end
      
      `SFD:
      begin
        rTx_Data = rSFD_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `DEST_ADDR:
      begin
        rTx_Data = rDest_Addr_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `SRC_ADDR:
      begin
        rTx_Data = rSrc_Addr_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `LEN_TYPE:
      begin
        rTx_Data = rLen_Type_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `DATA:
      begin
        rTx_Data = rPayload_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `PAD:
      begin
        rTx_Data = rPad_Buf[`pMII_WIDTH-1:0]; 
      end
      
      `FCS:
      begin
        rTx_Data = rFCS_Buf[`pMII_WIDTH-1:0]; 
      end

      default:
        rTx_Data = 0;
      
    endcase
  end

  //==========================================
  // crc
  //==========================================


endmodule
