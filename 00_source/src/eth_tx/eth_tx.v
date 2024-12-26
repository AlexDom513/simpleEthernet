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
  output wire [1:0]   Tx_Data, // bit[0] ('first')
  output wire         Tx_En
);

  //==========================================
  // Constants
  //==========================================
  localparam pPreamble  = 56'h55555555555555; // 0101_0101 ... 7x, read out as 1010_1010 ...
  localparam pSFD       = 8'hD5;              // 1101_0101 ... read out as 1010_1011
  localparam pDest_Addr = 48'hFFFFFFFFFFFF;   // broadcast address
  localparam pSrc_Addr  = 48'h020000000001;   // locally administered address for testing
  localparam pLen_Type  = 16'h0800;           // IPv4

  //==========================================
  // Wires/Registers
  //==========================================

  // fsm/control
  reg [3:0]   rTx_Ctrl_FSM_State;
  reg         rTx_En;
  reg         rCrc_En;

  // data
  reg [1:0]   rTx_Data;
  reg         rFifo_Rd;

  // buffer regs
  reg [55:0]  rPreamble_Buf;
  reg [7:0]   rSFD_Buf;
  reg [47:0]  rDest_Addr_Buf;
  reg [47:0]  rSrc_Addr_Buf;
  reg [15:0]  rLen_Type_Buf;
  reg [7:0]   rPayload_Buf;
  reg [7:0]   rPad_Buf;
  reg [31:0]  rFCS_Buf;

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
  // data_fifo
  //==========================================
  async_fifo async_fifo_inst (
    .wclk     (Clk),
    .wrst_n   (~Rst),
    .winc     (0),
    .wdata    (0),
    .wfull    (),
    .awfull   (),
    .rclk     (Clk),
    .rrst_n   (~Rst),
    .rinc     (0),
    .rdata    (),
    .rempty   (),
    .arempty  ()
  );

  //==========================================
  // eth_buffer_regs
  //==========================================
  // in register, shift right by pMII_WIDTH to make
  // LSBs avaliable first for eth_data_mux

  always @(posedge Clk)
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
      case (rTx_Ctrl_FSM_State)

        `IDLE:
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

        `PREAMBLE:
        begin
          rPreamble_Buf <= rPreamble_Buf >> `pMII_WIDTH;
        end

        `SFD:
        begin
          rSFD_Buf <= rSFD_Buf >> `pMII_WIDTH;
        end

        `DEST_ADDR:
        begin
          rDest_Addr_Buf <= rDest_Addr_Buf >> `pMII_WIDTH;
        end

        `SRC_ADDR:
        begin
          rSrc_Addr_Buf <= rSrc_Addr_Buf >> `pMII_WIDTH;
        end

        `LEN_TYPE:
        begin
          rLen_Type_Buf <= rLen_Type_Buf >> `pMII_WIDTH;
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

  //==========================================
  // eth_data_mux
  //==========================================

  assign Tx_Data = rTx_Data;

  always @(*)
  begin

    case(rTx_Ctrl_FSM_State)
      `IDLE:
        rTx_Data = 0;
      `PREAMBLE:
        rTx_Data = rPreamble_Buf[`pMII_WIDTH-1:0];
      `SFD:
        rTx_Data = rSFD_Buf[`pMII_WIDTH-1:0];
      `DEST_ADDR:
        rTx_Data = rDest_Addr_Buf[`pMII_WIDTH-1:0];
      `SRC_ADDR:
        rTx_Data = rSrc_Addr_Buf[`pMII_WIDTH-1:0]; 
      `LEN_TYPE:
        rTx_Data = rLen_Type_Buf[`pMII_WIDTH-1:0];
      `DATA:
        rTx_Data = rPayload_Buf[`pMII_WIDTH-1:0];
      `PAD:
        rTx_Data = rPad_Buf[`pMII_WIDTH-1:0];
      `FCS:
        rTx_Data = rFCS_Buf[`pMII_WIDTH-1:0];
      default:
        rTx_Data = 0;
    endcase
  end

  //==========================================
  // crc
  //==========================================

endmodule
