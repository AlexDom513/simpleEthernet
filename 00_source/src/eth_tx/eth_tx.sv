//--------------------------------------------------------------------
// simpleEthernet
// eth_tx.sv
// Ethernet RMII transmit module
// 7/4/24
//--------------------------------------------------------------------

import eth_tx_pkg::*;

module eth_tx (
  input  logic       Clk,
  input  logic       Rst,
  input  logic [7:0] Eth_Byte,
  input  logic       Eth_Byte_Valid,
  input  logic       Eth_Pkt_Rdy,
  output logic [1:0] Txd,
  output logic       Tx_En
);

  //------------------------------------------
  // Constants
  //------------------------------------------
  localparam pPREAMBLE  = 56'h55555555555555; // 0101_0101 ... 7x, read out as 1010_1010 ...
  localparam pSFD       = 8'hD5;              // 1101_0101 ... read out as 1010_1011
  localparam pDEST_ADDR = 48'hFFFFFFFFFFFF;   // broadcast address
  localparam pSRC_ADDR  = 48'h020000000001;   // locally administered address for testing
  localparam pLEN_TYPE  = 16'hFFFF;           // len type

  //------------------------------------------
  // Logic
  //------------------------------------------

  // fsm
  eth_tx_ctrl_state_t sTx_Ctrl_FSM_State;
  eth_tx_ctrl_state_t sTx_Ctrl_FSM_State_d1;

  // control
  logic       wTx_En;
  logic       rTx_En;
  logic       wFifo_Empty;
  logic       wCrc_En;
  logic       rCrc_En_d1;
  logic       rCrc_En_d2;
  logic [1:0] rCrc_Bits_Cnt;

  // data
  logic[1:0]  rTx_Data;
  logic[1:0]  rTx_Data_d1;
  logic       wFifo_Rd_Valid;
  logic       rFifo_Rd_Valid_d1;
  logic [7:0] wFifo_Rd_Data;

  // placeholder
  logic       wFifo_Full;
  logic       wFifo_Afull;
  logic       wFifo_Aempty;

  // crc
  logic [7:0]  rCrc_Byte;
  logic [31:0] rCrc_Computed;
  logic [31:0] wCrc_Computed;
  logic [31:0] wCrc_Out;
  logic [31:0] wCrc_Computed_Tx;
  logic        wCrc_Byte_Valid;

  // buffer regs
  logic [55:0] rPreamble_Buf;
  logic [7:0]  rSFD_Buf;
  logic [47:0] rDest_Addr_Buf;
  logic [47:0] rSrc_Addr_Buf;
  logic [15:0] rLen_Type_Buf;
  logic [7:0]  rPayload_Buf;
  logic [7:0]  rPad_Buf;
  logic [31:0] rFCS_Buf;

  //------------------------------------------
  // eth_tx_ctrl
  //------------------------------------------
  eth_tx_ctrl eth_tx_ctrl_inst (
    .Clk               (Clk),
    .Rst               (Rst),
    .Eth_Pkt_Rdy       (Eth_Pkt_Rdy),
    .Tx_Ctrl_FSM_State (sTx_Ctrl_FSM_State),
    .Tx_En             (wTx_En),
    .Fifo_Empty        (wFifo_Empty),
    .Fifo_Rd           (wFifo_Rd_Valid),
    .Crc_En            (wCrc_En)
  );

  // register previous state
  always_ff @(posedge Clk)
  begin
    sTx_Ctrl_FSM_State_d1 <= sTx_Ctrl_FSM_State;
  end

  //------------------------------------------
  // data_fifo
  //------------------------------------------
  // holds payload bytes prior to transmission

  async_fifo async_fifo_inst (
    .wclk     (Clk),
    .wrst_n   (~Rst),
    .winc     (Eth_Byte_Valid),
    .wdata    (Eth_Byte),
    .wfull    (wFifo_Full),
    .awfull   (wFifo_Afull),
    .rclk     (Clk),
    .rrst_n   (~Rst),
    .rinc     (wFifo_Rd_Valid),
    .rdata    (wFifo_Rd_Data),
    .rempty   (wFifo_Empty),
    .arempty  (wFifo_Aempty)
  );

  always_ff @(posedge Clk)
  begin
    if (Rst)
      rFifo_Rd_Valid_d1 <= 0;
    else
      rFifo_Rd_Valid_d1 <= wFifo_Rd_Valid;
  end

  //------------------------------------------
  // eth_buffer_regs
  //------------------------------------------
  // in register, shift right by pMII_WIDTH to make
  // LSBs avaliable first for eth_data_mux

  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      rPreamble_Buf  <= 0;
      rSFD_Buf       <= 0;
      rDest_Addr_Buf <= 0;
      rSrc_Addr_Buf  <= 0;
      rLen_Type_Buf  <= 0;
      rPayload_Buf   <= 0;
      rPad_Buf       <= 0;
      rFCS_Buf       <= 0;
    end
    else begin
      case (sTx_Ctrl_FSM_State)

        IDLE:
        begin
          rPreamble_Buf   <= pPREAMBLE;
          rSFD_Buf        <= pSFD;
          rDest_Addr_Buf  <= {{pDEST_ADDR[7:0]},    {pDEST_ADDR[15:8]},
                              {pDEST_ADDR[23:16]},  {pDEST_ADDR[31:24]},
                              {pDEST_ADDR[39:32]},  {pDEST_ADDR[47:40]}};
          rSrc_Addr_Buf   <= {{pSRC_ADDR[7:0]},     {pSRC_ADDR[15:8]},
                              {pSRC_ADDR[23:16]},   {pSRC_ADDR[31:24]},
                              {pSRC_ADDR[39:32]},   {pSRC_ADDR[47:40]}};
          rLen_Type_Buf   <= {{pLEN_TYPE[7:0]},     {pLEN_TYPE[15:8]}};
          rPad_Buf        <= 0; // unused
        end

        PREAMBLE:
        begin
          rPreamble_Buf <= rPreamble_Buf >> pMII_WIDTH;
        end

        SFD:
        begin
          rSFD_Buf <= rSFD_Buf >> pMII_WIDTH;
        end

        DEST_ADDR:
        begin
          rDest_Addr_Buf <= rDest_Addr_Buf >> pMII_WIDTH;
        end

        SRC_ADDR:
        begin
          rSrc_Addr_Buf <= rSrc_Addr_Buf >> pMII_WIDTH;
        end

        LEN_TYPE:
        begin
          rLen_Type_Buf <= rLen_Type_Buf >> pMII_WIDTH;
          rPayload_Buf <= wFifo_Rd_Data;
        end

        DATA:
        begin
          if (rFifo_Rd_Valid_d1)
            rPayload_Buf <= wFifo_Rd_Data;
          else
            rPayload_Buf <= rPayload_Buf >> pMII_WIDTH;
        end

        FCS:
        begin
          if (sTx_Ctrl_FSM_State_d1 == DATA)
            rFCS_Buf <= (wCrc_Computed_Tx >> pMII_WIDTH);
          else
            rFCS_Buf <= rFCS_Buf >> pMII_WIDTH;
        end

        default:
        begin
          rPreamble_Buf <= 0;
          rSFD_Buf      <= 0;
          rDest_Addr_Buf<= 0;
          rSrc_Addr_Buf <= 0;
          rLen_Type_Buf <= 0;
        end

      endcase
    end
  end

  //------------------------------------------
  // eth_data_mux
  //------------------------------------------
  // muxes data to be transmitted

  assign Txd = rTx_Data_d1;
  assign Tx_En = rTx_En;

  always_comb
  begin
    case(sTx_Ctrl_FSM_State)
      IDLE:
        rTx_Data = 0;
      PREAMBLE:
        rTx_Data = rPreamble_Buf[pMII_WIDTH-1:0];
      SFD:
        rTx_Data = rSFD_Buf[pMII_WIDTH-1:0];
      DEST_ADDR:
        rTx_Data = rDest_Addr_Buf[pMII_WIDTH-1:0];
      SRC_ADDR:
        rTx_Data = rSrc_Addr_Buf[pMII_WIDTH-1:0]; 
      LEN_TYPE:
        rTx_Data = rLen_Type_Buf[pMII_WIDTH-1:0];
      DATA:
        rTx_Data = rPayload_Buf[pMII_WIDTH-1:0];
      PAD:
        rTx_Data = rPad_Buf[pMII_WIDTH-1:0];
      FCS:
        if (sTx_Ctrl_FSM_State_d1 == DATA)
          rTx_Data = wCrc_Computed_Tx[pMII_WIDTH-1:0];
        else
          rTx_Data = rFCS_Buf[pMII_WIDTH-1:0];

      default:
        rTx_Data = 0;
    endcase
  end

  // pipeline output
  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      rTx_En <= 0;
      rTx_Data_d1 <= 0;
    end
    else begin
      rTx_En <= wTx_En;
      rTx_Data_d1 <= rTx_Data;
    end
  end

  //------------------------------------------
  // crc
  //------------------------------------------
  // computes 32-bit CRC for transmitted data

  // pipeline crc_en
  always_ff @(posedge Clk)
  begin
    if (Rst) begin
      rCrc_En_d1 <= 0;
      rCrc_En_d2 <= 0;
    end 
    else begin
      rCrc_En_d1 <= wCrc_En;
      rCrc_En_d2 <= rCrc_En_d1;
    end
  end

  // form up bytes for crc, indicate when formed byte is valid
  assign wCrc_Byte_Valid = (rCrc_Bits_Cnt == 0) & (rCrc_En_d1 != 0);

  always_ff @(posedge Clk)
  begin
    if (Rst)
      rCrc_Byte <= 0;
    else begin
      if (wCrc_En) begin
        rCrc_Bits_Cnt <= rCrc_Bits_Cnt + 1;
        rCrc_Byte <= {rTx_Data, rCrc_Byte[7:2]};
      end
      else begin
        rCrc_Bits_Cnt <= 0;
        rCrc_Byte <= 0;
      end
    end
  end

  // instantiate crc generator
  eth_crc_gen eth_crc_gen_inst (
    .Clk      (Clk),
    .Rst      (Rst),
    .Crc_Req  (wCrc_En),
    .Byte_Rdy (wCrc_Byte_Valid),
    .Byte     (rCrc_Byte),
    .Crc_Out  (wCrc_Out)
  );

  // only update rCrc_Computed when byte is ready
  assign wCrc_Computed = (wCrc_Byte_Valid) ? wCrc_Out : rCrc_Computed;

  always_ff @(posedge Clk)
  begin
    if (wCrc_Byte_Valid & rCrc_En_d2)
      rCrc_Computed <= wCrc_Out;
  end

  // keep crc byte order for transmission
  assign wCrc_Computed_Tx = wCrc_Computed;
  
endmodule
